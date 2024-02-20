function scatter_signal = monte_carlo_scatter(xray_source, voxels, detector_obj, sfactor)
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
    
    % Retrieve sub-objects of all the objects
    sensor_unit = detector_obj.sensor;
    gantry      = detector_obj.gantry;
    d_array     = detector_obj.detector_array;
    
    
    % Retrieve information within the sub-objects
    num_rotations = gantry.num_rotations;
    d2detector = gantry.dist_to_detector;
        
    npy = d_array.ny_pixels; 
    npz = d_array.nz_pixels; 
    
    num_bins = sensor_unit.num_bins;
    energies_at_bin = @(bin) xray_source.get_energies(sensor_unit.get_range(bin));

    vox_init = voxels.array_position;
    vox_dims = voxels.dimensions;
    vox_nplanes = voxels.num_planes;
    vox_last = vox_init + (vox_nplanes - 1) .* vox_dims;


    % Retrieve the energies and intensities of the source, then precalculate the
    % mus of the voxels with the energies
    energy_list = []; intensity_list = [];
    for bin = 1:num_bins
        [energies, intensities] = energies_at_bin(bin);
        energy_list = [energy_list, energies];
        intensity_list = [intensity_list, intensities];
    end
    mu_arr = voxels.precalculate_mus(energy_list);
    mfp_arr = voxels.precalculate_mfps(energy_list);


    % Check that the voxels are entirely within the detector
    assert(vox_init(1)^2 + vox_init(2)^2 <= (d2detector/2)^2, ...
        'Phantom is not entirely within the detector');
    assert(vox_last(1)^2 + vox_last(2)^2 <= (d2detector/2)^2, ...
        'Phantom is not entirely within the detector');


    scatter = zeros(num_bins, npy, npz, num_rotations);
    for k = 1:num_rotations
        % Do the linear indexing of scatter
        ray_generator = d_array.ray_at_angle(gantry, angle);
        scatter_idxs = zeros(npy, npz, sfactor, 2); 
        scatter_vals = NaN  (npy, npz, sfactor);
        energies     = zeros(npy, npz, sfactor);    
        for z_pix = 1:npz
            for y_pix = 1:npy
                [ray_start, ray_dir, ray_length] = ray_generator(y_pix, z_pix);
                [ls, idxs] = ray_tracing(ray_start, ray_dir * ray_length, ...
                    vox_init, vox_dims, vox_nplanes);
                for sf = 1:sfactor
                    for ei = 1:length(energy_list)
                        energy = energy_list(ei);
                        intensity = intensity_list(ei)/sfactor;
                        [new_ray_start, new_ray_dir, mu, nrj, scattered] =  ...
                            calculate_mu(-log(rand), ls, idxs, ray_start, ...
                            ray_dir, ray_length, energy, NaN, 0, mu_arr, ...
                            mfp_arr, voxels, ray_tracing);

                        energies(y_pix, z_pix, sf) = nrj;

                        if scattered
                            [pixel, hit] = d_array.hit_pixel(...
                                new_ray_start, new_ray_dir, gantry, k);
                            scatter_idxs(y_pix, z_pix, sf, :) = pixel;
                        else
                            hit = true;
                            scatter_idxs(y_pix, z_pix, sf, :) = [y_pix, z_pix];
                        end
                        
                        if hit
                            scatter_vals(y_pix, z_pix, sf) = intensity * exp(-mu);
                        else
                            scatter_vals(y_pix, z_pix, sf) = NaN;
                        end
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

                        scatter(bin, y_index, z_index, k) = ...
                        scatter(bin, y_index, z_index, k) + ...
                            scatter_vals(y_pix, z_pix, sf);
                    end
                end
            end

        end
    end
end

function [ray_start, ray_dir, mu, nrj, scattered] = calculate_mu (n_mfp, ls, idxs, ray_start,...
     ray_dir, ray_len, nrj, prev_mu, num_scatter, mu_arr, mfp_arr, voxels, ray_tracing)
            
    % If there are no intersections, exit
    scattered = false;
    if isempty(ls); mu = prev_mu; return; end
    
    if  num_scatter == 0; mu = 0;
    else                ; mu = prev_mu;
    end

    % Get the mean free path of the first intersection
    mfps = voxels.get_saved_mfp(idxs, mfp_arr);
    
    % Check if the ray scatters at all
    ray_nmfp = n_mfp - cumsum(ls ./ mfps);
    check_nmfp = ray_nmfp < 0;
    
    if any(check_nmfp) % If the ray scatters
        % Get the index of the scatter event
        i = find(check_nmfp, 1, "first");
        
        % Calculate the mu of the ray until the end of the current voxel
        mu_to_scatter = voxels.get_saved_mu(idxs(:, 1:i), mu_arr);
        mu = mu + sum(ls(1:i) .* mu_to_scatter) + ...
            (mfps(i) * ray_nmfp(i)) * mu_to_scatter(i); % Remove the mu of the current voxel up to the scatter event

        % Get the new direction and energy of the ray, and update the start point
        ray_start = ray_start + (sum(ls(1:i)) + ray_nmfp(i) * mfps(i)) .* ray_dir; 
        [ray_dir, nrj] = random_scatter(ray_dir, nrj);
        
        % Create a new ray with the new direction, energy, and start point
        [ls, idxs] = ray_tracing(ray_start, ray_dir * ray_len, ...
            voxels.array_position, voxels.dimensions, voxels.num_planes);

        mu_arr = voxels.get_mu_arr(nrj);
        mfp_arr = voxels.get_mfp_arr(nrj);
        
        % Now repeat the process for the new ray
        [ray_start, ray_dir, mu, nrj, ~] = calculate_mu(-log(rand), ls, idxs, ...
            ray_start, ray_dir, ray_len, nrj, mu, num_scatter + 1, mu_arr, mfp_arr, voxels);
        scattered = true;
    else
        mu = mu + sum(ls .* voxels.get_saved_mu(idxs, mu_arr));  % This case only occurs if the ray does not scatter
    end
end