function [lengths, indices] = ray_trace_many(ray_start, v1_to_v2, init_plane, v_dims, num_planes)
    
    num_rays = size(ray_start, 2);
    lengths = cell(1, num_rays);
    indices = cell(1, num_rays);
        
    last_plane = init_plane + (num_planes - 1) .* v_dims;
    a1 = (init_plane - ray_start) ./ v1_to_v2;
    an = (last_plane - ray_start) ./ v1_to_v2;

    a_min = max(max(min(a1, an), [], 1), 0);
    a_max = min(min(max(a1, an), [], 1), 1);
    
    % Find the which rays do not intersect the volume
    nan_list = a_max <= a_min; not_nan_list = ~nan_list;

    % Filter out any rays that do not intersect the volume
    num_intersecting_rays = num_rays - sum(nan_list, "all");
    v1_to_v2 = v1_to_v2(:, not_nan_list);
    ray_start = ray_start(:, not_nan_list);
    a_min = a_min(not_nan_list);
    a_max = a_max(not_nan_list);

    a_min_coord = zeros(3, num_intersecting_rays) + a_min;
    a_max_coord = zeros(3, num_intersecting_rays) + a_max;
    backwards = v1_to_v2 < 0;
    for i = 1:num_intersecting_rays
        a_min_coord(backwards(:, i), i) = a_max(i);
        a_max_coord(backwards(:, i), i) = a_min(i);
    end

    % Ensure that the index is not less than 1 (this can happen due to floating point errors)
    index_min = max(                                                         ...
        floor(num_planes -                                                   ... 
            (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ v_dims), 1);

    index_max = min(...
        ceil(1 + (ray_start - init_plane + a_max_coord .* v1_to_v2) ./ v_dims), ...
        num_planes);

    % Refill the arrays with NaNs
    i_min = zeros(3, num_rays);
    i_min(:, not_nan_list) = index_min;
    i_min(:, nan_list) = NaN;
    i_max = zeros(3, num_rays);
    i_max(:, not_nan_list) = index_max;
    i_max(:, nan_list) = NaN;

    rs = zeros(3, num_rays);
    rs(:, not_nan_list) = ray_start;
    rs(:, nan_list) = NaN;
    v12 = zeros(3, num_rays);
    v12(:, not_nan_list) = v1_to_v2;
    v12(:, nan_list) = NaN;

    amin = zeros(1, num_rays);
    amin(not_nan_list) = a_min;
    amin(nan_list) = NaN;
    amax = zeros(1, num_rays);
    amax(not_nan_list) = a_max;
    amax(nan_list) = NaN;
       

    parfor i = 1:num_rays
        if not_nan_list(i)
            [lengths{i}, indices{i}] = ray_trace_single(...
                rs(:, i), v12(:, i), init_plane, v_dims, ...
                i_min(:, i), i_max(:, i), amin(i), amax(i));
        else
            lengths{i} = []; indices{i} = [];
        end
    end
end

function [ls, idxs] = ray_trace_single(ray_start, v1_to_v2, init_plane, v_dims, index_min, index_max, a_min, a_max)
    v_min = init_plane + v_dims .* (index_min - 1);

    a_set_x = get_set_a(ray_start(1), v_min(1), v_dims(1), index_min(1), index_max(1), v1_to_v2(1));
    a_set_y = get_set_a(ray_start(2), v_min(2), v_dims(2), index_min(2), index_max(2), v1_to_v2(2));
    a_set_z = get_set_a(ray_start(3), v_min(3), v_dims(3), index_min(3), index_max(3), v1_to_v2(3));
    a = rmmissing(unique([a_set_x, a_set_y, a_set_z, a_min, a_max]));
    a = a(a >= a_min & a <= a_max); % Remove any values outside the range

    len_a = length(a);
    d_12 = norm(v1_to_v2);
    
    ls   = zeros(1, len_a - 1);
    idxs = zeros(3, len_a - 1);
    
    dist_to_voxels = (ray_start - init_plane) ./ v_dims;
    vox_v1_to_v2_2 = v1_to_v2 ./ (2 .* v_dims);
    
    a_1 = a(2:end);
    parfor i = 1:len_a-1
        a_i = a_1(i); a_i_1 = a(i); % Pre-access the values to speed up the code
        idxs(:, i) = 1 + (dist_to_voxels + ((a_i + a_i_1) .* vox_v1_to_v2_2));
        ls(i) = d_12 * (a_i - a_i_1);
    end
    idxs = min(floor(idxs), index_max);
    idxs = idxs(:, ls > 1e-14); % Remove any indices with a length of 0 (this can happen due to floating point errors)
    ls = ls(ls > 1e-14); % Remove any lengths of 0 (this can happen due to floating point errors)
end

function set_a = get_set_a(start_point, voxels_min, v_dims, i_min, i_max, dist_to_detector)
    % Get the set of a values for a given coordinate - created for speed reasons
    if abs(dist_to_detector) < 1e-14 % Avoid floating point errors
        set_a = []; return % No intersections as the ray is parallel to the plane
    end
    len = i_max - i_min + 1;
    da = v_dims ./ dist_to_detector;
    set_a = zeros(1, len) + da;
    set_a(1) = (voxels_min - start_point) ./ dist_to_detector;
    set_a = cumsum(set_a);
end