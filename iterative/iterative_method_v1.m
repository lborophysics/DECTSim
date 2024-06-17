%try with both if loop and while loop
%conditions to end loop: Point of inflection of niter vs similarity index
%plot
%OR a cap of niter
function [converged_image, niter] = iterative_method_v1(ref_phantom, imaging_phantom, theta, phantom_res)
    
    %for first test: let imaging_phantom = ref_phantom;
    imaging_phantom = ref_phantom;
    %Generate first sinogram:
    [R_0, xp_0] = sinogram(imaging_phantom, theta);
    
    %Add white Gaussian noise to the sinogram (aquired data)
    %to simulate detector noise
    %note: noise varies with administered dose. Change this to a function
    %later in the project.
    
    mean_signal_power = mean(R_0, "all");
    R_0 = awgn(R_0, 20, mean_signal_power);
    
    %Generate reconstruction using fiter
    %Hann filter is used. it was deemed the best after prior work (p87 of
    %lab book)
    I_0 = iradon(R_0, theta, 'linear', 'Hann', 1, phantom_res);
    figure, imshow(I_0), title('reconstruction version 1')

    %calculate similarity index:
    %between ref_phantom and reconstruction
    ssimval_0 = ssim(I_0, ref_phantom);
    
    % generate projection vector p:
    projection_vect = flip(R_0);
    projection_vect = projection_vect(:);
    % generate current image estimate vector:
    f_vector = I_0.';
    f_vector = f_vector(:);

    %initialise iteration counter:
    niter = 0;
    max_iter = 1000; %Change later, maximum number of iteration set st that vector of ssimval has predefined length to improve performance
    ssimval_vect = zeros(max_iter, 1);

    while niter < 100 %add inflection condition here as an OR later
        %update iteration counter:
        niter = niter + 1;
      
        %LIKELIHOOD FUNCTION:
        L = likelihood_function();

        %nth sinogram (updated each loop)
        R_n = %a convolution of something with R_0??
        %nth reconstruction
        I_n = iradon(R_n, theta, 'linear', 'Hann', 1, phantom_res);
        %ssimval for nth reconstruction
        ssimval_vect(niter) = ssim(I_n, ref_phantom);
        
        %new image estimate vector f:
        
    end
    %generate vector of iteration counter for plotting:
    ssimval_vect = ssimval_vect(1:niter);
    niter_vect = 1:niter;
    figure, plot(niter_vect, ssimval_vect), hold on;
    xlabel('Number of Iterations'), ylabel('Similarity Index'),
    title('Iteration number vs reconstruction quality'),
    hold off;

    %attempt the above loop but "for".
    
end