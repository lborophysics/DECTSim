function R = rotz_vec(angle)
arguments
    angle (1,:) double
end
% Computes the z-rotation matrix for a given angle in radians
% Input:
%   angle - the angle of rotation in radians
% Output:
%   R - the corresponding z-rotation matrix
num_angles = length(angle);
R = zeros(3, 3, num_angles);
R(1, 1, :) = cos(angle);
R(1, 2, :) = -sin(angle);
R(2, 1, :) = sin(angle);
R(2, 2, :) = cos(angle);
R(3, 3, :) = 1;
end
