function obj = voxel_cube(cube_centre, cube_size, material)
    % This function returns a function handle that can be used to create a cube of size cube_size
    cube_min = cube_centre - cube_size/2;
    cube_max = cube_centre + cube_size/2;
    obj = voxel_object(@cube, material);

    function result = cube(i, j, k)
        result = i >= cube_min(1) & i <= cube_max(1) & ...
                 j >= cube_min(2) & j <= cube_max(2) & ...
                 k >= cube_min(3) & k <= cube_max(3);
    end
end