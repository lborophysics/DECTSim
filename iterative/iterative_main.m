%iterative main:

%{

step 1:
generate a reference phantom (DONE)
generate actual phantom that we are imaging: aka reference phantom but with
a bit of noise! (DONE)

step 2:
image the phantom and obtain sinogram data

step 3: 
inverse radon transform the sinogram data

step 4:
comparison to reference oahntom 

step 5: 
enter iterative loop:
compute likelihood function, 
maximise likelihood function
to find fn+1 
%}

phantom_res = 512;
ref_phantom = phantom(phantom_res);

figure, imshow(ref_phantom), title('Reference Phantom')

%generate phantom for imaging by adding white gaussian noise to the
%reference phantom

signal_power = mean(ref_phantom, "all");
imaging_phantom = awgn(ref_phantom, 20, signal_power);

figure, imshow(imaging_phantom), title('Imaging Phantom');

%information for sinogram generation
acquisition_angle_res = 1;
theta = 0:acquisition_angle_res:179;

%call iteration function
%[converged_image, niter] = iterative_method_v1(ref_phantom, imaging_phantom, theta, phantom_res);


%% SINOGRAM WITH AND WITHOUT NOISE PLOT:

%Generate first sinogram:
[R_0, xp_0] = sinogram(ref_phantom, theta);

%Add white Gaussian noise to the sinogram (aquired data)
%to simulate detector noise
%note: noise varies with administered dose. Change this to a function
%later in the project.

mean_signal_power = mean(R_0, "all");
R_0 = awgn(R_0, 30, mean_signal_power);


figure, hold on;
imagesc(R_0) %,[],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
colormap gray;
%  title('Sinogram of Shepp-Logan phantom');
title('Sinogram with Noise');
xlabel('\theta (degrees)');
ylabel('x''');
axis tight;
%colormap(gca,hot),

colorbar;
hold off;


%reconstruction1(R_0, theta, phantom_res)
