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
                    htol = tol;
                end
                cs = material_attenuation.cross_section(Z(2), E(i));
                tc.verifyEqual(cs, carbon_cs(i), 'RelTol', tol);
                
                mfp = carbon.mean_free_path(E(i));
                c_exp = 12.011 / (carbon_cs(i)*constants.N_A);
                tc.verifyEqual(mfp, c_exp, 'RelTol', tol);

                cs = material_attenuation.cross_section(Z(3), E(i));
                tc.verifyEqual(cs, silicon_cs(i), 'RelTol', tol);

                mfp = silicon.mean_free_path(E(i));
                s_exp = 28.085 / (silicon_cs(i)*constants.N_A*0.4);
                tc.verifyEqual(mfp, s_exp, 'RelTol', tol);

                cs = material_attenuation.cross_section(Z(4), E(i));
                tc.verifyEqual(cs, iron_cs(i), 'RelTol', tol);

                mfp = iron.mean_free_path(E(i));
                i_exp = 55.845 / (iron_cs(i)*constants.N_A*0.3);
                tc.verifyEqual(mfp, i_exp, 'RelTol', tol);

                cs = material_attenuation.cross_section(Z(5), E(i));
                tc.verifyEqual(cs, iodine_cs(i), 'RelTol', tol);

                mfp = iodine.mean_free_path(E(i));
                io_exp = 126.90447 / (iodine_cs(i)*constants.N_A);
                tc.verifyEqual(mfp, io_exp, 'RelTol', tol);
                
                if i > 1 % This is the far end of the fit (lowest z and energy) so it is the worst - so bad testing would have pointlessly high errors
                    cs = material_attenuation.cross_section(Z(1), E(i));
                    tc.verifyEqual(cs, hydrogen_cs(i), 'RelTol', htol);
                    
                    mfp = hydrogen.mean_free_path(E(i));
                    h_exp = 1.008 / (hydrogen_cs(i)*constants.N_A);
                    tc.verifyEqual(mfp, h_exp, 'RelTol', htol);

                    cs = comined.mean_free_path(E(i));
                    comb_exp = 1/(0.7*(0.1/(h_exp) + 0.3/(c_exp) + 0.2/(s_exp*0.4) + 0.3/(i_exp*0.3) + 0.1/(io_exp)));
                    tc.verifyEqual(cs, comb_exp, 'RelTol', tol);
                end
            end
        end
    end

end