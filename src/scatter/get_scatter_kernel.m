function kernel = get_scatter_kernel()
    % Taken from XCIST see the XCIST_LICENSE
    fileID = fopen("scatter_kernel.dat", "r");
    kernel = fread(fileID, 'float32'); 
    kernel = reshape(kernel, 65, 49)'; % Transpose as matlab is column major, while data is currently row major 
    kernel = kernel / sum(kernel, "all");
end