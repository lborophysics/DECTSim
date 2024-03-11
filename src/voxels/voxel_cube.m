function obj = voxel_cube(cube_centre, cube_size, material)
    % This function returns a function handle that can be used to create a cube of size cube_size
    cube_min = cube_centre - cube_size/2;
    cube_max = cube_centre + cube_size/2;
    obj = voxel_object(@cube, material);

    function result = cube(x, y, z) 
        result = x >= cube_min(1) & x <= cube_max(1) & ...
                 y >= cube_min(2) & y <= cube_max(2) & ...
                 z >= cube_min(3) & z <= cube_max(3);
    end
end