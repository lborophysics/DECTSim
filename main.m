% MAIN SCRIPT
close all
clc
set(0,'DefaultFigureWindowStyle','docked')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% User inputted variables:
%phantom_res = 512; %phantom resolution
acquisition_angle_res = 1;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%generate shepp-logan phantom data
%[P, E] = phantom(phantom_res);

%generate custom phantoms:
my_phantom = custom_phantom('acr');
phantom_res = length(my_phantom);

figure, imshow(my_phantom);

%my_phantom2 = custom_phantom('j_sphere');
%figure, imshow(my_phantom2);


%plot phantom 
%figure; 
%imagesc(P), colormap gray; axis tight; colorbar; axis equal;
%title('Shepp-Logan phantom');

theta = 0:acquisition_angle_res:179;
[R, xp] = sinogram(my_phantom, theta);

%plot sinogram 
figure, imshow(R,[]);
xlabel('\theta (degrees)'), ylabel('x''');

%visualise 1D projections
%[x_proj, y_proj] = oneD_xy_proj(P);

% reconstruction of pahntom image from sinogram 
%I = reconstruction1(R, theta, phantom_res);
%get reconstruction comparison metrics
%getMetrics(I, P);

% add noise!
%sinNoise = awgn(R, 25, 'measured');

%reconstruct with all the filters! and the metrics

defaultFilters(R,my_phantom, theta, phantom_res);
%defaultFilters(R, P, theta, phantom_res);

%defaultFilters(sinNoise, P, theta,phantom_res);


%Example access materials class:
%initialise class
materials_class = Materials;

%get air values
name = 'polyethylene';
energy = materials_class.get_NIST_data(name).energy;
attenuation = materials_class.get_NIST_data(name).attenuation;
log_E = log(energy);
log_A = log(attenuation);

%testing different curve fits 

fitType = 'fourier8';
tic;
fitobject = fit(log_E, log_A, fitType);
toc

%get data plot with fit
figure, plot(fitobject,log_E, log_A), hold on;
title(['Material: ' name, ', Fit Type: ' fitType]),
xlabel('log Photon Energy [keV]'), ylabel('log Attenuation [cm^2/g]'),
hold off;

%get all material plots:
mat = ["air" "water" "bone" "polyethylene"];
for i = 1:length(mat)
    materials_class.plot_material_parameters(mat{i});
end



%% Redoing noise analysis:
clear all;
clc;
close all;

P = phantom(256);
figure, imshow(P), title('Shepp-Logan Phantom')

theta = 0:179;
[R, xp] = sinogram(P, theta);

%add noise to sinograms 
R_mean = mean(R, "all");
R_SNR = 10*log10(sqrt(R_mean));
R_noise = awgn(R, R_SNR);

%filtered backprojection with all filters

I1 = iradon(R_noise, theta,'linear', 'None', 256);
I2 = iradon(R_noise, theta,'linear', 'Ram-Lak', 256);
I3 = iradon(R_noise, theta,'linear', 'Shepp-Logan', 256);
I4 = iradon(R_noise, theta,'linear', 'Cosine', 256);
I5 = iradon(R_noise, theta,'linear', 'Hamming', 256);
I6 = iradon(R_noise, theta,'linear', 'Hann', 256);

I1_max = max(I1, [], 'all');
I2_max = max(I2, [], "all");
I3_max = max(I3, [], 'all');
I4_max = max(I4, [], "all");
I5_max = max(I5, [], 'all');
I6_max = max(I6, [], "all");

I1_norm = I1/I1_max;
I2_norm = I2/I2_max;
I3_norm = I3/I3_max;
I4_norm = I4/I4_max;
I5_norm = I5/I5_max;
I6_norm = I6/I6_max;

figure, imshow(I1_norm), title('None');
getMetrics(I1, P)

figure, imshow(I2_norm), title('Ram-Lak');
getMetrics(I2, P)

figure, imshow(I3_norm), title('Shepp-Logan');
getMetrics(I3, P)

figure, imshow(I4_norm), title('Cosine');
getMetrics(I4, P)

figure, imshow(I5_norm), title('Hamming');
getMetrics(I5, P)

figure, imshow(I6_norm), title('Hann');
getMetrics(I6, P)

