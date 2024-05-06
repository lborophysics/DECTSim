classdef voxel_shapes_tests < matlab.unittest.TestCase

    methods
        function get_mu = get_get_mu(~, obj)
            get_mu = @func;
            function mu = func(i, j, k, e)
                if isscalar(i)
                    if obj.is_in_object(i, j, k)
                        mu = obj.material.get_mu(e);
                    else
                        mu = 0;
                    end
                else
                    mu = zeros(1, length(i));
                    mu(obj.is_in_object(i, j, k)) = obj.material.get_mu(e);
                end
            end
        end    
    end

    methods (Test)
        % Test methods

        function test_cylinder(tc)
            radius = 1;
            width = 2;
            water= material_attenuation("water");
            cylinder = voxel_cylinder([0, 0, 0], radius, width, water);
            my_cyl = tc.get_get_mu(cylinder);
            for x = -2:0.25:2
                if x ^ 2 <= radius ^ 2
                    for y = -2:0.25:2
                        if x^2 + y^2 <= radius^2
                            for z = -2:0.25:2
                                if z >= -width/2 && z <= width/2
                                    tc.verifyEqual(my_cyl(x, y, z, 10), water.get_mu(10))
                                else
                                    tc.verifyEqual(my_cyl(x, y, z, 10), 0)
                                end
                            end
                        else
                            tc.verifyEqual(my_cyl(x, y, 0, 1), 0)
                        end
                    end
                else
                    tc.verifyEqual(my_cyl(x, 0, 0, 1), 0)
                end
            end
            cylinder = voxel_cylinder([1, 2, 3], radius, width, water);
            my_cyl = tc.get_get_mu(cylinder);

            for x = -1:0.25:3
                if (x-1) ^ 2 <= radius ^ 2
                    for y = 0:0.25:4
                        if (x-1)^2 + (y-2)^2 <= radius^2
                            for z = 1:0.25:5
                                if z - 3 >= -width/2 && z - 3 <= width/2
                                    tc.verifyEqual(my_cyl(x, y, z, 5), water.get_mu(5))
                                else
                                    tc.verifyEqual(my_cyl(x, y, z, 1), 0)
                                end
                            end
                        else
                            tc.verifyEqual(my_cyl(x, y, 0, 1), 0)
                        end
                    end
                else
                    tc.verifyEqual(my_cyl(x, 0, 0, 1), 0)
                end
            end

        end

        function test_box(tc)
            water = material_attenuation("water");
            my_box = voxel_cube([0,0,0], 100, water);
            box_fun = tc.get_get_mu(my_box);
            res = box_fun(-100:0.5:100, -100:0.5:100, -100:0.5:100, 10);
            exp = cat(2,zeros(1, 100), zeros(1, 201)+water.get_mu(10), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)

            my_box = voxel_cube([100, 100, 100], [200, 200, 100], water);
            box_fun = tc.get_get_mu(my_box);
            res = box_fun(-100:300, -100:300, 50:0.25:150, 2);
            exp = cat(2,zeros(1, 100), zeros(1, 201) + water.get_mu(2), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)
        end

        function test_ellipsoid(tc)
            water = material_attenuation("water");
            my_ellipsoid = voxel_ellipsoid([0, 0, 0], 1, 1, 1, water); % unit sphere
            ellipsoid_fun = tc.get_get_mu(my_ellipsoid);
            for x = -2:0.25:2
                for y = -2:0.25:2
                    for z = -2:0.25:2
                        if x^2 + y^2 + z^2 <= 1
                            tc.verifyEqual(ellipsoid_fun(x, y, z, 10), water.get_mu(10))
                        else
                            tc.verifyEqual(ellipsoid_fun(x, y, z, 10), 0)
                        end
                    end
                end
            end

            my_ellipsoid = voxel_ellipsoid([1, 2, 3], 2, 1, 1, water);
            ellipsoid_fun = tc.get_get_mu(my_ellipsoid);
            for x = -2:1:4
                for y = -1:1:5
                    for z = 0:1:6
                        if (x-1)^2/4 + (y-2)^2 + (z-3)^2 <= 1
                            tc.verifyEqual(ellipsoid_fun(x, y, z, 10), water.get_mu(10))
                        else
                            tc.verifyEqual(ellipsoid_fun(x, y, z, 10), 0)
                        end
                    end
                end
            end
        end

        function test_rotated_ellipsoid(tc)
            water = material_attenuation("water");
            rotated_ellipsoid1 = voxel_ellipsoid_rotated([0, 0, 0], 1, 2, 3, pi/2, water);
            rotated_ellipsoid2 = voxel_ellipsoid_rotated([0, 0, 0], 1, 2, 3, pi, water);
            rot_ellipsoid_fun1 = tc.get_get_mu(rotated_ellipsoid1);
            rot_ellipsoid_fun2 = tc.get_get_mu(rotated_ellipsoid2);
            for x = -2:1:2
                for y = -2:1:2
                    for z = -2:1:2
                        if x^2/4 + y^2 + z^2/9 <= 1
                            tc.verifyEqual(rot_ellipsoid_fun1(x, y, z, 10), water.get_mu(10))
                        else
                            tc.verifyEqual(rot_ellipsoid_fun1(x, y, z, 10), 0)
                        end
                        if x^2 + y^2/4 + z^2/9 <= 1
                            tc.verifyEqual(rot_ellipsoid_fun2(x, y, z, 10), water.get_mu(10))
                        else
                            tc.verifyEqual(rot_ellipsoid_fun2(x, y, z, 10), 0)
                        end
                    end
                end
            end
        end
    end
end