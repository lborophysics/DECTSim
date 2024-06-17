function DECT=subtraction_DECT(E1, E2, acquisition_angle_res, phantom, material_1, material_2)

%E1 and E2 - X-ray tube voltages (in MeV)
%acquisition angle resolution for radon transform 
%material_1 - material relative to which I1 is normalised (string)
%material_2 - material relative to which I2 is normalised (string)


    %generate acr phantoms with custom attenuation for each energy:
    P_E1 = get_phantom_var_energy(E1, phantom);
    P_E2 = get_phantom_var_energy(E2, phantom);
    %figure, imshow(P_E1), title('E1 ACR phantom');
    %figure, imshow(P_E2), title('E2 ACR phantom');
    
    %define angle sweep and phantom dimensions:
    phantom_res = length(P_E1);
    theta = 0:acquisition_angle_res:179;
    
    %get sinograms
    [R1, ~] = sinogram(P_E1, theta);
    [R2, ~] = sinogram(P_E2, theta);
    
    %add noise to sinograms
    R1_mean = mean(R1, "all");
    R2_mean = mean(R2, "all");
    
    R1_SNR = 10*log10(sqrt(R1_mean));
    R2_SNR = 10*log10(sqrt(R2_mean));
    
    R1_noise = awgn(R1, R1_SNR);
    R2_noise = awgn(R2, R2_SNR);
    
    %filtered backprojection with Hann filter
    I1 = iradon(R1_noise, theta,'linear', 'Hann', phantom_res);
    I2 = iradon(R2_noise, theta,'linear', 'Hann', phantom_res);
    
    %figure, imshow(I1), title('E1')
    %figure, imshow(I2), title('E2')
    
    %Check: maximum and minimum array values 
    %make sure these are between 1 and 0:
    I1 = I1 + abs(min(I1, [], 'all'));
    I1 = I1 ./ max(I1, [], 'all');
    
    I2 = I2 + abs(min(I2, [], 'all'));
    I2 = I2 ./ max(I2, [], 'all');
    
    %Verify minimum and maximum values of images is between 0 and 1:
    if max(I1,[], 'all') ~= 1 || min(I1, [], 'all') ~=0
        error(message('in normalisation of reconstruction'))
    end
    
    if max(I2,[], 'all') ~= 1 || min(I2, [], 'all') ~=0
        error(message('in normalisation of reconstruction'))
    end
    
    %% get attenuation values of each material in each reconstruction
    %air
    [~,~, I1_weighting] = get_CNR_acr(I1, material_1);
    [~,~, I2_weighting] = get_CNR_acr(I2, material_2);
       
    %show this on a graph!
    I1_norm = I1 /I1_weighting;
    I2_norm = I2 /I2_weighting;
    
    %Subtraction DECT
    DECT = I1_norm- I2_norm;
    %figure, imagesc(DECT), colorbar;
    
    %normalise
    DECT = DECT - min(DECT, [], 'all');
    DECT = DECT / max(DECT, [], 'all');
    
    [CNR_air, ~, ~] = get_CNR_acr(DECT, 'air')
    [CNR_bone, ~, ~] = get_CNR_acr(DECT, 'bone')
    [CNR_pol, ~, ~] = get_CNR_acr(DECT, 'polyethylene')
    [CNR_acryl, ~, ~] = get_CNR_acr(DECT, 'acrylic')
    
    %Make reference phantom for metrics purpose:
    [~,~, P_E1_x] = get_CNR_acr(I1, material_1);
    [~,~, P_E2_x] = get_CNR_acr(I2, material_2);
    P_E1_norm = P_E1/ P_E1_x;
    P_E2_norm = P_E2/ P_E2_x;
    DECT_ref = P_E1_norm- P_E2_norm;
    DECT_ref = DECT_ref - min(DECT_ref, [], 'all');
    DECT_ref = DECT_ref / max(DECT_ref, [], 'all');
    getMetrics(DECT, DECT_ref) 

end