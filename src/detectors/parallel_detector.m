classdef parallel_detector < detector
   
    properties
        init_centre       (3, 1) double
        centre            (3, 1) double
        dims              (1, 2) double % [length, width]
        pixel_dims        (1, 2) double
        init_detector_vec (3, 1) double = [1;0;0] % Vector from left to right corner of detector
        detector_vec      (3, 1) double = [1;0;0] % Vector from left to right corner of detector
    end

    methods
        function self = parallel_detector(dist_to_detector, detector_dims, num_pixels, rotation_angle)
            arguments
                dist_to_detector         double
                detector_dims     (1, 2) double
                num_pixels        (1, 2) double
                rotation_angle           double = pi/180
            end
            self@detector(dist_to_detector, rotation_angle, num_pixels(1), num_pixels(2), pi);
            self.dims        = detector_dims;
            self.pixel_dims  = detector_dims ./ num_pixels;
            
            % Only true for initial configuration
            self.centre = self.to_source_vec * -dist_to_detector/2;
            self.init_centre = self.centre;
        end

        function self = rotate(self) % How can I make this fast?
            % Rotate the detector and the source (better to do this than recalculate the source position?)
            self.detector_vec  = self.rot_mat * self.detector_vec;
            self.to_source_vec = self.rot_mat * self.to_source_vec;
            self.centre        = self.rot_mat * self.centre;
        end

        function ray_generator = get_ray_generator(self, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                ray_per_pixel  int32             = 1
            end
            assert(nargin==1, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Cache some variables to make the function faster
            centre           = self.centre;
            detector_vec     = self.detector_vec;
            pixel_width      = self.pixel_dims(1);
            pixel_height     = self.pixel_dims(2);
            dist_to_detector = self.dist_to_detector;
            to_source_vec    = self.to_source_vec;
            ny_pixels        = self.ny_pixels;
            nz_pixels        = self.nz_pixels;

            % Create the function which returns the rays
            ray_generator = @generator;
            function xray = generator(y_pixel, z_pixel)
                assert(y_pixel <= ny_pixels && y_pixel > 0 && z_pixel <= nz_pixels && z_pixel > 0, ...
                        "Pixel number must be between 1 and the number of pixels on the detector.")
                pixel_centre = centre +  ... 
                               detector_vec .* (y_pixel - (ny_pixels+1)/2) .* pixel_width + ...
                               [0;0;z_pixel - (nz_pixels+1)/2] .* pixel_height;
                source_position = pixel_centre + to_source_vec * dist_to_detector;
                xray = ray(source_position, -to_source_vec, dist_to_detector);
            end
        end
        function pixel_generator = get_pixel_generator(self, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                angle_index    double
                ray_per_pixel  int32             = 1
            end
            assert(nargin==2, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")
            
            if angle_index == 1; rot_mat = eye(3);
            else;                rot_mat = rotz(self.rot_angle * (angle_index - 1));
            end
            detector_vec  = rot_mat * self.init_detector_vec;
            to_source_vec = rot_mat * self.init_to_source_vec;
            centre        = rot_mat * self.init_centre;

            % Cache some variables to make the function faster
            pixel_width      = self.pixel_dims(1);
            pixel_height     = self.pixel_dims(2);
            dist_to_detector = self.dist_to_detector;
            ny_pixels        = self.ny_pixels;
            nz_pixels        = self.nz_pixels;
            detector_response= @self.detector_response;

            % Create the function which returns the rays
            pixel_generator = @generator;
            function pixel_value = generator(y_pixel, z_pixel, voxels)
                assert(y_pixel <= ny_pixels && y_pixel > 0 && z_pixel <= nz_pixels && z_pixel > 0, ...
                        "Pixel number must be between 1 and the number of pixels on the detector.")
                pixel_centre = centre +  ... 
                               detector_vec .* (y_pixel - (ny_pixels+1)/2) .* pixel_width + ...
                               [0;0;z_pixel - (nz_pixels+1)/2] .* pixel_height;
                source_position = pixel_centre + to_source_vec * dist_to_detector;
                xray = ray(source_position, -to_source_vec, dist_to_detector);
                pixel_value = detector_response(xray.calculate_mu(voxels));
            end
        end
    end
end
