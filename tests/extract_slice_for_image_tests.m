classdef extract_slice_for_image_tests < matlab.unittest.TestCase

    methods (Test)
        function test_dimensions_and_alpha(tc)
            phantom = voxel_array([0; 0; 0], [4; 6; 2], 1, {});

            [preview, alpha] = extract_slice_for_image(phantom);

            tc.verifyEqual(alpha, zeros(6, 4));
            tc.verifyEqual(preview, zeros(6, 4));
        end

        function test_uniform_foreground(tc)
            object = voxel_cube([0; 0; 0], 4, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {object});

            [preview, alpha] = extract_slice_for_image(phantom);

            tc.verifyEqual(preview, 0.5 * ones(4, 4));
            tc.verifyEqual(alpha, ones(4, 4));
        end

        function test_x_axis_orientation(tc)
            object = voxel_object(@(x, y, z) x <= 0, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {object});

            [~, alpha] = extract_slice_for_image(phantom);

            tc.verifyEqual(alpha(:, 1:2), ones(4, 2));
            tc.verifyEqual(alpha(:, 3:4), zeros(4, 2));
        end

        function test_y_axis_orientation(tc)
            object = voxel_object(@(x, y, z) y <= 0, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {object});

            [~, alpha] = extract_slice_for_image(phantom);

            tc.verifyEqual(alpha(1:2, :), zeros(2, 4));
            tc.verifyEqual(alpha(3:4, :), ones(2, 4));
        end

        function test_denser_material_maps_to_lighter_grey(tc)
            water = voxel_cube([0; 0; 0], 4, material_attenuation("water"));
            bone = voxel_cube([0; 0; 0], 2, material_attenuation("bone"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {water, bone});

            [preview, ~] = extract_slice_for_image(phantom);

            water_pixels = preview([1, 4], [1, 4]);
            bone_pixels = preview(2:3, 2:3);

            tc.verifyEqual(water_pixels, 0.15 * ones(2, 2), "AbsTol", eps);
            tc.verifyEqual(bone_pixels, 0.85 * ones(2, 2), "AbsTol", eps);
        end

        function test_only_central_z_slice_is_sampled(tc)
            off_centre_object = voxel_object( ...
                @(x, y, z) z < -0.5, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 3], 1, {off_centre_object});

            [~, alpha] = extract_slice_for_image(phantom);

            tc.verifyEqual(alpha, zeros(4, 4));

            centred_object = voxel_object( ...
                @(x, y, z) abs(z) <= 0.5, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 3], 1, {centred_object});
            [~, alpha] = extract_slice_for_image(phantom);

            tc.verifyEqual(alpha, ones(4, 4));
        end

        function test_custom_slice_selection(tc)
            object = voxel_object( ...
                @(x, y, z) z < -0.5, ...
                material_attenuation("water"));

            phantom = voxel_array( ...
                [0; 0; 0], [4; 4; 3], 1, {object});

            % Central slice should be empty.
            [~, central_alpha] = extract_slice_for_image(phantom);

            % First slice should contain the object.
            [~, first_alpha] = extract_slice_for_image( ...
                phantom, slice=1);

            tc.verifyEqual(central_alpha, zeros(4, 4));
            tc.verifyEqual(first_alpha, ones(4, 4));
        end

        function test_invalid_slice(tc)
            % Create a phantom with three z slices.
            phantom = voxel_array( ...
                [0; 0; 0], [4; 4; 3], 1, {});

            % Check invalid slice values.
            invalid_slices = [0, 4, 1.5, NaN, Inf, -Inf];

            for slice = invalid_slices
                tc.verifyError( ...
                    @() extract_slice_for_image(phantom, slice=slice), ...
                    "DECTSim:InvalidSlice");
            end
        end
    end
end
