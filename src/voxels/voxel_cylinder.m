function func = voxel_cylinder(centre, radius, width, material)
%VOXEL_CYLINDER Summary of this function goes here
%   Detailed explanation goes here
    len_2 = width / 2;
    rsq = radius ^ 2;
    x = centre(1); y = centre(2); z = centre(3);
    func = @cylinder;
    material = @material.get_mu;
    function result = cylinder(i, j, k, energy)
        result = zeros(1, length(i));
        result( ...
            ((i - x) .^ 2 + (j - y) .^ 2) <= rsq &...
            (k - z <= len_2 & k - z >= -len_2) ...
            ) = material(energy);
    end
end
