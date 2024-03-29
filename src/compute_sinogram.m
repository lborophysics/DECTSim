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
fluences = xray_source.get_fluences(sensor_range);
fluences = reshape(fluences, num_esamples, num_bins)';

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
    pixel_generator = feval(set_array_angle, angle);
    ray_starts = zeros(3, npy*npz);
    ray_dirs = zeros(3, npy*npz);
    intensity_list = zeros(num_bins, num_esamples, npy, npz);

    for z_pix = 1:npz
        for y_pix = 1:npy
            pixel_position = pixel_generator(y_pix, z_pix);
            % Even if parallel beams are removed, this still must be called for
            % every pixel, as the source position may change (cloud of points)
            ray_start = feval(get_source_pos, angle, pixel_position); 
            ray_dir = pixel_position - ray_start;
            ray_length2 = sum(ray_dir.^2);
            
            % Here you are missing a call to the source dependent of the pixel position
            ray_starts(:, (z_pix-1)*npy + y_pix) = ray_start;
            ray_dirs(:, (z_pix-1)*npy + y_pix) = ray_dir;
            intensity_list(:, :, y_pix, z_pix) = ...
                fluences .* pix_size / ray_length2;
        end
    end

    [ray_lens, ray_idxs] = ray_tracing(ray_starts, ray_dirs);
    for z_pix = 1:npz
        for y_pix = 1:npy
            ls = ray_lens{(z_pix-1)*npy + y_pix};
            if isempty(ls)
                photon_count(:, y_pix, z_pix, angle) = ...
                    sum(intensity_list(:, :, y_pix, z_pix), 2);
            else
                idxs = ray_idxs{(z_pix-1)*npy + y_pix};
                obj_idxs = get_object_idxs(idxs);

                % Get a the length of the ray in each object
                obj_lens = zeros(num_obj + 1, 1);
                for i = 1:num_obj+1
                    obj_lens(i) = sum(ls(obj_idxs == i));
                end

                % Now we calculate the attenuation
                mus = sum(mu_dict .* obj_lens, 1);
                photons = intensity_list(:, :, y_pix, z_pix) .* ...
                    reshape(exp(-mus), num_bins, num_esamples);
                photon_count(:, y_pix, z_pix, angle) = sum(photons, 2); % Sum over the sample dimension
            end
        end
    end
end

% Calculate the scatter signal
if scatter_type == 1
    scatter_count = 0;
elseif scatter_type == 2 % Fast scatter
    scatter_count = ...
        convolutional_scatter(xray_source, photon_count, detector_obj, sfactor);
else
    scatter_count = ...
        monte_carlo_scatter  (xray_source, phantom     , detector_obj, sfactor);
end
% Convert the photon count (rays + scatter) to a signal
signal = sensor_unit.get_signal(photon_count + scatter_count);

% Convert the signal to a sinogram
sinogram = sensor_unit.get_image(signal);
end