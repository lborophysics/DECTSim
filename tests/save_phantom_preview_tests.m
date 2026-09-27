classdef save_phantom_preview_tests < matlab.unittest.TestCase
    properties
        output_file
    end

    methods (TestMethodSetup)
        function create_output_file(tc)
            tc.output_file = string(tempname) + ".png";
            tc.addTeardown(@() delete(tc.output_file(isfile(tc.output_file))));
        end
    end

    methods (Test)
        function test_dimensions_and_alpha(tc)
            phantom = voxel_array([0; 0; 0], [4; 6; 2], 1, {});

            [preview, alpha] = save_phantom_preview(phantom, tc.output_file);

            tc.verifyEqual(alpha, zeros(6, 4));
            tc.verifyEqual(preview, zeros(6, 4));
        end

        function test_uniform_foreground(tc)
            object = voxel_cube([0; 0; 0], 4, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {object});

            [preview, alpha] = save_phantom_preview(phantom, tc.output_file);

            tc.verifyEqual(preview, 0.5 * ones(4, 4));
            tc.verifyEqual(alpha, ones(4, 4));
        end

        function test_saved_alpha_and_nested_directory(tc)
            root = string(tempname);
            output_file = fullfile(root, "nested", "preview.png");
            cleanup = onCleanup(@() rmdir(root, "s")); %#ok<NASGU>

            object = voxel_cube([0; 0; 0], 2, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [2; 2; 2], 1, {object});
            [~, expected_alpha] = save_phantom_preview(phantom, output_file);

            [~, ~, saved_alpha] = imread(output_file);
            tc.verifyTrue(isfile(output_file));
            tc.verifyEqual(double(saved_alpha) / 255, expected_alpha, ...
                "AbsTol", 1 / 255);
        end

        function test_x_axis_orientation(tc)
            object = voxel_object(@(x, y, z) x <= 0, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {object});

            [~, alpha] = save_phantom_preview(phantom, tc.output_file);

            tc.verifyEqual(alpha(:, 1:2), ones(4, 2));
            tc.verifyEqual(alpha(:, 3:4), zeros(4, 2));
        end

        function test_y_axis_orientation(tc)
            object = voxel_object(@(x, y, z) y <= 0, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {object});

            [~, alpha] = save_phantom_preview(phantom, tc.output_file);

            tc.verifyEqual(alpha(1:2, :), zeros(2, 4));
            tc.verifyEqual(alpha(3:4, :), ones(2, 4));
        end

        function test_denser_material_maps_to_lighter_grey(tc)
            water = voxel_cube([0; 0; 0], 4, material_attenuation("water"));
            bone = voxel_cube([0; 0; 0], 2, material_attenuation("bone"));
            phantom = voxel_array([0; 0; 0], [4; 4; 2], 1, {water, bone});

            [preview, ~] = save_phantom_preview(phantom, tc.output_file);

            water_pixels = preview([1, 4], [1, 4]);
            bone_pixels = preview(2:3, 2:3);

            tc.verifyEqual(water_pixels, 0.15 * ones(2, 2), "AbsTol", eps);
            tc.verifyEqual(bone_pixels, 0.85 * ones(2, 2), "AbsTol", eps);
        end

        function test_only_central_z_slice_is_sampled(tc)
            off_centre_object = voxel_object( ...
                @(x, y, z) z < -0.5, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 3], 1, {off_centre_object});

            [~, alpha] = save_phantom_preview(phantom, tc.output_file);

            tc.verifyEqual(alpha, zeros(4, 4));

            centred_object = voxel_object( ...
                @(x, y, z) abs(z) <= 0.5, material_attenuation("water"));
            phantom = voxel_array([0; 0; 0], [4; 4; 3], 1, {centred_object});
            [~, alpha] = save_phantom_preview(phantom, tc.output_file);

            tc.verifyEqual(alpha, ones(4, 4));
        end
    end
end
