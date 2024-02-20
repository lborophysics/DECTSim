classdef voxel_array_tests < matlab.unittest.TestCase
    properties
        test_obj1
        test_obj2
        test_obj3
        test_obj4
        material1
        material2
    end

    methods (TestMethodSetup)
        % Setup for each test
        function setup (tc)
            centre = [0; 0; 0];
            object_dims = [10; 10; 10];
            tc.material1 = material_attenuation("water");
            vobj1 = voxel_object(@(i,j,k) i==i, tc.material1); % Define a simple function for testing
            tc.material2 = material_attenuation("air");
            vobj2 = voxel_object(@(i,j,k) i==i, tc.material2); % Define a simple function for testing
            tc.test_obj1 = voxel_array(centre, object_dims, 1, {vobj1});
            tc.test_obj2 = voxel_array(centre, object_dims, 0.5, {vobj1});
            tc.test_obj3 = voxel_array(centre, object_dims, 1, {vobj2});
            tc.test_obj4 = voxel_array([5; 4; 0.5], object_dims, 1, {vobj1});
        end
    end

    methods (Test)
        % Test methods
        function test_attributes(tc)
            % Verify attributes
            tc.verifyEqual(tc.test_obj1.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj1.num_planes, [11; 11; 11]);
            tc.verifyEqual(tc.test_obj1.dimensions, [1; 1; 1]);

            tc.verifyEqual(tc.test_obj2.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj2.num_planes, [21; 21; 21]);
            tc.verifyEqual(tc.test_obj2.dimensions, [0.5; 0.5; 0.5]);

            tc.verifyEqual(tc.test_obj3.array_position, [-5; -5; -5]);
            tc.verifyEqual(tc.test_obj3.num_planes, [11; 11; 11]);
            tc.verifyEqual(tc.test_obj3.dimensions, [1; 1; 1]);

            tc.verifyEqual(tc.test_obj4.array_position, [0; -1; -4.5]);
            tc.verifyEqual(tc.test_obj4.num_planes, [11; 11; 11]);
            tc.verifyEqual(tc.test_obj4.dimensions, [1; 1; 1]);
        end

        function test_collection(tc)
            mat1 = material_attenuation("water");
            mat1_att = mat1.get_mu(1);
            big_box = voxel_cube([0,0,0], 10, mat1);
            mat2 = material_attenuation("bone");
            mat2_att = mat2.get_mu(1);
            med_box = voxel_cube([0,0,0], 6, mat2);
            mat3 = material_attenuation("air");
            mat3_att = mat3.get_mu(1);
            small_box = voxel_cube([0,0,0], 2, mat3);
            my_collection = voxel_array([0.5;0.5;0.5], [10;10;10], 1, {big_box, med_box, small_box});
            get_mu = @(x,y,z,e) my_collection.get_saved_mu([x + 5;y + 5;z + 5], [mat1_att, mat2_att, mat3_att, inf]); % coord to index -> + 5
            for x = -5:5
                if abs(x) <= 1
                    tc.verifyEqual(get_mu(x, 0, 0, 1), mat3_att)
                elseif abs(x) <= 3
                    tc.verifyEqual(get_mu(x, 0, 0, 1), mat2_att)
                else
                    tc.verifyEqual(get_mu(x, 0, 0, 1), mat1_att)
                end
            end
            for y = -5:5
                if abs(y) <= 1
                    tc.verifyEqual(get_mu(0, y, 0, 1), mat3_att)
                elseif abs(y) <= 3
                    tc.verifyEqual(get_mu(0, y, 0, 1), mat2_att)
                else
                    tc.verifyEqual(get_mu(0, y, 0, 1), mat1_att)
                end
            end
        end

        function test_get_dicts(tc)
            centre = [0; 0; 0];
            object_dims = [10; 10; 10];
            water = voxel_cube([0,0,0], 10, material_attenuation("water"));
            air =  voxel_cube([0,0,0], 6, material_attenuation("air")); 
            bone =  voxel_cube([0,0,0], 2, material_attenuation("bone"));

            obj1 = voxel_array(centre, object_dims, 1, {air, water, bone});
            obj2 = voxel_array(centre, object_dims, 0.5, {bone, air, water});

            arr_exp1 = [air.get_mu(12) water.get_mu(12) bone.get_mu(12) air.get_mu(12)];
            arr_exp2 = [bone.get_mu(24) air.get_mu(24) water.get_mu(24) air.get_mu(24)];

            tc.verifyEqual(obj1.get_mu_arr(12), arr_exp1);
            tc.verifyEqual(obj2.get_mu_arr(24), arr_exp2);

            arr_exp1 = [...
                air.material.mean_free_path(12) ...
                water.material.mean_free_path(12) ...
                bone.material.mean_free_path(12) ...
                air.material.mean_free_path(12)];

            arr_exp2 = [...
                bone.material.mean_free_path(24) ...
                air.material.mean_free_path(24) ...
                water.material.mean_free_path(24) ...
                air.material.mean_free_path(24)];
            
            tc.verifyEqual(obj1.get_mfp_arr(12), arr_exp1);
            tc.verifyEqual(obj2.get_mfp_arr(24), arr_exp2);
        end

        function test_saved_dicts(tc)
            mat1 = material_attenuation("water");
            mat2 = material_attenuation("bone");
            mat3 = material_attenuation("air");

            mat1_att = mat1.get_mu(13); mat1_mfp = mat1.mean_free_path(59);
            mat2_att = mat2.get_mu(13); mat2_mfp = mat2.mean_free_path(59);
            mat3_att = mat3.get_mu(13); mat3_mfp = mat3.mean_free_path(59);

            big_box   = voxel_cube([0,0,0], 10, mat1);
            med_box   = voxel_cube([0,0,0], 6 , mat2);            
            small_box = voxel_cube([0,0,0], 2 , mat3);
            my_collection = voxel_array([0.5;0.5;0.5], [10;10;10], 1, {big_box, med_box, small_box});
            
            mu_arr = my_collection.get_mu_arr(13);
            mfp_arr = my_collection.get_mfp_arr(59);
            get_mu = @(x,y,z) my_collection.get_saved_mu([x + 5;y + 5;z + 5], mu_arr); % coord to index -> + 5
            get_mfp = @(x,y,z) my_collection.get_saved_mfp([x + 5;y + 5;z + 5], mfp_arr); % coord to index -> + 5

            for x = -5:5
                if abs(x) <= 1
                    tc.verifyEqual(get_mu (x, 0, 0), mat3_att)
                    tc.verifyEqual(get_mfp(x, 0, 0), mat3_mfp)
                elseif abs(x) <= 3
                    tc.verifyEqual(get_mu (x, 0, 0), mat2_att)
                    tc.verifyEqual(get_mfp(x, 0, 0), mat2_mfp)
                else
                    tc.verifyEqual(get_mu (x, 0, 0), mat1_att)
                    tc.verifyEqual(get_mfp(x, 0, 0), mat1_mfp)
                end
            end
            for y = -5:5
                if abs(y) <= 1
                    tc.verifyEqual(get_mu (0, y, 0), mat3_att)
                    tc.verifyEqual(get_mfp(0, y, 0), mat3_mfp)
                elseif abs(y) <= 3
                    tc.verifyEqual(get_mu (0, y, 0), mat2_att)
                    tc.verifyEqual(get_mfp(0, y, 0), mat2_mfp)
                else
                    tc.verifyEqual(get_mu (0, y, 0), mat1_att)
                    tc.verifyEqual(get_mfp(0, y, 0), mat1_mfp)
                end
            end
        end
        
    end

end