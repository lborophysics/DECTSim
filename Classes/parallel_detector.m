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
        rotz_90 = zrot(pi/2);
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
            obj.num_pixels      = ceil(detector_width / pixel_width);
            
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
            corner_to_ray = norm(ray_instance.end_point - obj.detector_corner);
            pixel = ceil(round(corner_to_ray / obj.pixel_width, 12));
        end

        function pixel_array = get_pixel_array(obj, ray_array)
            mu_array = zeros(1, obj.num_pixels);
            num_hits = mu_array;
            for i = 1:length(ray_array)
                pixel = obj.get_hit_pixel(ray_array{i}.direction);
                mu_array(pixel) = mu_array(pixel) + exp(-ray_array{i}.mu);
                num_hits(pixel) = num_hits(pixel) + ray_array{i}.energy;
            end
            pixel_array = zeros(1, length(mu_array));
            for i = 1:length(mu_array)
                pixel_array(i) = mu_array(i) * num_hits(i);
            end 
        end

        function obj = rotate_detector(obj, angle) % How can I make this fast?
            arguments
                obj   parallel_detector
                angle double
            end
            rot_mat = zrot(angle);
            obj.vec_to_detector = rot_mat * obj.vec_to_detector;
            obj.detector_centre = rot_mat * obj.detector_centre;
            obj.detector_corner = rot_mat * obj.detector_corner;
        end
    end
end
