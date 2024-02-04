function obj = voxel_box(box_centre, box_size, material)
    % This function returns a function handle that can be used to create a box of size box_size
    box_min = box_centre - box_size/2;
    box_max = box_centre + box_size/2;
    obj = voxel_object(@box, material);

    function result = box(i, j, k)
        result = i >= box_min(1) & i <= box_max(1) & ...
                 j >= box_min(2) & j <= box_max(2) & ...
                 k >= box_min(3) & k <= box_max(3);
    end
end