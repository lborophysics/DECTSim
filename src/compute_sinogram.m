function sinogram = compute_sinogram(xray_source, phantom, detector_obj, scatter, sfactor)
    % Compute the sinogram of the phantom, given the source and detector, and
    % optionally, the scatter model.
    %
    % Parameters:
    %  - xray_source: the source object, this returns a sample of the source spectrum
    %            giving energy and intensities of the photons. Made up of the following:
    %            - spectrum: the energy spectrum of the source
    %            - collimation: adjusts the source spectrum to account for the collimation
    %            - filter: adjusts the source spectrum to account for the filter
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
        
    npy = d_array.n_pixels(1); 
    npz = d_array.n_pixels(2); 
    
    num_bins = sensor_unit.num_bins;
    energies_at_bin = @(bin) xray_source.get_energies(sensor_unit.get_range(bin));

    vox_init = phantom.array_position;
    vox_dims = phantom.dimensions;
    vox_nplanes = phantom.num_planes;
    vox_last = vox_init + (vox_nplanes - 1) .* vox_dims;
    get_saved_mu = @phantom.get_saved_mu;


    % Retrieve the energies and intensities of the source, then precalculate the
    % mus of the voxels with the energies
    energy_list = []; intensity_list = [];
    for bin = 1:num_bins
        [energies, intensities] = energies_at_bin(bin);
        energy_list = [energy_list, energies];
        intensity_list = [intensity_list, intensities];
    end
    mu_dict = phantom.precalculate_mus(energy_list);


    % Check that the voxels are entirely within the detector
    assert(vox_init(1)^2 + vox_init(2)^2 <= (d2detector/2)^2, ...
        'Phantom is not entirely within the detector');
    assert(vox_last(1)^2 + vox_last(2)^2 <= (d2detector/2)^2, ...
        'Phantom is not entirely within the detector');
    

    % Start the ray tracing loop
    photon_count = zeros(num_bins, npy, npz, num_rotations);
    for angle = 1:num_rotations 
        % For each rotation, we calculate the image for the source
        ray_generator = d_array.ray_at_angle(gantry, angle);
        for z_pix = 1:npz
            for y_pix = 1:npy
                [ray_start, ray_dir, ray_length] = ray_generator(y_pix, z_pix);
                [ls, idxs] = ray_tracing(ray_start, ray_dir * ray_length, ...
                    vox_init, vox_dims, vox_nplanes);
                for bin = 1:num_bins
                    % Get the energies for the current bin
                    [energies, intensities] = energies_at_bin(bin);
                    for ei = 1:length(energies)
                        if ~isempty(ls)
                            mu = sum(ls .* get_saved_mu(idxs, mu_dict(num2str(energies(ei)))));
                        else
                            mu = 0;
                        end
                        photon_count(bin, y_pix, z_pix, angle) = intensities(ei)*exp(-mu);
                    end
                end
            end
        end
    end
    
    % Calculate the scatter signal
    if scatter_type == 1
        scatter_signal = 0;
    elseif scatter_type == 2 % Fast scatter
        scatter_count = ...
            convolutional_scatter(xray_source, photon_count, detector_obj, sfactor);
        scatter_signal = sensor_unit.get_signal(scatter_count);
    else
        scatter_count = ...
            monte_carlo_scatter  (xray_source, phantom     , detector_obj, sfactor);
        scatter_signal = sensor_unit.get_signal(scatter_count);
    end
    % Convert the photon count to a signal
    primary_signal = sensor_unit.get_signal(photon_count);

    % The following line is equivalent to image + scatter, 
    % but is there as in the future we likely will adapt the 
    % detector response.
    sinogram = sensor_unit.get_image(primary_signal + scatter_signal);
end