function [A] = system_matrix(phantom_res, theta, R ) %R is the sinogram 
    detector_num = size(R, 1);
    angle_num = length(theta);
    pixel_len = 1; %set all pixel lengths to 1 

    %define geometry of source and detectors (SEE HOW RADON TRANSFORM
    %GEOMETRY WORKS!)

    %generate empty system matrix:
    row_num = detector_num * angle_num;
    col_num = phantom_res*phantom_res; %assuming image matrix is always square
    A = zeros(row_num, col_num);
    
    %loop through angles
    for i = 1:angle_num
        current_angle = theta(i);

        %loop through detectors
        for j = 1:detector_num
            %detector position:
            detector_pos 
            
        end

    end

end