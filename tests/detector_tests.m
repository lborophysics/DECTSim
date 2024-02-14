classdef detector_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods
        function test_curved_init(tc)
            % detector = curved_detector(9, 18, pi/180, pi/2); % using detector width
            detector = curved_detector(9, [pi/20, 0.1], [111 + 1e-13, 212], 4);
            tc.verifyEqual(detector.init_source_pos, detector.source_position, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, [0; 4.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/180);
            tc.verifyEqual(detector.pixel_height, 0.1);

            detector.rotate();
            tc.verifyEqual(detector.init_source_pos, [0; 4.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, [-4.5; 0; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/180);
            tc.verifyEqual(detector.pixel_height, 0.1);

            detector = curved_detector(9, [pi/20, 0.1], [111, 212 + 1e-13]);
            detector.rotate();
            tc.verifyEqual(detector.source_position, 4.5*rotz(pi/2 + pi/180)*[1; 0; 0], 'AbsTol', 1e-15);

            % detector = curved_detector(11, 11, pi/30, pi/4); % using detector width
            detector = curved_detector(11, [11*pi/30, 0.31], [13, 27], 8);
            tc.verifyEqual(detector.init_source_pos, detector.source_position, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, [0; 5.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/30, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_height, 0.31);
            
            detector.rotate();
            tc.verifyEqual(detector.init_source_pos, [0; 5.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.source_position, rotz(pi/4)*[0; 5.5; 0], 'AbsTol', 1e-15); 
            tc.verifyEqual(detector.pixel_angle, pi/30, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_height, 0.31);

            detector.reset();
            tc.verifyEqual(detector.source_position, [0; 5.5; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.init_source_pos, detector.source_position, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_angle, pi/30, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.pixel_height, 0.31);
        end

        function test_parallel_init(tc)
            detector = parallel_detector(5, [0.11 0.1], [100+1e-13, 10], 2);
            tc.verifyEqual(detector.centre, [0; -2.5; 0]);
            tc.verifyEqual(detector.init_centre, detector.centre);
            tc.verifyEqual(detector.pixel_dims, [0.11 0.1]);

            detector.rotate();
            tc.verifyEqual(detector.centre, [2.5; 0; 0], 'AbsTol', 1e-15);
            tc.verifyEqual(detector.init_centre, [0; -2.5; 0]);
            tc.verifyEqual(detector.pixel_dims, [0.11 0.1]);

            detector = parallel_detector(5, [11, 7], [100, 50+1e-14]);
            detector.rotate();
            tc.verifyEqual(detector.centre, rotz(pi/180)*[0; -2.5; 0], 'AbsTol', 1e-15);
            
            detector = parallel_detector(7, [0.028, 0.044], [500, 250], 4); 
            tc.verifyEqual(detector.centre, [0; -3.5; 0]);
            tc.verifyEqual(detector.init_centre, detector.centre);
            tc.verifyEqual(detector.pixel_dims, [0.028, 0.044]); 
            
            detector.rotate();
            tc.verifyEqual(detector.centre, [ 1/sqrt(2); -1/sqrt(2); 0]*3.5, 'AbsTol', 1e-15);
            tc.verifyEqual(detector.init_centre, [0; -3.5; 0]);
            tc.verifyEqual(detector.pixel_dims, [0.028, 0.044]);

            detector.reset();
            tc.verifyEqual(detector.centre, [0; -3.5; 0]);
            tc.verifyEqual(detector.init_centre, detector.centre);
            tc.verifyEqual(detector.pixel_dims, [0.028, 0.044]); 
        end

        function test_curved_ray_gen(tc)
            detector = curved_detector(9, [9*pi/60, 0.4], [60, 10], 4);
            empty_voxels = voxel_array([0;0;0], [1;1;1], 1);
            ray_generator = detector.get_ray_generator(empty_voxels);

            rot_by_pixel = rotz(pi/60);
            unit_vector = rotz(pi/120) * [-1; 0; 0];
            z_pos = @(i) (-2 + 0.2 + (0.4 .* (i-1)))/9;
            for i = 30:40
                for j = 1:10
                    my_ray = ray([0; 4.5; 0], rot_by_pixel^(i-1) * unit_vector, 9, empty_voxels);
                    gen_ray = ray_generator(i, j);
                    tc.verifyEqual(gen_ray.start_point, my_ray.start_point);
                    tc.verifyEqual(gen_ray.v1_to_v2, my_ray.v1_to_v2 + [0;0;z_pos(j)*9], 'RelTol', 1e-13);
                end
            end
        end

        function test_para_ray_gen(tc)
            unit_vector = [0; -1; 0];
            detector = parallel_detector(2, [0.1, 0.35], [110, 20], 1);
            empty_voxels = voxel_array([0;0;0], [1;1;1], 1);
            ray_generator = detector.get_ray_generator(empty_voxels);

            y_increment = [1; 0; 0] * 0.1;
            z_increment = [0; 0; 7] / 20;
            start = [-5.45; 1; -3.325];
            for i = 50:60
                for j = 5:15
                    my_ray = ray(start + y_increment*(i-1) + z_increment*(j-1), unit_vector, 2, empty_voxels);
                    gen_ray = ray_generator(i, j);
                    tc.verifyEqual(gen_ray.start_point, my_ray.start_point, 'AbsTol', 7e-15);
                    tc.verifyEqual(gen_ray.v1_to_v2, my_ray.v1_to_v2);
                end
            end
        end

        function test_para_pixel_gen_scatter(tc)
            detector = parallel_detector(2, [0.01, 0.01], [110, 20], 1);
            graphite = material_attenuation("graphite", 12, 1, 2.26);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, voxel_object(@(i, j, k) i==i, graphite));
            pix_gen_scatter = detector.get_pixel_generator(1, array, @scatter_ray);
            pix_gen = detector.get_pixel_generator(1, array);


            for i = 50:60
                for j = 5:15
                    [scatter_pval, pixel_hit, scattered] = pix_gen_scatter(i, j);
                    [pval] = pix_gen(i, j);
                    if scattered && any(pixel_hit) && all([i, j] == pixel_hit) 
                        % Unlikely case: Scattered, but small angle so still hits pixel
                        tc.verifyEqual(scatter_pval, pval, 'RelTol', 1e-5);
                    elseif scattered && any(pixel_hit)
                        % Scattered, but still hits pixel
                        tc.verifyNotEqual(scatter_pval, pixel_hit);
                    elseif scattered
                        % Scattered, but doesn't hit pixel
                        tc.verifyTrue(isnan(scatter_pval))
                    else
                        % Doesn't scatter
                        tc.verifyEqual(scatter_pval, pval, 'RelTol', 1e-5);
                    end         
                end
            end

            func = @(a, b, c) "Not a ray";
            tc.verifyError(@() detector.get_pixel_generator(1, array, func), "parallel_detector:InvalidRayType");
        end

        function test_get_scan_angles(tc)
            for num_rotations = 2:10
                detector = parallel_detector(2, [11, 1], [110, 1], num_rotations);
                res = detector.get_scan_angles();
                exp = rad2deg(linspace(0, pi, num_rotations+1));

                tc.verifyEqual(res, exp(1:end-1), 'AbsTol', 1e-15);
            end
        end
        
        function test_generate_image(tc)
            detector = parallel_detector(10, [1, 1], [5, 1], 4);
            mat = material_attenuation("water"); 
            my_box = voxel_cube([0;0;0], [3;3;3], mat);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            att = mat.get_mu(30);
            sq2 = sqrt(2);
            
            image = squeeze(detector.generate_image(array));
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 2e-15);
            tc.verifyEqual(image(:, 3), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);
            
            detector_2d = parallel_detector(10, [0.15, 0.1], [50, 10], 4);
            image = detector_2d.generate_image(array);
            image_p = detector_2d.generate_image_p(array);
            tc.verifyEqual(image_p, image, 'RelTol', 1e-14)
        end

        function test_generate_image_p(tc)
            detector = parallel_detector(10, [1, 1], [5, 1], 4);
            mat = material_attenuation("water");
            my_box = voxel_cube([0;0;0], [3;3;3], mat);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            att = mat.get_mu(30);
            sq2 = sqrt(2);
            
            image = squeeze(detector.generate_image_p(array));
            tc.verifyEqual(size(image), [5, 4]);
            tc.verifyEqual(image(:, 1), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 2), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 2e-15);
            tc.verifyEqual(image(:, 3), [0;3;3;3;0].*att, 'AbsTol', 1e-15);
            tc.verifyEqual(image(:, 4), [3*sq2-4;3*sq2-2;3*sq2;3*sq2-2;3*sq2-4].*att, 'AbsTol', 3e-15);
        end

        function test_curved_generate_image_p(tc)
            dist_to_detector = 10;
            num_rotations = 16;
            detector = curved_detector(dist_to_detector, [pi/500, 0.01], [25, 10], num_rotations);
            my_mat = material_attenuation("water");
            my_box = voxel_cube([0;0;0], [3;3;3], my_mat);
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, my_box);
            image = detector.generate_image(array);
            image_p = detector.generate_image_p(array);
            tc.verifyEqual(image_p, image, 'RelTol', 1e-14)
        end

        function test_hit_para_pixel(tc)
            detector = parallel_detector(2, [0.1, 0.35], [110, 20], 10);
            empty_voxels = voxel_array([0;0;0], [1;1;1], 1);
            ray_generator = detector.get_ray_generator(empty_voxels);
            for i = 1:110
                for j = 1:20
                    gen_ray = ray_generator(i, j);
                    [pixel, hit] = detector.hit_pixel(gen_ray, detector.detector_vec);
                    tc.verifyEqual(pixel, [i, j]);
                    tc.verifyTrue(hit);
                end
            end

            pixel_centre = detector.centre +  detector.detector_vec .* ...
                           (-(111)/2) .* 0.1 + [0;0;0.35] .* (-(21)/2);
            source_position = pixel_centre + detector.to_source_vec .* 2;
            xray = ray(source_position, -detector.to_source_vec, 2, empty_voxels); % should miss
            [pixel, hit] = detector.hit_pixel(xray, detector.detector_vec);
            tc.verifyEqual(pixel, [0, 0]);
            tc.verifyFalse(hit);

            xray = ray(source_position, rotz(pi/2) * -detector.to_source_vec, 2, empty_voxels); % should not intersect
            [pixel, hit] = detector.hit_pixel(xray, detector.detector_vec);
            tc.verifyEqual(pixel, [0, 0]);
            tc.verifyFalse(hit);

            detector.rotate();
            ray_generator = detector.get_ray_generator(empty_voxels);
            for i = 1:110
                for j = 1:20
                    gen_ray = ray_generator(i, j);
                    [pixel, hit] = detector.hit_pixel(gen_ray, detector.detector_vec);
                    tc.verifyEqual(pixel, [i, j]);
                    tc.verifyTrue(hit);
                end
            end
        end

        function test_scatter_image(tc)
            % This test should probably include a test for correct scatter factor (not that it has no effect when no scatter is present)
            % Check that with no scattering, the scatter image is the same as the regular image
            detector = parallel_detector(10, [1, 1], [5, 1], 4);
            air = material_attenuation("air");
            array = voxel_array(zeros(3, 1), [5; 5; 5], 1, voxel_object(@(i, j, k) i==i, air));
            
            image = detector.generate_image_p(array);
            scatter = detector.slow_scatter(array);
            tc.verifyEqual(image, scatter, 'RelTol', 1e-15, 'AbsTol', 1e-15);

            scatter = detector.slow_scatter_p(array);
            tc.verifyEqual(image, scatter, 'RelTol', 1e-15, 'AbsTol', 1e-15);

            detector = parallel_detector(10, [1, 1], [5, 1], 4, "slow");
            scatter_image = detector.generate_image_p(array);
            tc.verifyEqual(image, scatter_image, 'RelTol', 1e-15, 'AbsTol', 1e-15);
            
            detector = parallel_detector(10, [1, 1], [5, 1], 4, "slow", 2);
            scatter_image = detector.generate_image_p(array);
            tc.verifyEqual(image, scatter_image, 'RelTol', 1e-15, 'AbsTol', 1e-15);

            scatter = detector.slow_scatter(array); % Now scatter factor is 2
            tc.verifyEqual(image, scatter, 'RelTol', 1e-15, 'AbsTol', 1e-15);
        end

        function test_air_scan(tc)
            detector = parallel_detector(2, [0.1, 0.35], [110, 20], 10);
            air = material_attenuation("air");
            scan = detector.air_scan();
            exp = zeros(110, 20, 10) + air.get_mu(30)*2;
            tc.verifyEqual(scan, exp, 'RelTol', 1e-15);
        end

    end
end