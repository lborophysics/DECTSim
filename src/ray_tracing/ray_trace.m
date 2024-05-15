function [lengths, indices] = ray_trace(ray_start, v1_to_v2, init_plane, v_dims, num_planes)
    
    last_plane = init_plane + (num_planes - 1) .* v_dims;
    v1_to_v2 = round(v1_to_v2*1e10)/1e10;
    
    to_plane = init_plane - ray_start;
    from_plane = last_plane - ray_start;
    
    a1 = to_plane   ./ v1_to_v2;
    an = from_plane ./ v1_to_v2;

    a_min = max([0; min(a1, an)]);
    a_max = min([1; max(a1, an)]);
    
    if a_max <= a_min; lengths = []; indices = []; return; end
    
    a_min_coord = zeros(3, 1) + a_min;
    a_max_coord = zeros(3, 1) + a_max;
    a_min_coord(v1_to_v2 <= 0) = a_max;
    a_max_coord(v1_to_v2 <= 0) = a_min;

    % Ensure that the index is not less than 1 (this can happen due to floating point errors)
    index_min = max(                                                                         ...
        floor(num_planes -                                                            ... 
            (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ v_dims), ...
        [1;1;1]                                                                              ...
        );

    index_max = min(...
        ceil(1 + (ray_start - init_plane + a_max_coord .* v1_to_v2) ./ v_dims), ...
        num_planes);

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

    indices = floor(1 + ((a(2:end) + a(1:end-1)).* v1_to_v2./2 - to_plane) ./ v_dims);
    lengths = norm(v1_to_v2) * diff(a);
end

%{
Example code to run the function:
ray_trace([6;6;6], [-22;-22;-22], [-2.5;-2.5;-2.5], [1;1;1], [6;6;6])

Use above to create the mex function.
All the inputs must be double(3x1)
%}