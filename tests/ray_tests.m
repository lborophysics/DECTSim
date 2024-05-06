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

        function test_siddon_ray_reversability(tc)
            % Voxel array constants
            vox_arr_center = zeros(3, 1);
            phantom_radius = 30/2 * units.cm; % In the x-y planex
            phantom_width = 50 * units.cm; % In the z direction
            voxel_size = 1 * units.mm;

            % Create voxel array
            water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
            voxels = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
                voxel_size, {water_cylinder});

            % Detector constants
            dist_to_detector = 1.05 * units.m;
            pixel_size = [1 1] .* units.mm;
            num_pixels = [900 1];
            num_rotations = 360;

            dgantry = parallel_gantry(dist_to_detector, num_rotations, 2*pi);
            darray = flat_detector(pixel_size, num_pixels);
            
            pixels_45 = darray.set_array_angle(dgantry, 43);
            pixels_45 = reshape(pixels_45, 3, num_pixels(1), num_pixels(2));
            pixels_135 = darray.set_array_angle(dgantry, 137);
            pixels_135 = reshape(pixels_135, 3, num_pixels(1), num_pixels(2));
            pixels_225 = darray.set_array_angle(dgantry, 222);
            pixels_225 = reshape(pixels_225, 3, num_pixels(1), num_pixels(2));
            pixels_315 = darray.set_array_angle(dgantry, 318);
            pixels_315 = reshape(pixels_315, 3, num_pixels(1), num_pixels(2));

            pixel360_45  = pixels_45(:, 360, 1);
            pixel360_135 = pixels_135(:, 360, 1);
            pixel360_225 = pixels_225(:, 143, 1);
            pixel360_315 = pixels_315(:, 670, 1);

            ray_start_45 = dgantry.get_source_pos(43, 0);
            ray_start_135 = dgantry.get_source_pos(137, 0);
            ray_start_225 = dgantry.get_source_pos(222, 0);
            ray_start_315 = dgantry.get_source_pos(318, 0);

            ray_dir_45 = pixel360_45 - ray_start_45;
            ray_dir_135 = pixel360_135 - ray_start_135;
            ray_dir_225 = pixel360_225 - ray_start_225;
            ray_dir_315 = pixel360_315 - ray_start_315;

            vox_init    = voxels.array_position;
            vox_dims    = voxels.dimensions;
            vox_nplanes = voxels.num_planes;

            [lengths_45, indices_45] = ray_trace(ray_start_45, ray_dir_45, vox_init, vox_dims, vox_nplanes);
            [rev_lengths_45, rev_indices_45] = ray_trace(pixel360_45, -ray_dir_45, vox_init, vox_dims, vox_nplanes);

            tc.assertEqual(sum(lengths_45), sum(rev_lengths_45), 'AbsTol', 1e-13, 'RelTol', 2e-12);
            tc.assertEqual(lengths_45, flip(rev_lengths_45, 2), 'AbsTol', 1e-10, 'RelTol', 1e-12);
            tc.assertEqual(indices_45, flip(rev_indices_45, 2), 'AbsTol', 1e-13, 'RelTol', 1e-12);

            [lengths_135, indices_135] = ray_trace(ray_start_135, ray_dir_135, vox_init, vox_dims, vox_nplanes);
            [rev_lengths_135, rev_indices_135] = ray_trace(pixel360_135, -ray_dir_135, vox_init, vox_dims, vox_nplanes);
            
            tc.assertEqual(sum(lengths_135), sum(rev_lengths_135), 'AbsTol', 1e-13, 'RelTol', 2e-12);
            tc.assertEqual(lengths_135, flip(rev_lengths_135, 2), 'AbsTol', 1e-10, 'RelTol', 1e-12);
            tc.assertEqual(indices_135, flip(rev_indices_135, 2), 'AbsTol', 1e-13, 'RelTol', 1e-12);

            [lengths_225, indices_225] = ray_trace(ray_start_225, ray_dir_225, vox_init, vox_dims, vox_nplanes);
            [rev_lengths_225, rev_indices_225] = ray_trace(pixel360_225, -ray_dir_225, vox_init, vox_dims, vox_nplanes);
            
            tc.assertEqual(sum(lengths_225), sum(rev_lengths_225), 'AbsTol', 1e-13, 'RelTol', 2e-10);
            tc.assertEqual(lengths_225, flip(rev_lengths_225, 2), 'AbsTol', 1e-9, 'RelTol', 1e-12);
            tc.assertEqual(indices_225, flip(rev_indices_225, 2), 'AbsTol', 1e-13, 'RelTol', 1e-12);

            [lengths_315, indices_315] = ray_trace(ray_start_315, ray_dir_315, vox_init, vox_dims, vox_nplanes);
            [rev_lengths_315, rev_indices_315] = ray_trace(pixel360_315, -ray_dir_315, vox_init, vox_dims, vox_nplanes);

            tc.assertEqual(sum(lengths_315), sum(rev_lengths_315), 'AbsTol', 1e-13, 'RelTol', 3e-12);
            tc.assertEqual(lengths_315, flip(rev_lengths_315, 2), 'AbsTol', 1e-10, 'RelTol', 1e-12);
            tc.assertEqual(indices_315, flip(rev_indices_315, 2), 'AbsTol', 1e-13, 'RelTol', 1e-12);
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
    end
end