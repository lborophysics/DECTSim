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
    end

end