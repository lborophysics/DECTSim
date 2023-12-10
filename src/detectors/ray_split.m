classdef ray_split < ray
    methods
        function obj = ray_split(start_point, direction, dist_to_detector)
            obj@ray(start_point, direction, dist_to_detector);
        end

        function [lengths, indices, len_a] = get_intersections_2D(self, voxels, ray_start, v1_to_v2, dims, num_planes, init_plane, last_plane)
            a1 = (init_plane - ray_start) ./ v1_to_v2;
            an = (last_plane - ray_start) ./ v1_to_v2;

            a_min = max([0; min(a1, an)]);
            a_max = min([1; max(a1, an)]);

            if a_max <= a_min
                lengths = []; indices = []; len_a = 0;
                return
            end

            a_min_coord = zeros(2, 1) + a_min;
            a_max_coord = zeros(2, 1) + a_max;
            a_min_coord(v1_to_v2 < 0) = a_max;
            a_max_coord(v1_to_v2 < 0) = a_min;

            index_min = floor(num_planes - (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ dims);
            index_max = ceil(1 + (ray_start - init_plane + a_max_coord .* v1_to_v2) ./ dims);

            a_set_x = self.get_set_a(voxels, dims(1), 1, index_min(1), index_max(1), v1_to_v2(1));
            a_set_y = self.get_set_a(voxels, dims(2), 2, index_min(2), index_max(2), v1_to_v2(2));
            a = unique([a_set_x, a_set_y, a_min, a_max]);
            a = a(a >= a_min & a <= a_max); % Remove any values outside the range and add the min and max values

            % Calculate the lengths of the intersections and calculate the indices of the intersections
            len_a = length(a);
            d_12 = norm(v1_to_v2);
            lengths = zeros(1, len_a - 1);
            indices = zeros(2, len_a - 1);
            dist_to_voxels = (ray_start - init_plane) ./ dims;
            vox_v1_to_v2_2 = v1_to_v2 ./ (2 .* dims);
            a_1 = a(2:end);
            parfor i = 1:len_a-1
                a_i = a_1(i); a_i_1 = a(i); % Pre-access the values to speed up the code
                indices(:, i) = 1 + (dist_to_voxels + ((a_i + a_i_1) .* vox_v1_to_v2_2));
                lengths(i) = d_12 * (a_i - a_i_1);
            end
            indices = floor(indices);
        end
            

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            % Get the minimum and maximum parameters of the array
            ray_start = self.start_point;
            v1_to_v2 = self.end_point - ray_start; % Vector from v1 to v2

            dims       = voxels.dimensions;
            num_planes = voxels.num_planes;
            init_plane = voxels.get_point_position([1; 1; 1]);
            last_plane = voxels.get_point_position(num_planes);

            g_ray = v1_to_v2 == 0;
            ng_ray = ~g_ray;
            if any(g_ray)
                if sum(g_ray) == 3
                    error('The ray does not move, it is a point')
                elseif sum(g_ray) == 2
                    num_voxels = voxels.num_planes(ng_ray) - 1;
                    ng_index = floor((self.start_point(g_ray) - init_plane(g_ray)) ./ dims(g_ray)) + 1; % The index of the non-generic 
                    indices = zeros(3, num_voxels);
                    indices(ng_ray, :) = 1:num_voxels;
                    indices( g_ray, :) = repmat(ng_index, 1, num_voxels);
                    lengths = zeros(1, num_voxels) + dims(ng_ray);
                    return
                % else
                %     [lengths, indices_2d, len_a] = self.get_intersections_2D(...
                %         voxels, ray_start(ng_ray), v1_to_v2(ng_ray), dims(ng_ray),...
                %         num_planes(ng_ray), init_plane(ng_ray), last_plane(ng_ray)...
                %         );
                %     if len_a == 0; indices = []; return; end
                % 
                %     indices = zeros(3, len_a-1);
                %     indices(ng_ray, :) = indices_2d;
                % 
                %     indices( g_ray, :) = floor((self.start_point(g_ray) - init_plane(g_ray)) ./ dims(g_ray)) + 1; % The index of the non-generic 
                %     indices = indices(:, lengths > 1e-14); % Remove any indices with a length of 0 (this can happen due to floating point errors)
                %     lengths = lengths(lengths > 1e-14); % Remove any lengths of 0 (this can happen due to floating point errors)
                end                
                % return
            end

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
            index_min = max(                                                     ...
                floor(num_planes -                                               ... 
                    (last_plane - ray_start - a_min_coord .* v1_to_v2) ./ dims), ...
                [1;1;1]                                                          ...
                );

            index_max = min(                                                     ...
                ceil(1 +                                                         ...    
                    (ray_start - init_plane + a_max_coord .* v1_to_v2) ./ dims), ...
                num_planes                                                       ...
                );
            
            % Get the intersection points - this is faster than a for loop
            a_set_x = self.get_set_a(voxels, dims(1), 1, index_min(1), index_max(1), v1_to_v2(1));
            a_set_y = self.get_set_a(voxels, dims(2), 2, index_min(2), index_max(2), v1_to_v2(2));
            a_set_z = self.get_set_a(voxels, dims(3), 3, index_min(3), index_max(3), v1_to_v2(3));
            
            % Get the union of the arrays
            %rmmissing is a hack to remove NaNs, need to find a better way
            a = unique([a_set_x, a_set_y, a_set_z, a_min, a_max]);
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
                indices(:, i) = 1 + (dist_to_voxels + ((a_i + a_i_1) .* vox_v1_to_v2_2));
                lengths(i) = d_12 * (a_i - a_i_1);
            end
            indices = min(floor(indices), index_max);
            indices = indices(:, lengths > 1e-14); % Remove any indices with a length of 0 (this can happen due to floating point errors)
            lengths = lengths(lengths > 1e-14); % Remove any lengths of 0 (this can happen due to floating point errors)
            % indices = indices(indices > 0 & indices <= voxels.num_planes); % Remove any indices outside the range
        end
    end
end
