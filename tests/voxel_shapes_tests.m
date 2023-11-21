 classdef voxel_shapes_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function box(tc)
            my_box = voxel_box([0,0,0], 100);
            res = my_box(-100:0.5:100, -100:0.5:100, -100:0.5:100);
            exp = cat(2,zeros(1, 100), ones(1, 201), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)

            my_box = voxel_box([100, 100, 100], [200, 200, 100]);
            res = my_box(-100:300, -100:300, 50:0.25:150);
            exp = cat(2,zeros(1, 100), ones(1, 201), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)
        end

        function shepp_logan(tc)
            my_shepp1 = voxel_shepp_logan([0;0;0], 100, 1);
            my_shepp2 = voxel_shepp_logan([1;1;1], 20, 0.5);
            my_shepp3 = voxel_shepp_logan([0;0;0], 3000, 100);
            actual_shepp1 = phantom(100);
            actual_shepp2 = phantom(40);
            actual_shepp3 = phantom(30);

            tc.verifyEqual(my_shepp1(0, 0, "abc"), actual_shepp1(50, 50))
            tc.verifyEqual(my_shepp2(-6.8, -5.5, []), actual_shepp2(4, 7))
            tc.verifyEqual(my_shepp3(1810, 1720, 50), actual_shepp3(3, 2))
        end
    end

end