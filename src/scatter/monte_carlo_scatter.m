function scatter_count = monte_carlo_scatter(xray_source, voxels, detector_obj, sfactor)
%monte_carlo_scatter Monte Carlo simulation of scatter signal
%
% Parameters:
%  source: Source object (see compute_sinogram.m for details)
%  voxels: voxel array object (see compute_sinogram.m for details)
%  detector: Detector object (see compute_sinogram.m for details)
%  scatter_factor: This determines how many rays to scatter for each pixel
%
% Returns:
%  scatter_signal: The scatter signal
arguments
    xray_source  {mustBeA(xray_source, 'source')}
    voxels       {mustBeA(voxels, 'voxel_array')}
    detector_obj {mustBeA(detector_obj, 'detector')}
    sfactor      double = 1
end

% Retrieve sub-objects of all the objects
sensor_unit = detector_obj.sensor;
gantry      = detector_obj.gantry;
d_array     = detector_obj.detector_array;

% Retrieve information about the movement of the gantry
num_rotations = gantry.num_rotations;
d2detector = gantry.dist_to_detector;

% Retrieve information about the detector array
npy = d_array.n_pixels(1);
npz = d_array.n_pixels(2);
ray_at_angle = @(ang) d_array.ray_at_angle(gantry, ang);
hit_pixel = @(ang) d_array.hit_pixel(gantry, ang);
pix_size = prod(d_array.pixel_dims);

% Retrieve information about the sensor unit
num_bins = sensor_unit.num_bins;
num_esamples = sensor_unit.num_samples;
sensor_range = sensor_unit.get_range();

% Retrieve information about the voxels
vox_init    = voxels.array_position;
vox_dims    = voxels.dimensions;
vox_nplanes = voxels.num_planes;
vox_last    = vox_init + (vox_nplanes - 1) .* vox_dims;

% Identify which compiled functions are available to use
if ~~exist('ray_trace_many_mex', 'file')
    ray_tracing_many = @(ray_starts, ray_dirs) ray_trace_many_mex(...
        ray_starts, ray_dirs, vox_init, vox_dims, vox_nplanes);
else
    ray_tracing_many = @(ray_starts, ray_dirs) ray_trace_many(...
        ray_starts, ray_dirs, vox_init, vox_dims, vox_nplanes);
end

% Create function handles to retrieve the mfp and mu values
get_saved_mfp    = @voxels.get_saved_mfp;
get_saved_mu     = @voxels.get_saved_mu;
precalculate_mus = @voxels.precalculate_mus;

num_scatters = 100; % Number of scatter rays to sample at each scatter point (will be a parameter later)
mfp_fraction = 1e-3; % Fraction of the mean free path to sample scatter points

% We use the sensor unit to sample the source so then we can correctly index
% the sinogram (for speed).
energy_list = xray_source.get_energies(sensor_range);

% Now the fluences
fluences = xray_source.get_fluences(sensor_range);

mean_energy = sum(energy_list .* fluences) / sum(fluences);
% mu_dict = voxels.precalculate_mus(energy_list);
% mfp_dict = voxels.precalculate_mfps(energy_list);
mu_dict  = voxels.get_mu_arr(mean_energy );
mfp_dict = voxels.get_mfp_arr(mean_energy);


% Check that the voxels are entirely within the detector
assert(vox_init(1)^2 + vox_init(2)^2 <= (d2detector/2)^2, ...
    'Phantom is not entirely within the detector');
assert(vox_last(1)^2 + vox_last(2)^2 <= (d2detector/2)^2, ...
    'Phantom is not entirely within the detector');

num_angle_samples = 1e7;
sample_angles = compton_dist(zeros(1, num_angle_samples) + mean_energy);

