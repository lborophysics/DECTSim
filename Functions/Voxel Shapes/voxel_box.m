function func = voxel_box(box_centre, box_size)
    % This function returns a function handle that can be used to create a box of size box_size
    func = @voxel_cross;
    function result = voxel_cross(i, j, k)
        result = zeros(length(i));
        box_min = box_centre - box_size;
        box_max = box_centre + box_size;
        result(                                 ...
            i >= box_min(1) & i <= box_max(1) & ...
            j >= box_min(2) & j <= box_max(2) & ...
            k >= box_min(3) & k <= box_max(3)   ...
        ) = 1;
    end
end