function scatter_count = deterministic_scatter(xray_source, phantom, detector_obj, sfactor)
% deterministic_scatter Deterministic scatter estimation simulation
%
% Parameters:
%  source: Source object (see compute_sinogram.m for details)
%  phantom: voxel array object (see compute_sinogram.m for details)
%  detector: Detector object (see compute_sinogram.m for details)
%  scatter_factor: This determines how many rays to scatter for each pixel
%
% Returns:
%  scatter_signal: The scatter signal
arguments
    xray_source  {mustBeA(xray_source, 'source')}
    phantom      {mustBeA(phantom, 'voxel_array')}
    detector_obj {mustBeA(detector_obj, 'detector')}
    sfactor      double = 1
end

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

if ~(strcmp(phantom.world_material.name, "air") || strcmp(phantom.world_material.name, "vacuum"))
    warning("The world material is not air or vacuum, we do not consider scatter in this material. So your scatter signal may be incorrect or an underestimation.")
end
    
vox_init    = phantom.array_position;
vox_dims    = phantom.dimensions;
vox_nplanes = phantom.num_planes;
vox_last    = vox_init + (vox_nplanes - 1) .* vox_dims;

% Now lets define some functions that we will use to calculate the sinogram
get_source_pos  = @(angle, pixel_pos) gantry.get_source_pos(angle, pixel_pos);
set_array_angle = @(angle) d_array.set_array_angle(gantry, angle);
hit_pixel       = @(angle) d_array.hit_pixel(gantry, angle);

% Identify which compiled functions are available to use
if ~~exist('ray_trace_many_mex', 'file')
    ray_tracing = @(ray_starts, ray_dirs) ray_trace_many_mex(ray_starts, ray_dirs, ...
        vox_init, vox_dims, vox_nplanes);
else
    ray_tracing = @(ray_starts, ray_dirs) ray_trace_many    (ray_starts, ray_dirs, ...
        vox_init, vox_dims, vox_nplanes);
end

% Create function handles to retrieve the mfp and mu values
get_saved_mfp    = @(idxs, mfp_dict) phantom.get_saved_mfp(idxs, mfp_dict);
get_saved_mu     = @(idxs, mu_dict)  phantom.get_saved_mu(idxs, mu_dict);
precalculate_mus = @(energies)       phantom.precalculate_mus(energies);

num_scatters = 100*sfactor; % Number of scatter rays to sample at each scatter point (will be a parameter later)
mfp_fraction = 1e-2; % Fraction of the mean free path to sample scatter points

% We use the sensor unit to sample the source so then we can correctly index
% the sinogram (for speed).
energy_list = xray_source.get_energies(sensor_range);

% Now the fluences
fluences = xray_source.get_fluences(sensor_range, 1:npy);
av_fluences = sum(fluences, 1) / npy;
mean_energy = sum(energy_list .* av_fluences) / sum(av_fluences);

% mu_dict = phantom.precalculate_mus(energy_list);
% mfp_dict = phantom.precalculate_mfps(energy_list);
mu_dict  = phantom.get_mu_arr (mean_energy);
mfp_dict = phantom.get_mfp_arr(mean_energy);


% Check that the phantom are entirely within the detector
assert(vox_init(1)^2 + vox_init(2)^2 <= (d2detector/2)^2, ...
    'Phantom is not entirely within the detector');
assert(vox_last(1)^2 + vox_last(2)^2 <= (d2detector/2)^2, ...
    'Phantom is not entirely within the detector');

num_angle_samples = 1e6;
sample_angles = compton_dist(zeros(1, num_angle_samples) + mean_energy); % possibly make this a tall array?