scatter_count = zeros(num_bins, npy, npz, num_rotations);
parfor angle = 1:num_rotations
    % Do the linear indexing of scatter
    ray_generator = feval(ray_at_angle, angle);
    hit_at_angle  = feval(hit_pixel, angle);
    ang_scatter_count = zeros(num_bins, npy, npz);

    intensity_list = zeros(num_bins*num_esamples, npy, npz);
    ray_starts = zeros(3, npy*npz);
    ray_dirs   = zeros(3, npy*npz);
    ray_lens  = zeros(1, npy*npz);

    for z_pix = 1:npz
        for y_pix = 1:npy
            [ray_start, ray_dir, ray_length] = ray_generator(y_pix, z_pix);
            idx = (z_pix-1)*npy + y_pix;
            ray_starts(:, idx) = ray_start;
            ray_dirs(:, idx) = ray_dir;
            ray_lens(idx) = ray_length;

            intensity_list(:, y_pix, z_pix) = ...
                fluences .* pix_size / (ray_length^2)./sfactor;
        end
    end

    % Ray trace the primary rays
    [traced_lens, traced_idxs] = ray_tracing_many(ray_starts, ray_dirs .* ray_lens);

    for z_pix = 1:npz
        for y_pix = 1:npy
            ipix = (z_pix-1)*npy + y_pix;
            ls = traced_lens{ipix};
            intensity = sum(intensity_list(:, y_pix, z_pix));
            if isempty(ls); continue % If the ray doesn't hit the phantom
            else
                ray_start = ray_starts(:, ipix);
                ray_dir = ray_dirs(:, ipix);

                idxs = traced_idxs{ipix};
                mfps = get_saved_mfp(idxs, mfp_dict);
                mus  = get_saved_mu(idxs, mu_dict);

                % Calculate the probability of scattering at each intersection
                n_mfps = cumsum(ls ./ mfps);
                prob_scatter = 1 - exp(-n_mfps);

                % Calculate the number of scatter points to sample
                num_points = floor(n_mfps(end) ./ mfp_fraction);
                ray_num_scatters = num_scatters*num_points;

                % Determine where the scatter points are
                lis = zeros(1, ray_num_scatters);
                scatter_points = zeros(3, num_points);
                for i = 1:num_points
                    [~, iscatter] = find(n_mfps - i*mfp_fraction > 0, 1);
                    lis((i-1)*num_scatters+1:i*num_scatters) = iscatter;
                    scatter_points(:, i) = ray_start + ray_dir .* sum(ls(1:iscatter));
                end

                scatter_dirs     = zeros(3, ray_num_scatters);
                hit_pixels       = zeros(2, ray_num_scatters);
                scatter_energies = NaN  (1, ray_num_scatters);

                % Sample the scatter angles
                thetas = sample_angles(randi(num_angle_samples, 1, ray_num_scatters));

                % Calculate the scatter directions and energies
                [ndirs, nnrjs] = compton_scatter(ray_dir, mean_energy, thetas);

                % Loop over scatter points
                for point_idx = 1:num_points
                    point_range = (point_idx-1)*num_scatters+1:point_idx*num_scatters;

                    [pixels, scatter_lens, hits] = hit_at_angle(...
                        scatter_points(:, point_idx), ndirs(:, point_range));

                    hit_inds = point_range(hits);
                    scatter_energies(hit_inds) = nnrjs(hit_inds);
                    scatter_dirs(:, hit_inds) = ndirs(:, hit_inds) .* scatter_lens(hits);
                    hit_pixels(:, hit_inds) = pixels(:, hits);
                end

                % Remove scatter points that don't hit the detector arrays
                scatter_starts = repelem(scatter_points, 1, num_scatters);
                ignore = isnan(scatter_energies);
                scatter_starts  (:, ignore) = [];
                scatter_dirs    (:, ignore) = [];
                hit_pixels      (:, ignore) = [];
                scatter_energies(   ignore) = [];

                % Now trace the scattered rays that hit the detector
                [scatter_ray_lens, scatter_ray_idxs] = ray_tracing_many(...
                    scatter_starts, scatter_dirs);

                % Need this if we want to do multiple scattering
                % scatter_mfp_dict = voxels.precalculate_mfps(scatter_energies);

                % Now calculate the intensity at each scattered ray that hits the detector array
                scatter_mu_dict = precalculate_mus(scatter_energies);
                for si = 1:length(scatter_energies)
                    scatter_ray_idx = scatter_ray_idxs{si};

                    % This happens when the scatter ray is scattered outside the phantom
                    if isempty(scatter_ray_idx); continue; end

                    % scatter_mfps = voxels.get_saved_mfp(scatter_ray_idx, scatter_mfp_dict(:, si));
                    scatter_mus  = get_saved_mu(scatter_ray_idx, scatter_mu_dict(:, si));
                    li = lis(si);

                    % Intensity = ray_intensity * probability of scattering *
                    % percentage of rays getting to the scatter point *
                    % the percentage of rays getting to the detector from the scatter point
                    new_intensity = intensity * ...
                        exp(-sum(mus(1:li) .* ls(1:li))) * ...
                        (prob_scatter(li) ./ num_scatters) * ...
                        exp(-sum(scatter_mus .* scatter_ray_lens{si}));
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