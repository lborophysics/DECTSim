classdef parallel_detector
    properties
        pixel_width double
        width       double
        centre      (3, 1) double
        num_pixels  int32
    end
    
    properties(Access = private)
        corner           (3, 1) double
        vec_to_detector  (3, 1) double
        dist_to_detector        double
        source_position  (3, 1) double
        rotz_90 = rotz(pi/2);
    end

    methods
        function self = parallel_detector(source_position, vec_to_detector, dist_to_detector, detector_width, pixel_width)
            arguments
                source_position (3, 1) double
                vec_to_detector (3, 1) double
                dist_to_detector       double
                detector_width         double
                pixel_width            double
            end
            self.vec_to_detector  = vec_to_detector ;
            self.pixel_width      = pixel_width     ;
            self.width            = detector_width  ;
            self.dist_to_detector = dist_to_detector;
            self.source_position  = source_position ;
            self.centre           = source_position + vec_to_detector .* dist_to_detector;
            self.corner           = self.centre - self.rotz_90*vec_to_detector.*detector_width/2;
            self.num_pixels       = detector_width / pixel_width;
            assert(mod(self.num_pixels, 1) == 0, 'Detector width must be divisible by pixel width');
            
            % Produce a function which returns the vectors in which rays should be to hit all the pixels

        end
        
        function pixel = get_hit_pixel(self, ray_instance)
            arguments
                self          parallel_detector
                ray_instance  ray
            end
            
            % Find the intersection of the ray with the detector plane - 
            % Actually I need to implement an algorithm with fewer assumptions, 
            % remove dependence on source and depend on the unit vector instead, 
            % which comes with a start point!!
            assert(sum((ray_instance.end_point - self.centre) ~= 0) == 1, 'Ray does not hit detector plane')
            
            corner_to_ray = norm(ray_instance.end_point - self.corner);
            assert(corner_to_ray > 0 && corner_to_ray < self.width, 'Ray does not hit detector')
            
            pixel = floor(round(corner_to_ray / self.pixel_width, 12)) + 1;
        end

        function self = rotate_detector(self, angle) % How can I make this fast?
            arguments
                self  parallel_detector
                angle double
            end
            rot_mat = rotz(angle);
            new_vec = rot_mat * self.vec_to_detector;
            self.centre = self.source_position + new_vec.*self.dist_to_detector;
            self.corner = self.centre - self.rotz_90 * new_vec.*self.width/2;
            self.vec_to_detector = new_vec;
        end
    end
end
