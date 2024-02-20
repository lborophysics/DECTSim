function R = roty(angle)
    arguments
        angle (1,1) double
    end
    % Computes the y-rotation matrix for a given angle in radians
    % Input:
    %   angle - the angle of rotation in radians
    % Output:
    %   R - the corresponding y-rotation matrix
    
    R = [cos(angle), 0, sin(angle); 0, 1, 0; -sin(angle), 0, cos(angle)];
end