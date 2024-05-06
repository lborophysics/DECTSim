classdef scatter_tests < matlab.unittest.TestCase

    methods (Test)

        function test_cross_section(tc)
            % Test the cross section of different Z and E values
            % The values were taken from https://physics.nist.gov/cgi-bin/Xcom/xcom2?Method=Elem&Output2=Hand
            Z = [1, 6, 14, 26, 53];
            E = [10, 30, 60, 100]; % keV

            hydrogen_cs = [5.993E-01 5.924e-1 5.444e-1 4.923e-1].*1e-24;
            hydrogen = material_attenuation("H", 1, 1, 1);

            carbon_cs = [2.697E+00 3.300E+00 3.188E+00 2.924E+00] .* 1e-24;
            carbon = material_attenuation("C", 6, 0.5, 1);

            silicon_cs = [5.020E+00 7.002E+00 7.118E+00 6.678E+00] .* 1e-24;
            silicon = material_attenuation("Si", 14, 1, 0.4);

            iron_cs = [7.921E+00, 1.193E+01, 1.257E+01, 1.202E+01] .* 1e-24;
            iron = material_attenuation("Fe", 26, 0.1, 0.3);

            iodine_cs = [1.255E+01 2.088E+01 2.340E+01 2.318E+01].*1e-24;
            iodine = material_attenuation("I", 53, 1, 1);

            comined = material_attenuation("HCSiFeI", Z, [0.1, 0.3, 0.2, 0.3, 0.1], 0.7);

            for i = 1:length(E)
                if E(i) <= 20
                    tol = 0.11; % https://geant4-userdoc.web.cern.ch/UsersGuides/PhysicsReferenceManual/html/electromagnetic/gamma_incident/compton/compton.html#id276
                else
                    tol = 0.06; % https://geant4-userdoc.web.cern.ch/UsersGuides/PhysicsReferenceManual/html/electromagnetic/gamma_incident/compton/compton.html#id276
                end
                cs = cross_section(Z(2), E(i));
                tc.verifyEqual(cs, carbon_cs(i), 'RelTol', tol);

                mfp = carbon.mean_free_path(E(i));
                c_exp = 12.011 / (carbon_cs(i)*constants.N_A);
                tc.verifyEqual(mfp, c_exp, 'RelTol', tol);

                cs = cross_section(Z(3), E(i));
                tc.verifyEqual(cs, silicon_cs(i), 'RelTol', tol);

                mfp = silicon.mean_free_path(E(i));
                s_exp = 28.085 / (silicon_cs(i)*constants.N_A*0.4);
                tc.verifyEqual(mfp, s_exp, 'RelTol', tol);

                cs = cross_section(Z(4), E(i));
                tc.verifyEqual(cs, iron_cs(i), 'RelTol', tol);

                mfp = iron.mean_free_path(E(i));
                i_exp = 55.845 / (iron_cs(i)*constants.N_A*0.3);
                tc.verifyEqual(mfp, i_exp, 'RelTol', tol);

                cs = cross_section(Z(5), E(i));
                tc.verifyEqual(cs, iodine_cs(i), 'RelTol', tol);

                mfp = iodine.mean_free_path(E(i));
                io_exp = 126.90447 / (iodine_cs(i)*constants.N_A);
                tc.verifyEqual(mfp, io_exp, 'RelTol', tol);

                if i > 1 % This is the far end of the fit (lowest z and energy) so it is the worst - so bad testing would have pointlessly high errors
                    cs = cross_section(Z(1), E(i));
                    tc.verifyEqual(cs, hydrogen_cs(i), 'RelTol', tol);

                    mfp = hydrogen.mean_free_path(E(i));
                    h_exp = 1.008 / (hydrogen_cs(i)*constants.N_A);
                    tc.verifyEqual(mfp, h_exp, 'RelTol', tol);

                    cs = cross_section([1, 6, 14, 26, 53], E(i));
                    tc.verifyEqual(cs, [hydrogen_cs(i), carbon_cs(i), silicon_cs(i), iron_cs(i), iodine_cs(i)], 'RelTol', tol);

                    mfp = comined.mean_free_path(E(i));
                    comb_exp = 1/(0.7*(0.1/(h_exp) + 0.3/(c_exp) + 0.2/(s_exp*0.4) + 0.3/(i_exp*0.3) + 0.1/(io_exp)));
                    tc.verifyEqual(mfp, comb_exp, 'RelTol', tol);
                end
            end

            % Test the cross section of with an array of energies
            E = [10, 30, 60, 100] .* units.keV;
            cs = cross_section(Z(2), E);
            tc.verifyEqual(cs, carbon_cs', 'RelTol', [0.11, 0.06, 0.06, 0.06]');

            cs = cross_section(Z(3), E);
            tc.verifyEqual(cs, silicon_cs', 'RelTol', [0.11, 0.06, 0.06, 0.06]');
            
            cs = cross_section(Z(4), E);
            tc.verifyEqual(cs, iron_cs', 'RelTol', [0.11, 0.06, 0.06, 0.06]');
            
            cs = cross_section(Z(5), E);
            tc.verifyEqual(cs, iodine_cs', 'RelTol', [0.11, 0.06, 0.06, 0.06]');
            
            cs = cross_section([1, 6, 14, 26, 53], E(2:end)');
            tc.verifyEqual(cs, ...
                [hydrogen_cs(2:end)', carbon_cs(2:end)', silicon_cs(2:end)', iron_cs(2:end)', iodine_cs(2:end)'],...
                'RelTol', [0.06, 0.06, 0.06]');

            h_exp = 1.008  ./ (hydrogen_cs(2:end)*constants.N_A);
            c_exp = 12.011 ./ (carbon_cs(2:end)*constants.N_A);
            s_exp = 28.085 ./ (silicon_cs(2:end)*constants.N_A*0.4);
            i_exp = 55.845 ./ (iron_cs(2:end)*constants.N_A*0.3);
            io_exp = 126.90447 ./ (iodine_cs(2:end)*constants.N_A);
            comb_exp = 1./(0.7*(0.1./(h_exp) + 0.3./(c_exp) + 0.2./(s_exp*0.4) + 0.3./(i_exp*0.3) + 0.1./(io_exp)));
            
            mfp = comined.mean_free_path(E(2:end));
            tc.verifyEqual(mfp, comb_exp', 'RelTol', [0.06, 0.06, 0.06]');
            mfp = comined.mean_free_path(E(2:end)');
            tc.verifyEqual(mfp, comb_exp', 'RelTol', [0.06, 0.06, 0.06]');
        end

        function test_angle_distribution(tc)
            % Test the energy distribution of the scattered photons
            energies = [10, 30, 60, 100, 300]' .* units.keV;
            vectors = [
                [1 0 0]
                [0 1 0]
                [0 0 1]
                [1 0 1]
                [0 1 1]
                [1 1 0]
                [1 1 1]
                ];
            num_rays = 1e3;
            num_scatter = 1e5;
            esamples = zeros(5, num_scatter) + energies;
            thetas = compton_dist(esamples);
            phis = 2*pi*rand(1, num_scatter);
            for ei = 1:length(energies)-2
                for vi = 1:height(vectors)
                    e1 = energies(ei);
                    e2 = energies(ei+2);
                    v = vectors(vi, :)' / norm(vectors(vi, :));
                    angle_dist1 = zeros(1, num_rays);
                    angle_dist2 = zeros(1, num_rays);
                    edist1 = zeros(1, num_rays);
                    edist2 = zeros(1, num_rays);
                    for i = 1:num_rays
                        a1 = thetas(ei, randi(num_scatter ,1));
                        p1 = phis(randi(num_scatter, 1));
                        [d1, e1_scttrd] = compton_scatter(v, e1, a1, p1);
                        a2 = thetas(ei+2, randi(num_scatter,1));
                        [d2, e2_scttrd] = compton_scatter(v, e2, a2, p1);

                        angle_dist1(i) = acos(dot(v, d1));
                        angle_dist2(i) = acos(dot(v, d2));
                        edist1(i) = e1_scttrd;
                        edist2(i) = e2_scttrd;
                    end
                    % Check that the energy angle relationship is correct
                     tc.verifyEqual(edist1,...
                        (constants.me_c2 .* e1) ./ ...
                        (constants.me_c2 + e1 .* (1 - cos(angle_dist1))), ...
                        "RelTol", 0.1); % 1%

                    tc.verifyEqual(edist2,...
                        (constants.me_c2 .* e2) ./ ...
                        (constants.me_c2 + e2 .* (1 - cos(angle_dist2))), ...
                        "RelTol", 0.1); % 1%
                    % Check that as the energy increases the angle of scatter decreases
                    tc.verifyTrue(mean(angle_dist1) > mean(angle_dist2))
                    tc.verifyTrue(all(angle_dist1 > 0))
                    tc.verifyTrue(all(angle_dist2 > 0))

                    % Check that the distribution produces some angles in
                    % the right areas
                    tc.verifyTrue(all(angle_dist1 < pi))
                    tc.verifyTrue(all(angle_dist2 < pi))

                    tc.verifyTrue(any(angle_dist1 < pi/2))
                    tc.verifyTrue(any(angle_dist2 < pi/2))

                    tc.verifyTrue(any(angle_dist1 > pi/2))
                    tc.verifyTrue(any(angle_dist2 > pi/2))
                end
            end
        end
    end
end