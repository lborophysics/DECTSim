function R = zrot(angle)
arguments
    angle (1,1) double
end
% Computes the z-rotation matrix for a given angle in radians
% Input:
%   angle - the angle of rotation in radians
% Output:
%   R - the corresponding z-rotation matrix

R = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1];

end
