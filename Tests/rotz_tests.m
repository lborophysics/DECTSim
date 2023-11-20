classdef rotz_tests < matlab.unittest.TestCase

    methods (Test)
        function test_rotz(testCase)
            R = rotz(pi/2);
            testCase.verifyEqual(R, [0 -1 0; 1 0 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi/4);
            testCase.verifyEqual(R, [sqrt(2)/2 -sqrt(2)/2 0; sqrt(2)/2 sqrt(2)/2 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi/6);
            testCase.verifyEqual(R, [sqrt(3)/2 -1/2 0; 1/2 sqrt(3)/2 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi/3);
            testCase.verifyEqual(R, [1/2 -sqrt(3)/2 0; sqrt(3)/2 1/2 0; 0 0 1], 'AbsTol', 1e-15);

            R = rotz(pi);
            testCase.verifyEqual(R, [-1 0 0; 0 -1 0; 0 0 1], 'AbsTol', 1e-15);
        end
    end
end