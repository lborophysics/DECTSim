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
    end

    methods (Abstract)
        rotate(self)
        get_ray_generator(self, ray_per_pixel)
        get_pixel_generator(self, ray_per_pixel)
    end

    methods

        function self = detector(dist_to_detector, rotation_angle, ny_pixels, nz_pixels, total_rotation)
            % detector  Construct a detector object
            arguments
                dist_to_detector (1, 1) double
                rotation_angle   (1, 1) double
                ny_pixels        (1, 1) double
                nz_pixels        (1, 1) double
                total_rotation   (1, 1) double
            end
            self.dist_to_detector = dist_to_detector;
            self.total_rotation   = total_rotation;
            if mod(ny_pixels, 1) ~= 0 || mod(nz_pixels, 1) ~= 0
                assert(abs(mod(ny_pixels, 1)) < 1e-12, 'Number of pixels must be an integer, got %f', ny_pixels);
                assert(abs(mod(nz_pixels, 1)) < 1e-12, 'Number of pixels must be an integer, got %f', nz_pixels);
                ny_pixels = round(ny_pixels);
                nz_pixels = round(nz_pixels);
            end
            self.ny_pixels = ny_pixels;
            self.nz_pixels = nz_pixels;
            % Define how the detector should be rotated
            self.rot_angle     = rotation_angle;
            self.rot_mat       = rotz(rotation_angle);
            self.num_rotations = ceil(total_rotation / rotation_angle); % default to 180 degrees
        end
        

        function image = generate_image(self, voxels)
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
            image = -log(image);
        end
        
        function image = generate_image_p(self, voxels)
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
            image = -log(image);
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