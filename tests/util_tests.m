classdef util_tests < matlab.unittest.TestCase

    methods (Test)
        function test_rotz(tc)
            R = rotz(pi/2);
            tc.verifyEqual(R, [0 -1 0; 1 0 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi/4);
            tc.verifyEqual(R, [sqrt(2)/2 -sqrt(2)/2 0; sqrt(2)/2 sqrt(2)/2 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi/6);
            tc.verifyEqual(R, [sqrt(3)/2 -1/2 0; 1/2 sqrt(3)/2 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi/3);
            tc.verifyEqual(R, [1/2 -sqrt(3)/2 0; sqrt(3)/2 1/2 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi);
            tc.verifyEqual(R, [-1 0 0; 0 -1 0; 0 0 1], 'AbsTol', 1e-15);
        end

        function test_roty(tc)
            R = roty(pi/2);
            tc.verifyEqual(R, [0 0 1; 0 1 0; -1 0 0], 'AbsTol', 1e-15);

            R = roty(pi/4);
            tc.verifyEqual(R, [sqrt(2)/2 0 sqrt(2)/2; 0 1 0; -sqrt(2)/2 0 sqrt(2)/2], 'AbsTol', 1e-15);

            R = roty(pi/6);
            tc.verifyEqual(R, [sqrt(3)/2 0 1/2; 0 1 0; -1/2 0 sqrt(3)/2], 'AbsTol', 1e-15);

            R = roty(pi/3);
            tc.verifyEqual(R, [1/2 0 sqrt(3)/2; 0 1 0; -sqrt(3)/2 0 1/2], 'AbsTol', 1e-15);

            R = roty(pi);
            tc.verifyEqual(R, [-1 0 0; 0 1 0; 0 0 -1], 'AbsTol', 1e-15);
        end
    end
end