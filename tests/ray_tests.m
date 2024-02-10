classdef ray_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods
        function gen_get_intersections(tc, ray)
            water = material_attenuation("water"); 
            my_box = voxel_cube([0;0;0], [3;3;3], water);
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
            tc.assertEqual(r.v1_to_v2, [10;0;0]);
            tc.assertEqual(r.energy, 30); % default energy - may change later

            r2 = ray([0;-5;0], [0;1;0], 10, 100);
            tc.assertEqual(r2.start_point, [0;-5;0]);
            tc.assertEqual(r2.v1_to_v2, [0;10;0]);
            tc.assertEqual(r2.energy, 100);
        end

        function test_siddon_ray(tc)
            tc.gen_get_intersections(@ray);
        end

        function test_calculate_mu(tc)
            water = material_attenuation("water");
            my_box = voxel_cube([0;0;0], [3;3;3], water);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            water_attenuation = water.get_mu(30); % Default value of ray
            % voxel_array.air
            % array.air
            % air= material_attenuation("air");
            % air_attenuation = air.get_mu(30);

            r = ray([-6;0;0], [1;0;0], 12);
            tc.assertEqual(r.calculate_mu(array), 3*water_attenuation, "RelTol", 3e-16);

            r = ray([0;-6;0], [0;1;0], 12);
            tc.assertEqual(r.calculate_mu(array), 3*water_attenuation, "RelTol", 3e-16);

            r = ray([0;0;-6], [0;0;1], 12);
            tc.assertEqual(r.calculate_mu(array), 3*water_attenuation, "RelTol", 3e-16);

            r = ray([6;6;6], [-1;-1;-1], 22); % 3D diagonal backwards
            tc.assertEqual(r.calculate_mu(array), 3*sqrt(3)*water_attenuation, "RelTol", 4e-16);

            r = ray([6;6;6], [1;1;1], 22); % 3D diagonal away
            tc.assertEqual(r.calculate_mu(array), 0);
        end

        function test_scatter_ray(tc)
            rng(1712345)
            energy = 300;
            start = [-6;0;0];
            direction = [1;0;0];
            dist_to_detector = 100;
            r  = ray(start, direction, dist_to_detector, energy);
            
            lead = material_attenuation("lead", 82, 1, 11.34); % Dense -> Likely to scatter
            my_box = voxel_cube([0;0;0], [3;3;3], lead);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            
            mu = r.calculate_mu(array);
            [lengths, indices] = r.get_intersections(array);
            for i = 1:100
                rs = scatter_ray(start, direction, dist_to_detector, energy); % In loop so n_mfp is random
                nrs = rs.calculate_mu(array);
                total_mu = nrs.mu;
                if nrs.scatter_event == 1 % Check if it scattered once

                    mfp_dict = array.get_mfp_dict(energy);
                    mfp = array.get_saved_mfp(indices, mfp_dict);

                    mu_dict = array.get_mu_dict(energy);

                    ray_n_mfp = lengths ./ mfp;
                    ray_mu = lengths .* array.get_saved_mu(indices, mu_dict);

                    tc.assertTrue(sum(ray_n_mfp) > rs.n_mfp); % Check it should have scattered
                    tc.assertTrue(nrs.energy < energy); % energy is lost in scatter

                    for j = 1:length(ray_n_mfp)
                        if sum(ray_n_mfp(1:j)) > rs.n_mfp
                            % The length of the scatter should be the sum of the lengths of the voxels minus
                            % the length within the voxel totalling the n_mfp
                            scatter_length = sum(lengths(1:j)) - (sum(ray_n_mfp(1:j)) - rs.n_mfp) * mfp(j);
                            uptoscatter_mu = sum(ray_mu(1:j)) - (sum(ray_n_mfp(1:j)) - rs.n_mfp) * mfp(j) * ray_mu(j);
                            break
                        end
                    end
                    tc.assertEqual(nrs.start_point, start + scatter_length .* direction, 'RelTol', 1e-14, 'AbsTol', 1e-15);

                    scattered_ray = ray(nrs.start_point, nrs.direction, dist_to_detector, nrs.energy);
                    scatter_mu = scattered_ray.calculate_mu(array);
                    tc.assertEqual(total_mu, scatter_mu + uptoscatter_mu, 'RelTol', 1e-14, 'AbsTol', 1e-14);

                    tc.assertNotEqual(nrs.n_mfp, rs.n_mfp); % n_mfp should have changed
                    tc.assertNotEqual(nrs.direction, direction); % direction should have changed
                elseif nrs.scatter_event == 0 % If no scatter - should be the same
                    tc.assertEqual(total_mu, mu);
                    tc.assertEqual(nrs.energy, energy);
                    tc.assertEqual(nrs.start_point, start);
                    tc.assertEqual(nrs.direction, direction);
                    tc.assertEqual(nrs.end_point, start + dist_to_detector * direction);
                end
            end
        end

    end
end