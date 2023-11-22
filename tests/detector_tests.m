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
            detector = curved_detector([0; 1; 0], 15, pi, 20);
            tc.verifyEqual(detector.vec_to_detector, [1; 0; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, 20/15);
            tc.verifyEqual(detector.detector_angle, pi);

            detector = detector.move_detector([1; 0; 0]);
            tc.verifyEqual(detector.vec_to_detector, [0; -1; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, 20/15);
            tc.verifyEqual(detector.detector_angle, pi);

            detector = curved_detector([1; 0; 0], 9, pi/2, 18);
            tc.verifyEqual(detector.vec_to_detector, [sqrt(2)/2; -sqrt(2)/2; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, 2);
            tc.verifyEqual(detector.detector_angle, pi/2);

            detector = detector.move_detector([0; 1; 0]);
            tc.verifyEqual(detector.vec_to_detector, [sqrt(2)/2; sqrt(2)/2; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, 2);
            tc.verifyEqual(detector.detector_angle, pi/2);
        end

        function test_parallel_init(tc)
            detector = parallel_detector(5, 11, 0.1, pi/2);
            tc.verifyEqual(detector.pixel_width, 0.1);
            tc.verifyEqual(detector.width, 11);
            tc.verifyEqual(detector.centre, [0; -2.5; 0]);
            tc.verifyEqual(detector.num_pixels, 110);

            detector = detector.rotate();
            tc.verifyEqual(detector.pixel_width, 0.1);
            tc.verifyEqual(detector.width, 11);
            tc.verifyEqual(detector.centre, [2.5; 0; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.num_pixels, 110);

            detector = parallel_detector(7, 14, 0.2, pi/4); 
            tc.verifyEqual(detector.pixel_width, 0.2);
            tc.verifyEqual(detector.width, 14);
            tc.verifyEqual(detector.centre, [0; -3.5; 0]);
            tc.verifyEqual(detector.num_pixels, 70);

            detector = detector.rotate();
            tc.verifyEqual(detector.pixel_width, 0.2);
            tc.verifyEqual(detector.width, 14);
            tc.verifyEqual(detector.centre, [sqrt(2)/2; -sqrt(2)/2; 0]*3.5, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.num_pixels, 70);
        end

        function test_hit_curved_pixel(tc)
            init_unit_vector = [1; 0; 0];
            detector = curved_detector([1; 0; 0], 90, pi/2, 18);

            rot_by_pixel = rotz(18/90);
            vec = rotz(-pi/4) * init_unit_vector;
            for i = 1:ceil((pi/2) / 18/90)
                tc.verifyEqual(detector.get_hit_pixel(vec), i);
                vec = rot_by_pixel * vec;
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
            my_box = voxel_box([0;0;0], [3;3;3]);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            sq2 = sqrt(2);
            
            image = detector.generate_image(array);
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;1/sq2;1/sq2;1/sq2;0], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [1-2*sq2/3;1-sq2/3;1;1-sq2/3;1-2*sq2/3], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 3), [0;1/sq2;1/sq2;1/sq2;0], 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [1-2*sq2/3;1-sq2/3;1;1-sq2/3;1-2*sq2/3], 'AbsTol', 1e-15);
        end
    end
end