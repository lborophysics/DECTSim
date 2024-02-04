 classdef voxel_shapes_tests < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function test_cylinder(tc)
            radius = 1;
            width = 2;
            water= material("water");
            my_cyl = voxel_cylinder([0, 0, 0], radius, width, water);
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
            my_cyl = voxel_cylinder([1, 2, 3], radius, width, water);
            for x = -1:0.25:3
                if (x-1) ^ 2 <= radius ^ 2
                    for y = 0:0.25:4
                        if (x-1)^2 + (y-2)^2 <= radius^2
                            for z = 1:0.25:5
                                if z - 3 >= -width/2 && z - 3 <= width/2
                                    tc.verifyEqual(my_cyl(x, y, z, 0.5), water.get_mu(0.5))
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

        function box(tc)
            water = material("water");
            my_box = voxel_box([0,0,0], 100, water);
            res = my_box(-100:0.5:100, -100:0.5:100, -100:0.5:100, 10);
            exp = cat(2,zeros(1, 100), zeros(1, 201)+water.get_mu(10), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)

            my_box = voxel_box([100, 100, 100], [200, 200, 100], water);
            res = my_box(-100:300, -100:300, 50:0.25:150, 0.02);
            exp = cat(2,zeros(1, 100), zeros(1, 201) + water.get_mu(0.02), zeros(1, 100)); %101 includes 0
            tc.verifyEqual(res, exp)
        end

        function shepp_logan(tc)
            my_shepp1 = voxel_shepp_logan([0;0;0], 100, 1);
            my_shepp2 = voxel_shepp_logan([1;1;1], 20, 0.5);
            my_shepp3 = voxel_shepp_logan([0;0;0], 3000, 100);
            actual_shepp1 = phantom(100);
            actual_shepp2 = phantom(40);
            actual_shepp3 = phantom(30);

            tc.verifyEqual(my_shepp1(0, 0, "abc"), actual_shepp1(50, 50))
            tc.verifyEqual(my_shepp2(-6.8, -5.5, []), actual_shepp2(4, 7))
            tc.verifyEqual(my_shepp3(1810, 1720, 50), actual_shepp3(3, 2))
        end

        function test_collection(tc)
            mat1 = material("water"); mat1.get_mu = @(e) 10;
            big_box = voxel_box([0,0,0], 10, mat1);
            mat2 = material("water"); mat2.get_mu = @(e) 5;
            med_box = voxel_box([0,0,0], 6, mat2);
            mat3 = material("water"); mat3.get_mu = @(e) 1;
            small_box = voxel_box([0,0,0], 2, mat3);
            my_collection = voxel_collection(big_box, med_box, small_box);
            for x = -5:5
                if abs(x) <= 1
                    tc.verifyEqual(my_collection(x, 0, 0, 1), 1)
                elseif abs(x) <= 3
                    tc.verifyEqual(my_collection(x, 0, 0, 1), 5)
                else
                    tc.verifyEqual(my_collection(x, 0, 0, 1), 10)
                end
            end
            for y = -5:5
                if abs(y) <= 1
                    tc.verifyEqual(my_collection(0, y, 0, 1), 1)
                elseif abs(y) <= 3
                    tc.verifyEqual(my_collection(0, y, 0, 1), 5)
                else
                    tc.verifyEqual(my_collection(0, y, 0, 1), 10)
                end
            end
        end
    end

end