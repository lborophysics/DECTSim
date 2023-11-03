function func = voxel_cross(cross_center, cross_size)
    % This function returns a function handle that can be used to create a cross of size cross_size
    func = @voxel_cross;
    cross_start = cross_center - cross_size/2;
    cross_end   = cross_center + cross_size/2;
        
    function result = voxel_cross(i, j, k)
        result = zeros(1, length(i));
        result((i >= cross_start(1) & i <= cross_end(1) | ...
                j >= cross_start(2) & j <= cross_end(2)) & ...
                k >= cross_start(3) & k <= cross_end(3)) = 10;
    end
end