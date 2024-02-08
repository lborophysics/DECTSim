function [lengths, indices] = ray_trace(ray_start, v1_to_v2, init_plane, last_plane, v_dims, num_planes)
    a1 = (init_plane - ray_start) ./ v1_to_v2;
    an = (last_plane - ray_start) ./ v1_to_v2;

    a_min = max([0, min(a1(1), an(1)), min(a1(2), an(2)), min(a1(3), an(3))]);
    a_max = min([1, max(a1(1), an(1)), max(a1(2), an(2)), max(a1(3), an(3))]);
    
    if a_max <= a_min
        lengths = []; indices = [];
        return
    end
    a_min_coord = zeros(3, 1) + a_min;
    a_max_coord = zeros(3, 1) + a_max;
    a_min_coord(v1_to_v2 <  0) = a_max;
    a_max_coord(v1_to_v2 <  0) = a_min;

    % Ensure that the index is not less than 1 (this can happen due to floating point errors)
    index_min = max(                                                                         ...
        floor(num_planes -                                                            ... 
            (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ v_dims), ...
        [1;1;1]                                                                              ...
        );

    index_max = min(...
        ceil(1 + (ray_start - init_plane + a_max_coord .* v1_to_v2) ./ v_dims), ...
        num_planes);
    v_min = init_plane + v_dims .* (index_min - 1);

    a_set_x = get_set_a(ray_start(1), v_min(1), v_dims(1), index_min(1), index_max(1), v1_to_v2(1));
    a_set_y = get_set_a(ray_start(2), v_min(2), v_dims(2), index_min(2), index_max(2), v1_to_v2(2));
    a_set_z = get_set_a(ray_start(3), v_min(3), v_dims(3), index_min(3), index_max(3), v1_to_v2(3));

    % Get the union of the arrays
    %rmmissing is a hack to remove NaNs, need to find a better way
    a = rmmissing(unique([a_set_x, a_set_y, a_set_z, a_min, a_max]));
    a = a(a >= a_min & a <= a_max); % Remove any values outside the range and add the min and max values
    
    len_a = length(a);
    d_12 = norm(v1_to_v2);
    lengths = zeros(1, len_a - 1);
    indices = zeros(3, len_a - 1);
    dist_to_voxels = (ray_start - init_plane) ./ v_dims;
    vox_v1_to_v2_2 = v1_to_v2 ./ (2 .* v_dims);
    a_1 = a(2:end);
    parfor i = 1:len_a-1
        a_i = a_1(i); a_i_1 = a(i); % Pre-access the values to speed up the code
        indices(:, i) = 1 + (dist_to_voxels + ((a_i + a_i_1) .* vox_v1_to_v2_2));
        lengths(i) = d_12 * (a_i - a_i_1);
    end
    indices = min(floor(indices), index_max);
    indices = indices(:, lengths > 1e-14); % Remove any indices with a length of 0 (this can happen due to floating point errors)
    lengths = lengths(lengths > 1e-14); % Remove any lengths of 0 (this can happen due to floating point errors)
end

function set_a = get_set_a(start_point, voxels_min, v_dims, i_min, i_max, dist_to_detector)
    % Get the set of a values for a given coordinate - created for speed reasons
    if abs(dist_to_detector) < 1e-14 % Avoid floating point errors
        set_a = []; return % No intersections as the ray is parallel to the plane
    end
    len = i_max - i_min + 1;
    set_a = zeros(1, len);
    set_a(1) = (voxels_min - start_point) ./ dist_to_detector;
    da = v_dims ./ dist_to_detector;
    for i = 2:len
        set_a(i) = set_a(i-1) + da;
    end
end