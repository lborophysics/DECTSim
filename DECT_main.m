%% DECT MAIN
%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get three ACR phantoms of different energies

%choose 3 different energies:
E1 = 1e-3; %MeV
E2 = 1e-1; %MeV
E3 = 10;   %MeV

%generate phantoms with custom attenuation for each energy:
P_E1 = get_phantom_var_energy(E1, 'acr');
P_E2 = get_phantom_var_energy(E2, 'acr');
P_E3 = get_phantom_var_energy(E3, 'acr');

%compare plots!
figure, imshow(P_E1), title(['ACR phantom for photon of energy ', num2str(E1), ' MeV'])
figure, imshow(P_E2), title(['ACR phantom for photon of energy ', num2str(E2), ' MeV'])
figure, imshow(P_E3), title(['ACR phantom for photon of energy ', num2str(E3), ' MeV'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot NIST data on one plot

%initialise materials class
materials_class = Materials;

names = [ "water"; "bone"; "air"; "polyethylene"];
figure, 
title("NIST data"), xlabel("log Photon Energy [MeV]"), ylabel("log Attenuation [cm^2/g]");
hold on;
label = [];
for i = 1:length(names)
    name = names(i);
    data = materials_class.get_NIST_data(name);
    energy = data.energy;
    attenuation = data.attenuation;
    label = [label; name ];
    plot(log(energy), log(attenuation), "LineWidth", 2), legend(label), hold on;
end
hold off;
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FBP for two photon energies. Comparison to DECT. 
close all; 
clear all;
clc;

%define two photon energies
E1 = 47e-3; %MeV (70 keV)
E2 = 100e-3; %MeV (150 keV)

%generate acr phantoms with custom attenuation for each energy:
P_E1 = get_phantom_var_energy(E1, 'acr');
P_E2 = get_phantom_var_energy(E2, 'acr');

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

figure, imshow(I1), title('E1 ACR phantom reconstruction');
figure, imshow(I2), title('E2 ACR phantom reconstruction');

%combine sinograms to obtain DECT image:
DECT_sinogram = 0.5*R1_noise + 0.5*R2_noise;
I_DECT = iradon(DECT_sinogram, theta,'linear', 'Hann', phantom_res);

%Reconstruction metrics relative to combination of custom phantoms:
ref_phantom = 0.5*P_E1 + 0.5*P_E2;
%For single FBP:
disp('Photon energy 47 keV:')
getMetrics(I1, ref_phantom);
disp('Photon energy 100 keV:')
getMetrics(I2, ref_phantom);
%For DECT image:
disp('DECT reconstruction metrics:')
getMetrics(I_DECT, ref_phantom);

%display DECT reconstruction
%figure, imshow(I_DECT, parula), title('DECT ACR phantom reconstruction');


%% DECT BY SUBTRACTION:
%surely these need to be calibrated?? lets make water the calibration
%Calobrate wrt different materials:

%Water calibration
centre = ceil(0.5*length(I1));
water_I1 = I1(centre, centre);
water_I2 = I2(centre, centre);
water_ratio = water_I2/water_I1;
I1_cal = I1 * water_ratio;

subtraction_DECT12 = I1_cal - I2;
subtraction_DECT21 = I2 - I1_cal;

%figure, imshow(subtraction_DECT12), title('DECT: subtraction I1-I2, water');
%figure, imshow(subtraction_DECT21), title('DECT: subtraction I2-I1, water');


r_phantom = 0.9;
r_insert = r_phantom/5; %replace this with literature value
d = r_phantom/2 * cos(pi/4);
d = ceil(d*centre);

%Air Calibration
air_I1 = I1(centre + d, centre + d);
air_I2 = I2(centre + d, centre + d);
air_ratio = air_I2/air_I1;
I1_cal = I1 * air_ratio;

subtraction_DECT12 = I1_cal - I2;
subtraction_DECT21 = I2 - I1_cal;

%figure, imshow(subtraction_DECT12), title('DECT: subtraction I1-I2, air');
%figure, imshow(subtraction_DECT21), title('DECT: subtraction I2-I1, air');

%
red_pol = subtraction_DECT21;
blue_acrylic = subtraction_DECT12;

%Bone calibration
bone_I1 = I1(centre + d, centre - d);
bone_I2 = I2(centre + d, centre - d);
bone_ratio = bone_I2/bone_I1;
I1_cal = I1 * bone_ratio;

subtraction_DECT12 = I1_cal - I2;
subtraction_DECT21 = I2 - I1_cal;

%figure, imshow(subtraction_DECT12), title('DECT: subtraction I1-I2, bone');
%figure, imshow(subtraction_DECT21), title('DECT: subtraction I2-I1, bone');

%polyethylene calibration
polyethylene_I1 = I1(centre - d, centre - d);
polyethylene_I2 = I2(centre - d, centre - d);
polyethylene_ratio = polyethylene_I2/polyethylene_I1;
I1_cal = I1 * polyethylene_ratio;

subtraction_DECT12 = I1_cal - I2;
subtraction_DECT21 = I2 - I1_cal;


%figure, imshow(subtraction_DECT12), title('DECT: subtraction I1-I2, polyethylene');
%figure, imshow(subtraction_DECT21), title('DECT: subtraction I2-I1, polyethylene');

%
green_bone = subtraction_DECT12;

%acrylic calibration
acrylic_I1 = I1(centre - d, centre + d);
acrylic_I2 = I2(centre - d, centre + d);
acrylic_ratio = acrylic_I2/acrylic_I1;
I1_cal = I1 * acrylic_ratio;

subtraction_DECT12 = I1_cal - I2;
subtraction_DECT21 = I2 - I1_cal;

blue_acrylic2 = subtraction_DECT21;

%subtraction_DECT21 = subtraction_DECT21 * 1000;
%figure, imshow(subtraction_DECT12, parula), title('DECT: subtraction I1-I2, acrylic');
%figure, imshow(subtraction_DECT21, parula), title('DECT: subtraction I2-I1, acrylic');


%addition_DECT = 0.5*(I2+I1);
%figure, imshow(addition_DECT), title('DECT addition');
%addition_DECT2 = (I2 + I1)*0.5*(0.5*water_ratio);



%% foced RGB attempt:
zeroMat = zeros(size(red_pol,1), size(red_pol,2));
%rgbPic = cat(3, red_pol, green_bone, blue_acrylic);

%maximise each channel: such that biggest value is 1 
maxRed = max(red_pol, [], "all");
red_pol_max = red_pol/ maxRed;
redChannel = cat (3, red_pol_max, zeroMat, zeroMat);

maxGreen = max(green_bone, [], "all");
green_bone_max = green_bone/ maxGreen;
greenChannel = cat(3, zeroMat, green_bone_max, zeroMat);

maxBlue = max(blue_acrylic, [], "all");
blue_acrylic_max = blue_acrylic/ maxBlue;
blueChannel = cat(3, zeroMat, zeroMat, blue_acrylic_max);


maxBlue2 = max(blue_acrylic2, [], "all");
blue_acrylic_max2 = blue_acrylic2/ maxBlue2;
blueChannel2 = cat(3, zeroMat, zeroMat, blue_acrylic_max2);

rgbPic2 = cat(3, red_pol_max, green_bone_max, blue_acrylic_max2);

figure, imshow(redChannel);
figure, imshow(greenChannel);
figure, imshow(blueChannel2);
%figure, imshow(rgbPic);
figure, imshow(rgbPic2), title('Forced RGB image');

%{
%% attempt at triple energy? 

e1 = 40;
e2 = 70;
e3 = 100;

p_e1 = get_phantom_var_energy(e1, 'acr');
p_e2 = get_phantom_var_energy(e2, 'acr');
p_e3 = get_phantom_var_energy(e3, 'acr');

%define angle sweep and phantom dimensions:
phantom_res = length(p_e1);
acquisition_angle_res = 1; %degrees
theta = 0:acquisition_angle_res:179;

%get sinograms
[r1, xp1] = sinogram(p_e1, theta);
[r2, xp2] = sinogram(p_e2, theta);
[r3, xp3] = sinogram(p_e3, theta);

%add noise to sinograms 
R1_noise = awgn(r1, 35, 'measured');
R2_noise = awgn(r2, 35, 'measured');
R3_noise = awgn(r3, 35, 'measured');

%filtered backprojection with Hann filter
i1 = iradon(R1_noise, theta,'linear', 'Hann', phantom_res);
i2 = iradon(R2_noise, theta,'linear', 'Hann', phantom_res);
i3 = iradon(R2_noise, theta,'linear', 'Hann', phantom_res);

redM = max(i1, [], "all")
greenM = max(i2, [], "all")
blueM = max(i3, [], "all")

zeroC = zeros(size(i1,1), size(i1,2));
i1 = i1/redM;
i2 = i2/greenM;
i3 = i3/blueM;

redC = cat(3,i1, zeroC, zeroC);
greenC = cat(3, zeroC, i2, zeroC);
blueC = cat(3, zeroC, zeroC, i3);
figure, imshow(redC);
figure, imshow(greenC);
figure, imshow(blueC);


rgb = cat (3, i1, i2, i3);
figure, imshow(rgb)

%}


%% ANother attempt at forced RGB but with multiplication
close all; 
clear all;
clc;

%define two photon energies
E1 = 47e-3; %MeV (70 keV)
E2 = 100e-3; %MeV (150 keV)

%generate acr phantoms with custom attenuation for each energy:
P_E1 = get_phantom_var_energy(E1, 'acr');
P_E2 = get_phantom_var_energy(E2, 'acr');

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

figure, imshow(I1), title('E1 ACR phantom reconstruction');
figure, imshow(I2), title('E2 ACR phantom reconstruction');

%% GET A DECT MULTIPLICATION IMAGE BY CALIBRATING RELATIVE TO EACH MATERIAL

%Water calibration
centre = ceil(0.5*length(I1));
water_I1 = I1(centre, centre);
water_I2 = I2(centre, centre);
water_ratio = water_I2/water_I1;
I1_cal = I1 * water_ratio;
DECT_water = I2 .* I1_cal;


r_phantom = 0.9;
r_insert = r_phantom/5; %replace this with literature value
d = r_phantom/2 * cos(pi/4);
d = ceil(d*centre);
%Air Calibration
air_I1 = I1(centre + d, centre + d);
air_I2 = I2(centre + d, centre + d);
air_ratio = air_I2/air_I1;
I1_cal = I1 * air_ratio;
DECT_air = I2 .* I1_cal;

%Bone calibration
bone_I1 = I1(centre + d, centre - d);
bone_I2 = I2(centre + d, centre - d);
bone_ratio = bone_I2/bone_I1;
I1_cal = I1 * bone_ratio;
DECT_bone = I2 .* I1_cal;

%polyethylene calibration
polyethylene_I1 = I1(centre - d, centre - d);
polyethylene_I2 = I2(centre - d, centre - d);
polyethylene_ratio = polyethylene_I2/polyethylene_I1;
I1_cal = I1 * polyethylene_ratio;
DECT_pol =  I2 .* I1_cal;

%acrylic calibration
acrylic_I1 = I1(centre - d, centre + d);
acrylic_I2 = I2(centre - d, centre + d);
acrylic_ratio = acrylic_I2/acrylic_I1;
I1_cal = I1 * acrylic_ratio;
DECT_acryl =  I2 .* I1_cal;

%% foced RGB attempt:
zeroMat = zeros(size(DECT_pol,1), size(DECT_pol,2));

%maximise each channel: such that biggest value is 1
%red = polyethylene:
maxRed = max(DECT_pol, [], "all");
red = DECT_pol/ maxRed;
redChannel = cat (3, red, zeroMat, zeroMat);

maxGreen = max(DECT_bone, [], "all");
green = DECT_bone/ maxGreen;
greenChannel = cat(3, zeroMat, green, zeroMat);

maxBlue = max(DECT_acryl, [], "all");
blue= DECT_acryl/ maxBlue;
blueChanne = cat(3, zeroMat, zeroMat, blue);

rgbPic = cat(3, red, green, blue);

gbPic = cat(3, zeroMat, green, blue);
figure, imshow(gbPic)
rbPic = cat(3,red, zeroMat,blue);
figure, imshow(rbPic)

figure, imshow(redChannel);
figure, imshow(greenChannel);
figure, imshow(blueChannel);
figure, imshow(rgbPic), title('Forced RGB image');
