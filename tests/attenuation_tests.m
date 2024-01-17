classdef attenuation_tests < matlab.unittest.TestCase
    
    methods(Static)
        % Shared setup for the entire test class
        function mu = water_by_z(energy)
            Z = [1, 8];
            R = [0.111898, 0.888102];
            density = 1;
            water = gen_material(Z, R, density);
            mu = water(energy);
        end

        function mu = bone_by_z(energy)
            Z = [1, 6, 7, 8, 11, 12, 15, 16, 20];
            R = [0.034000, 0.155000, 0.042000, 0.435000, 0.001000, 0.002000, 0.103000, 0.003000, 0.225000];
            density = 1.92;
            bone = gen_material(Z, R, density);
            mu = bone(energy);
        end

        function mu = blood_by_z(energy)
            Z = [1, 6, 7, 8, 11, 15, 16, 17, 19, 26];
            R = [0.102000, 0.110000, 0.033000, 0.745000, 0.001000, 0.001000, 0.002000, 0.003000, 0.002000, 0.001000];
            density = 1.06;
            blood = gen_material(Z, R, density);
            mu = blood(energy);
        end

        function mu = lung_by_z(energy)
            Z = [1, 6, 7, 8, 11, 15, 16, 17, 19];
            R = [0.103000, 0.105000, 0.031000, 0.749000, 0.002000, 0.002000, 0.003000, 0.003000, 0.002000];
            density = 1.050;
            lung = gen_material(Z, R, density);
            mu = lung(energy);
        end

        function mu = muscle_by_z(energy)
            Z = [1, 6, 7, 8, 11, 15, 16, 17, 19];
            R = [0.102000, 0.143000, 0.034000, 0.710000, 0.001000, 0.002000, 0.003000, 0.001000, 0.004000];
            density = 1.050;
            muscle = gen_material(Z, R, density);
            mu = muscle(energy);
        end
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function test_water_by_z(tc)
            tc.verifyEqual(tc.water_by_z(1e-3  ), 4.078E+03, "RelTol", 1e-3)
            tc.verifyEqual(tc.water_by_z(1.5e-2), 1.673E+00, "RelTol", 1e-3)
            tc.verifyEqual(tc.water_by_z(8e-2  ), 1.837E-01, "RelTol", 1e-3)
            tc.verifyEqual(tc.water_by_z(1.25  ), 6.323E-02, "RelTol", 1e-3)
            tc.verifyEqual(tc.water_by_z(2e1   ), 1.813E-02, "RelTol", 1e-3)
        end

        function test_bone_by_z(tc)
            tc.verifyEqual(tc.bone_by_z(1e-3     ), 3.781E+03 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(tc.bone_by_z(1.305E-03), 1.873E+03 * 1.92, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(tc.bone_by_z(1.5e-3   ), 1.295E+03 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(tc.bone_by_z(2.472E-03), 4.907E+02 * 1.92, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(tc.bone_by_z(3e-3     ), 2.958e+02 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(tc.bone_by_z(2e-2     ), 4.001E+00 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(tc.bone_by_z(3e-1     ), 1.113E-01 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(tc.bone_by_z(1.25     ), 5.871E-02 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(tc.bone_by_z(2e1      ), 2.068E-02 * 1.92, "RelTol", 1e-3)
        end

        function test_blood_by_z(tc)
            tc.verifyEqual(tc.blood_by_z(1e-3      ), 3.806E+03 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(1.5e-3    ), 1.282E+03 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(2.472E-03 ), 3.149E+02 * 1.06, "RelTol", 2e-2)% Check this is because of the absorption edge
            tc.verifyEqual(tc.blood_by_z(2.6414E-03), 2.633E+02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(3e-3      ), 1.862E+02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(5e-3      ), 4.232E+01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(2e-2      ), 8.428E-01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(3e-1      ), 1.176E-01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(1.25      ), 6.265E-02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(tc.blood_by_z(2e1       ), 1.793E-02 * 1.06, "RelTol", 1e-3)
        end

        function test_lung_by_z(tc)
            tc.verifyEqual(tc.lung_by_z(1e-3      ), 3.803E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.lung_by_z(1.5e-3    ), 1.283E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.lung_by_z(2.472E-03 ), 3.170E+02 * 1.050, "RelTol", 2e-2)% Check this is because of the absorption edge
            tc.verifyEqual(tc.lung_by_z(2.8224E-03), 2.204E+02 * 1.050, "RelTol", 5e-3)% Check this is because of the absorption edge
            tc.verifyEqual(tc.lung_by_z(3e-3      ), 1.888E+02 * 1.050, "RelTol", 1e-3) 
            tc.verifyEqual(tc.lung_by_z(2e-2      ), 8.316E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.lung_by_z(3e-1      ), 1.177E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.lung_by_z(1.25      ), 6.271E-02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.lung_by_z(2e1       ), 1.794E-02 * 1.050, "RelTol", 1e-3)
        end

        function test_muscle_by_z(tc)
            tc.verifyEqual(tc.muscle_by_z(1e-3      ), 3.719E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.muscle_by_z(1.5e-3    ), 1.251E+03 * 1.050, "RelTol", 1e-3) 
            tc.verifyEqual(tc.muscle_by_z(2.472E-03 ), 3.085E+02 * 1.050, "RelTol", 2e-2) % Check this is because of the absorption edge
            tc.verifyEqual(tc.muscle_by_z(2.8224E-03), 2.145E+02 * 1.050, "RelTol", 2e-3) % Check this is because of the absorption edge
            tc.verifyEqual(tc.muscle_by_z(3e-3      ), 1.812E+02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.muscle_by_z(2e-2      ), 8.205E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.muscle_by_z(3e-1      ), 1.176E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.muscle_by_z(1.25      ), 6.265E-02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(tc.muscle_by_z(2e1       ), 1.786E-02 * 1.050, "RelTol", 1e-3)
        end
    end
end