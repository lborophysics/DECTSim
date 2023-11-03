classdef voxel_array_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods
        function test_attributes(tc)
            % Define parameters
            centre = [0; 0; 0];
            object_dims = [10; 10; 10];
            voxel_size = 1;
            get_voxel_mu = @(i, j, k) i + j + k; % Define a simple function for testing
    
            % Instantiate voxel_array
            voxelObj = voxel_array_tests(centre, object_dims, voxel_size, get_voxel_mu);
    
            % Verify attributes
            tc.verifyEqual(voxelObj.array_position, [-5, -5, -5]);
            tc.verifyEqual(voxelObj.num_planes, [10, 10, 10]);
            tc.verifyEqual(voxelObj.dimensions, [1, 1, 1]);
            tc.verifyEqual(voxelObj.get_voxel_mu(1, 1, 1), 3);

            voxelObj = voxel_array_tests(centre, object_dims, 0.5, get_voxel_mu);
            tc.verifyEqual(voxelObj.array_position, [-5, -5, -5]);
            tc.verifyEqual(voxelObj.num_planes, [20, 20, 20]);
            tc.verifyEqual(voxelObj.dimensions, [0.5, 0.5, 0.5]);
            tc.verifyEqual(voxelObj.get_voxel_mu(1, 2, 3), 6);

            get_voxel_mu2 = @(i, j, k) i - j - k;
            voxelObj = voxel_array_tests(centre, object_dims, voxel_size, get_voxel_mu2);
            tc.verifyEqual(voxelObj.array_position, [-5, -5, -5]);
            tc.verifyEqual(voxelObj.num_planes, [10, 10, 10]);
            tc.verifyEqual(voxelObj.dimensions, [1, 1, 1]);
            tc.verifyEqual(voxelObj.get_voxel_mu(1, 2, 3), -4);

            voxelObj = voxel_array_tests([-5; 4; 0.5], object_dims, voxel_size, get_voxel_mu);
            tc.verifyEqual(voxelObj.array_position, [0, -1, -4.75]);
        end

    end

end