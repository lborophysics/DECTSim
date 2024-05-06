function scatter = convolutional_scatter(xray_source, photon_count, detector, sfactor)
    % Given an image of intensities, return the appropriate scatter
    % This will need to be changed once we use energy bins for the detector
    %
    % Parameters:
    %   xray_source: source object (see compute_sinogram.m for details)
    %   photon_count: 4D array of photon counts (num_bins, npy, npz, num_rotations)
    %   detector: detector object (see compute_sinogram.m for details)
    %   sfactor: scatter factor
    % 
    % Returns:
    %   scatter: 4D array of scatter (num_bins, npy, npz, num_rotations)

    % Note: detector might not be necessary, could instead just pass the air scan.
    arguments
        xray_source  {mustBeA(xray_source, 'source')}
        photon_count (:, :, :, :) double
        detector     {mustBeA(detector, 'detector')}
        sfactor      double 
    end
    
    scatter = zeros(size(photon_count));
    skernel = get_scatter_kernel(); 
    air = air_scan(xray_source, detector);
    for i = 1:detector.the_gantry.num_rotations
        e_average = mean(photon_count(:, :, :, i), [2, 3, 4]);
        e_average = e_average ./ sum(e_average);

        slice = sum(photon_count(:, :, :, i), 1);
        air_slice = sum(air(:, :, :, i), 1);

        scatter_slice = conv2(...
            sfactor.*0.025.*slice.*(-reallog(slice./air_slice)), ...
            skernel, 'same');
            
        scatter_slice = kron(scatter_slice, e_average);
        scatter(:, :, :, i) = scatter_slice;
    end
end

%{
    Taken from https://github.com/xcist/main/blob/edaf763b4fcc477feffc1179765debdc36e84831/gecatsim/pyfiles/Scatter_ConvolutionModel.py
    The method and scatter kernel has the following license:
    Copyright 2020, General Electric Company. All rights reserved. See: XCAT_LICENSE.txt
%}