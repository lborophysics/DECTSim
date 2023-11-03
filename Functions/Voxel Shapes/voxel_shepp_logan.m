function func = voxel_shepp_logan(voxel_size)
    % This function returns a function handle that can be used to create a cross of size cross_size
    func = @voxel_cross;
    twoD_phantom = phantom(voxel_size);    
    function result = voxel_cross(i, j, k)
        indices = sub2ind([voxel_size, voxel_size], i, j);
        result = twoD_phantom(indices);
    end
end