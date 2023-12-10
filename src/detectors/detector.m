classdef (Abstract) detector
    properties (Access=protected) % Do all these need to be stored? Could be calculated on the fly?
        dist_to_detector   (1, 1) double % Distance from source to detector
        num_pixels         (1, 1) double % Number of pixels in the detector
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

        function self = detector(dist_to_detector, rotation_angle, num_pixels, total_rotation)
            % detector  Construct a detector object
            arguments
                dist_to_detector (1, 1) double
                rotation_angle   (1, 1) double
                num_pixels       (1, 1) double
                total_rotation   (1, 1) double
            end
            self.dist_to_detector = dist_to_detector;
            self.total_rotation   = total_rotation;
            self.num_pixels       = num_pixels;
            if mod(num_pixels, 1) ~= 0
                assert(abs(mod(num_pixels, 1)) < 1e-12, 'Number of pixels must be an integer, got %f', num_pixels);
                self.num_pixels = round(num_pixels);
            end

            % Define how the detector should be rotated
            self.rot_angle     = rotation_angle;
            self.rot_mat       = rotz(rotation_angle);
            self.num_rotations = ceil(total_rotation / rotation_angle); % default to 180 degrees
        end
        

        function image = generate_image(self, voxels)
            image = zeros(self.num_rotations, self.num_pixels);
            for i = 1:self.num_rotations
                ray_generator = self.get_ray_generator();
                for j = 1:self.num_pixels
                    
                    ray = ray_generator(j);
                    
                    mu = ray.calculate_mu(voxels);
                    
                    image(i, j) = self.detector_response(mu);
                end
                self = self.rotate();
            end
            image = mat2gray(-log(image'));
        end
        
        function image = generate_image_p(self, voxels)
            image = zeros(self.num_rotations, self.num_pixels);
            get_pixel_generator = @self.get_pixel_generator;
            for i = 1:self.num_rotations
                pixel_calc = get_pixel_generator(i);
                parfor j = 1:self.num_pixels
                    image(i, j) = feval(pixel_calc, j, voxels);
                end
            end
            image = mat2gray(-log(image'));
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