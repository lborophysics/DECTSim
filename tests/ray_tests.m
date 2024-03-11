classdef ray_tests < matlab.unittest.TestCase
    properties
        air
        lead
        water
        water_array
        lead_array
    end


    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup_test(tc)
            tc.air = material_attenuation("air");
            tc.lead = material_attenuation("lead", 82, 1, 11.34);
            tc.water = material_attenuation("water");
            abox = voxel_cube([0;0;0], [3;3;3], tc.water);
            tc.water_array = voxel_array(zeros(3, 1), [5; 5; 5], 1, {abox});
            abox = voxel_cube([0;0;0], [3;3;3], tc.lead);
            tc.lead_array = voxel_array(zeros(3, 1), [5; 5; 5], 1, {abox});
        end
    end
    methods (Test)
        % Test methods
        function test_siddon_ray(tc)
            threes = zeros(3, 5) + 3;

            voxels = tc.water_array;
            cached_ray_trace = @(start, v1to2) ray_trace(start, v1to2, ...
                voxels.array_position, voxels.dimensions, voxels.num_planes);
            [lengths, indices] = cached_ray_trace([-6;0;0], [1;0;0].*22);
            exp = threes; exp(1, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            [lengths, indices] = cached_ray_trace([0;-6;0], [0;1;0].*22);
            exp = threes; exp(2, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            [lengths, indices] = cached_ray_trace([0;0;-6], [0;0;1].*22);
            exp = threes; exp(3, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            [lengths, indices] = cached_ray_trace([-6;-6;0], [1;1;0].*20);
            exp = threes; exp(2, :) = [1, 2, 3, 4, 5]; exp(1, :) = [1, 2, 3, 4, 5];
            s2 = sqrt(2);
            tc.assertEqual(lengths, [s2, s2, s2, s2, s2], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            [lengths, indices] = cached_ray_trace([0;0;6], [0;0;-1].*22);
            exp = threes; exp(3, :) = [5, 4, 3, 2, 1];
            tc.assertEqual(lengths, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices, exp);

            [lengths, indices] = cached_ray_trace([6;6;6], [-1;-1;-1].*22);
            exp = [
                5, 4, 3, 2, 1;
                5, 4, 3, 2, 1;
                5, 4, 3, 2, 1
                ];
            s3 = sqrt(3);
            tc.assertEqual(lengths, [s3, s3, s3, s3, s3], 'AbsTol', 5e-15);
            tc.assertEqual(indices, exp);

            [lengths, indices] = cached_ray_trace([6;6;6], [1;1;1].*22);
            tc.assertEqual(lengths, []);
            tc.assertEqual(indices, []);
        end

        function test_many_siddon_ray(tc)
            threes = zeros(3, 5) + 3;

            voxels = tc.water_array;
            cached_ray_trace_many = @(start, v1to2) ray_trace_many(start, v1to2, ...
                voxels.array_position, voxels.dimensions, voxels.num_planes);

            [lengths, indices] = cached_ray_trace_many([-6;0;0], [1;0;0].*12);
            exp = threes; exp(1, :) = [1, 2, 3, 4, 5];
            tc.assertEqual(lengths{1}, [1, 1, 1, 1, 1], 'AbsTol', 2e-15);
            tc.assertEqual(indices{1}, exp);

            start_points = [-6,0,0; 0,-6,0; 0,0,-6; -6,-6,0; 0,0,6; 6,6,6; 6,6,6]';
            directions = [1,0,0; 0,1,0; 0,0,1; 1,1,0; 0,0,-1; -1,-1,-1; 1,1,1]';
            v1to2 = directions .* 22;
            [lengths, indices] = cached_ray_trace_many(start_points, v1to2);

            iexp1 = threes; iexp1(1, :) = [1, 2, 3, 4, 5];
            iexp2 = threes; iexp2(2, :) = [1, 2, 3, 4, 5];
            iexp3 = threes; iexp3(3, :) = [1, 2, 3, 4, 5];
            iexp4 = threes; iexp4(2, :) = [1, 2, 3, 4, 5]; iexp4(1, :) = [1, 2, 3, 4, 5];
            iexp5 = threes; iexp5(3, :) = [5, 4, 3, 2, 1];
            iexp6 = [
                5, 4, 3, 2, 1;
                5, 4, 3, 2, 1;
                5, 4, 3, 2, 1
                ];
            iexp7 = [];
            iexp = {iexp1, iexp2, iexp3, iexp4, iexp5, iexp6, iexp7};
            s3 = sqrt(3);
            s2 = sqrt(2);
            lexp1 = [1, 1, 1, 1, 1];
            lexp2 = [1, 1, 1, 1, 1];
            lexp3 = [1, 1, 1, 1, 1];
            lexp4 = [s2, s2, s2, s2, s2];
            lexp5 = [1, 1, 1, 1, 1];
            lexp6 = [s3, s3, s3, s3, s3];
            lexp7 = [];
            lexp = {lexp1, lexp2, lexp3, lexp4, lexp5, lexp6, lexp7};
            for i = 1:7
                tc.assertEqual(lengths{i}, lexp{i}, 'AbsTol', 5e-15);
                tc.assertEqual(indices{i}, iexp{i});
            end
        end

        % While scatter ray is not included in the project
        % function test_scatter_ray(tc)
        %     rng(1712345)
        %     energy = 300;
        %     start = [-6;0;0];
        %     direction = [1;0;0];
        %     dist_to_detector = 100;
        %     r  = ray(start, direction, dist_to_detector, tc.lead_array, energy);
        %
        %     mu = r.calculate_mu();
        %     [lengths, indices] = r.get_intersections(tc.lead_array);
        %     for i = 1:100
        %         rs = scatter_ray(start, direction, dist_to_detector, tc.lead_array, energy); % In loop so n_mfp is random
        %         nrs = rs.calculate_mu();
        %         total_mu = nrs.mu;
        %         if nrs.scatter_event == 1 % Check if it scattered once
        %
        %             mfp_dict = tc.lead_array.get_mfp_arr(energy);
        %             mfp = tc.lead_array.get_saved_mfp(indices, mfp_dict);
        %
        %             mu_dict = tc.lead_array.get_mu_arr(energy);
        %
        %             ray_n_mfp = lengths ./ mfp;
        %             ray_mu = lengths .* tc.lead_array.get_saved_mu(indices, mu_dict);
        %
        %             tc.assertTrue(sum(ray_n_mfp) > rs.n_mfp); % Check it should have scattered
        %             tc.assertTrue(nrs.energy < energy); % energy is lost in scatter
        %
        %             for j = 1:length(ray_n_mfp)
        %                 if sum(ray_n_mfp(1:j)) > rs.n_mfp
        %                     % The length of the scatter should be the sum of the lengths of the voxels minus
        %                     % the length within the voxel totalling the n_mfp
        %                     scatter_length = sum(lengths(1:j)) - (sum(ray_n_mfp(1:j)) - rs.n_mfp) * mfp(j);
        %                     uptoscatter_mu = sum(ray_mu(1:j)) - (sum(ray_n_mfp(1:j)) - rs.n_mfp) * mfp(j) * ray_mu(j);
        %                     break
        %                 end
        %             end
        %             tc.assertEqual(nrs.start_point, start + scatter_length .* direction, 'RelTol', 1e-14, 'AbsTol', 1e-15);
        %
        %             scattered_ray = ray(nrs.start_point, nrs.direction, dist_to_detector, tc.lead_array, nrs.energy);
        %             scatter_mu = scattered_ray.calculate_mu();
        %             tc.assertEqual(total_mu, scatter_mu + uptoscatter_mu, 'RelTol', 1e-14, 'AbsTol', 1e-14);
        %
        %             tc.assertNotEqual(nrs.n_mfp, rs.n_mfp); % n_mfp should have changed
        %             tc.assertNotEqual(nrs.direction, direction); % direction should have changed
        %         elseif nrs.scatter_event == 0 % If no scatter - should be the same
        %             tc.assertEqual(total_mu, mu);
        %             tc.assertEqual(nrs.energy, energy);
        %             tc.assertEqual(nrs.start_point, start);
        %             tc.assertEqual(nrs.direction, direction);
        %             tc.assertEqual(nrs.end_point, start + dist_to_detector * direction);
        %         end
        %     end
        %     r = ray([0;0;0], [1;0;0], 10, tc.lead_array);
        %     rs = scatter_ray([0;0;0], [1;0;0], 10, tc.lead_array);
        %     tc.assertEqual(r.energy, rs.energy); % Check the default energy is the same
        % end

    end
end