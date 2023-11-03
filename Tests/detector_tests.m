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

            detector = curved_detector([1; 0; 0], 9, pi/2, 18);

            tc.verifyEqual(detector.vec_to_detector, [sqrt(2)/2; -sqrt(2)/2; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, 2);
            tc.verifyEqual(detector.detector_angle, pi/2);
        end

        function test_hit_pixel(tc)
            init_unit_vector = [1; 0; 0];
            detector = curved_detector([1; 0; 0], 90, pi/2, 18);

            rot_by_pixel = rotz(18/90);
            vec = rotz(-pi/4) * init_unit_vector;
            for i = 1:ceil((pi/2) / 18/90)
                tc.verifyEqual(detector.get_hit_pixel(vec), i);
                vec = rot_by_pixel * vec;
            end
        end

        % function test_rot
    end
end