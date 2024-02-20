classdef detector_tests < matlab.unittest.TestCase

    properties
        % Test properties
        ray_source
        sensor_unit
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup_test(tc)
            tc.ray_source = single_energy(30);
            tc.sensor_unit = ideal_sensor([0, 100], 100);
        end
    end

    methods (Test)
        % Test methods
        function test_detector_array_init(tc)
            p1 = parallel_detector([0.1, 0.35], [110, 20]);
            tc.assertEqual(p1.pixel_dims, [0.1, 0.35]);
            tc.assertEqual(p1.n_pixels, [110, 20]);

            p2 = parallel_detector([0.34, 0.1], [20, 110]);
            tc.assertEqual(p2.pixel_dims, [0.34, 0.1]);
            tc.assertEqual(p2.n_pixels, [20, 110]);

            tc.verifyError(@() parallel_detector([-0.1, 0.35], [110, 20]), "MATLAB:validators:mustBePositive");
            tc.verifyError(@() parallel_detector([0.1, 0.35], [-110, 20]), "MATLAB:validators:mustBePositive");
            tc.verifyError(@() parallel_detector([0.1, 0.35], [110.5, 20]), "MATLAB:validators:mustBeInteger");

            c1 = curved_detector([0.1 0.35], [110, 20]);
            tc.assertEqual(c1.pixel_dims, [0.1, 0.35]);
            tc.assertEqual(c1.n_pixels, [110, 20]);
            
            c2 = curved_detector([0.34, 0.1], [20, 110]);
            tc.assertEqual(c2.pixel_dims, [0.34, 0.1]);
            tc.assertEqual(c2.n_pixels, [20, 110]);

            tc.verifyError(@() curved_detector([-0.1, 0.35], [110, 20]), "MATLAB:validators:mustBePositive");
            tc.verifyError(@() curved_detector([0.1, 0.35], [-110, 20]), "MATLAB:validators:mustBePositive");
            tc.verifyError(@() curved_detector([0.1, 0.35], [110.5, 20]), "MATLAB:validators:mustBeInteger");
        end

        function test_curved_ray_gen(tc)
            geom = gantry(9, 10, pi);
            c1 = curved_detector([9*pi/60, 0.4], [60, 10]);
            ray_generator = c1.ray_at_angle(geom, 1);

            rot_by_pixel = rotz(pi/60);
            unit_vector = rotz(pi/120) * [-1; 0; 0];
            z_pos = @(i) (-2 + 0.2 + (0.4 .* (i-1)))/9;
            for i = 30:40
                for j = 1:10
                    exp_start = [0; 4.5; 0];
                    exp_dir   = rot_by_pixel^(i-1) * unit_vector .* 9 + [0;0;z_pos(j)*9];
                    exp_len   = norm(exp_dir);
                    exp_dir   = exp_dir / exp_len;
                    [ray_start, ray_dir, ray_length] = ray_generator(i, j);
                    tc.verifyEqual(ray_start, exp_start, 'RelTol', 1e-14);
                    tc.verifyEqual(ray_dir, exp_dir, 'RelTol', 1e-14);
                    tc.verifyEqual(ray_length, exp_len, 'RelTol', 1e-14);
                end
            end
        end

        function test_para_ray_gen(tc)
            unit_vector = [0; -1; 0];
            geom = gantry(2, 10, pi);
            p1 = parallel_detector([0.1, 0.35], [110, 20]);
            ray_generator = p1.ray_at_angle(geom, 1);

            y_increment = [1; 0; 0] * 0.1;
            z_increment = [0; 0; 7] / 20;
            start = [-5.45; 1; -3.325];
            for i = 50:60
                for j = 5:15
                    exp_start = start + y_increment*(i-1) + z_increment*(j-1);
                    exp_dir   = unit_vector;
                    exp_len   = 2;
                    [ray_start, ray_dir, ray_length] = ray_generator(i, j);
                    tc.verifyEqual(ray_start, exp_start, 'RelTol', 1e-14);
                    tc.verifyEqual(ray_dir, exp_dir, 'RelTol', 1e-14);
                    tc.verifyEqual(ray_length, exp_len, 'RelTol', 1e-14);
                end
            end
        end


        function test_get_scan_angles(tc)
            for num_rotations = 2:10
                geom = gantry(2, num_rotations, pi);
                res = geom.get_scan_angles();
                exp = rad2deg(linspace(0, pi, num_rotations+1));

                tc.verifyEqual(res, exp(1:end-1), 'AbsTol', 1e-15);
            end
        end

        function test_hit_para_pixel(tc)
            geom = gantry(2, 10, pi);
            a1 = parallel_detector([0.1, 0.35], [110, 20]);
            ray_generator = a1.ray_at_angle(geom, 13);
            for i = 1:110
                for j = 1:20
                    [ray_start, ray_dir, ~] = ray_generator(i, j);
                    [pixel, hit] = a1.hit_pixel(ray_start, ray_dir, geom, 13);
                    tc.verifyEqual(pixel, [i, j]);
                    tc.verifyTrue(hit);
                end
            end
            [ray_start, ray_dir, ~] = ray_generator(111, 20);
            [pixel, hit] = a1.hit_pixel(ray_start, ray_dir, geom, 13);
            tc.verifyEqual(pixel, [0, 0]);
            tc.verifyFalse(hit);

            ray_generator = a1.ray_at_angle(geom, 35);
            [ray_start, ray_dir, ~] = ray_generator(55, 10);
            [pixel, hit] = a1.hit_pixel(ray_start, -ray_dir, geom, 35);
            tc.verifyEqual(pixel, [0, 0]);
            tc.verifyFalse(hit);                
        end

    end
end