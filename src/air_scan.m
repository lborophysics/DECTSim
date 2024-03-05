
function photon_count = air_scan(xray_source, detector_obj)
    % Compute the primary signal for an air scan
    %
    % parameters:
    %   xray_source:  source object (see compute_sinogram.m for details)
    %   detector_obj: detector object (see compute_sinogram.m for details)
    %
    % returns:
    %   photon_count:   4D array of photon counts (num_bins, npy, npz, num_rotations)

    % Check the inputs
    arguments
        xray_source  {mustBeA(xray_source , 'source'  )}
        detector_obj {mustBeA(detector_obj, 'detector')}
    end

    % Retrieve sub-objects of all the objects
    sensor_unit = detector_obj.sensor;
    gantry      = detector_obj.gantry;
    d_array     = detector_obj.detector_array;
    
    num_rotations = gantry.num_rotations;
    npy = d_array.n_pixels(1); 
    npz = d_array.n_pixels(2); 
    pix_size = prod(d_array.pixel_dims);
    
    num_bins = sensor_unit.num_bins;
    num_esamples = sensor_unit.num_samples;
    sensor_range = sensor_unit.get_range();

    single_rotation = zeros(num_bins, npy, npz);
    ray_generator = d_array.ray_at_angle(gantry, 1);
    air = material_attenuation("air");
    
    energies = xray_source.get_energies(sensor_range);
    energy_list = reshape(energies, num_bins, num_esamples);

    fluences = xray_source.get_fluences(sensor_range);
    fluences = reshape(fluences, num_esamples, num_bins)';
    intensity_list = zeros(num_bins, num_esamples, npy, npz);
    
    for z_pix = 1:npz
        for y_pix = 1:npy
            [~, ~, ray_length] = ray_generator(y_pix, z_pix);
            intensity_list(:, :, y_pix, z_pix) = ...
                fluences .* pix_size / (ray_length^2);
            
            for bin = 1:sensor_unit.num_bins    
                for ei = 1:sensor_unit.num_samples
                    nrj = energy_list(bin, ei);
                    if isnan(nrj); continue; end
                    intensity = intensity_list(bin, ei, y_pix, z_pix);

                    mu = ray_length*air.get_mu(nrj);
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