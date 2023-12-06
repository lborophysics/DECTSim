function func = voxel_shepp_logan(centre, phantom_size, voxel_size)
    % This function returns a function handle that can be used to create a cross of size cross_size
    func = @shepp_logan;
    array_size = floor(phantom_size / voxel_size);
    left_corner = centre - phantom_size / 2;
    twoD_phantom = phantom(array_size);
    function result = shepp_logan(i, j, ~, ~)
        % Convert coordinates to indices
        i = floor((i - left_corner(1)) / voxel_size);
        j = floor((j - left_corner(2)) / voxel_size);
        i(i>array_size | i<1) = 1; % Set to the (1, 1) coordinate
        j(j>array_size | j<1) = 1;
        n = sub2ind([array_size, array_size], i, j);
        result = twoD_phantom(n);
    end
end