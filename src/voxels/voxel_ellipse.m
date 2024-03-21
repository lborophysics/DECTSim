function obj = voxel_ellipse(centre, a, b, c, material)
    %VOXEL_ELLIPSE A voxel object representing an 3d ellipsoid
    x = centre(1); y = centre(2); z = centre(3);
    obj = voxel_object(@ellipse, material);

    function result = ellipse(i, j, k)
        result = ((i - x) / a) .^ 2 + ((j - y) / b) .^ 2 + ((k - z) / c) .^ 2 <= 1;
    end
end 