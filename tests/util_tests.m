classdef util_tests < matlab.unittest.TestCase
    properties (Constant)
        eps = 2^(-52);
    end

    methods (Test)
        function test_rotz(tc)
            R = rotz(pi/2);
            tc.verifyEqual(R, [0 -1 0; 1 0 0; 0 0 1], 'AbsTol', 10*tc.eps);

            R = rotz(pi/4);
            tc.verifyEqual(R, [sqrt(2)/2 -sqrt(2)/2 0; sqrt(2)/2 sqrt(2)/2 0; 0 0 1], 'AbsTol', 10*tc.eps);

            R = rotz(pi/6);
            tc.verifyEqual(R, [sqrt(3)/2 -1/2 0; 1/2 sqrt(3)/2 0; 0 0 1], 'AbsTol', 10*tc.eps);

            R = rotz(pi/3);
            tc.verifyEqual(R, [1/2 -sqrt(3)/2 0; sqrt(3)/2 1/2 0; 0 0 1], 'AbsTol', 10*tc.eps);

            R = rotz(pi);
            tc.verifyEqual(R, [-1 0 0; 0 -1 0; 0 0 1], 'AbsTol', 10*tc.eps);
        end


        function test_rotz_vec(tc)
            R = rotz_vec([pi/2 pi/4 pi/6 pi/3 pi]);
            pi_2 = [0 -1 0; 1 0 0; 0 0 1];
            pi_4 = [sqrt(2)/2 -sqrt(2)/2 0; sqrt(2)/2 sqrt(2)/2 0; 0 0 1];
            pi_6 = [sqrt(3)/2 -1/2 0; 1/2 sqrt(3)/2 0; 0 0 1];
            pi_3 = [1/2 -sqrt(3)/2 0; sqrt(3)/2 1/2 0; 0 0 1];
            pi_1 = [-1 0 0; 0 -1 0; 0 0 1];
            tc.verifyEqual(R(:, :, 1), pi_2, 'AbsTol', 10*tc.eps);
            tc.verifyEqual(R(:, :, 2), pi_4, 'AbsTol', 10*tc.eps);
            tc.verifyEqual(R(:, :, 3), pi_6, 'AbsTol', 10*tc.eps);
            tc.verifyEqual(R(:, :, 4), pi_3, 'AbsTol', 10*tc.eps);
            tc.verifyEqual(R(:, :, 5), pi_1, 'AbsTol', 10*tc.eps);
        end

        function test_roty(tc)
            R = roty(pi/2);
            tc.verifyEqual(R, [0 0 1; 0 1 0; -1 0 0], 'AbsTol', 10*tc.eps);

            R = roty(pi/4);
            tc.verifyEqual(R, [sqrt(2)/2 0 sqrt(2)/2; 0 1 0; -sqrt(2)/2 0 sqrt(2)/2], 'AbsTol', 10*tc.eps);

            R = roty(pi/6);
            tc.verifyEqual(R, [sqrt(3)/2 0 1/2; 0 1 0; -1/2 0 sqrt(3)/2], 'AbsTol', 10*tc.eps);

            R = roty(pi/3);
            tc.verifyEqual(R, [1/2 0 sqrt(3)/2; 0 1 0; -sqrt(3)/2 0 1/2], 'AbsTol', 10*tc.eps);

            R = roty(pi);
            tc.verifyEqual(R, [-1 0 0; 0 1 0; 0 0 -1], 'AbsTol', 10*tc.eps);
        end

        function test_chord2ang(tc)
            tc.verifyEqual(chord2ang(1, 1), 2*asin(1), 'AbsTol', 10*tc.eps);
            tc.verifyEqual(chord2ang(1, 2), 2*asin(1/2), 'AbsTol', 10*tc.eps);
            tc.verifyEqual(chord2ang(2, 1), 2*asin(2), 'AbsTol', 10*tc.eps);

            % Check that the inverse of chord2ang is chord
            radius = 1.5;
            theta = deg2rad(30);
            chord = @(radius, theta) 2 * radius * sin(theta/2);
            tc.verifyEqual(chord2ang(chord(radius, theta), 2*radius), theta, 'AbsTol', 10*tc.eps);
            
            radius = 2.5;
            theta = deg2rad(45);
            tc.verifyEqual(chord2ang(chord(radius, theta), 2*radius), theta, 'AbsTol', 10*tc.eps);

            radius = 3.5;
            theta = deg2rad(60);
            tc.verifyEqual(chord2ang(chord(radius, theta), 2*radius), theta, 'AbsTol', 10*tc.eps);
        end

        function test_units(tc)
            % Below should be changed if the basis of the units changes - Be very careful changing this.
            tc.verifyEqual(units.cm, 1); 
            tc.verifyEqual(units.m , units.cm*100 , 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.mm, units.cm/10  , 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.um, units.mm/1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.nm, units.um/1000, 'RelTol', 4*tc.eps);

            tc.verifyEqual(units.m2 , units.m ^2, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.cm2, units.cm^2, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.mm2, units.mm^2, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.um2, units.um^2, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.nm2, units.nm^2, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.barn, units.cm2*1e-24, 'RelTol', 4*tc.eps);

            % Mass (Change below if the basis of the units changes) - Be very careful changing this.
            tc.verifyEqual(units.g, 1);
            tc.verifyEqual(units.kg, units.g *1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.mg, units.g /1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.ug, units.mg/1000, 'RelTol', 4*tc.eps);

            % Energy (Change below if the basis of the units changes) - Be very careful changing this.
            tc.verifyEqual(units.keV, 1)
            tc.verifyEqual(units.MeV, units.keV*1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.eV , units.keV/1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.meV, units.eV /1000, 'RelTol', 4*tc.eps);

            % Time (Change below if the basis of the units changes) - Be very careful changing this.
            tc.verifyEqual(units.s, 1);
            tc.verifyEqual(units.ms, units.s /1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.us, units.ms/1000, 'RelTol', 4*tc.eps);
            tc.verifyEqual(units.ns, units.us/1000, 'RelTol', 4*tc.eps);
        end


    end
end