classdef (Abstract) detector < handle
    properties (SetAccess=protected) % Do all these need to be stored? Could be calculated on the fly?
        dist_to_detector   (1, 1) double % Distance from source to detector
        ny_pixels          (1, 1) double % Number of pixels in the y direction
        nz_pixels          (1, 1) double % Number of pixels in the z direction (consolidate these into a single array?)
        num_rotations      (1, 1) double % Number of rotations around the object
        rot_mat            (3, 3) double % Matrix for each individual rotation of the detector around the object
        rot_angle          (1, 1) double
        total_rotation     (1, 1) double % The maximum rotation of the detector around the object
        init_to_source_vec (3, 1) double = [0;1;0] % The initial vector from the left edge of the detector to the source
        to_source_vec      (3, 1) double = [0;1;0] % Vector from source to centre of detector
    end

    properties(Constant, NonCopyable)
        scatter_kernel = get_scatter_kernel();
    end

    properties(SetAccess=private)
        scatter_factor (1, 1) double % Factor to multiply the scatter by
        scatter_type   (1, 1) double % Type of scatter to use
    end

    methods (Abstract) % These need to be implemented by the child class
        rotate(self)
        reset(self)
        hit_pixel(self, ray)
        get_ray_generator(self, voxels, ray_type, ray_per_pixel)
        get_pixel_generator(self, angle_index, voxels, ray_type, ray_per_pixel)
    end

    methods

        function self = detector(dist_to_detector, num_rotations, n_pixels, total_rotation, scatter_type, scatter_factor)
            % detector  Construct a detector object
            arguments
                dist_to_detector (1, 1) double
                num_rotations    (1, 1) double
                n_pixels         (1, 2) double
                total_rotation   (1, 1) double
                scatter_type     (1, 1) string
                scatter_factor   (1, 1) double
            end
            self.dist_to_detector = dist_to_detector;
            self.total_rotation   = total_rotation;
            ny_pixels = n_pixels(1); nz_pixels = n_pixels(2);
            if mod(ny_pixels, 1) ~= 0 || mod(nz_pixels, 1) ~= 0
                assert(abs(mod(ny_pixels, 1)) < 1e-15*ny_pixels, 'Number of pixels must be an integer, got %f', ny_pixels);
                assert(abs(mod(nz_pixels, 1)) < 1e-15*nz_pixels, 'Number of pixels must be an integer, got %f', nz_pixels);
                ny_pixels = round(ny_pixels);
                nz_pixels = round(nz_pixels);
            end
            self.ny_pixels = ny_pixels;
            self.nz_pixels = nz_pixels;
            % Define how the detector should be rotated
            self.rot_angle      = total_rotation / num_rotations;
            self.rot_mat        = rotz(self.rot_angle);
            self.num_rotations  = num_rotations;

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


        function image = generate_image(self, voxels)
            self.check_voxels(voxels);
            image = zeros(self.ny_pixels, self.nz_pixels, self.num_rotations);
            for i = 1:self.num_rotations
                ray_generator = self.get_ray_generator(voxels);
                for j = 1:self.nz_pixels
                    for k = 1:self.ny_pixels
                        ray = ray_generator(k, j);

                        mu = ray.calculate_mu();

                        image(k, j, i) = mu;
                    end
                end
                self.rotate();
            end
            scatter = self.do_scatter(image, voxels);
            % The following line is equivalent to image + scatter, 
            % but is there as in the future we likely will adapt the 
            % detector response.
            image = -reallog(self.detector_response(image + scatter));
        end

        function image = generate_image_p(self, voxels)
            self.check_voxels(voxels);
            image = zeros(self.ny_pixels, self.nz_pixels, self.num_rotations);
            get_pixel_generator = @self.get_pixel_generator;
            for k = 1:self.num_rotations
                pixel_calc = get_pixel_generator(k, voxels);
                for j = 1:self.nz_pixels
                    parfor i = 1:self.ny_pixels
                        image(i, j, k) = feval(pixel_calc, i, j);
                    end
                end
            end
            scatter = self.do_scatter(image, voxels);
            % The following line is equivalent to image + scatter, 
            % but is there as in the future we likely will adapt the 
            % detector response.
            image = -reallog(self.detector_response(image + scatter));
        end

        function scatter = do_scatter(self, image, voxels)
            if self.scatter_type == 0
                scatter = 0;
            elseif self.scatter_type == 1 % Fast scatter
                scatter = self.conv_scatter(image);
            elseif self.scatter_type == 2 % Slow scatter
                scatter = (self.slow_scatter_p(voxels)-image) / 2;
            end
        end

        function scan = air_scan(self)
            % air_scan  Generate a scan of air
            dtd = self.dist_to_detector;
            air = voxel_object(@(i,j,k) i==i, material_attenuation("air"));
            array = voxel_array(zeros(3, 1), zeros(3,1)+1e6, dtd/10, air);
            scan = zeros(self.ny_pixels, self.nz_pixels, self.num_rotations);
            ray_generator = self.get_ray_generator(array);
            image_at_angle = zeros(self.ny_pixels, self.nz_pixels);
            for k = 1:self.nz_pixels
                for j = 1:self.ny_pixels
                    ray = ray_generator(j, k);
                    mu = ray.calculate_mu();
                    image_at_angle(j, k) = mu;
                end
            end
            for i = 1:self.num_rotations
                scan(:, :, i) = image_at_angle;
            end
        end

        function scatter = conv_scatter(self, image)
            % Given an image of intensities, return the appropriate scatter
            % This will need to be changed once we use energy bins for the detector
            scatter = zeros(size(image));
            skernel = self.scatter_kernel;
            sfactor = self.scatter_factor;
            air = self.detector_response(self.air_scan());
            image = self.detector_response(image); % I need the intensities, not the attenuation
            for i = 1:self.num_rotations
                % Create a 2D image, with padding of the size of the kernel
                slice = image(:, :, i);
                air_slice = air(:, :, i);
                scatter_slice = conv2(...
                    sfactor.*0.025.*slice.*(-reallog(slice./air_slice)), ...
                    skernel, 'same') .* mean(slice, 'all');
                scatter(:, :, i) = scatter_slice;
            end
        end

        function scatter = slow_scatter_p(self, voxels)
            % Do some Monte Carlo simulation of scatter
            ny = self.ny_pixels; nz = self.nz_pixels;
            scatter = zeros(ny, nz, self.num_rotations);
            for k = 1:self.num_rotations
                pixel_calc = self.get_pixel_generator(k, voxels, @scatter_ray);
                scatter_idxs = zeros(ny, nz, self.scatter_factor, 2); 
                scatter_vals = zeros(ny, nz, self.scatter_factor);
                for j = 1:nz
                    parfor i = 1:ny
                        [pval, pixel, ~] = feval(pixel_calc, i, j);
                        scatter_idxs(i, j, :, :) = pixel;
                        scatter_vals(i, j, :) = pval;
                    end
                end

                % Add the scatter to the image
                for sf = 1:self.scatter_factor
                    for j = 1:nz
                        for i = 1:ny
                            if ~isnan(scatter_vals(i, j, sf))
                                scatter(scatter_idxs(i, j, sf, 1), scatter_idxs(i, j, sf, 2), k) = ...
                                scatter(scatter_idxs(i, j, sf, 1), scatter_idxs(i, j, sf, 2), k) + scatter_vals(i, j, sf);
                            end
                        end
                    end
                end
            end
            scatter = scatter / self.scatter_factor;
        end

        function scatter = slow_scatter(self, voxels)
            % Do some Monte Carlo simulation of scatter
            self.reset(); % Reset the detector to the initial position
            ny = self.ny_pixels; nz = self.nz_pixels;
            scatter = zeros(ny, nz, self.num_rotations);
            for k = 1:self.num_rotations
                pixel_calc = self.get_pixel_generator(k, voxels, @scatter_ray);
                for j = 1:nz
                    for i = 1:ny
                        [pval, pixel, ~] = pixel_calc(i, j);
                        for sf = 1:self.scatter_factor
                            if ~isnan(pval(sf))
                                scatter(pixel(sf, 1), pixel(sf, 2), k) =  ...
                                scatter(pixel(sf, 1), pixel(sf, 2), k) + pval(sf);
                            end
                        end
                    end
                end
            end
            scatter = scatter / self.scatter_factor;
        end

        function scan_angles = get_scan_angles(self)
            % Get the angles at which the detector should be rotated to scan the object (in degrees)
            scan_angles = rad2deg(linspace(0, self.total_rotation, self.num_rotations+1));
            scan_angles = scan_angles(1:end-1);
        end

        function image = detector_response(~, attenuation_matrix)
            % detector_response  Calculate the detector response for the image made up of the attenuation coefficients
            image = exp(-attenuation_matrix);
        end
    end
end