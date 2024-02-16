classdef (Abstract) detector < handle
    properties (SetAccess=protected) % Do all these need to be stored? Could be calculated on the fly?
        % Detector geometry
        dist_to_detector   (1, 1) double % Distance from source to detector
        init_to_source_vec (3, 1) double = [0;1;0] % The initial vector from the left edge of the detector to the source
        to_source_vec      (3, 1) double = [0;1;0] % Vector from source to centre of detector

        % Detector movement
        num_rotations      (1, 1) double % Number of rotations around the object
        rot_mat            (3, 3) double % Matrix for each individual rotation of the detector around the object
        rot_angle          (1, 1) double
        total_rotation     (1, 1) double % The maximum rotation of the detector around the object

        % Detector sensor properties
        sensor_unit                      % The sensor unit/element for the detector
        nz_pixels          (1, 1) double % Number of pixels in the z direction (consolidate these into a single array?)
        ny_pixels          (1, 1) double % Number of pixels in the y direction

        % Source properties
        xray_source                      % The source of the x-rays
    end

    properties(Constant, NonCopyable)
        scatter_kernel = get_scatter_kernel();
    end

    properties(SetAccess=private)
        scatter_factor (1, 1) double % Factor to multiply the scatter by
        scatter_type   (1, 1) double % Type of scatter to use
        energy_list 
        intensity_list
    end

    methods (Abstract) % These need to be implemented by the child class
        rotate(self)
        reset(self)
        hit_pixel(self, ray)
        get_ray_generator(self, voxels, ray_type, ray_per_pixel)
        get_pixel_generator(self, angle_index, voxels, ray_type, ray_per_pixel)
    end

    methods

        function self = detector(xray_source, sensor_unit, dist_to_detector, ...
            n_pixels, num_rotations, total_rotation, scatter_type, scatter_factor)
            % detector  Construct a detector object
            arguments
                xray_source            %source
                sensor_unit            %sensor
                dist_to_detector (1, 1) double
                n_pixels         (1, 2) double
                num_rotations    (1, 1) double
                total_rotation   (1, 1) double
                scatter_type     (1, 1) string
                scatter_factor   (1, 1) double
            end
            % Set the source properties
            self.xray_source = xray_source;

            % Detector Geometry
            self.dist_to_detector = dist_to_detector;
            self.total_rotation   = total_rotation;
            
            % Set the detector movement properties
            self.rot_angle      = total_rotation / num_rotations;
            self.rot_mat        = rotz(self.rot_angle);
            self.num_rotations  = num_rotations;

            % Set the sensor properties
            self.sensor_unit = sensor_unit;
            ny_pixels = n_pixels(1); nz_pixels = n_pixels(2);
            if mod(ny_pixels, 1) ~= 0 || mod(nz_pixels, 1) ~= 0
                assert(abs(mod(ny_pixels, 1)) < 1e-15*ny_pixels, 'Number of pixels must be an integer, got %f', ny_pixels);
                assert(abs(mod(nz_pixels, 1)) < 1e-15*nz_pixels, 'Number of pixels must be an integer, got %f', nz_pixels);
                ny_pixels = round(ny_pixels);
                nz_pixels = round(nz_pixels);
            end
            self.ny_pixels = ny_pixels;
            self.nz_pixels = nz_pixels;

            energy_list = []; intensity_list = [];
            for bin = 1:self.sensor_unit.num_bins
                [energies, intensities] = self.xray_source.get_energies(self.sensor_unit.get_range(bin));
                energy_list = [energy_list, energies];
                intensity_list = [intensity_list, intensities];
            end
            self.energy_list = energy_list;
            self.intensity_list = intensity_list;
            
            % Set the scatter properties
            scatter_type = lower(scatter_type);
            if     scatter_type == "none";  scatter_type = 0;
            elseif scatter_type == "fast";  scatter_type = 1;
            elseif scatter_type == "slow";  scatter_type = 2;
            else; error('detector:scatter_type', ...
                'The scatter_type string must be "none", "slow" or "fast", got %s', scatter_type);
            end
            self.scatter_type = scatter_type;

            % For "slow" scatter, this will be how slow (i.e. the factor determining how much convolution to do).
            % For now, it is ignored in this case and no convolution is done.
            % For "fast" scatter, this is the factor to multiply the scatter by
            self.scatter_factor = scatter_factor;
        end

        function check_voxels(self, voxels)
            % Check that the voxels are all within the detector
            init_plane = voxels.array_position;
            last_plane = init_plane + (voxels.num_planes - 1) .* voxels.dimensions;
            assert(init_plane(1)^2 + init_plane(2)^2 <= (self.dist_to_detector/2)^2, ...
                'Voxels array is not entirely within the detector');
            assert(last_plane(1)^2 + last_plane(2)^2 <= (self.dist_to_detector/2)^2, ...
                'Voxels array is not entirely within the detector');
        end

        function voxels = precalculate_mus(self, voxels)
            voxels = voxels.precalculate_mus(self.energy_list);
        end


        function image = generate_image(self, voxels)
            self.check_voxels(voxels);
            voxels = self.precalculate_mus(voxels);
            
            ny = self.ny_pixels; nz = self.nz_pixels;
            photon_count = zeros(self.sensor_unit.num_bins, ny, nz, self.num_rotations);
            for i = 1:self.num_rotations
                ray_generator = self.get_ray_generator(voxels, self.energy_list(1));
                for j = 1:nz
                    for k = 1:ny
                        ray = ray_generator(k, j);
                        photon_count(:, k, j, i) = self.for_all_energies(ray);
                        self.rotate();
                    end
                end
            end
            primary_signal = self.sensor_unit.get_signal(photon_count);
            scatter_signal = self.do_scatter(photon_count, voxels);
            % The following line is equivalent to image + scatter,
            % but is there as in the future we likely will adapt the 
            % detector response.
            image = self.sensor_unit.get_image(primary_signal + scatter_signal);
        end

        function image = generate_image_p(self, voxels)
            self.check_voxels(voxels);
            voxels = self.precalculate_mus(voxels);
            
            ny = self.ny_pixels; nz = self.nz_pixels; num_bins = self.sensor_unit.num_bins;
            photon_count = zeros(num_bins, ny, nz, self.num_rotations);
            get_pixel_generator = @self.get_pixel_generator;
            for_all_energies = @self.for_all_energies;
            
            for k = 1:self.num_rotations 
                % For each rotation, we calculate the image for the source
                pixel_calc = get_pixel_generator(k, voxels, self.energy_list(1));
                for j = 1:nz
                    parfor i = 1:self.ny_pixels
                        ray = feval(pixel_calc, i, j);
                        photon_count(:, i, j, k) = for_all_energies(ray);
                    end
                end
            end
            primary_signal = self.sensor_unit.get_signal(photon_count);
            scatter_signal = self.do_scatter(primary_signal, voxels);            
            % The following line is equivalent to image + scatter, 
            % but is there as in the future we likely will adapt the 
            % detector response.
            image = self.sensor_unit.get_image(primary_signal + scatter_signal);
        end

        function photon_count = for_all_energies(self, ray)
            photon_count = zeros(self.sensor_unit.num_bins, 1);
            for bin = 1:self.sensor_unit.num_bins
                % Get the energies for the current bin
                [energies, intensities] = ...
                    self.xray_source.get_energies(self.sensor_unit.get_range(bin));
                for ei = 1:length(energies)
                    energy = energies(ei); intensity = intensities(ei);
                    ray = ray.update_energy(energy);
                    mu = ray.calculate_mu();
                    photon_count(bin) = intensity*exp(-mu);
                end
            end
        end


        function scatter_signal = do_scatter(self, image, voxels)
            if self.scatter_type == 0
                scatter_signal = 0;
            elseif self.scatter_type == 1 % Fast scatter
                scatter_signal = self.conv_scatter(image);
            elseif self.scatter_type == 2 % Slow scatter
                scatter_signal = self.slow_scatter(voxels);
            end
        end

        function scan = air_scan(self)
            % air_scan  Generate a scan of air
            air = voxel_object(@(i,j,k) i==i, material_attenuation("air"));
            array = voxel_array(zeros(3, 1), zeros(3,1)+1e6, self.dist_to_detector/10, air);

            num_bins = self.sensor_unit.num_bins;
            scan = zeros(num_bins, self.ny_pixels, self.nz_pixels, self.num_rotations);
            image_at_angle = zeros(num_bins, self.ny_pixels, self.nz_pixels);
            ray_generator = self.get_ray_generator(array, self.energy_list(1));
            for k = 1:self.nz_pixels
                for j = 1:self.ny_pixels
                    ray = ray_generator(j, k);
                    image_at_angle(:, j, k) = for_all_energies(ray);
                end
            end
            for i = 1:self.num_rotations
                scan(:, :, :, i) = image_at_angle;
            end
        end

        function scatter = conv_scatter(self, image)
            % Given an image of intensities, return the appropriate scatter
            % This will need to be changed once we use energy bins for the detector
            scatter = zeros(size(image));
            skernel = self.scatter_kernel;
            sfactor = self.scatter_factor;
            air = self.air_scan();
            image = self.detector_response(image); % I need the intensities, not the attenuation
            for i = 1:self.num_rotations
                % Create a 2D image, with padding of the size of the kernel
                slice = image(:, :, :, i);
                air_slice = air(:, :, :, i);
                scatter_slice = conv2(...
                    sfactor.*0.025.*slice.*(-reallog(slice./air_slice)), ...
                    skernel, 'same') .* mean(slice, 3); % Double check the mean is correct
                scatter(:, :, :, i) = scatter_slice;
            end
        end

        function scatter = slow_scatter(self, voxels)
            % Do some Monte Carlo simulation of scatter
            scatter = zeros(self.sensor_unit.num_bins, self.ny_pixels,...
                self.nz_pixels, self.num_rotations);
            for k = 1:self.num_rotations
                scatter = self.scatter_at_angle(scatter, k, voxels);
            end
            scatter = self.sensor_unit.get_signal(scatter);
            squeeze(scatter);
        end

        function scatter = scatter_at_angle(self, scatter, k, voxels)
            % This is the function that will be called for each pixel
            ny = self.ny_pixels; nz = self.nz_pixels;

            elist = self.energy_list; ilist = self.intensity_list;  
            pixel_calc = self.get_pixel_generator(k, voxels, elist(1), @scatter_ray);
            scatter_idxs = zeros(ny, nz, self.scatter_factor, 2); 
            scatter_vals = NaN(ny, nz, self.scatter_factor);
            energies = zeros(ny, nz, self.scatter_factor);

            % Do the linear indexing of scatter
            for j = 1:nz
                parfor i = 1:ny
                    [pval, pixel, energy] = feval(pixel_calc, i, j, elist, ilist);
                    scatter_idxs(i, j, :, :) = pixel;
                    scatter_vals(i, j, :) = pval;
                    energies(i, j, :) = energy;
                end
            end

            % Add the scatter to the image (non linear indexing of scatter)
            for sf = 1:self.scatter_factor
                for j = 1:nz
                    for i = 1:ny
                        if ~isnan(scatter_vals(i, j, sf))
                            y_index = scatter_idxs(i, j, sf, 1);
                            z_index = scatter_idxs(i, j, sf, 2);
                            bin = self.sensor_unit.get_energy_bin(energies(i, j, sf));

                            scatter(bin, y_index, z_index, k) = ...
                            scatter(bin, y_index, z_index, k) + ...
                                scatter_vals(i, j, sf);
                        end
                    end
                end

            end
        end

        function scan_angles = get_scan_angles(self)
            % Get the angles at which the detector should be rotated to scan the object (in degrees)
            scan_angles = rad2deg(linspace(0, self.total_rotation, self.num_rotations+1));
            scan_angles = scan_angles(1:end-1);
        end
    end
end