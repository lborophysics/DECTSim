classdef parallel_detector < detector
   
    properties
        centre           (3, 1) double
        corner           (3, 1) double
        width            (1, 1) double
        pixel_width      (1, 1) double        
        detector_vec     (3, 1) double = [1;0;0] % Vector from left to right corner of detector
    end

    methods
        function self = parallel_detector(dist_to_detector, detector_length, pixel_width, rotation_angle)
            arguments
                dist_to_detector  double
                detector_length   double
                pixel_width       double
                rotation_angle    double = pi/180
            end
            self@detector(dist_to_detector, rotation_angle, detector_length / pixel_width, pi);
            self.width       = detector_length;
            self.pixel_width = pixel_width;
            
            % Only true for initial configuration
            self.centre = self.to_source_vec * -dist_to_detector/2;
            self.corner = self.centre - self.detector_vec * self.width/2;
        end

        function self = rotate(self) % How can I make this fast?
            % Rotate the detector and the source (better to do this than recalculate the source position?)
            self.detector_vec  = self.rot_mat * self.detector_vec;
            self.to_source_vec = self.rot_mat * self.to_source_vec;
            self.centre        = self.rot_mat * self.centre;

            % Recalculate the corner
            self.corner = self.centre - self.detector_vec.*self.width/2;
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
            corner           = self.corner; 
            detector_vec     = self.detector_vec;
            pixel_width      = self.pixel_width;
            dist_to_detector = self.dist_to_detector;
            to_source_vec    = self.to_source_vec;
            num_pixels       = self.num_pixels;

            % Create the function which returns the rays
            ray_generator = @generator;
            function xray = generator(pixel)
                assert(pixel <= num_pixels && pixel > 0, "Pixel number must be between 1 and the number of pixels on the detector.")
                pixel_centre = corner + detector_vec .* (pixel - 0.5) * pixel_width;
                source_position = pixel_centre + to_source_vec * dist_to_detector;
                xray = ray(source_position, -to_source_vec, dist_to_detector);
            end
        end
    end
end
