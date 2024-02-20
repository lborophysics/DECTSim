function scatter = convolutional_scatter(xray_source, photon_count, detector, sfactor)
    % Given an image of intensities, return the appropriate scatter
    % This will need to be changed once we use energy bins for the detector
    %
    % Parameters:
    %   xray_source: source object (see compute_sinogram.m for details)
    %   photon_count: 4D array of photon counts (num_bins, npy, npz, num_rotations)
    %   detector: detector object (see compute_sinogram.m for details)
    %   sfactor: scatter factor
    % Check the inputs
    arguments
        xray_source  {mustBeA(xray_source, 'source')}
        photon_count (:, :, :, :) double
        detector     {mustBeA(detector, 'detector')}
        sfactor      double 
    end
    
    scatter = zeros(size(photon_count));
    skernel = get_scatter_kernel(); 
    air = air_scan(xray_source, detector);
    for i = 1:detector.gantry.num_rotations
        % Create a 3D photon_count
        slice = photon_count(:, :, :, i);
        air_slice = air(:, :, :, i);
        scatter_slice = conv2(...
            sfactor.*0.025.*slice.*(-reallog(slice./air_slice)), ...
            skernel, 'same') .* mean(slice, 1); % Double check the mean is correct
        scatter(:, :, :, i) = scatter_slice;
    end
end

