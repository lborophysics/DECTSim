classdef parallel_detector < detector
   
    properties(Access = protected)
        corner           (3, 1) double
        detector_vec     (3, 1) double = [1;0;0] % Vector from corner to corner of detector
        to_source_vec    (3, 1) double = [0;1;0] % Vector from source to centre of detector
        dist_to_detector        double
        rot_mat          (3, 3) double
        rotz90           (3, 3) double = rotz(pi/2)
    end

    methods
        function self = parallel_detector(dist_to_detector, detector_width, pixel_width, rotation_angle)
            arguments
                dist_to_detector double
                detector_width   double
                pixel_width      double
                rotation_angle   double
            end
            % Detector Properties
            self.pixel_width      = pixel_width     ;
            self.width            = detector_width  ;
            self.dist_to_detector = dist_to_detector;
            self.num_pixels       = detector_width / pixel_width;
            assert(mod(self.num_pixels, 1) == 0, 'Detector width must be divisible by pixel width');
            
            % Only true for initial configuration
            self.centre = self.to_source_vec * -dist_to_detector/2;
            self.corner = self.centre - self.detector_vec * detector_width/2;

            % Define how the detector should be rotated
            self.rot_mat = rotz(rotation_angle);
            self.num_rotations = ceil(pi / rotation_angle);
        end

%        Redundant???
         function pixel = get_hit_pixel(self, ray_instance)
            arguments
                self          parallel_detector
                ray_instance  ray
            end
            assert(sum((ray_instance.end_point - self.centre) ~= 0) == 1, 'Ray does not hit detector line')
            
            corner_to_ray = norm(ray_instance.end_point - self.corner);
            assert(corner_to_ray > 0 && corner_to_ray < self.width, 'Ray does not hit detector')
            
            pixel = floor(round(corner_to_ray / self.pixel_width, 12)) + 1;
        end 

        function scan_angles = get_scan_angles(self)
            % Get the angles at which the detector should be rotated to scan the object (in degrees)
            scan_angles = rad2deg(linspace(0, pi, self.num_rotations+1));
            scan_angles = scan_angles(1:end-1);
        end

        function self = rotate(self) % How can I make this fast?
            arguments 
                self  parallel_detector
            end
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
            ray_generator = @generator;
            function xray = generator(pixel)
                assert(pixel <= self.num_pixels, 'Pixel number exceeds number of pixels in detector')
                pixel_centre = self.corner + self.detector_vec .* (pixel - 0.5) * self.pixel_width;
                source_position = pixel_centre + self.to_source_vec * self.dist_to_detector;
                xray = ray(source_position, -self.to_source_vec, self.dist_to_detector);
            end
        end
    end
end
