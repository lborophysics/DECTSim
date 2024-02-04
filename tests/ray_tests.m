classdef ray_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods
        function gen_get_intersections(tc, ray)
            my_box = voxel_box([0;0;0], [3;3;3]);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            threes = zeros(3, 5) + 3;
            
            r = ray([-6;0;0], [1;0;0], 12);
            [lengths, indices] = r.get_intersections(array);
            exp = threes; exp(1, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            r = ray([0;-6;0], [0;1;0], 12);
            [lengths, indices] = r.get_intersections(array);
            exp = threes; exp(2, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            r = ray([0;0;-6], [0;0;1], 12);
            [lengths, indices] = r.get_intersections(array);
            exp = threes; exp(3, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            r = ray([-6;-6;0], [1;1;0], 20);
            [lengths, indices] = r.get_intersections(array);
            exp = threes; exp(2, :) = [1, 2, 3, 4, 5]; exp(1, :) = [1, 2, 3, 4, 5];
            s2 = sqrt(2);
            tc.assertEqual(lengths, [s2, s2, s2, s2, s2], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            r = ray([0;0;-6], [0;0;1], 12);
            [lengths, indices] = r.get_intersections(array);
            exp = threes; exp(3, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            r = ray([6;6;6], [-1;-1;-1], 22); % 3D diagonal backwards
            [lengths, indices] = r.get_intersections(array);
            exp = [
                5, 4, 3, 2, 1;
                5, 4, 3, 2, 1;
                5, 4, 3, 2, 1
            ];
            s3 = sqrt(3);
            tc.assertEqual(lengths, [s3, s3, s3, s3, s3], 'AbsTol', 5e-15);
            tc.assertEqual(indices, exp);

            r = ray([6;6;6], [1;1;1], 22); % 3D diagonal away
            [lengths, indices] = r.get_intersections(array);
            tc.assertEqual(lengths, []);
            tc.assertEqual(indices, []);
        end
    end

    methods (Test)
        % Test methods
        function test_ray_init(tc)
            r = ray([0;0;0], [1;0;0], 10);
            tc.assertEqual(r.start_point, [0;0;0]);
            tc.assertEqual(r.direction, [1;0;0]);
            tc.assertEqual(r.end_point, [10;0;0]);
            tc.assertEqual(r.energy, 100); % default energy - may change later

            r2 = ray([0;-5;0], [0;1;0], 10);
            tc.assertEqual(r2.start_point, [0;-5;0]);
            tc.assertEqual(r2.direction, [0;1;0]);
            tc.assertEqual(r2.end_point, [0;5;0]);
            tc.assertEqual(r2.energy, 100); % default energy - may change later
        end

        function test_siddon_ray(tc)
            tc.gen_get_intersections(@ray);
        end

        function test_calculate_mu(tc)
            water = get_material("water");
            my_box = voxel_box([0;0;0], [3;3;3], water);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            voxel_attenuation = water.get_mu(100/1000); % Default value of ray
            
            r = ray([-6;0;0], [1;0;0], 12);
            tc.assertEqual(r.calculate_mu(array), 3*voxel_attenuation, "RelTol", 3e-16);

            r = ray([0;-6;0], [0;1;0], 12);
            tc.assertEqual(r.calculate_mu(array), 3*voxel_attenuation, "RelTol", 3e-16);

            r = ray([0;0;-6], [0;0;1], 12);
            tc.assertEqual(r.calculate_mu(array), 3*voxel_attenuation, "RelTol", 3e-16);
            
            r = ray([6;6;6], [-1;-1;-1], 22); % 3D diagonal backwards
            tc.assertEqual(r.calculate_mu(array), 3*sqrt(3)*voxel_attenuation, "RelTol", 4e-16);

            r = ray([6;6;6], [1;1;1], 22); % 3D diagonal away
            tc.assertEqual(r.calculate_mu(array), 0);
        end

        function test_update_parameters(tc)
            r = ray([0;0;0], [1;0;0], 10);
            r = r.update_parameters([1;0;0], [0;1;0]);
            tc.assertEqual(r.start_point, [1;0;0]);
            tc.assertEqual(r.direction, [0;1;0]);
            tc.assertEqual(r.end_point, [1;10;0]);
            tc.assertEqual(r.energy, 100); % default energy - may change later

            r = ray([0;0;0], [1;0;0], 5);
            r = r.update_parameters([0;0;1], [0;0;1]);
            tc.assertEqual(r.start_point, [0;0;1]);
            tc.assertEqual(r.direction, [0;0;1]);
            tc.assertEqual(r.end_point, [0;0;6]);
            tc.assertEqual(r.energy, 100); % default energy - may change later
        end

        function test_move_start_point(tc)
            r = ray([0;0;0], [1;0;0], 10);
            r = r.move_start_point([1;0;0]);
            tc.assertEqual(r.start_point, [1;0;0]);
            tc.assertEqual(r.direction, [1;0;0]);
            tc.assertEqual(r.end_point, [11;0;0]);
            tc.assertEqual(r.energy, 100); % default energy - may change later

            r = ray([0;0;0], [1;0;0], 10);
            r = r.move_start_point([0;0;1]);
            tc.assertEqual(r.start_point, [0;0;1]);
            tc.assertEqual(r.direction, [1;0;0]);
            tc.assertEqual(r.end_point, [10;0;1]);
            tc.assertEqual(r.energy, 100); % default energy - may change later
        end
    end
end