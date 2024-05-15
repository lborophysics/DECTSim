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
    if all(nan_list)
        for i = 1:num_rays; lengths{i} = []; indices{i} = []; end 
        return  % No rays intersect the volume
    end

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
    index_min = max(                                                                         ...
        floor(num_planes -                                                            ... 
            (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ v_dims), ...
        [1;1;1]                                                                              ...
        );

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
    v1_to_v2 = round(v1_to_v2*1e10)/1e10;
    to_plane = init_plane - ray_start;

    if     v1_to_v2(1) == 0; xrange = [];
    elseif v1_to_v2(1) <  0; xrange = (index_max(1):-1:index_min(1)) - 1;
    else;                    xrange = (index_min(1)   :index_max(1)) - 1;
    end
    a_set_x = (to_plane(1) + (v_dims(1) * xrange)) ./ v1_to_v2(1);

    if     v1_to_v2(2) == 0; yrange = [];
    elseif v1_to_v2(2) <  0; yrange = (index_max(2):-1:index_min(2)) - 1;
    else;                    yrange = (index_min(2)   :index_max(2)) - 1;
    end
    a_set_y = (to_plane(2) + (v_dims(2) * yrange)) ./ v1_to_v2(2);

    if     v1_to_v2(3) == 0; zrange = [];
    elseif v1_to_v2(3) <  0; zrange = (index_max(3):-1:index_min(3)) - 1;
    else;                    zrange = (index_min(3)   :index_max(3)) - 1;
    end
    a_set_z = (to_plane(3) + (v_dims(3) * zrange)) ./ v1_to_v2(3);

    % Get the union of the arrays
    a = unique([a_min, a_set_x, a_set_y, a_set_z, a_max]);
    % a = sort([a_min, a_set_x, a_set_y, a_set_z, a_max]);
    a = a(a >= a_min & a <= a_max);

    idxs = floor(1 + ((a(2:end) + a(1:end-1)).* v1_to_v2./2 - to_plane) ./ v_dims);
    ls = norm(v1_to_v2) * diff(a);
end

%{
Example code to run the function:
ray_trace_many([-6,0,0; 0,-6,0; 0,0,-6; -6,-6,0; 0,0,6; 6,6,6; 6,6,6]', [1,0,0; 0,1,0; 0,0,1; 1,1,0; 0,0,-1; -1,-1,-1; 1,1,1]'.*22, [-2.5;-2.5;-2.5], [1;1;1], [6;6;6])


Use above to create the mex function.
ray_start & v1_to_v2 are double(3x:inf)
init_plane, v_dims & num_planes are double(3x1)
%}