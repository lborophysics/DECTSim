classdef curved_detector < detector
    properties
        init_to_source_vec (3, 1) double % The vector from the left edge of the detector to the source
        source_position    (3, 1) double % The position of the source
        pixel_angle        (1, 1) double % The angle covered by each pixel
    end
    methods
        function self = curved_detector(dist_to_detector, detector_angle, pixel_angle, rotation_angle)
            arguments
                dist_to_detector double
                detector_angle   double
                % detector_width   double
                pixel_angle      double
                rotation_angle   double = pi/180
            end
            % detector_angle = 2 * asin(detector_width / (2 * dist_to_detector));

            self@detector(dist_to_detector, rotation_angle, detector_angle/pixel_angle, 2*pi);
            self.pixel_angle    = pixel_angle;
            
            % Only true for initial configuration
            self.init_to_source_vec = rotz(-detector_angle/2) * self.to_source_vec; 
            self.source_position    = self.to_source_vec * dist_to_detector/2;
        end

        function self = rotate(self)
            % rotate the detector by the rotation angle
            self.init_to_source_vec = self.rot_mat * self.init_to_source_vec;
            self.source_position    = self.rot_mat * self.source_position;
        end

        function ray_generator = get_ray_generator(self, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           curved_detector
                ray_per_pixel  int32             = 1
            end
            assert(nargin==1, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Cache some variables to make the function faster
            pixel_angle      = self.pixel_angle;
            dist_to_detector = self.dist_to_detector;
            num_pixels       = self.num_pixels;
            to_source_vec    = rotz(pixel_angle / 2) * self.init_to_source_vec;
            source_pos       = self.source_position;

            % Create the function which returns the rays
            ray_generator = @generator;
            function xray = generator(pixel)            
                assert(pixel <= num_pixels && pixel > 0, "Pixel number must be between 1 and the number of pixels on the detector.")
                pixel_vec = rotz(pixel_angle * (pixel - 1)) * to_source_vec;
                xray = ray(source_pos, -pixel_vec, dist_to_detector);
            end
        end
                

    end
end
