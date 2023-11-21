classdef curved_detector
    properties
        pixel_angle
        detector_angle
        vec_to_detector
    end
    
    properties(Access = private)
        rot_matrix
    end

    methods
        function obj = curved_detector(vec_to_detector, dist_to_detector, detector_angle, detector_size)
            arguments
                vec_to_detector (3, 1) double
                dist_to_detector       double
                detector_angle         double
                detector_size          double
            end
            obj.pixel_angle     = detector_size / dist_to_detector;
            obj.detector_angle  = detector_angle;
            obj.rot_matrix      = rotz(-detector_angle / 2);
            obj.vec_to_detector = obj.rot_matrix * vec_to_detector; % rotate to edge of detector
        end
        
        function pixel = get_hit_pixel(obj, ray_unit_vector)
            arguments
                obj
                ray_unit_vector (3, 1) double
            end
            % get the angle between the ray and the detector
            angle = acos(dot(ray_unit_vector, obj.vec_to_detector));

            % get pixel number
            pixel = floor(angle / obj.pixel_angle) + 1;
        end

        function obj = move_detector(obj, new_direction) % How can I make this fast?
            arguments
                obj           curved_detector
                new_direction (3, 1) double
            end
            obj.vec_to_detector = obj.rot_matrix * new_direction;
        end 
    end
end
