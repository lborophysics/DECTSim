%function to test accuracy of fittings:
%outputs array of percentage difference between NIST attenuation data and
%attenuation estimated using NIST energy and fourier 8 fitting function

function [p_diff_vec, p_diff_max] = get_p_diff(name)
    %initialise materials class
    materials_class = Materials;

    %get NIST data:
    NIST_data = materials_class.get_NIST_data(name);
    NIST_energy = NIST_data.energy;

    NIST_energy = NIST_energy(25:end,:);
    disp(NIST_energy(1,1))
    
    NIST_attenuation = NIST_data.attenuation; 
    NIST_attenuation = NIST_attenuation(25:end,:);

    %estimate attenuation vector from NIST energy:
    estimate = zeros(length(NIST_energy), 1);

    for i = 1:length(estimate)
        E = NIST_energy(i);
        estimate(i) = get_attenuation_coeffs(E, name);
    end

    %get percentage difference
    p_diff_vec = 100*(NIST_attenuation - estimate)./(NIST_attenuation);
    p_diff_max = max(p_diff_vec);
end




