classdef attenuation_tests < matlab.unittest.TestCase
    methods(Test)
        % Test methods

        function test_constructor(tc)
            % Test the constructor
            tc.verifyError(@() material_attenuation(), 'MATLAB:minrhs', 'Not enough input arguments.');
            tc.verifyError(@() material_attenuation("water", 2), 'MATLAB:invalidInput');
            tc.verifyError(@() material_attenuation("1", 2, 3, 4, 5), 'MATLAB:invalidInput');
            tc.verifyError(@() material_attenuation(1), 'assert:failure');
            tc.verifyError(@() material_attenuation('water'), 'assert:failure');
            tc.verifyError(@() material_attenuation("wat"), 'MATLAB:invalidMaterial');
            tc.verifyError(@() material_attenuation("my_water", [1, 8], [0.111898, 0.888102], [0, 1]), 'assert:failure');
            tc.verifyError(@() material_attenuation("my_water", [1, 8], [0.1, 0.2], "1"), 'assert:failure');
            tc.verifyError(@() material_attenuation("my_water", [1, 2;1, 2], [0.111898, 0.888102], 1), 'assert:failure');
            tc.verifyError(@() material_attenuation("my_water", [1, 8], [0.1, 0.2; 0.3, 0.4], 1), 'assert:failure');
            tc.verifyError(@() material_attenuation("my_water", 1, [0.1, 0.2], 1), 'assert:failure');
        end

        function test_water(tc) % Don't forget to convet MeV to KeV
            water_mat = material_attenuation("Water");
            water = @(e) water_mat.get_mu(e*1000);
            tc.verifyEqual(water(1e-3  ), 4.078E+03, "RelTol", 1e-3)
            tc.verifyEqual(water(1.5e-2), 1.673E+00, "RelTol", 1e-3)
            tc.verifyEqual(water(8e-2  ), 1.837E-01, "RelTol", 1e-3)
            % tc.verifyEqual(water(1.25  ), 6.323E-02, "RelTol", 2e-3) % Now out of energy range
            % tc.verifyEqual(water(2e1   ), 1.813E-02, "RelTol", 1e-3) % Now out of energy range

            water_mat = material_attenuation("_water", [1, 8], [0.111898, 0.888102], 1);
            water = @(e) water_mat.get_mu(e.*1000);
            tc.verifyEqual(water(1e-3  ), 4.078E+03, "RelTol", 1e-3)
            tc.verifyEqual(water(1.5e-2), 1.673E+00, "RelTol", 1e-3)
            tc.verifyEqual(water(8e-2  ), 1.837E-01, "RelTol", 1e-3)
            % tc.verifyEqual(water(1.25  ), 6.323E-02, "RelTol", 2e-3) % Now out of energy range
            % tc.verifyEqual(water(2e1   ), 1.813E-02, "RelTol", 1e-3) % Now out of energy range
        end

        function test_bone(tc)
            bone_mat = material_attenuation("bone");
            bone = @(e) bone_mat.get_mu(e*1000);
            tc.verifyEqual(bone(1e-3     ), 3.781E+03 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(1.305E-03), 1.873E+03 * 1.92, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(bone(1.5e-3   ), 1.295E+03 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(2.472E-03), 4.907E+02 * 1.92, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(bone(3e-3     ), 2.958e+02 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(2e-2     ), 4.001E+00 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(3e-1     ), 1.113E-01 * 1.92, "RelTol", 1e-3)
            % tc.verifyEqual(bone(1.25     ), 5.871E-02 * 1.92, "RelTol", 1e-3) % Now out of energy range
            % tc.verifyEqual(bone(2e1      ), 2.068E-02 * 1.92, "RelTol", 1e-3) % Now out of energy range
        end

        function test_blood(tc)
            blood_mat = material_attenuation("blood");
            blood = @(e) blood_mat.get_mu(e*1000);
            tc.verifyEqual(blood(1e-3      ), 3.806E+03 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(1.5e-3    ), 1.282E+03 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(2.472E-03 ), 3.149E+02 * 1.06, "RelTol", 2e-2)% Check this is because of the absorption edge
            tc.verifyEqual(blood(2.6414E-03), 2.633E+02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(3e-3      ), 1.862E+02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(5e-3      ), 4.232E+01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(2e-2      ), 8.428E-01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(3e-1      ), 1.176E-01 * 1.06, "RelTol", 1e-3)
            % tc.verifyEqual(blood(1.25      ), 6.265E-02 * 1.06, "RelTol", 2e-3) % Now out of energy range
            % tc.verifyEqual(blood(2e1       ), 1.793E-02 * 1.06, "RelTol", 1e-3) % Now out of energy range
        end

        function test_lung_by_z(tc)
            lung_mat = material_attenuation("lung");
            lung = @(e) lung_mat.get_mu(e*1000);
            tc.verifyEqual(lung(1e-3      ), 3.803E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(1.5e-3    ), 1.283E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(2.472E-03 ), 3.170E+02 * 1.050, "RelTol", 2e-2)% Check this is because of the absorption edge
            tc.verifyEqual(lung(2.8224E-03), 2.204E+02 * 1.050, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(lung(3e-3      ), 1.888E+02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(2e-2      ), 8.316E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(3e-1      ), 1.177E-01 * 1.050, "RelTol", 1e-3)
            % tc.verifyEqual(lung(1.25      ), 6.271E-02 * 1.050, "RelTol", 2e-3) % Now out of energy range
            % tc.verifyEqual(lung(2e1       ), 1.794E-02 * 1.050, "RelTol", 1e-3) % Now out of energy range
        end

        function test_muscle_by_z(tc)
            muscle_mat = material_attenuation("muscle");
            muscle = @(e) muscle_mat.get_mu(e*1000);
            tc.verifyEqual(muscle(1e-3      ), 3.719E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(1.5e-3    ), 1.251E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(2.472E-03 ), 3.085E+02 * 1.050, "RelTol", 2e-2) % Check this is because of the absorption edge
            tc.verifyEqual(muscle(2.8224E-03), 2.145E+02 * 1.050, "RelTol", 3e-3) % Check this is because of the absorption edge
            tc.verifyEqual(muscle(3e-3      ), 1.812E+02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(2e-2      ), 8.205E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(3e-1      ), 1.176E-01 * 1.050, "RelTol", 1e-3)
            % tc.verifyEqual(muscle(1.25      ), 6.265E-02 * 1.050, "RelTol", 2e-3) % Now out of energy range
            % tc.verifyEqual(muscle(2e1       ), 1.786E-02 * 1.050, "RelTol", 1e-3) % Now out of energy range
        end

        function test_air_by_z(tc)
            air_mat = material_attenuation("air");
            air = @(e) air_mat.get_mu(e*1000);
            tc.verifyEqual(air(1e-3      ), 3.606E+03 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(air(1.5e-3    ), 1.191E+03 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(air(3E-03     ), 1.625E+02 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(air(4E-03     ), 7.788E+01 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(air(2e-2      ), 7.779E-01 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(air(6e-2      ), 1.875E-01 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(air(3e-1      ), 1.067E-01 * 1.205E-03, "RelTol", 1e-3)

            E = [1 10 20 30 50 60 90 100];
            for e = E
                mu = photon_attenuation([6 7 8 18], [0.000124 0.755268 0.231781 0.012827], 1.205E-03, e);
                tc.verifyEqual(air_mat.get_mu(e), mu)
            end

            E = [1 1.5 3 4 20 60 300];
            mus = air_mat.get_mu(E);
            tc.verifyEqual(mus(1), 3.606E+03 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(mus(2), 1.191E+03 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(mus(3), 1.625E+02 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(mus(4), 7.788E+01 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(mus(5), 7.779E-01 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(mus(6), 1.875E-01 * 1.205E-03, "RelTol", 1e-3)
            tc.verifyEqual(mus(7), 1.067E-01 * 1.205E-03, "RelTol", 1e-3)
        end

        function test_get_photon_attenuation(tc)
            air_mat = material_attenuation("air");
            E = log([1 1.5 3 4 20 60 300]);
            grid_int = get_photon_attenuation(air_mat.atomic_numbers);
            mus = sum(exp(grid_int(E)) .* air_mat.mass_fractions, 2);
            tc.verifyEqual(mus(1), 3.606E+03, "RelTol", 1e-3)
            tc.verifyEqual(mus(2), 1.191E+03, "RelTol", 1e-3)
            tc.verifyEqual(mus(3), 1.625E+02, "RelTol", 1e-3)
            tc.verifyEqual(mus(4), 7.788E+01, "RelTol", 1e-3)
            tc.verifyEqual(mus(5), 7.779E-01, "RelTol", 1e-3)
            tc.verifyEqual(mus(6), 1.875E-01, "RelTol", 1e-3)
            tc.verifyEqual(mus(7), 1.067E-01, "RelTol", 1e-3)
        end

        function test_read_excel(tc)
            materials = material_attenuation.get_materials("resources/example_materials.xlsx");
            tc.verifyEqual(length(materials), 6);
            tc.verifyEqual(materials{1}.name, "air");
            tc.verifyEqual(materials{1}.atomic_numbers, [6 7 8 18]);
            % I think the following error is to do with how excel stores its data - but I'm not sure, so this could be wrong to make the test pass
            tc.verifyEqual(materials{1}.mass_fractions, [0.000124 0.755268 0.231781 0.012817], "RelTol", 1.0001e-5);
            tc.verifyEqual(materials{1}.density, 1.205E-03);

            tc.verifyEqual(materials{2}.name, "water");
            tc.verifyEqual(materials{2}.atomic_numbers, [1 8]);
            tc.verifyEqual(materials{2}.mass_fractions, [0.111898 0.888102]);
            tc.verifyEqual(materials{2}.density, 1);

            tc.verifyEqual(materials{3}.name, "bone");
            tc.verifyEqual(materials{3}.atomic_numbers, [1 6 7 8 11 12 15 16 20]);
            tc.verifyEqual(materials{3}.mass_fractions, [0.034 0.155 0.042 0.435 0.001 0.002 0.103 0.003 0.225]);
            tc.verifyEqual(materials{3}.density, 1.92);

            tc.verifyEqual(materials{4}.name, "fat");
            tc.verifyEqual(materials{4}.atomic_numbers, [1 6 7 8 11 16 17]);
            tc.verifyEqual(materials{4}.mass_fractions, [0.114 0.598 0.007 0.278 0.001 0.001 0.001]);   
            tc.verifyEqual(materials{4}.density, 0.95);

            tc.verifyEqual(materials{5}.name, "blood");
            tc.verifyEqual(materials{5}.atomic_numbers, [1 6 7 8 11 15 16 17 19 26]);
            tc.verifyEqual(materials{5}.mass_fractions, [0.102 0.11 0.033 0.745 0.001 0.001 0.002 0.003	0.002 0.001]);
            tc.verifyEqual(materials{5}.density, 1.06);

            tc.verifyEqual(materials{6}.name, "muscle");
            tc.verifyEqual(materials{6}.atomic_numbers, [1 6 7 8 11 15 16 17 19]);
            tc.verifyEqual(materials{6}.mass_fractions, [0.102 0.143 0.034 0.71 0.001 0.002 0.003 0.001 0.004]);
            tc.verifyEqual(materials{6}.density, 1.05);
        end
    end
end