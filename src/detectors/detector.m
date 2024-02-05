classdef (Abstract) detector
    properties (Access=protected) % Do all these need to be stored? Could be calculated on the fly?
        dist_to_detector   (1, 1) double % Distance from source to detector
        ny_pixels          (1, 1) double % Number of pixels in the y direction
        nz_pixels          (1, 1) double % Number of pixels in the z direction
        num_rotations      (1, 1) double % Number of rotations around the object
        rot_mat            (3, 3) double % Matrix for each individual rotation of the detector around the object
        rot_angle          (1, 1) double
        total_rotation     (1, 1) double % The maximum rotation of the detector around the object
        init_to_source_vec (3, 1) double = [0;1;0] % The initial vector from the left edge of the detector to the source
        to_source_vec      (3, 1) double = [0;1;0] % Vector from source to centre of detector
        scatter_kernel     (49, 65) double
    end

    properties
        scatter_factor (1, 1) double = 0 % Factor to multiply the scatter by
    end

    methods (Abstract)
        rotate(self)
        get_ray_generator(self, ray_per_pixel)
        get_pixel_generator(self, ray_per_pixel)
    end

    methods

        function self = detector(dist_to_detector, num_rotations, n_pixels, total_rotation, scatter_factor)
            % detector  Construct a detector object
            arguments
                dist_to_detector (1, 1) double
                num_rotations    (1, 1) double
                n_pixels         (1, 2) double
                total_rotation   (1, 1) double
                scatter_factor   (1, 1) double = 0
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
            self.scatter_factor = scatter_factor;
            self.scatter_kernel = get_scatter_kernel();
        end
        
        function check_voxels(self, voxels)
            % Check that the voxels are all within the detector
            init_plane = voxels.get_point_position([1; 1; 1]);
            last_plane = voxels.get_point_position(voxels.num_planes);
            assert(init_plane(1)^2 + init_plane(2)^2 <= (self.dist_to_detector/2)^2, 'Voxels array is not entirely within the detector');
            assert(last_plane(1)^2 + last_plane(2)^2 <= (self.dist_to_detector/2)^2, 'Voxels array is not entirely within the detector');
        end


        function image = generate_image(self, voxels)
            self.check_voxels(voxels);
            image = zeros(self.ny_pixels, self.nz_pixels, self.num_rotations);
            for i = 1:self.num_rotations
                ray_generator = self.get_ray_generator();
                image_at_angle = zeros(self.ny_pixels, self.nz_pixels);
                for k = 1:self.nz_pixels
                    for j = 1:self.ny_pixels
                        ray = ray_generator(j, k);
                    
                        mu = ray.calculate_mu(voxels);
                    
                        image_at_angle(j, k) = self.detector_response(mu);
                    end
                end
                image(:, :, i) = image_at_angle;
                self = self.rotate();
            end
            if self.scatter_factor > 0; scatter = self.get_scatter(image);
            else; scatter = 0; end
            image = -reallog(image + scatter);
        end
        
        function image = generate_image_p(self, voxels)
            self.check_voxels(voxels);
            image = zeros(self.ny_pixels, self.nz_pixels, self.num_rotations);
            get_pixel_generator = @self.get_pixel_generator;
            for i = 1:self.num_rotations
                pixel_calc = get_pixel_generator(i);
                image_at_angle = zeros(self.ny_pixels, self.nz_pixels);
                for k = 1:self.nz_pixels
                    parfor j = 1:self.ny_pixels
                        image_at_angle(j, k) = feval(pixel_calc, j, k, voxels);
                    end
                end
                image(:, :, i) = image_at_angle;
            end
            if self.scatter_factor > 0; scatter = self.get_scatter(image);
            else; scatter = 0; end
            image = -reallog(image + scatter);
        end

        function scan = air_scan(self)
            % air_scan  Generate a scan of air
            dtd = self.dist_to_detector;
            air = get_material("air");
            air_cylinder = @(i,j,k,e) air.get_mu(e);
            array = voxel_array(zeros(3, 1), zeros(3,1)+dtd*2, dtd/100, air_cylinder);
            scan = zeros(self.ny_pixels, self.nz_pixels, self.num_rotations);
            ray_generator = self.get_ray_generator();
            image_at_angle = zeros(self.ny_pixels, self.nz_pixels);
            for k = 1:self.nz_pixels
                for j = 1:self.ny_pixels
                    ray = ray_generator(j, k);
                    mu = ray.calculate_mu(array);
                    image_at_angle(j, k) = self.detector_response(mu);
                end
            end
            for i = 1:self.num_rotations
                scan(:, :, i) = image_at_angle;
            end
        end


        function scatter = get_scatter(self, image)
            % Given an image of intensities, return the appropriate scatter
            scatter = zeros(size(image));
            skernel = self.scatter_kernel;
            sfactor = self.scatter_factor;
            air = self.air_scan();
            for i = 1:self.num_rotations
                % Create a 2D image, with padding of the size of the kernel
                slice = image(:, :, i);
                air_slice = air(:, :, i);   
                scatter_slice = conv2(sfactor.*0.025.*slice.*(-reallog(slice./air_slice)), skernel, 'same') .* mean(slice, 'all');
                scatter(:, :, i) = scatter_slice;
            end
        end
        
        function scan_angles = get_scan_angles(self)
            % Get the angles at which the detector should be rotated to scan the object (in degrees)
            scan_angles = rad2deg(linspace(0, self.total_rotation, self.num_rotations+1));
            scan_angles = scan_angles(1:end-1);
        end

        function pixel = detector_response(~, attenuation)
            % detector_response  Calculate the detector response for a given attenuation coefficient
            arguments
                ~
                attenuation (1, 1) double
            end
            pixel = exp(-attenuation);
        end
    end
end