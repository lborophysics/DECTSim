%Dect main v2:

%% IMAGE BASED APPROACH  
close all; 
clear all;
clc;

%define two photon energies
E1 = 47e-3; %MeV (70 keV)
E2 = 100e-3; %MeV (150 keV)

%generate acr phantoms with custom attenuation for each energy:
P_E1 = get_phantom_var_energy(E1, 'acr');
P_E2 = get_phantom_var_energy(E2, 'acr');
figure, imshow(P_E1), title('E1 ACR phantom');
figure, imshow(P_E2), title('E2 ACR phantom');

%define angle sweep and phantom dimensions:
phantom_res = length(P_E1);
acquisition_angle_res = 1; %degrees
theta = 0:acquisition_angle_res:179;

%get sinograms
[R1, xp1] = sinogram(P_E1, theta);
[R2, xp2] = sinogram(P_E2, theta);

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

%filtered backprojection with no filter
%I1 = iradon(R1_noise, theta, 'None');
%I2 = iradon(R2_noise, theta, 'None');

%To display reconstruction - normalise reconstruction (array) to have all
%values between 0 and 1;
I1_max = max(I1, [], 'all');
I2_max = max(I2, [], "all");

I1_norm = I1/I1_max;
I2_norm = I2/I2_max;

figure, imshow(I1_norm), title('E1 ACR phantom reconstruction');
figure, imshow(I2_norm), title('E2 ACR phantom reconstruction');

%Combine images I1_norm and I2_norm:
%normalise and weight reconstructions WRT water mean attenuation
%water is often used to calibrate in CT
I1_water_mean = 0.482681;
I2_water_mean = 0.930128;

I1_norm = I1./I1_water_mean;
I2_norm = I2./I2_water_mean;
DECT_times = I1_norm .* I2_norm;
DECT_times_norm = DECT_times/(max(DECT_times,[],'all'));

figure, imshow(DECT_times_norm), title('DECT ACR reconstruction');

%get metrics for each reconstruction:
getMetrics(I1_norm, P_E1)
getMetrics(I2_norm, P_E2)

ref_DECT = (P_E1.*P_E2)/(max((P_E1.*P_E2),[],'all'));
getMetrics(DECT_times_norm, ref_DECT )

%get CNR for each reconstruction
%does not require normalisation anyway
air_E1  = get_CNR_acr(I1_norm, 'air') ;
air_E2  = get_CNR_acr(I2_norm, 'air') ;
disp('DECT:')
air_DECT= get_CNR_acr(DECT_times_norm, 'air') ;

bone_E1 = get_CNR_acr(I1_norm, 'bone');
bone_E2 = get_CNR_acr(I2_norm, 'bone');
disp('DECT:')
bone_DECT = get_CNR_acr(DECT_times_norm, 'bone');

pol_E1 = get_CNR_acr(I1_norm, 'polyethylene');
pol_E2 = get_CNR_acr(I2_norm, 'polyethylene');
disp('DECT:')
pol_DECT = get_CNR_acr(DECT_times_norm, 'polyethylene');

acryl_E1 = get_CNR_acr(I1_norm, 'acrylic');
acryl_E2 = get_CNR_acr(I2_norm, 'acrylic');
disp('DECT:')
acryl_DECT = get_CNR_acr(DECT_times_norm, 'acrylic');


