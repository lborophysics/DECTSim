function sinogram = compute_sinogram(xray_source, phantom, detector_obj, scatter, sfactor)
% Compute the sinogram of the phantom, given the source and detector, and
% optionally, the scatter model.
%
% Parameters:
%  - xray_source: the source object, this returns a sample of the source spectrum
%            giving energy and fluences of the photons.
%  - phantom: the phantom object, this allows you to determine the following:
%             - How the world is divided into voxels, for ray tracing
%             - What material is in each voxel
%             - Determine the attenuation and mean free path of the materials
%  - detector_obj: the detector object, which includes the foll`owing:
%              - Gantry: How the detector is positioned and moves
%              - Ray generation: Determines where the rays are directed from the source
%              - Sensor: Determines how the rays are detected
%  - scatter: A string that determines the scatter model to use. If not provided,
%            no scatter is used. The following are the available scatter models:
%            - 'none': no scatter is used
%            - 'fast': the convolution scatter model is used
%            - 'slow': the Monte Carlo scatter model is used
%  - sfactor: For the Monte Carlo scatter model, the number of scatter
%                    events to simulate for each photon. For the convolution
%                    scatter model, it is the strength of the scatter.  If
%                    not provided, the default value is 1.
%
% Returns:
%  - sinogram: the sinogram of the phantom, given the source and detector
%              and optionally, the scatter model
arguments
    xray_source    {mustBeA(xray_source, 'source')}
    phantom        {mustBeA(phantom, 'voxel_array')}
    detector_obj   {mustBeA(detector_obj, 'detector')}
    scatter string {mustBeMember(scatter, ["none", "fast", "slow"])} = "none"
    sfactor double = 1
end

% Determine the scatter model
scatter_type = find(["none", "fast", "slow"] == scatter);

% Retrieve sub-objects of all the objects
sensor_unit = detector_obj.sensor;
gantry      = detector_obj.gantry;
d_array     = detector_obj.detector_array;


% Retrieve information within the sub-objects
num_rotations  = gantry.num_rotations;
d2detector     = gantry.dist_to_detector;

npy = d_array.n_pixels(1);
npz = d_array.n_pixels(2);

pix_size = prod(d_array.pixel_dims);

num_bins     = sensor_unit.num_bins;
num_esamples = sensor_unit.num_samples;
sensor_range = sensor_unit.get_range();

num_obj     = phantom.nobj;
vox_init    = phantom.array_position;
vox_dims    = phantom.dimensions;
vox_nplanes = phantom.num_planes;
vox_last    = vox_init + (vox_nplanes - 1) .* vox_dims;

% Now lets define some functions that we will use to calculate the sinogram
get_source_pos  = @(angle, pixel_pos) gantry.get_source_pos(angle, pixel_pos);
set_array_angle = @(angle) d_array.set_array_angle(gantry, angle);
get_object_idxs = @(idxs) phantom.get_object_idxs(idxs);

% Identify which compiled functions are available to use
if ~~exist('ray_trace_many_mex', 'file')
    ray_tracing = @(ray_starts, ray_dirs) ray_trace_many_mex(ray_starts, ray_dirs, ...
        vox_init, vox_dims, vox_nplanes);
else
    ray_tracing = @(ray_starts, ray_dirs) ray_trace_many    (ray_starts, ray_dirs, ...
        vox_init, vox_dims, vox_nplanes);
end

% We use the sensor unit range to sample the source so then we can correctly
% index the sinogram (for speed).
energies = xray_source.get_energies(sensor_range);
energy_list = reshape(energies, num_esamples, num_bins)';

% Now the fluences
fluences = xray_source.get_fluences(sensor_range, 1:npy);

% Pre-calculate the mu values for the energy list
mu_dict = phantom.precalculate_mus(energy_list);


% Check that the voxels are entirely within the detector
assert(vox_init(1)^2 + vox_init(2)^2 <= (d2detector/2)^2, ...
    'Phantom is not entirely within the detector');
assert(vox_last(1)^2 + vox_last(2)^2 <= (d2detector/2)^2, ...
    'Phantom is not entirely within the detector');


% Start the ray tracing loop
photon_count = zeros(num_bins, npy, npz, num_rotations);
parfor angle = 1:num_rotations
    % For each rotation, we calculate the image for the source
    intensity_list = zeros(num_bins, num_esamples, npy, npz);

    pixel_positions = feval(set_array_angle, angle);
    ray_starts = feval(get_source_pos, angle, pixel_positions);
    ray_dirs = pixel_positions - ray_starts;
    ray_length2s = reshape(sum(ray_dirs.^2, 1), npy, npz);
    ray_lens = sqrt(ray_length2s);

    % Doing nested loop here, as the calculation is simpler without vectorisation
    for y_pix = 1:npy
        % Get the fluences for the pixel
        yfluences = fluences(y_pix, :);
        yfluences = reshape(yfluences, num_esamples, num_bins)';
        for z_pix = 1:npz
            intensity_list(:, :, y_pix, z_pix) = ...
                yfluences .* pix_size ./ ray_length2s(y_pix, z_pix);
        end
    end

    [traced_ls, traced_idxs] = ray_tracing(ray_starts, ray_dirs);
    for z_pix = 1:npz
        for y_pix = 1:npy
            ls = traced_ls{(z_pix-1)*npy + y_pix};
            obj_lens = zeros(num_obj, 1);
            if isempty(ls)
                % If no ray tracing inside the world, then the ray is entirely in the world material (probably air)
                obj_lens(end) = ray_lens(y_pix, z_pix);
            else
                idxs = traced_idxs{(z_pix-1)*npy + y_pix};
                obj_idxs = get_object_idxs(idxs);

                % Get a the length of the ray in each object
                for i = 1:num_obj
                    obj_lens(i) = sum(ls(obj_idxs == i));
                end

                % Add the residual length in air
                obj_lens(end) = obj_lens(end) + (ray_lens(y_pix, z_pix) - sum(obj_lens));
            end 
            % Now we calculate the attenuation
            mus = sum(mu_dict .* obj_lens, 1);
            photons = intensity_list(:, :, y_pix, z_pix) .* ...
                reshape(exp(-mus), num_bins, num_esamples);
            photon_count(:, y_pix, z_pix, angle) = sum(photons, 2); % Sum over the sample dimension
        end
    end
end

% Calculate the scatter signal
if scatter_type == 1
    scatter_count = zeros(size(photon_count));
elseif scatter_type == 2 % Fast scatter
    scatter_count = ...
        convolutional_scatter(xray_source, photon_count, detector_obj, sfactor);
else
    scatter_count = ...
        monte_carlo_scatter  (xray_source, phantom     , detector_obj, sfactor);
end
% Convert the photon count (rays + scatter) to a signal
photon_signal = sensor_unit.get_signal(photon_count);
scatter_signal = sensor_unit.get_signal(scatter_count);

air = air_scan(xray_source, detector_obj);
air_signal = sensor_unit.get_signal(air);

% Convert the signal to a sinogram
sinogram = sensor_unit.get_image(photon_signal + scatter_signal, air_signal);
end