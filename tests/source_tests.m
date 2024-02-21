classdef source_tests < matlab.unittest.TestCase

    methods(Test)
        function test_single_energy(tc)
            s1 = single_energy(50);
            tc.verifyEqual(s1.energy, 50);
            range1 = [0 10; 10 20; 20 30; 30 40; 40 50; 50 60];
            expE = [NaN; NaN; NaN; NaN; NaN; 50]';
            expI = [NaN; NaN; NaN; NaN; NaN; 1]';
            [e, i] = s1.get_energies(range1);
            tc.verifyEqual(e, expE);
            tc.verifyEqual(i, expI);

            s2 = single_energy(21);
            tc.verifyEqual(s2.energy, 21);
            range2 = [0 7; 7 10; 10 15; 15 25; 25 30; 30 40; 40 50; 50 60];
            expE = [NaN; NaN; NaN; 21; NaN; NaN; NaN; NaN]';
            expI = [NaN; NaN; NaN; 1; NaN; NaN; NaN; NaN]';
            [e, i] = s2.get_energies(range2);
            tc.verifyEqual(e, expE);
            tc.verifyEqual(i, expI);
        end

    end
end