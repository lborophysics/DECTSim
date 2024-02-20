classdef signal_tests < matlab.unittest.TestCase

    methods(Test)
        function test_air_scan(tc)
            g1 = gantry(2, 10, pi);
            a1 = parallel_detector([0.1, 0.35], [110, 20]);
            s1 = ideal_sensor([0, 100], 100);
            d1 = detector(g1, a1, s1);

            xray_source = single_energy(30);

            air = material_attenuation("air");
            scan = squeeze(sum(air_scan(xray_source, d1), 1));
            expected = zeros(110, 20, 10) + exp(-air.get_mu(30)*2);
            tc.verifyEqual(scan, expected, 'RelTol', 1e-15);
        end
    end
end