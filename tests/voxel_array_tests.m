classdef voxel_array_tests < matlab.unittest.TestCase
    properties
        test_obj1
        test_obj2
        test_obj3
        test_obj4
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup (tc)
            centre = [0; 0; 0];
            object_dims = [10; 10; 10];
            material1 = get_material("water");
            material1.get_mu = @(i, j, k, e) i + j + k + e; % Define a simple function for testing
            material2 = get_material("water");
            material2.get_mu = @(i, j, k, e) i - j - k + e; % Define a simple function for testing
            tc.test_obj1 = voxel_array(centre, object_dims, 1, material1);
            tc.test_obj2 = voxel_array(centre, object_dims, 0.5, material1);
            tc.test_obj3 = voxel_array(centre, object_dims, 1, material2);
            tc.test_obj4 = voxel_array([5; 4; 0.5], object_dims, 1, material1);
        end
    end

    methods (Test)
        % Test methods
        function test_attributes(tc)
            % Verify attributes
            water = get_material("water"); water_id = water.id;
            tc.verifyEqual(tc.test_obj1.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj1.num_planes, [11; 11; 11]);
            tc.verifyEqual(tc.test_obj1.dimensions, [1; 1; 1]);
            tc.verifyEqual(tc.test_obj1.voxel_obj.id, water_id);
            tc.verifyEqual(tc.test_obj1.voxel_obj.get_mu(1, 1, 1, 0), 3);

            tc.verifyEqual(tc.test_obj2.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj2.num_planes, [21; 21; 21]);
            tc.verifyEqual(tc.test_obj2.dimensions, [0.5; 0.5; 0.5]);
            tc.verifyEqual(tc.test_obj2.voxel_obj.get_mu(1, 2, 3, 4), 10);

            tc.verifyEqual(tc.test_obj3.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj3.num_planes, [11; 11; 11]);
            tc.verifyEqual(tc.test_obj3.dimensions, [1; 1; 1]);
            tc.verifyEqual(tc.test_obj3.voxel_obj.get_mu(1, 2, 3, -3), -7);

            tc.verifyEqual(tc.test_obj4.array_position, [0; -1; -4.5]);
            tc.verifyEqual(tc.test_obj4.num_planes, [11; 11; 11]);
            tc.verifyEqual(tc.test_obj4.dimensions, [1; 1; 1]);
            tc.verifyEqual(tc.test_obj4.voxel_obj.get_mu(1, 2, 3, 1), 7);            
        end

        function test_get_point_position(tc)
            % Verify get_point_position
            tc.verifyEqual(tc.test_obj1.get_point_position([1; 1; 1]), [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj1.get_point_position([1; 2; 3]), [-5; -4; -3]);
            tc.verifyEqual(tc.test_obj1.get_point_position([11; 10; 9]), [5; 4; 3]);
            tc.verifyEqual(tc.test_obj1.get_points_position(...
            [1, 1, 11], [1, 2, 10], [1, 3, 9]), [-5, -5, 5; -5, -4, 4; -5, -3, 3;]);
            
            tc.verifyEqual(tc.test_obj2.get_point_position([1; 1; 1]), [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj2.get_point_position([1; 2; 3]), [-5; -4.5; -4]);
            tc.verifyEqual(tc.test_obj2.get_point_position([21; 20; 19]), [5; 4.5; 4]);
            tc.verifyEqual(tc.test_obj2.get_points_position(...
            [1, 1, 21], [1, 2, 20], [1, 3, 19]), [-5, -5, 5; -5, -4.5, 4.5; -5, -4, 4;]);

            tc.verifyEqual(tc.test_obj3.get_point_position([1; 1; 1]), [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj3.get_point_position([1; 2; 3]), [-5; -4; -3]);
            tc.verifyEqual(tc.test_obj3.get_point_position([10; 9; 8]), [4; 3; 2]);
            tc.verifyEqual(tc.test_obj3.get_points_position(...
            [1, 1, 10], [1, 2, 9], [1, 3, 8]), [-5, -5, 4; -5, -4, 3; -5, -3, 2;]);

            tc.verifyEqual(tc.test_obj4.get_point_position([1; 1; 1]), [0; -1; -4.5]);
            tc.verifyEqual(tc.test_obj4.get_point_position([1; 2; 3]), [0; 0; -2.5]);
            tc.verifyEqual(tc.test_obj4.get_point_position([10; 9; 8]), [9; 7; 2.5]);
            tc.verifyEqual(tc.test_obj4.get_points_position(...
            [1, 1, 10], [1, 2, 9], [1, 3, 8]), [0, 0, 9; -1, 0, 7; -4.5, -2.5, 2.5;]);
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
            for i = 1:3
                for j = 10:12
                    for k = 5:7
                        for e = -1:1:1
                            ijk1 = tc.test_obj1.get_point_position([i; j; k]) + tc.test_obj1.dimensions/2;
                            ijk2 = tc.test_obj2.get_point_position([i; j; k]) + tc.test_obj2.dimensions/2;
                            ijk3 = tc.test_obj3.get_point_position([i; j; k]) + tc.test_obj3.dimensions/2;
                            ijk4 = tc.test_obj4.get_point_position([i; j; k]) + tc.test_obj4.dimensions/2;

                            tc.verifyEqual(tc.test_obj1.get_mu(i, j, k, e), ijk1(1) + ijk1(2) + ijk1(3) + e);
                            tc.verifyEqual(tc.test_obj2.get_mu(i, j, k, e), ijk2(1) + ijk2(2) + ijk2(3) + e);
                            tc.verifyEqual(tc.test_obj3.get_mu(i, j, k, e), ijk3(1) - ijk3(2) - ijk3(3) + e);
                            tc.verifyEqual(tc.test_obj4.get_mu(i, j, k, e), ijk4(1) + ijk4(2) + ijk4(3) + e);
                        end
                    end
                end
            end
        end
    end

end