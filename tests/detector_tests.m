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
            p1 = flat_detector([0.1, 0.35], [110, 20]);
            tc.assertEqual(p1.pixel_dims, [0.1, 0.35]);
            tc.assertEqual(p1.n_pixels, [110, 20]);

            p2 = flat_detector([0.34, 0.1], [20, 110]);
            tc.assertEqual(p2.pixel_dims, [0.34, 0.1]);
            tc.assertEqual(p2.n_pixels, [20, 110]);

            tc.verifyError(@() flat_detector([-0.1, 0.35], [110, 20]), "MATLAB:validators:mustBePositive");
            tc.verifyError(@() flat_detector([0.1, 0.35], [-110, 20]), "MATLAB:validators:mustBePositive");
            tc.verifyError(@() flat_detector([0.1, 0.35], [110.5, 20]), "MATLAB:validators:mustBeInteger");

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
            d2d = 9; radius = d2d/2;
            geom = gantry(d2d, 10, pi);
            pixel_width = radius * pi / 60;
            c1 = curved_detector([pixel_width, 0.4], [60, 10]);
            pixel_generator = c1.set_array_angle(geom, 1);

            angle = chord2ang(pixel_width, d2d);
            chord_radius = realsqrt(radius^2 - (pixel_width/2)^2);
            vector = rotz(-61*angle/2) * [0; -chord_radius; 0];
            z_pos = @(i) (-2 + 0.2 + (0.4 .* (i-1)));
            for i = 20:40
                for j = 1:10
                    exp_pos   = rotz(angle*i) * vector + [0;0;z_pos(j)];
                    
                    pixel_position = pixel_generator(i, j);
                    tc.verifyEqual(pixel_position, exp_pos, 'RelTol', 1e-14);
                end
            end
        end

        function test_para_ray_gen(tc)
            unit_vector = [0; -1; 0];
            geom = gantry(2, 10, pi);
            p1 = flat_detector([0.1, 0.35], [110, 20]);
            pixel_generator = p1.set_array_angle(geom, 1);

            y_increment = [1; 0; 0] * 0.1;
            z_increment = [0; 0; 7] / 20;
            start = [-5.45; 1; -3.325];
            for i = 50:60
                for j = 5:15
                    exp_start = start + y_increment*(i-1) + z_increment*(j-1);
                    exp_dir   = unit_vector .* 2;
                    exp_pos   = exp_start + exp_dir;
                    pixel_position = pixel_generator(i, j);
                    tc.verifyEqual(pixel_position, exp_pos, 'RelTol', 1e-14);
                end
            end
        end


        function test_get_scan_angles(tc)
            for num_rotations = 2:10
                geom = gantry(2, num_rotations, pi);
                res = geom.scan_angles;
                exp = linspace(0, pi, num_rotations+1);

                tc.verifyEqual(res, exp(1:end-1), 'AbsTol', 1e-15);
            end
        end

        function test_hit_para_pixel(tc)
            geom = gantry(2, 10, pi);
            a1 = flat_detector([0.1, 0.35], [110, 20]);
            pixel_generator = a1.set_array_angle(geom, 13);
            hit_at_angle = a1.hit_pixel(geom, 13);
            for i = 1:1%10
                for j = 1:20
                    pixel_pos = pixel_generator(i, j);
                    ray_start = geom.get_source_pos(13, pixel_pos);
                    ray_dir   = pixel_pos - ray_start;
                    exp_ray_len = norm(ray_dir);

                    [pixel, act_ray_len, angle, hit] = hit_at_angle(ray_start, ray_dir ./ exp_ray_len);
                    tc.verifyEqual(pixel, [i; j]);
                    tc.verifyEqual(act_ray_len, exp_ray_len, "RelTol", 1e-15);
                    tc.verifyTrue(hit);
                    % tc.verifyEqual(angle, pi/2, "RelTol", 1e-15);
                end
            end

            % Test for a ray that just misses the detector
            pixel_pos = pixel_generator(111, 20);
            ray_start = geom.get_source_pos(13, pixel_pos);
            ray_dir   = pixel_pos - ray_start;
            ray_dir   = ray_dir ./ norm(ray_dir);
            hit_at_angle = a1.hit_pixel(geom, 13);

            [pixel, act_ray_len, angle, hit] = hit_at_angle(ray_start, ray_dir);
            tc.verifyEqual(pixel, [0; 0]);
            tc.verifyEqual(act_ray_len, 0, "RelTol", 1e-15);
            % tc.verifyEqual(angle, 0, "RelTol", 1e-15);
            tc.verifyFalse(hit);

            % Test for a ray would hit the detector if it was going the other way
            pixel_generator = a1.set_array_angle(geom, 35);
            pixel_pos = pixel_generator(55, 10);
            ray_start = geom.get_source_pos(35, pixel_pos);
            ray_dir   = pixel_pos - ray_start;
            ray_dir   = ray_dir ./ norm(ray_dir);
            hit_at_angle = a1.hit_pixel(geom, 35);
            
            [pixel, act_ray_len, angle, hit] = hit_at_angle(ray_start, -ray_dir);
            tc.verifyEqual(pixel, [0; 0]);
            tc.verifyEqual(act_ray_len, 0, "RelTol", 1e-15);
            % tc.verifyEqual(angle, 0, "RelTol", 1e-15);
            tc.verifyFalse(hit);                
            

            % [ray_start, ray_dir, ray_len] = pixel_generator(55, 15);
            pixel_pos = pixel_generator(55, 15);
            ray_start = geom.get_source_pos(13, pixel_pos);
            ray_dir   = pixel_pos - ray_start;
            ray_len   = norm(ray_dir);
            ray_dir   = ray_dir ./ ray_len;
            
            ray_dirs = repmat(ray_dir, 1, 10);
            ray_starts = repmat(ray_start, 1, 10);
            [pixels, act_ray_lens, angles, hits] = hit_at_angle(ray_starts, ray_dirs);
            tc.verifyTrue(all(pixels(1,:) == 55));
            tc.verifyTrue(all(pixels(2,:) == 15));
            tc.verifyEqual(act_ray_lens, repmat(ray_len, 1, 10), "RelTol", 1e-15);
            % tc.verifyEqual(angles, repmat(pi/2, 1, 10), "RelTol", 1e-15);
            tc.verifyTrue(all(hits));

            ray_dirs(:, 2:4) = -ray_dirs(:, 2:4);
            [pixels, act_ray_lens, angles, hits] = hit_at_angle(ray_starts, ray_dirs);
            tc.verifyTrue(all(pixels(1,2:4) == 0));
            tc.verifyTrue(all(pixels(2,2:4) == 0));
            
            tc.verifyEqual(act_ray_lens(2:4), zeros(1, 3), "RelTol", 1e-15);
            % tc.verifyEqual(angles(2:4), zeros(1, 3), "RelTol", 1e-15);
            
            tc.verifyTrue(all(~hits(2:4)));
            tc.verifyTrue(all(pixels(1,[1,5:end]) == 55));
            tc.verifyTrue(all(pixels(2,[1,5:end]) == 15));
            
            tc.verifyEqual(act_ray_lens([1,5:end]), repmat(ray_len, 1, 7), "RelTol", 1e-15);
            % tc.verifyEqual(angles([1,5:end]), repmat(pi/2, 1, 7), "RelTol", 1e-15);
            
            tc.verifyTrue(all(hits([1,5:end])));
        end

        function test_hit_curved_pixel(tc)
            geom = gantry(9, 10, pi);
            c1 = curved_detector([4.5*pi/60, 0.4], [60, 10]);
            pixel_generator = c1.set_array_angle(geom, 1);
            hit_at_angle = c1.hit_pixel(geom, 1);
            for i = 1:60
                for j = 1:10
                    pixel_pos = pixel_generator(i, j);
                    ray_start = geom.get_source_pos(1, pixel_pos);
                    ray_dir   = pixel_pos - ray_start;
                    exp_ray_len = norm(ray_dir);
                    unit_ray = ray_dir ./ exp_ray_len;

                    [pixel, act_ray_len, angle, hit] = hit_at_angle(ray_start, unit_ray);
                    tc.verifyEqual(pixel, [i; j]);
                    tc.verifyEqual(act_ray_len, exp_ray_len, "RelTol", 2e-15);
                    tc.verifyTrue(hit);
                    
                    unit_xy_pos = pixel_pos(1:2) ./ norm(pixel_pos(1:2));
                    unit_xy_pos(3) = 0;
                    tc.verifyEqual(angle, asin(abs(sum(unit_ray .* unit_xy_pos))), "RelTol", 5e-14);
                end
            end
            % return
            % Test for a ray that just misses the detector  
            pixel_pos = pixel_generator(61, 10);
            ray_start = geom.get_source_pos(1, pixel_pos);
            ray_dir   = pixel_pos - ray_start;
            ray_dir   = ray_dir ./ norm(ray_dir);
            hit_at_angle = c1.hit_pixel(geom, 1);

            [pixel, act_ray_len, angle, hit] = hit_at_angle(ray_start, ray_dir);
            tc.verifyEqual(pixel, [0; 0]);
            tc.verifyEqual(act_ray_len, 0, "RelTol", 1e-15);
            tc.verifyFalse(hit);
            tc.verifyEqual(angle, 0, "RelTol", 1e-15);  

            % Test for a ray would hit the detector if it was going the other way
            pixel_generator = c1.set_array_angle(geom, 35);
            pixel_pos = pixel_generator(30, 5);
            ray_start = geom.get_source_pos(35, pixel_pos);
            ray_dir   = pixel_pos - ray_start;
            ray_dir   = ray_dir ./ norm(ray_dir);
            hit_at_angle = c1.hit_pixel(geom, 35);
            
            [pixel, act_ray_len, angle, hit] = hit_at_angle(ray_start, -ray_dir);
            tc.verifyEqual(pixel, [0; 0]);
            tc.verifyEqual(act_ray_len, 0, "RelTol", 1e-15);
            tc.verifyFalse(hit);
            tc.verifyEqual(angle, 0, "RelTol", 1e-15);         
        end
    end
end