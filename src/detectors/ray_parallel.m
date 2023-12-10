classdef ray_parallel < ray
    methods
        function obj = ray_parallel(start_point, direction, dist_to_detector)
            obj@ray(start_point, direction, dist_to_detector);
        end

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            % Get the minimum and maximum parameters of the array
            ray_start = self.start_point;
            v1_to_v2 = self.end_point - ray_start; % Vector from v1 to v2
            %Can this be simplified when the ray is parallel to 2 planes?

            init_plane = voxels.get_point_position([1; 1; 1]);
            last_plane = voxels.get_point_position(voxels.num_planes);
            dims = voxels.dimensions;
            
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
            a_min_coord(v1_to_v2 < 0) = a_max;
            a_max_coord(v1_to_v2 < 0) = a_min;

            % Ensure that the index is not less than 1 (this can happen due to floating point errors)
            index_min = max(                                                                         ...
                floor(voxels.num_planes -                                                            ... 
                    (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ dims), ...
                [1;1;1]                                                                              ...
                );

            index_max = min(                                                                         ...
                ceil(1 +                                                                             ...    
                    (ray_start - init_plane + a_max_coord .* v1_to_v2) ./ dims), ...
                voxels.num_planes                                                                    ...
                );
            
            % Get the intersection points - this is faster than a for loop
            len = index_max - index_min + 1; total_len = max(len);
            set_ax = zeros(1, total_len); set_ay = zeros(1, total_len); set_az = zeros(1, total_len);
            ia = (voxels.get_point_position(index_min) - ray_start) ./ v1_to_v2;
            da = dims ./ v1_to_v2; 
            ia_x = ia(1); da_x = da(1); 
            ia_y = ia(2); da_y = da(2); 
            ia_z = ia(3); da_z = da(3); 
            set_ax(1) = ia_x; 
            set_ay(1) = ia_y; 
            set_az(1) = ia_z;
            parfor i = 1:total_len
                set_ax(i+1) = ia_x + i*da_x;
                set_ay(i+1) = ia_y + i*da_y;
                set_az(i+1) = ia_z + i*da_z;
            end
            % Get the union of the arrays
            %rmmissing is a hack to remove NaNs, need to find a better way
            a = rmmissing(unique([set_ax, set_ay, set_az, a_min, a_max]));
            a = a(a >= a_min & a <= a_max); % Remove any values outside the range and add the min and max values

            % Calculate the lengths of the intersections and calculate the indices of the intersections
            len_a = length(a);
            d_12 = norm(v1_to_v2);
            lengths = zeros(1, len_a - 1);
            indices = zeros(3, len_a - 1);
            dist_to_voxels = (ray_start - init_plane) ./ dims;
            vox_v1_to_v2_2 = v1_to_v2 ./ (2 .* dims);
            a_1 = a(2:end);
            parfor i = 1:len_a-1
                a_i = a_1(i); a_i_1 = a(i); % Pre-access the values to speed up the code
                indices(:, i) = 1 + (dist_to_voxels + ((a_i + a_i_1) .* vox_v1_to_v2_2)) ;
                lengths(i) = d_12 * (a_i - a_i_1);
            end
            indices = min(floor(indices), index_max);
            % indices = indices(indices > 0 & indices <= voxels.num_planes); % Remove any indices outside the range
        end
    end
end
