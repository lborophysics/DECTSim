classdef voxel_shapes < matlab.unittest.TestCase

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
            res = my_box(-100:100, -100:100, -100:100);
            exp = cat(2,zeros(1, 50), ones(1, 101), zeros(1, 50)); %101 includes 0
            tc.verifyEqual(res, exp)

            my_box = voxel_box([100, 100, 100], [200, 200, 100]);
            res = my_box(-100:300, -100:300, 50:0.25:150);
            exp = cat(2,zeros(1, 100), ones(1, 201), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)
        end

        function shepp_logan(tc)
            my_shepp1 = voxel_shepp_logan(100);
            my_shepp2 = voxel_shepp_logan(20);
            my_shepp3 = voxel_shepp_logan(3000);
            actual_shepp1 = phantom(100);
            actual_shepp2 = phantom(20);
            actual_shepp3 = phantom(3000);

            for i = 1:20
                for j = 1:20
                    tc.verifyEqual(my_shepp1(i, j, "abc"), actual_shepp1(i, j))
                    tc.verifyEqual(my_shepp2(i, j, []), actual_shepp2(i, j))
                    tc.verifyEqual(my_shepp3(i*10, j*10, 50), actual_shepp3(i*10, j*10))
                end
            end
        end
    end

end