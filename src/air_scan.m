
function photon_count = air_scan(xray_source, detector_obj)
    % Compute the primary signal for an air scan
    %
    % parameters:
    %   xray_source:  source object (see compute_sinogram.m for details)
    %   detector_obj: detector object (see compute_sinogram.m for details)
    %
    % returns:
    %   photon_count:   4D array of photon counts (num_bins, npy, npz, num_rotations)

    % Note this function is horrifically inefficient and can be vectorised
    % The reason why it's not the worst, is that it only needs to be run once per run,
    % and the actual computation isn't that slow.

    % Check the inputs
    arguments
        xray_source  {mustBeA(xray_source , 'source'  )}
        detector_obj {mustBeA(detector_obj, 'detector')}
    end

    % Retrieve sub-objects of all the objects
    sensor_unit = detector_obj.the_sensor;
    the_gantry  = detector_obj.the_gantry;
    d_array     = detector_obj.the_array;
    
    num_rotations = the_gantry.num_rotations;
    
    npy = d_array.n_pixels(1); 
    npz = d_array.n_pixels(2); 
    pix_size = prod(d_array.pixel_dims);
    
    num_bins = sensor_unit.num_bins;
    num_esamples = sensor_unit.num_samples;
    sensor_range = sensor_unit.get_range();

    single_rotation = zeros(num_bins, npy, npz);
    air = material_attenuation("air");
    
    energies = xray_source.get_energies(sensor_range);
    energy_list = reshape(energies, num_bins, num_esamples);

    % fluences = xray_source.get_fluences(sensor_range);
    % fluences = reshape(fluences, num_esamples, num_bins)';
    get_fluences = @(ypixel) xray_source.get_fluences(sensor_range, ypixel);
    intensity_list = zeros(num_bins, num_esamples, npy, npz);
    
    lin_elist = reshape(energy_list, 1, []);
    mu_arr = reshape(air.get_mu(lin_elist), num_bins, num_esamples);
    
    pixel_positions = d_array.set_array_angle(the_gantry, 1);
    ray_starts = the_gantry.get_source_pos(1, pixel_positions);
    ray_dirs = pixel_positions - ray_starts;
    ray_length2s = reshape(sum(ray_dirs.^2, 1), npy, npz);
    ray_lens = sqrt(ray_length2s);
    
    for z_pix = 1:npz
        for y_pix = 1:npy           
            % Get the fluences for the pixel
            fluences = get_fluences(y_pix);
            fluences = reshape(fluences, num_esamples, num_bins)';
            
            intensity_list(:, :, y_pix, z_pix) = ...
                fluences .* pix_size / ray_length2s(y_pix, z_pix);
            
            for bin = 1:sensor_unit.num_bins    
                for ei = 1:sensor_unit.num_samples
                    if isnan(energy_list(bin, ei)); continue; end
                    intensity = intensity_list(bin, ei, y_pix, z_pix);

                    mu = ray_lens(y_pix, z_pix) * mu_arr(bin, ei);
                    single_rotation(bin, y_pix, z_pix) = ...
                        single_rotation(bin, y_pix, z_pix) + intensity*exp(-mu);
                end
            end
        end
    end
    
    photon_count = zeros(num_bins, npy, npz, num_rotations);
    for angle = 1:num_rotations
        photon_count(:,:,:,angle) = single_rotation;
    end
end