classdef attenuation_tests < matlab.unittest.TestCase
    methods(Test)
        % Test methods

        function test_constructor(tc)
            % Test the constructor
            tc.verifyError(@() get_material(), 'MATLAB:notEnoughInputs', 'Not enough input arguments.');
            tc.verifyError(@() get_material("water", 2), 'MATLAB:invalidInput', 'Invalid number of input arguments.');
            tc.verifyError(@() get_material(1, 2, 3, 4), 'MATLAB:invalidInput', 'Invalid number of input arguments.');
            tc.verifyError(@() get_material(1), 'assert:failure', 'When only one input is given, it should be a string with the name of the material.');
            tc.verifyError(@() get_material('water'), 'assert:failure', 'When only one input is given, it should be a string with the name of the material.');
            tc.verifyError(@() get_material("wat"), 'MATLAB:invalidMaterial', 'The material wat is not available. Available materials are: air, blood, bone, lung, muscle, water.');
            tc.verifyError(@() get_material([1, 8], [0.111898, 0.888102], [0, 1]), 'assert:failure', 'The density should be a scalar number.');
            tc.verifyError(@() get_material([1, 8], [0.1, 0.2], "1"), 'assert:failure', 'The density should be a scalar number.');
            tc.verifyError(@() get_material([1, 2;1, 2], [0.111898, 0.888102], 1), 'assert:failure', 'The atomic numbers should be a vector.');
            tc.verifyError(@() get_material([1, 8], [0.1, 0.2; 0.3, 0.4], 1), 'assert:failure', 'The mass fractions should be a vector.');
            tc.verifyError(@() get_material(1, [0.1, 0.2], 1), 'assert:failure', 'The atomic numbers and mass fractions should have the same length.');
        end
        
        function test_water_by_z(tc)
            water_mat = get_material("water");
            water = @water_mat.get_mu;
            tc.verifyEqual(water(1e-3  ), 4.078E+03, "RelTol", 1e-3)
            tc.verifyEqual(water(1.5e-2), 1.673E+00, "RelTol", 1e-3)
            tc.verifyEqual(water(8e-2  ), 1.837E-01, "RelTol", 1e-3)
            tc.verifyEqual(water(1.25  ), 6.323E-02, "RelTol", 1e-3)
            tc.verifyEqual(water(2e1   ), 1.813E-02, "RelTol", 1e-3)

            water_mat = get_material([1, 8], [0.111898, 0.888102], 1);
            water = @water_mat.get_mu;
            tc.verifyEqual(water(1e-3  ), 4.078E+03, "RelTol", 1e-3)
            tc.verifyEqual(water(1.5e-2), 1.673E+00, "RelTol", 1e-3)
            tc.verifyEqual(water(8e-2  ), 1.837E-01, "RelTol", 1e-3)
            tc.verifyEqual(water(1.25  ), 6.323E-02, "RelTol", 1e-3)
            tc.verifyEqual(water(2e1   ), 1.813E-02, "RelTol", 1e-3)
        end

        function test_bone_by_z(tc)
            bone_mat = get_material("bone");
            bone = @bone_mat.get_mu;
            tc.verifyEqual(bone(1e-3     ), 3.781E+03 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(1.305E-03), 1.873E+03 * 1.92, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(bone(1.5e-3   ), 1.295E+03 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(2.472E-03), 4.907E+02 * 1.92, "RelTol", 1e-2)% Check this is because of the absorption edge
            tc.verifyEqual(bone(3e-3     ), 2.958e+02 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(2e-2     ), 4.001E+00 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(3e-1     ), 1.113E-01 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(1.25     ), 5.871E-02 * 1.92, "RelTol", 1e-3)
            tc.verifyEqual(bone(2e1      ), 2.068E-02 * 1.92, "RelTol", 1e-3)
        end

        function test_blood_by_z(tc)
            blood_mat = get_material("blood");
            blood = @blood_mat.get_mu;
            tc.verifyEqual(blood(1e-3      ), 3.806E+03 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(1.5e-3    ), 1.282E+03 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(2.472E-03 ), 3.149E+02 * 1.06, "RelTol", 2e-2)% Check this is because of the absorption edge
            tc.verifyEqual(blood(2.6414E-03), 2.633E+02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(3e-3      ), 1.862E+02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(5e-3      ), 4.232E+01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(2e-2      ), 8.428E-01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(3e-1      ), 1.176E-01 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(1.25      ), 6.265E-02 * 1.06, "RelTol", 1e-3)
            tc.verifyEqual(blood(2e1       ), 1.793E-02 * 1.06, "RelTol", 1e-3)
        end

        function test_lung_by_z(tc)
            lung_mat = get_material("lung");    
            lung = @lung_mat.get_mu;            
            tc.verifyEqual(lung(1e-3      ), 3.803E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(1.5e-3    ), 1.283E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(2.472E-03 ), 3.170E+02 * 1.050, "RelTol", 2e-2)% Check this is because of the absorption edge
            tc.verifyEqual(lung(2.8224E-03), 2.204E+02 * 1.050, "RelTol", 5e-3)% Check this is because of the absorption edge
            tc.verifyEqual(lung(3e-3      ), 1.888E+02 * 1.050, "RelTol", 1e-3) 
            tc.verifyEqual(lung(2e-2      ), 8.316E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(3e-1      ), 1.177E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(1.25      ), 6.271E-02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(lung(2e1       ), 1.794E-02 * 1.050, "RelTol", 1e-3)
        end

        function test_muscle_by_z(tc)
            muscle_mat = get_material("muscle");
            muscle = @muscle_mat.get_mu;
            tc.verifyEqual(muscle(1e-3      ), 3.719E+03 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(1.5e-3    ), 1.251E+03 * 1.050, "RelTol", 1e-3) 
            tc.verifyEqual(muscle(2.472E-03 ), 3.085E+02 * 1.050, "RelTol", 2e-2) % Check this is because of the absorption edge
            tc.verifyEqual(muscle(2.8224E-03), 2.145E+02 * 1.050, "RelTol", 2e-3) % Check this is because of the absorption edge
            tc.verifyEqual(muscle(3e-3      ), 1.812E+02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(2e-2      ), 8.205E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(3e-1      ), 1.176E-01 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(1.25      ), 6.265E-02 * 1.050, "RelTol", 1e-3)
            tc.verifyEqual(muscle(2e1       ), 1.786E-02 * 1.050, "RelTol", 1e-3)
        end
    end
end