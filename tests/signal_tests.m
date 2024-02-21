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
            tc.geom = gantry(2, 180, pi);
        end
    end

    methods(Test)
        function test_air_scan(tc)
            g1 = gantry(2, 10, pi);
            a1 = parallel_detector([0.1, 0.35], [110, 20]);
            d1 = detector(g1, a1, tc.sensor_unit);

            xray_source = single_energy(30);

            air = material_attenuation("air");
            scan = squeeze(sum(air_scan(xray_source, d1), 1));
            expected = zeros(110, 20, 10) + exp(-air.get_mu(30)*2);
            tc.verifyEqual(scan, expected, 'RelTol', 1e-15);
        end

        function test_generate_image(tc)
            
            a1 = parallel_detector([1, 1], [5, 1]);
            g1 = gantry(10, 4, pi);
            d1 = detector(g1, a1, tc.sensor_unit);
            mat = material_attenuation("water"); 
            my_box = voxel_cube([0;0;0], [3;3;3], mat);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, {my_box}, material_attenuation("vacuum"));
            att = mat.get_mu(30);
            sq2 = sqrt(2);
            
            image = squeeze(compute_sinogram(tc.ray_source, array, d1));
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 2e-15);
            tc.verifyEqual(image(:, 3), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);

            % 2D 
            a2 = parallel_detector([1, 1], [5, 5]);
            d2 = detector(g1, a2, tc.sensor_unit);
            image = compute_sinogram(tc.ray_source, array, d2);
            tc.verifyEqual(size(image), [5, 5, 4]);
            for row = 2:4
                tc.verifyEqual(image(:, row, 1), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
                tc.verifyEqual(image(:, row, 2), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 2e-15);
                tc.verifyEqual(image(:, row, 3), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
                tc.verifyEqual(image(:, row, 4), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);
            end
            tc.verifyEqual(image(:, 1, :), zeros(5, 1, 4), 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 5, :), zeros(5, 1, 4), 'AbsTol', 1e-15);

            % No hits 2D
            array = voxel_array(zeros(3, 1), [1; 1; 1], 1, {}, material_attenuation("vacuum"));
            image = compute_sinogram(tc.ray_source, array, d2);
            tc.verifyEqual(image, zeros(5, 5, 4), 'AbsTol', 1e-15);
        end

        function test_scatter_image(tc)
            % This test should probably include a test for correct scatter factor (not that it has no effect when no scatter is present)
            % Check that with no scattering, the scatter image is the same as the regular image
            a1 = parallel_detector([1, 1], [5, 1]);
            g1 = gantry(10, 4, pi);
            d1 = detector(g1, a1, tc.sensor_unit);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, {}, material_attenuation("vacuum")); % Will never scatter
        
            % Check that 
            image = compute_sinogram(tc.ray_source, array, d1);
            scatter_count = monte_carlo_scatter(tc.ray_source, array, d1);
            scatter_signal = tc.sensor_unit.get_signal(scatter_count);

            scatter = tc.sensor_unit.get_image(scatter_signal);
            tc.verifyEqual(scatter, image, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        
            scatter_image = compute_sinogram(tc.ray_source, array, d1, "slow");
            tc.verifyEqual(scatter_image, image, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        
            scatter_image = compute_sinogram(tc.ray_source, array, d1, "slow", 3);
            tc.verifyEqual(scatter_image, image, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        end
    end
end