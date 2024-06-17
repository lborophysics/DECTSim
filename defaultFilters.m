%code for filters
% Default MATLAB fiters:

function defaultFilters(R, P, theta, phantom_res)
    
    none = iradon(R, theta, 'nearest', 'None', phantom_res);% 'outputSize', 256);
    none = none(2:end-1, 2:end-1);
    figure, imshow(none,[]), title('No Filter');
    disp('none:')
    getMetrics(none,P)
    
    ramLak = iradon(R, theta,'nearest', 'ram-lak',phantom_res);
    ramLak = ramLak(2:end-1, 2:end-1);
    figure, imshow(ramLak,[]), title('Ram-Lak Filter');
    disp('ramLak:')
    getMetrics(ramLak,P)
    
    shepp = iradon(R, theta,'nearest', 'Shepp-Logan', phantom_res);
    shepp = shepp(2:end-1, 2:end-1);
    figure, imshow(shepp,[]), title('Shepp-Logan Filter');
    disp('shepp:')
    getMetrics(shepp,P)
    
    cosine = iradon(R, theta,'nearest', 'Cosine',phantom_res);
    cosine = cosine(2:end-1, 2:end-1);
    figure, imshow(cosine,[]), title('Cosine');
    disp('cosine:')
    getMetrics(cosine,P)
    
    hamming = iradon(R, theta,'nearest', 'Hamming',phantom_res);
    hamming = hamming(2:end-1, 2:end-1);
    figure, imshow(hamming,[]), title('Hamming Filter');
    disp('hamming:')
    getMetrics(hamming,P)
    
    hann = iradon(R, theta,'nearest', 'Hann',phantom_res);
    hann = hann(2:end-1, 2:end-1);
    figure, imshow(hann,[]), title('Hann Filter');
    disp('hann:')
    getMetrics(hann,P)

end
