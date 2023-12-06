classdef detector_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods
        function test_curved_init(tc)
            % detector = curved_detector(9, 18, pi/180, pi/2); % using detector width
            detector = curved_detector(9, pi, pi/180, pi/2);
            tc.verifyEqual(detector.init_source_pos, detector.source_position, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, [0; 4.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/180);

            detector = detector.rotate();
            tc.verifyEqual(detector.init_source_pos, [0; 4.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, [-4.5; 0; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/180);

            detector = curved_detector(9, pi, pi/180);
            detector = detector.rotate();
            tc.verifyEqual(detector.source_position, 4.5*rotz(pi/2 + pi/180)*[1; 0; 0], 'AbsTol', 1e-15);

            % detector = curved_detector(11, 11, pi/30, pi/4); % using detector width
            detector = curved_detector(11, pi/3, pi/30, pi/4);
            tc.verifyEqual(detector.init_source_pos, detector.source_position, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, [0; 5.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/30);
            
            detector = detector.rotate();
            tc.verifyEqual(detector.init_source_pos, [0; 5.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, rotz(pi/4)*[0; 5.5; 0], 'AbsTol', 1e-15); 
            tc.verifyEqual(detector.pixel_angle, pi/30);
        end

        function test_parallel_init(tc)
            detector = parallel_detector(5, 11, 0.1, pi/2);
            tc.verifyEqual(detector.centre, [0; -2.5; 0]);
            tc.verifyEqual(detector.corner, [-5.5; -2.5; 0]);
            tc.verifyEqual(detector.width, 11);
            tc.verifyEqual(detector.pixel_width, 0.1);

            detector = detector.rotate();
            tc.verifyEqual(detector.centre, [2.5; 0; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.corner, [2.5; -5.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.width, 11);
            tc.verifyEqual(detector.pixel_width, 0.1);

            detector = parallel_detector(5, 11, 0.1);
            detector = detector.rotate();
            tc.verifyEqual(detector.centre, rotz(pi/180)*[0; -2.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.corner, rotz(pi/180)*[-5.5; -2.5; 0], 'AbsTol', 1e-15);
            
            detector = parallel_detector(7, 14, 0.2, pi/4); 
            tc.verifyEqual(detector.centre, [0; -3.5; 0]);
            tc.verifyEqual(detector.corner, [-7; -3.5; 0]);
            tc.verifyEqual(detector.width, 14);
            tc.verifyEqual(detector.pixel_width, 0.2);

            detector = detector.rotate();
            tc.verifyEqual(detector.centre, [ 1/sqrt(2); -1/sqrt(2); 0]*3.5, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.corner, [-1/sqrt(2); -3/sqrt(2); 0]*3.5, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.width, 14);
            tc.verifyEqual(detector.pixel_width, 0.2);
        end

        function test_curved_ray_gen(tc)
            % detector = curved_detector(9, 18, pi/60, pi/2); % using detector width
            detector = curved_detector(9, pi, pi/60, pi/2);
            ray_generator = detector.get_ray_generator();

            rot_by_pixel = rotz(pi/60);
            unit_vector = rotz(pi/120) * [-1; 0; 0];
            for i = 1:60
                my_ray = ray([0; 4.5; 0], unit_vector, 9);
                gen_ray = ray_generator(i);
                tc.verifyEqual(gen_ray.start_point, my_ray.start_point);
                tc.verifyEqual(gen_ray.direction, my_ray.direction, 'RelTol', 1e-13);
                tc.verifyEqual(gen_ray.end_point, my_ray.end_point, 'RelTol', 1e-13);
                unit_vector = rot_by_pixel * unit_vector;
            end
        end

        function test_para_ray_gen(tc)
            unit_vector = [0; -1; 0];
            detector = parallel_detector(2, 11, 0.1, 0);
            ray_generator = detector.get_ray_generator();

            trans_by_pixel = [1; 0; 0] * 0.1;
            start = [-5.45; 1; 0];
            for i = 1:110
                my_ray = ray(start, unit_vector, 2);
                gen_ray = ray_generator(i);
                tc.verifyEqual(gen_ray.start_point, my_ray.start_point, 'AbsTol', 7e-15);
                tc.verifyEqual(gen_ray.direction, my_ray.direction);
                tc.verifyEqual(gen_ray.end_point, my_ray.end_point, 'AbsTol', 7e-15);
                start = start + trans_by_pixel;
            end
        end

        function test_get_scan_angles(tc)
            for divisor = 2:10
                detector = parallel_detector(2, 11, 0.1, pi/divisor);
                res = detector.get_scan_angles();
                exp = rad2deg(linspace(0, pi, divisor+1));

                tc.verifyEqual(res, exp(1:end-1), 'AbsTol', 1e-15);
            end
        end
        
        function test_generate_image(tc)
            detector = parallel_detector(10, 5, 1, pi/4);
            my_box = voxel_box([0;0;0], [3;3;3], @(e)1);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            sq2 = sqrt(2);
            
            image = detector.generate_image(array);
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;1/sq2;1/sq2;1/sq2;0], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [1-2*sq2/3;1-sq2/3;1;1-sq2/3;1-2*sq2/3], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 3), [0;1/sq2;1/sq2;1/sq2;0], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [1-2*sq2/3;1-sq2/3;1;1-sq2/3;1-2*sq2/3], 'AbsTol', 1e-15);
        end

        function test_generate_image_p(tc)
            detector = parallel_detector(10, 5, 1, pi/4);
            my_box = voxel_box([0;0;0], [3;3;3], @(e)1);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            sq2 = sqrt(2);
            
            image = detector.generate_image_p(array);
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;1/sq2;1/sq2;1/sq2;0], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [1-2*sq2/3;1-sq2/3;1;1-sq2/3;1-2*sq2/3], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 3), [0;1/sq2;1/sq2;1/sq2;0], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [1-2*sq2/3;1-sq2/3;1;1-sq2/3;1-2*sq2/3], 'AbsTol', 1e-15);
        end

        function test_curved_generate_image_p(tc)
            dist_to_detector = 10;
            detector_angle = pi/20;
            pixel_angle = detector_angle/500;
            rotation_angle = pi/8;
            detector = curved_detector(dist_to_detector, detector_angle, pixel_angle, rotation_angle);
            my_box = voxel_box([0;0;0], [3;3;3], @(e)1);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            image = detector.generate_image(array);
            image_p = detector.generate_image_p(array);
            tc.verifyEqual(image_p, image, 'AbsTol', 1e-14)
        end
    end
end