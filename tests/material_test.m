classdef material_test < matlab.unittest.TestCase

    methods (Test)
        function test_water(tc)
            tc.verifyEqual(water(1e-3), 4.078E+03)
            tc.verifyEqual(water(1.5e-2), 1.673E+00)
            tc.verifyEqual(water(8e-2), 1.837E-01)
            tc.verifyEqual(water(1.25), 6.323E-02)
            tc.verifyEqual(water(2e1),1.813E-02)
            
            tc.verifyWarning(@ () water(9e-4), '')
            tc.verifyWarning(@ () water(2.1e1), '')
        end

        function test_bone(tc)
            tc.verifyEqual(bone(1e-3     ), 3.781E+03 * 1.92)
            tc.verifyEqual(bone(1.305E-03), 1.873E+03 * 1.92)
            tc.verifyEqual(bone(1.5e-3   ), 1.295E+03 * 1.92)
            tc.verifyEqual(bone(2.472E-03), 4.907E+02 * 1.92)
            tc.verifyEqual(bone(3e-3     ), 2.958e+02 * 1.92)
            tc.verifyEqual(bone(2e-2     ), 4.001E+00 * 1.92)
            tc.verifyEqual(bone(3e-1     ), 1.113E-01 * 1.92)
            tc.verifyEqual(bone(1.25     ), 5.871E-02 * 1.92)
            tc.verifyEqual(bone(2e1      ), 2.068E-02 * 1.92)
        end

        function test_blood(tc)
            tc.verifyEqual(blood(1e-3      ), 3.806E+03 * 1.06)
            tc.verifyEqual(blood(1.5e-3    ), 1.282E+03 * 1.06)
            tc.verifyEqual(blood(2.472E-03 ), 3.149E+02 * 1.06)
            tc.verifyEqual(blood(2.6414E-03), 2.633E+02 * 1.06)
            tc.verifyEqual(blood(3e-3      ), 1.862E+02 * 1.06)
            tc.verifyEqual(blood(5e-3      ), 4.232E+01 * 1.06)
            tc.verifyEqual(blood(2e-2      ), 8.428E-01 * 1.06)
            tc.verifyEqual(blood(3e-1      ), 1.176E-01 * 1.06)
            tc.verifyEqual(blood(1.25      ), 6.265E-02 * 1.06)
            tc.verifyEqual(blood(2e1       ), 1.793E-02 * 1.06)
        end

        function test_lung(tc)
            tc.verifyEqual(lung(1e-3      ), 3.803E+03 * 1.050)
            tc.verifyEqual(lung(1.5e-3    ), 1.283E+03 * 1.050)
            tc.verifyEqual(lung(2.472E-03 ), 3.170E+02 * 1.050)
            tc.verifyEqual(lung(2.8224E-03), 2.204E+02 * 1.050)
            tc.verifyEqual(lung(3e-3      ), 1.888E+02 * 1.050)
            tc.verifyEqual(lung(2e-2      ), 8.316E-01 * 1.050)
            tc.verifyEqual(lung(3e-1      ), 1.177E-01 * 1.050)
            tc.verifyEqual(lung(1.25      ), 6.271E-02 * 1.050)
            tc.verifyEqual(lung(2e1       ), 1.794E-02 * 1.050)
        end

        function test_muscle(tc)
            tc.verifyEqual(muscle(1e-3      ), 3.719E+03 * 1.050)
            tc.verifyEqual(muscle(1.5e-3    ), 1.251E+03 * 1.050)
            tc.verifyEqual(muscle(2.472E-03 ), 3.085E+02 * 1.050)
            tc.verifyEqual(muscle(2.8224E-03), 2.145E+02 * 1.050)
            tc.verifyEqual(muscle(3e-3      ), 1.812E+02 * 1.050)
            tc.verifyEqual(muscle(2e-2      ), 8.205E-01 * 1.050)
            tc.verifyEqual(muscle(3e-1      ), 1.176E-01 * 1.050)
            tc.verifyEqual(muscle(1.25      ), 6.265E-02 * 1.050)
            tc.verifyEqual(muscle(2e1       ), 1.786E-02 * 1.050)
        end

    end

end