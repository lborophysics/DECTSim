classdef parallel_detector
    properties
        pixel_width            double
        detector_width         double
        detector_centre (3, 1) double
        num_pixels             int32
    end
    
    properties(Access = private)
        detector_corner  (3, 1) double
        vec_to_detector  (3, 1) double
        rotz_90 = rotz(pi/2);
    end

    methods
        function obj = parallel_detector(source_position, vec_to_detector, dist_to_detector, detector_width, pixel_width)
            arguments
                source_position (3, 1) double
                vec_to_detector (3, 1) double
                dist_to_detector       double
                detector_width         double
                pixel_width            double
            end
            obj.vec_to_detector = vec_to_detector ;
            obj.pixel_width     = pixel_width     ;
            obj.detector_width  = detector_width  ;
            obj.detector_centre = source_position + vec_to_detector .* dist_to_detector;
            obj.detector_corner = obj.detector_centre - obj.rotz_90*vec_to_detector.*detector_width/2;
            obj.num_pixels      = detector_width / pixel_width;
            assert(mod(obj.num_pixels, 1) == 0, 'Detector width must be divisible by pixel width');
            
            % Produce a function which returns the vectors in which rays should be to hit all the pixels

        end
        
        function pixel = get_hit_pixel(obj, ray_instance)
            arguments
                obj           parallel_detector
                ray_instance  ray
            end
            
            % Find the intersection of the ray with the detector plane - 
            % Actually I need to implement an algorithm with fewer assumptions, 
            % remove dependence on source and depend on the unit vector instead, 
            % which comes with a start point!!
            assert(sum((ray_instance.end_point - obj.detector_centre) ~= 0) == 1, 'Ray does not hit detector plane')
            
            corner_to_ray = norm(ray_instance.end_point - obj.detector_corner);
            assert(corner_to_ray > 0 && corner_to_ray < obj.detector_width, 'Ray does not hit detector')
            
            pixel = floor(round(corner_to_ray / obj.pixel_width, 12)) + 1;
        end

        function obj = rotate_detector(obj, angle) % How can I make this fast?
            arguments
                obj   parallel_detector
                angle double
            end
            rot_mat = rotz(angle);
            obj.vec_to_detector = rot_mat * obj.vec_to_detector;
            obj.detector_centre = rot_mat * obj.detector_centre;
            obj.detector_corner = rot_mat * obj.detector_corner;
        end
    end
end
