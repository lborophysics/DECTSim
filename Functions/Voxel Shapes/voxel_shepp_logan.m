function func = voxel_shepp_logan(centre, phantom_size, voxel_size)
    % This function returns a function handle that can be used to create a cross of size cross_size
    func = @shepp_logan;
    twoD_phantom = phantom(floor(phantom_size / voxel_size));
    function result = shepp_logan(i, j, ~)
        % Convert coordinates to indices
        i = floor((i - centre(1)) / voxel_size);
        j = floor((j - centre(2)) / voxel_size);
        result = twoD_phantom(i, j);
    end
end