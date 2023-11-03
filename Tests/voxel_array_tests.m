classdef voxel_array_tests < matlab.unittest.TestCase
    properties
        test_obj1
        test_obj2
        test_obj3
        test_obj4
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup (tc)
            centre = [0; 0; 0];
            object_dims = [10; 10; 10];
            get_voxel_mu1 = @(i, j, k) i + j + k; % Define a simple function for testing
            get_voxel_mu2 = @(i, j, k) i - j - k; % Define a simple function for testing
            tc.test_obj1 = voxel_array(centre, object_dims, 1, get_voxel_mu1);
            tc.test_obj2 = voxel_array(centre, object_dims, 0.5, get_voxel_mu1);
            tc.test_obj3 = voxel_array(centre, object_dims, 1, get_voxel_mu2);
            tc.test_obj4 = voxel_array([5; 4; 0.5], object_dims, 1, get_voxel_mu1);
        end
    end

    methods (Test)
        % Test methods
        function test_attributes(tc)
            % Verify attributes
            tc.verifyEqual(tc.test_obj1.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj1.num_planes, [10; 10; 10]);
            tc.verifyEqual(tc.test_obj1.dimensions, [1; 1; 1]);
            tc.verifyEqual(tc.test_obj1.get_voxel_mu(1, 1, 1), 3);

            tc.verifyEqual(tc.test_obj2.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj2.num_planes, [20; 20; 20]);
            tc.verifyEqual(tc.test_obj2.dimensions, [0.5; 0.5; 0.5]);
            tc.verifyEqual(tc.test_obj2.get_voxel_mu(1, 2, 3), 6);

            tc.verifyEqual(tc.test_obj3.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj3.num_planes, [10; 10; 10]);
            tc.verifyEqual(tc.test_obj3.dimensions, [1; 1; 1]);
            tc.verifyEqual(tc.test_obj3.get_voxel_mu(1, 2, 3), -4);

            tc.verifyEqual(tc.test_obj4.array_position, [0; -1; -4.5]);
            tc.verifyEqual(tc.test_obj4.num_planes, [10; 10; 10]);
            tc.verifyEqual(tc.test_obj4.dimensions, [1; 1; 1]);
            tc.verifyEqual(tc.test_obj4.get_voxel_mu(1, 2, 3), 6);            
        end

        function test_get_point_position(tc)
            % Verify get_point_position
            tc.verifyEqual(tc.test_obj1.get_point_position(1, 1, 1), [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj1.get_point_position(1, 2, 3), [-5; -4; -3]);
            tc.verifyEqual(tc.test_obj1.get_point_position(10, 9, 8), [4; 3; 2]);

            tc.verifyEqual(tc.test_obj2.get_point_position(1, 1, 1), [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj2.get_point_position(1, 2, 3), [-5; -4.5; -4]);
            tc.verifyEqual(tc.test_obj2.get_point_position(20, 19, 18), [4.5; 4; 3.5]);

            tc.verifyEqual(tc.test_obj3.get_point_position(1, 1, 1), [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj3.get_point_position(1, 2, 3), [-5; -4; -3]);
            tc.verifyEqual(tc.test_obj3.get_point_position(10, 9, 8), [4; 3; 2]);

            tc.verifyEqual(tc.test_obj4.get_point_position(1, 1, 1), [0; -1; -4.5]);
            tc.verifyEqual(tc.test_obj4.get_point_position(1, 2, 3), [0; 0; -2.5]);
            tc.verifyEqual(tc.test_obj4.get_point_position(10, 9, 8), [9; 7; 2.5]);
        end

        function test_get_single_coord(tc)
            % Verify get_single_coord
            tc.verifyEqual(tc.test_obj1.get_single_coord(1, 1), -5);
            tc.verifyEqual(tc.test_obj1.get_single_coord(2, 2), -4);
            tc.verifyEqual(tc.test_obj1.get_single_coord(3, 10), 4);

            tc.verifyEqual(tc.test_obj2.get_single_coord(1, 11), 0);
            tc.verifyEqual(tc.test_obj2.get_single_coord(2, 12), 0.5);
            tc.verifyEqual(tc.test_obj2.get_single_coord(3, 20), 4.5);

            tc.verifyEqual(tc.test_obj3.get_single_coord(1, 4), -2);
            tc.verifyEqual(tc.test_obj3.get_single_coord(2, 5), -1);
            tc.verifyEqual(tc.test_obj3.get_single_coord(3, 8), 2);

            tc.verifyEqual(tc.test_obj4.get_single_coord(1, 1), 0);
            tc.verifyEqual(tc.test_obj4.get_single_coord(2, 2), 0);
            tc.verifyEqual(tc.test_obj4.get_single_coord(3, 3), -2.5);

            tc.verifyError(@() tc.test_obj1.get_single_coord(4, 1), 'assert:failure', 'coord must be between 1 and 3');
        end

        function test_get_mu(tc)
            for i = 1:10
                for j = 15:25
                    for k = 5:11
                        tc.verifyEqual(tc.test_obj1.get_mu(i, j, k), i + j + k);
                        tc.verifyEqual(tc.test_obj2.get_mu(i, j, k), i + j + k);
                        tc.verifyEqual(tc.test_obj3.get_mu(i, j, k), i - j - k);
                        tc.verifyEqual(tc.test_obj4.get_mu(i, j, k), i + j + k);
                    end
                end
            end
        end
    end

end