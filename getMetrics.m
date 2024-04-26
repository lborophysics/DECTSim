%display image comparison metrics. 

function getMetrics(image, P)
    
    %verify sizes
    if size(image) == size(P)
    elseif size(image)>size(P)
        diffx = size(image,1)-size(P,1);
        diffy = size(image,2)-size(P,2);
        image = image(1+0.5*ceil(diffx):end-0.5*ceil(diffx), 1+0.5*ceil(diffy):end-0.5*ceil(diffy));
    elseif size(image)<size(P)
        diffx = size(P,1)-size(image,1);
        diffy = size(P,2)-size(image,2);
        P = P(1+0.5*ceil(diffx):end-0.5*ceil(diffx), 1+0.5*ceil(diffy):end-0.5*ceil(diffy));
    end
    
    %compute
    ssimval = ssim(image,P);
    peaksnr = psnr(image, P);

    %output
    disp(['Structural Similarity Index (ssim): ', num2str(ssimval), '.'])
    disp(['Peak Signal to Noise Ratio (psnr): ', num2str(peaksnr), ' dB.'])

end
