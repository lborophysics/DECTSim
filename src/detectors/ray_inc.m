classdef ray_inc < ray   
    methods(Access=private) 
        
        function [lengths, indices] = get_intersections_3D(self, voxels, v12)
            ray_start = self.start_point;            

            % Get the voxel attributes
            init_plane = voxels.get_point_position([1; 1; 1]);
            dims = voxels.dimensions;
            num_planes = voxels.num_planes;

            a1 = (init_plane - ray_start) ./ v12;
            an = (init_plane + (num_planes - 1) .* dims - ray_start) ./ v12;
            a_min = max([0; min(a1, an)]); 
            a_max = min([1; max(a1, an)]);
            
            if a_max <= a_min
                lengths = []; indices = [];
                return
            end
            
            % Calculate the indices of the minimum and maximum values
            ijk_min = zeros(3, 1) ; ijk_max = zeros(3, 1);
            min_coord = (ray_start + a_min .* v12 - init_plane) ./ dims;
            max_coord = (ray_start + a_max .* v12 - init_plane) ./ dims;
            
            is_min = a_min == min([a1, an], [], 2);
            is_max = a_max == max([a1, an], [], 2);
            is_forward = v12 > 0; is_backward = v12 < 0; 
            if any(is_forward)
                ijk_min( is_min & is_forward) = 1;
                ijk_min(~is_min & is_forward) = ceil(min_coord(~is_min & is_forward));
                
                ijk_max( is_max & is_forward) = num_planes(is_max & is_forward) - 1;
                ijk_max(~is_max & is_forward) = floor(max_coord(~is_max & is_forward));
            end
            if any(is_backward)
                ijk_min( is_max & is_backward) = 0;
                ijk_min(~is_max & is_backward) = ceil(max_coord(~is_max & is_backward));

                ijk_max( is_min & is_backward) = num_planes(is_min & is_backward) - 2;
                ijk_max(~is_min & is_backward) = floor(min_coord(~is_min & is_backward));
            end         
            Nv = sum(ijk_max - ijk_min + 1); % The very maximum number of intersected voxels
            
            index = ijk_min;
            index(v12 < 0) = ijk_max(v12 < 0);

            a_c = (init_plane + index .* dims - ray_start) ./ v12;% Current a
            a_0 = a_min;
            
            index_update = ones(3, 1); index_update(v12 < 0) = -1;
            a_update = dims ./ abs(v12);
            
            n = 1;
            dist = norm(v12);
            lengths = zeros(1, Nv); 
            indices = zeros(3, Nv);
            while a_max - a_0 > 1e-14
                min_ac = min(a_c);
                planes = a_c == min_ac;
                lengths(n) = (min_ac - a_0) * dist;
                indices(:, n) = index;
                index(planes) = index(planes) + index_update(planes);
                a_c  (planes) = min_ac + a_update(planes);
                a_0 = min_ac;
                n = n + 1;
            end
            indices(v12 < 0, :) = indices(v12 < 0, :) + 1;
            indices = indices(:, lengths ~= 0);
            lengths = lengths(lengths ~= 0);
            % [lengths2, indices2] = get_intersections@ray(self, voxels)
        end
    end

    methods
        function obj = ray_inc(start_point, direction, dist_to_detector)
            arguments
                start_point      (3, 1) double
                direction        (3, 1) double
                dist_to_detector        double
            end
            obj@ray(start_point, direction, dist_to_detector);
        end

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            
            v12 = self.end_point - self.start_point; % Vector from v1 to v2
            ng_ray = abs(v12) > 1e-14; % Non-generic components of the ray

            % Get the voxel attributes
            init_plane = voxels.get_point_position([1; 1; 1]);
            dims = voxels.dimensions;

            % Calculate the index of the generic components of the ray
            if all(ng_ray) % If all components are non-generic
                [lengths, indices] = self.get_intersections_3D(voxels, v12);
                return
            elseif sum(ng_ray) == 1 % If only one component is non-generic (1-D ray)
                num_voxels = voxels.num_planes(ng_ray) - 1;
                ng_index = floor((self.start_point(~ng_ray) - init_plane(~ng_ray)) ./ dims(~ng_ray)) + 1; % The index of the non-generic 
                indices = zeros(3, num_voxels);
                indices(~ng_ray, :) = repmat(ng_index, 1, num_voxels);
                indices(ng_ray, :) = 1:num_voxels;
                lengths = zeros(1, num_voxels) + dims(ng_ray);
                return
            end
            g_coord = find(~ng_ray);
            ng_index = floor((self.start_point(g_coord) - init_plane(g_coord)) ./ dims(g_coord)) + 1;

            % Only consider the non-generic components of the ray
            ray_start = self.start_point(ng_ray);
            init_plane = init_plane(ng_ray);
            num_planes = voxels.num_planes(ng_ray);
            dims = dims(ng_ray);
            v12 = v12(ng_ray);
            
            a1 = (init_plane - ray_start) ./ v12; 
            an = (init_plane + (num_planes - 1) .* dims - ray_start) ./ v12;
            a_min = max([0; min(a1, an)]); 
            a_max = min([1; max(a1, an)]);
            
            if a_max <= a_min
                lengths = []; indices = [];
                return
            end
            
            % Calculate the indices of the minimum and maximum values
            min_coord = ceil((ray_start + a_min .* v12 - init_plane) ./ dims); 
            max_coord = floor((ray_start + a_max .* v12 - init_plane) ./ dims);
            
            is_backward = v12 < 0; 
            x_backward = is_backward(1); y_backward = is_backward(2);
            
            % Swap a1 and an if v12 < 0 
            if x_backward; axn = a1(1); ax1 = an(1);
            else;          ax1 = an(1); axn = a1(1); 
            end 
            if y_backward; ayn = a1(2); ay1 = an(2);
            else;          ay1 = an(2); ayn = a1(2); 
            end
            
            if a_min == ax1; i_min = 1 - x_backward;
            else;            i_min = min_coord(1);
            end 
            if a_max == axn; i_min = num_planes(1) - 1 - x_backward; 
            else;            i_max = max_coord(1);
            end
            
            if a_min == ay1; j_min = 1 - y_backward; 
            else;            j_min = min_coord(2);
            end
            if a_max == ayn; j_max = num_planes(2) - 1 - y_backward; 
            else;            j_max = max_coord(2);
            end
            
            Nv = sum((i_max - i_min + 1) * (j_max - j_min + 1)); % The very maximum number of intersected voxels
            a_update = dims ./ abs(v12);
            if x_backward; ix = i_max; ix_u = -1;
            else;          ix = i_min; ix_u =  1; 
            end
            if y_backward; iy = j_max; iy_u = -1;
            else;          iy = j_min; iy_u =  1;
            end
            a_c = (init_plane + [ix;iy] .* dims - ray_start) ./ v12; 
            ax_c = a_c(1); ay_c = a_c(2);
            ax_u = a_update(1); ay_u = a_update(2);
            a_0 = a_min;
            
            n = 1;
            dist = norm(v12);
            lengths = zeros(1, Nv);
            i_indices = zeros(1, Nv);
            j_indices = zeros(1, Nv);
            while a_max - a_0 > 1e-14
                min_ac = min(ax_c, ay_c);
                lengths(n) = (min_ac - a_0) * dist;
                i_indices(n) = ix + x_backward; j_indices(n) = iy + y_backward;
                if min_ac == ax_c; ix = ix + ix_u; ax_c = ax_c + ax_u; end
                if min_ac == ay_c; iy = iy + iy_u; ay_c = ay_c + ay_u; end
                a_0 = min_ac;
                n = n + 1;
            end
            indices = zeros(3, n-1);
            indices(ng_ray, :) = [i_indices(1:n-1); j_indices(1:n-1)];
            indices(g_coord, :) = ng_index;
            lengths = lengths(1:n-1);
            indices = indices(:, lengths ~= 0);
            lengths = lengths(lengths ~= 0);
            % [lengths2, indices2] = get_intersections@ray(self, voxels)
        end
    end
end
