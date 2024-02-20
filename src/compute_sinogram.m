function sinogram = compute_sinogram(source, phantom, detector, scatter)
    % Compute the sinogram of the phantom, given the source and detector, and
    % optionally, the scatter model.
    %
    % Parameters:
    %  - source: the source object, this returns a sample of the source spectrum
    %            giving energy and intensities of the photons. Made up of the following:
    %            - spectrum: the energy spectrum of the source
    %            - collimation: adjusts the source spectrum to account for the collimation
    %            - filter: adjusts the source spectrum to account for the filter
    %  - phantom: the phantom object, this allows you to determine the following:
    %             - How the world is divided into voxels, for ray tracing
    %             - What material is in each voxel
    %             - Determine the attenuation and mean free path of the materials
    %  - detector: the detector object, which includes the following:
    %              - Gantry: How the detector is positioned and moves
    %              - Ray generation: Determines where the rays are directed from the source
    %              - Sensor: Determines how the rays are detected
    %  - scatter: A string that determines the scatter model to use. If not provided,
    %            no scatter is used. The following are the available scatter models:
    %            - 'none': no scatter is used
    %            - 'fast': the convolution scatter model is used
    %            - 'slow': the Monte Carlo scatter model is used
    assert(nargin >= 3, 'Not enough arguments, need at least source, phantom and detector');
    if nargin < 4; scatter = "none"; end

    % Check the inputs
    assert(isa(source, 'source'), 'source must be a source object');
    assert(isa(phantom, 'phantom'), 'phantom must be a phantom object');
    assert(isa(detector, 'detector'), 'detector must be a detector object');
    assert(ischar(scatter), 'scatter must be a string');

    % Retrieve sub-objects of all the objects
    voxels = phantom.voxels;
    assert(isa(voxels, 'voxel_array'), 'The phantom must have a voxel array');
    sensor_unit = detector.sensor;
    assert(isa(sensor_unit, 'sensor'), 'The detector must have a sensor');
    gantry = detector.gantry;
    assert(isa(gantry, 'gantry'), 'The detector must have a gantry');
    d_array = gantry.detector_array;
    assert(isa(d_array, 'detector_array'), 'The gantry must have a detector array');


    % Determine the scatter model
    scatter = lower(scatter);
    if     scatter == "none"; scatter_type = 0;
    elseif scatter == "fast"; scatter_type = 1; scatter_kernel = get_scatter_kernel();
    elseif scatter == "slow"; scatter_type = 2;
    else; error('detector:scatter', ...
        'The scatter string must be "none", "slow" or "fast", got %s', scatter);
    end
    
    % Retrieve the energies and intensities of the source
    energy_list = []; intensity_list = [];
    for bin = 1:sensor_unit.num_bins
        [energies, intensities] = source.get_energies(sensor_unit.get_range(bin));
        energy_list = [energy_list, energies];
        intensity_list = [intensity_list, intensities];
    end

    init_plane = voxels.array_position;
    last_plane = init_plane + (voxels.num_planes - 1) .* voxels.dimensions;
    assert(init_plane(1)^2 + init_plane(2)^2 <= (gantry.dist_to_detector/2)^2, ...
        'Voxels array is not entirely within the detector');
    assert(last_plane(1)^2 + last_plane(2)^2 <= (gantry.dist_to_detector/2)^2, ...
        'Voxels array is not entirely within the detector');

    voxels = voxels.precalculate_mus(energy_list);

    for i = 1:gantry.num_rotations
        rays_at_angle = 
end

function [pixel_values, pixels, energies] = scatter_generator(y_pixel, z_pixel, elist, ilist)
    xray = static_ray_generator(y_pixel, z_pixel);
    
    num_energy = length(elist); 
    num_iters = self.scatter_factor * num_energy;
    
    pixel_values = NaN(num_iters, 1);
    pixels = repmat([y_pixel, z_pixel], num_iters, 1);
    energies = repmat(elist, 1, self.scatter_factor);
    
    fhit_pixel = @self.hit_pixel;
    update_energy = @(ei) xray.update_energy(elist(ei)).randomise_n_mfp();
    get_mu = @(ray, ei) ilist(ei) * exp(-ray.mu);

    if isempty(xray.lengths); pixel_values(:) = 0; return; end
    parfor i = 1:self.scatter_factor
        for ei = 1:num_energy
            new_ray = update_energy(ei).calculate_mu();
         
            hit = true;
            scattered = new_ray.scatter_event > 0;
            
            if scattered
                [pixel, hit] = fhit_pixel(new_ray, current_dv);
                pixels(i, :) = pixel;
                energies(i) = new_ray.energy;
            end
            
            % if scattered; fprintf("%d, ", hit); end

            if hit; pixel_values(i) = get_mu(new_ray, ei); end
        end
    end
end