scatter_count = zeros(num_bins, npy, npz, num_rotations);
parfor angle = 1:num_rotations
    % Do the linear indexing of scatter
    ang_scatter_count = zeros(num_bins, npy, npz);
    hit_at_angle = feval(hit_pixel, angle);
    
    % For each rotation, we calculate the image for the source
    intensity_list = zeros(num_bins*num_esamples, npy, npz);
    pixel_positions = feval(set_array_angle, angle);
    ray_starts = feval(get_source_pos, angle, pixel_positions);    
    ray_dirs = pixel_positions - ray_starts;

    % Ray trace the primary rays
    [traced_lens, traced_idxs] = ray_tracing(ray_starts, ray_dirs);
    
    ray_length2s = sum(ray_dirs.^2, 1);
    ray_dirs = ray_dirs ./ sqrt(ray_length2s);
    ray_length2s = reshape(ray_length2s, npy, npz);

    for y_pix = 1:npy
        for z_pix = 1:npz
            intensity_list(:, y_pix, :) = ...
                fluences(y_pix, :) .* pix_size ./ ray_length2s(y_pix, z_pix);
        end
    end

    for z_pix = 1:npz
        for y_pix = 1:npy
            ipix = (z_pix-1)*npy + y_pix;
            ls = traced_lens{ipix};
            intensity = sum(intensity_list(:, y_pix, z_pix));
            if ~isempty(ls) % If the ray hits the phantom, then it scatters - 
            % potentially change this if we would like to consider a world material that scatters a lot like water
                ray_start = ray_starts(:, ipix);
                ray_dir = ray_dirs(:, ipix);

                idxs = traced_idxs{ipix};
                mfps = get_saved_mfp(idxs, mfp_dict);
                mus  = get_saved_mu(idxs, mu_dict);

                % Calculate the probability of scattering at each intersection
                n_mfps = cumsum(ls ./ mfps);
                prob_scatter = 1 - exp(-ls ./ mfps);

                % Calculate the number of scatter points to sample
                num_points = floor(n_mfps(end) ./ mfp_fraction);
                ray_num_scatters = num_scatters*num_points;

                % Determine where the scatter points are
                lis = zeros(1, ray_num_scatters);
                scatter_points = zeros(3, num_points);
                probabilities = zeros(1, num_points);
                prev_scatter = 1;
                for i = 1:num_points
                    [~, iscatter] = find(n_mfps - i*mfp_fraction >= 0, 1);
                    lis((i-1)*num_scatters+1:i*num_scatters) = iscatter;
                    scatter_points(:, i) = ray_start + ray_dir .* sum(ls(1:iscatter));
                    probabilities(i) = sum(prob_scatter(prev_scatter:iscatter));
                    prev_scatter = iscatter+1;  
                end
                % Sample the scatter angles
                thetas = sample_angles(randi(num_angle_samples, 1, ray_num_scatters));
                phis  = 2*pi*rand(1, ray_num_scatters);

                scatter_starts = repelem(scatter_points, 1, num_scatters);
                prob_scatter   = repelem(probabilities, 1, num_scatters);

                scatter_dirs     = zeros(3, ray_num_scatters); 
                hit_pixels       = zeros(2, ray_num_scatters);
                scatter_energies = NaN  (1, ray_num_scatters);

                % Calculate the scatter directions and energies
                [ndirs, nnrjs] = compton_scatter(ray_dir, mean_energy, thetas, phis);
                [pixels, scatter_lens, angles, hits] = hit_at_angle(scatter_starts, ndirs);

                % Set all the scatter points that do hit the detector to the correct values
                scatter_energies(hits) = nnrjs (   hits);
                scatter_dirs (:, hits) = ndirs (:, hits) .* scatter_lens(hits);
                hit_pixels   (:, hits) = pixels(:, hits);

                % Remove scatter points that don't hit the detector arrays
                ignore = isnan(scatter_energies) | angles > pi/30; % this angle is the scatter grid angle
                scatter_starts  (:, ignore) = [];
                prob_scatter    (   ignore) = [];
                scatter_dirs    (:, ignore) = [];
                hit_pixels      (:, ignore) = [];
                scatter_energies(   ignore) = [];

                % Now trace the scattered rays that hit the detector
                [scatter_ray_lens, scatter_ray_idxs] = ray_tracing(...
                    scatter_starts, scatter_dirs);

                % Need this is needed if we want to do multiple scattering
                % scatter_mfp_dict = phantom.precalculate_mfps(scatter_energies);

                % Now calculate the intensity at each scattered ray that hits the detector array
                scatter_mu_dict = precalculate_mus(scatter_energies);
                for si = 1:length(scatter_energies)
                    scatter_ray_idx = scatter_ray_idxs{si};

                    % This happens when the scatter ray is scattered outside the phantom
                    if isempty(scatter_ray_idx); continue; end

                    % scatter_mfps = phantom.get_saved_mfp(scatter_ray_idx, scatter_mfp_dict(:, si));
                    scatter_mus  = get_saved_mu(scatter_ray_idx, scatter_mu_dict(:, si));
                    li = lis(si);

                    % Intensity = ray_intensity * probability of scattering *
                    % percentage of rays getting to the scatter point *
                    % the percentage of rays getting to the detector from the scatter point
                    new_intensity = intensity * ...
                        exp(-sum(mus(1:li) .* ls(1:li))-sum(scatter_mus .* scatter_ray_lens{si})) * ...
                        (prob_scatter(si) ./ num_scatters);% * ...
                        % exp(-sum(scatter_mus .* scatter_ray_lens{si}));
                    ang_scatter_count(:, hit_pixels(1, si), hit_pixels(2, si)) = ...
                        ang_scatter_count(:, hit_pixels(1, si), hit_pixels(2, si)) + ...
                        new_intensity;
                end
            end
        end
    end
    % Do this, so we can parallelise the loop
    scatter_count(:,:,:,angle) = ang_scatter_count;
end
end