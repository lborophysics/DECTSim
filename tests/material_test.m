classdef material_test < matlab.unittest.TestCase

    methods (Test)
        function test_init(tc)
            m = material(10);
            tc.verifyEqual(m.mu, 10);

            m = material(20);
            tc.verifyEqual(m.mu, 20);
        end
    end

end