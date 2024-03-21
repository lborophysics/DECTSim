function obj = voxel_ellipse_rotated(centre, a, b, c, angle, material)
    %VOXEL_ELLIPSE A voxel object representing an ellipsoid
    %   centre: 1x3 vector
    %   major: length of the major axis
    %   minor: length of the minor axis
    %   width: width of the ellipsoid
    %   angle: angle of rotation about the z-axis
    %   material: material of the object
    %   obj: voxel object
    arguments
        centre (3, 1) {mustBeNumeric, mustBeReal}
        a      (1, 1) {mustBeNumeric, mustBeReal, mustBePositive}
        b      (1, 1) {mustBeNumeric, mustBeReal, mustBePositive}
        c      (1, 1) {mustBeNumeric, mustBeReal, mustBePositive}
        angle  (1, 1) {mustBeNumeric, mustBeReal}
        material 
    end
    
    R = rotz(-angle);    
    centre = R * centre;
    % x = centre(1); y = centre(2); z = centre(3);
    div = [a; b; c];
    obj = voxel_object(@ellipse, material);

    function result = ellipse(i, j, k)
        new_frame = R * [i; j; k];
        % result = ((new_frame(1, :) - x) / a) .^ 2 + ...
        %          ((new_frame(2, :) - y) / b) .^ 2 + ...
        %          ((new_frame(3, :) - z) / c) .^ 2 <= 1;
        result = sum(((new_frame - centre) ./ div) .^ 2, 1) <= 1;
    end
end 