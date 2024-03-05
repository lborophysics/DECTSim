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

    % Identify which compiled functions are available to use
    if ~~exist('ray_trace_mex', 'file'); ray_tracing = @ray_trace_mex;
    else                               ; ray_tracing = @ray_trace;
    end

    if ~~exist('ray_trace_mex', 'file'); ray_tracing_many = @ray_trace_many_mex;
    else                               ; ray_tracing_many = @ray_trace_many;
    end
    
    % Retrieve sub-objects of all the objects
    sensor_unit = detector_obj.sensor;
    gantry      = detector_obj.gantry;
    d_array     = detector_obj.detector_array;
    
    
    % Retrieve information within the sub-objects
    num_rotations = gantry.num_rotations;
    d2detector = gantry.dist_to_detector;
        
    npy = d_array.n_pixels(1); 
    npz = d_array.n_pixels(2);
    pix_size = prod(d_array.pixel_dims);

    num_bins = sensor_unit.num_bins;
    num_esamples = sensor_unit.num_samples;
    sensor_range = sensor_unit.get_range();
    
    vox_init = voxels.array_position;
    vox_dims = voxels.dimensions;
    vox_nplanes = voxels.num_planes;
    vox_last = vox_init + (vox_nplanes - 1) .* vox_dims;


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


    scatter_count = zeros(num_bins, npy, npz, num_rotations);
    for angle = 1:num_rotations
        % Do the linear indexing of scatter
        ray_generator = d_array.ray_at_angle(gantry, angle);
        ray_starts = zeros(3, npy*npz);
        ray_dirs = zeros(3, npy*npz);
        intensity_list = zeros(num_bins*num_esamples, npy, npz);
        
        for z_pix = 1:npz
            for y_pix = 1:npy
                [ray_start, ray_dir, ray_length] = ray_generator(y_pix, z_pix);
                ray_starts(:, (z_pix-1)*npy + y_pix) = ray_start;
                ray_dirs(:, (z_pix-1)*npy + y_pix) = ray_dir * ray_length;
                intensity_list(:, y_pix, z_pix) = ...
                    fluences .* pix_size / (ray_length^2)./sfactor;
            end
        end
        [ray_lens, ray_idxs] = ray_tracing_many(ray_starts, ray_dirs, ...
            vox_init, vox_dims, vox_nplanes);

        scatter_idxs = zeros(npy, npz, sfactor, 2); 
        scatter_vals = zeros(npy, npz, sfactor);
        energies     = zeros(npy, npz, sfactor);    
        for z_pix = 1:npz
            for y_pix = 1:npy
                idxs = ray_idxs{(z_pix-1)*npy + y_pix};
                ls = ray_lens{(z_pix-1)*npy + y_pix};
                cached_calc_mu = @(n_mfp, nrj, mu_arr, mfp_arr) ...
                    calculate_scatter(n_mfp, ls, idxs, ray_start, ray_dir, ...
                    ray_length, nrj, NaN, 0, mu_arr, mfp_arr, voxels, ray_tracing);
                intensity = mean(intensity_list(:, y_pix, z_pix));

                if isempty(ls)
                    scatter_vals(y_pix, z_pix, :) = intensity;
                    scatter_idxs(y_pix, z_pix, :, :) = repmat([y_pix, z_pix], sfactor, 1);
                    energies(y_pix, z_pix, :) = mean_energy;
                    continue;
                end
                
                for sf = 1:sfactor
                    nrj = mean_energy;
                    if intensity == 0; continue; end
                    
                    [new_ray_start, new_ray_dir, mu, nrj, scattered] =  ...
                        cached_calc_mu(-log(rand), nrj, mu_dict, mfp_dict);

                    energies(y_pix, z_pix, sf) = nrj;

                    if scattered
                        [pixel, hit] = d_array.hit_pixel(...
                            new_ray_start, new_ray_dir, gantry, angle);
                        scatter_idxs(y_pix, z_pix, sf, :) = pixel;
                    else
                        hit = true;
                        scatter_idxs(y_pix, z_pix, sf, :) = [y_pix, z_pix];
                    end
                    
                    if hit
                        scatter_vals(y_pix, z_pix, sf) = ... 
                        scatter_vals(y_pix, z_pix, sf) + ...
                        intensity * exp(-mu);
                    else
                        scatter_vals(y_pix, z_pix, sf) = NaN;
                    end
                end
            end
        end

        % Add the scatter to the image (non linear indexing of scatter)
        for sf = 1:sfactor
            for z_pix = 1:npz
                for y_pix = 1:npy
                    if ~isnan(scatter_vals(y_pix, z_pix, sf))
                        y_index = scatter_idxs(y_pix, z_pix, sf, 1);
                        z_index = scatter_idxs(y_pix, z_pix, sf, 2);
                        bin = sensor_unit.get_energy_bin(energies(y_pix, z_pix, sf));
                        
                        scatter_count(bin, y_index, z_index, angle) = ...
                        scatter_count(bin, y_index, z_index, angle) + ...
                            scatter_vals(y_pix, z_pix, sf);
                    end
                end
            end
        end
    end
end