classdef signal_tests < matlab.unittest.TestCase

    properties
        % Test properties
        ray_source
        sensor_unit
        geom
    end
    
    methods (TestMethodSetup)
        function setup_test(tc)
            tc.ray_source = single_energy(30);
            tc.sensor_unit = ideal_sensor([0, 100], 100);
            tc.geom = parallel_gantry(2, 180, pi);
        end
    end

    methods(Test)
        function test_air_scan(tc)
            g1 = parallel_gantry(2, 10, pi);
            a1 = flat_detector([0.1, 0.35], [110, 20]);
            d1 = detector(g1, a1, tc.sensor_unit);

            xray_source = single_energy(30);

            air = material_attenuation("air");
            scan = squeeze(sum(air_scan(xray_source, d1), 1));
            intensity = 1e6 .* (0.1 * 0.35) / 4; % The conversion from fluences to intensity
            expected = zeros(110, 20, 10) + intensity*exp(-air.get_mu(30)*2);

            tc.verifyEqual(scan, expected, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        end

        function test_generate_image(tc)
            
            a1 = flat_detector([1, 1], [5, 1]);
            g1 = parallel_gantry(10, 4, pi);
            d1 = detector(g1, a1, tc.sensor_unit);
            mat = material_attenuation("water"); 
            my_box = voxel_cube([0;0;0], [3;3;3], mat);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, {my_box}, material_attenuation("vacuum"));
            att = mat.get_mu(30);
            sq2 = sqrt(2);

            image = squeeze(compute_sinogram(tc.ray_source, array, d1));
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);
            tc.verifyEqual(image(:, 3), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);

            % % 2D 
            a2 = flat_detector([1, 1], [5, 5]);
            sampled_sensor = ideal_sensor([0, 100], 50, 2);
            d2 = detector(g1, a2, sampled_sensor);
            image = compute_sinogram(tc.ray_source, array, d2);
            tc.verifyEqual(size(image), [5, 5, 4]);
            for row = 2:4
                tc.verifyEqual(image(:, row, 1), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
                tc.verifyEqual(image(:, row, 2), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);
                tc.verifyEqual(image(:, row, 3), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
                tc.verifyEqual(image(:, row, 4), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);
            end
            tc.verifyEqual(image(:, 1, :), zeros(5, 1, 4), 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 5, :), zeros(5, 1, 4), 'AbsTol', 1e-15);

            % No hits 2D
            array = voxel_array(zeros(3, 1), [1; 1; 1].*2, 1, {}, material_attenuation("vacuum"));
            image = compute_sinogram(tc.ray_source, array, d2);
            tc.verifyEqual(image, zeros(5, 5, 4), 'AbsTol', 1e-15);
        end

        function test_noscatter_image(tc)
            % This test should probably include a test for correct scatter factor (not that it has no effect when no scatter is present)
            % Check that with no scattering, the scatter image is the same as the regular image
            a1 = flat_detector([1, 1], [5, 1]);
            g1 = parallel_gantry(10, 4, pi);
            d1 = detector(g1, a1, tc.sensor_unit);
            d2 = detector(g1, a1, ideal_sensor([0, 100], 50, 2));
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, {}, material_attenuation("vacuum")); % Will never scatter
        
            % Check that 
            image = compute_sinogram(tc.ray_source, array, d1);
            scatter_count = monte_carlo_scatter(tc.ray_source, array, d1);
            scatter_signal = tc.sensor_unit.get_signal(scatter_count);

            tc.verifyEqual(scatter_signal, zeros(5,1,4), 'RelTol', 1e-15, 'AbsTol', 1e-15);
        
            scatter_image = compute_sinogram(tc.ray_source, array, d1, "slow");
            tc.verifyEqual(scatter_image, image, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        
            scatter_image = compute_sinogram(tc.ray_source, array, d2, "slow", 3);
            tc.verifyEqual(scatter_image, image, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        end

        function test_scatter_image(tc)
            rng(1712345)
            % THIS IS NOT GREAT - CHANGE 
            % Voxel array constants
            vox_arr_center = zeros(3, 1);
            phantom_radius = 15;% In the x-y plane
            phantom_width = 15; % In the z direction
            voxel_size = 1; % 1 cm

            % Create voxel array
            water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
            num_materials = 4;
            rot_mat_pos = rotz(2*pi/num_materials);
            init_mat_pos = [0; phantom_radius/2; 0];
            bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("bone"));
            init_mat_pos = rot_mat_pos * init_mat_pos;
            blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("fat"));
            init_mat_pos = rot_mat_pos * init_mat_pos;
            lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("blood"));
            init_mat_pos = rot_mat_pos * init_mat_pos;
            muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("muscle"));

            voxels = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
                voxel_size, {water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder});

            dgantry = parallel_gantry(105, 45, pi);
            darray = flat_detector([0.2 0.1], [450 1]);
            dsensor = ideal_sensor([0; 100], 100);
            d = detector(dgantry, darray, dsensor);
            
            scatter_sinogram = squeeze(compute_sinogram(single_energy(50), voxels, d, "slow", 1));
     
            scatter_sinogram_expected = matfile("scatter_cylinder_slow.mat").scatter_sinogram;
            tc.verifyEqual(scatter_sinogram, scatter_sinogram_expected, 'RelTol', 2e-8, 'AbsTol', 1e-8);
        end

        function test_conv_scatter_image(tc)
            % THIS IS NOT GREAT - CHANGE 
            % Voxel array constants
            vox_arr_center = zeros(3, 1);
            phantom_radius = 15;% In the x-y plane
            phantom_width = 15; % In the z direction
            voxel_size = 1; % 1 cm

            % Create voxel array
            water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
            num_materials = 4;
            rot_mat_pos = rotz(2*pi/num_materials);
            init_mat_pos = [0; phantom_radius/2; 0];
            bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("bone"));
            init_mat_pos = rot_mat_pos * init_mat_pos;
            blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("fat"));
            init_mat_pos = rot_mat_pos * init_mat_pos;
            lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("blood"));
            init_mat_pos = rot_mat_pos * init_mat_pos;
            muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("muscle"));

            voxels = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
                voxel_size, {water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder});

            dgantry = parallel_gantry(105, 180, pi);
            darray = flat_detector([0.1 0.1], [900 1]);
            dsensor = ideal_sensor([0; 100], 100);
            d = detector(dgantry, darray, dsensor);

            scatter_sinogram = squeeze(compute_sinogram(single_energy(50), voxels, d, "fast"));
            
            scatter_sinogram_expected = matfile("scatter_cylinder_fast.mat").scatter_sinogram;
            tc.verifyEqual(scatter_sinogram, scatter_sinogram_expected, 'RelTol', 2e-14, 'AbsTol', 2e-14);
        end
    end
end
