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
            detector = parallel_detector([0; 0; 0], [1; 0; 0], 5, 11, 0.1);
            tc.verifyEqual(detector.pixel_width, 0.1);
            tc.verifyEqual(detector.width, 11);
            tc.verifyEqual(detector.centre, [5; 0; 0]);
            tc.verifyEqual(detector.num_pixels, int32(110));

            detector = detector.rotate_detector(pi/2);
            tc.verifyEqual(detector.pixel_width, 0.1);
            tc.verifyEqual(detector.width, 11);
            tc.verifyEqual(detector.centre, [0; 5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.num_pixels, int32(110));

            detector = parallel_detector([1; 2; 3], [1; 0; 0], 7, 14, 0.2); 
            tc.verifyEqual(detector.pixel_width, 0.2);
            tc.verifyEqual(detector.width, 14);
            tc.verifyEqual(detector.centre, [8; 2; 3]);
            tc.verifyEqual(detector.num_pixels, int32(70));

            detector = detector.rotate_detector(pi/4);
            tc.verifyEqual(detector.pixel_width, 0.2);
            tc.verifyEqual(detector.width, 14);
            tc.verifyEqual(detector.centre, 7 * [sqrt(2)/2; sqrt(2)/2; 0] + [1; 2; 3], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.num_pixels, int32(70));
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

        function test_hit_para_pixel(tc)
            unit_vector = [1; 0; 0];
            detector = parallel_detector([0;0;0], unit_vector, 5, 11, 0.1);

            trans_by_pixel = [0; 1; 0] * 0.1;
            start = [0; -5.45; 0];
            for i = 1:110
                my_ray = ray(start, unit_vector, 5);
                tc.verifyEqual(detector.get_hit_pixel(my_ray), i)
                start = start + trans_by_pixel;
            end
        end
             
    end
end