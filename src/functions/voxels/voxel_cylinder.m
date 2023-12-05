function func = voxel_cylinder(centre, radius, width)
%VOXEL_CYLINDER Summary of this function goes here
%   Detailed explanation goes here
    len_2 = width / 2;
    rsq = radius ^ 2;
    x = centre(1); y = centre(2); z = centre(3);
    func = @cylinder;
    function result = cylinder(i, j, k)
        result = zeros(1, length(i));
        result( ...
            ((i - x) .^ 2 + (j - y) .^ 2) <= rsq &...
            (k - z <= len_2 & k - z >= -len_2) ...
            ) = 1;
    end
end

