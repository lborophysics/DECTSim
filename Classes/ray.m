classdef ray
    properties
        start_point (3, 1) double % 3D point
        end_point   (3, 1) double % 3D point
        direction   (3, 1) double % unit vector

        energy      double      % energy of the ray
    end

    properties (Access=private)
        dist_to_detector double % distance to the detector
    end

    methods (Access=private)
        function set_a = get_set_a(self, voxels, v_dims, coord, i_min, i_max, dist_to_detector)
            % Get the set of a values for a given coordinate - created for speed reasons
            if abs(dist_to_detector) < 1e-14 % Avoid floating point errors
                set_a = []; return % No intersections as the ray is parallel to the plane
            end

            len = i_max - i_min + 1;
            set_a = zeros(1, len);
            set_a(1) = (voxels.get_single_coord(coord, i_min) - self.start_point(coord)) ./ dist_to_detector;
            da = v_dims ./ dist_to_detector;
            for i = 2:len
                set_a(i) = set_a(i-1) + da;
            end
        end
    end
    
    methods
        function obj = ray(start_point, direction, dist_to_detector)
            arguments
                start_point (3, 1) double
                direction   (3, 1) double
                dist_to_detector   double
            end
            obj.start_point      = start_point;
            obj.direction        = direction;
            obj.dist_to_detector = dist_to_detector;
            obj.end_point        = start_point + direction .* dist_to_detector;

            obj.energy = 1;
        end

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            % Get the minimum and maximum parameters of the array
            v1_to_v2 = self.end_point - self.start_point; % Vector from v1 to v2

            init_plane = voxels.get_point_position(1, 1, 1);
            last_plane = voxels.get_point_position(voxels.num_planes(1), voxels.num_planes(2), voxels.num_planes(3));
            
            a1 = (init_plane - self.start_point) ./ v1_to_v2;
            an = (last_plane - self.start_point) ./ v1_to_v2;

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
                    (last_plane - self.start_point - a_min_coord .* v1_to_v2) ./ voxels.dimensions), ...
                [1;1;1]                                                                              ...
                );

            index_max = min(                                                                         ...
                ceil(1 +                                                                             ...    
                    (self.start_point - init_plane + a_max_coord .* v1_to_v2) ./ voxels.dimensions), ...
                voxels.num_planes                                                                    ...
                );
            
            % Get the intersection points - this is faster than a for loop
            a_set_x = self.get_set_a(voxels, voxels.dimensions(1), 1, index_min(1), index_max(1), v1_to_v2(1));
            a_set_y = self.get_set_a(voxels, voxels.dimensions(2), 2, index_min(2), index_max(2), v1_to_v2(2));
            a_set_z = self.get_set_a(voxels, voxels.dimensions(3), 3, index_min(3), index_max(3), v1_to_v2(3));
            
            % Get the union of the arrays
            %rmmissing is a hack to remove NaNs, need to find a better way
            a = rmmissing(unique([a_set_x, a_set_y, a_set_z, a_min, a_max]));
            a = a(a >= a_min & a <= a_max); % Remove any values outside the range and add the min and max values

            % Calculate the lengths of the intersections and calculate the indices of the intersections
            len_a = length(a);
            d_12 = sqrt(sum((self.start_point - self.end_point) .^ 2));
            lengths = zeros(1, len_a - 1);
            indices = zeros(3, len_a - 1);
            dist_to_voxels = (self.start_point - init_plane) ./ voxels.dimensions;
            vox_v1_to_v2_2 = v1_to_v2 ./ (2 .* voxels.dimensions);
            for i = 2:len_a
                a_i = a(i); a_i_1 = a(i-1); % Pre-access the values to speed up the code
                indices(:, i-1) = 1 + (dist_to_voxels + ((a_i + a_i_1) .* vox_v1_to_v2_2)) ;
                lengths(i-1) = d_12 * (a_i - a_i_1);
            end
            indices = min(floor(indices), index_max);
        end

        function mu = calculate_mu (self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            % Calculate the mu of the ray

            [lengths, indices] = self.get_intersections(voxels);
            if isempty(lengths) % No intersections
                mu = 0;
            else
                mu = sum(lengths .* voxels.get_mu(indices(1, :), indices(2, :), indices(3, :)));
            end
        end

        function self = update_parameters(self, new_start_point, new_direction)
            arguments
                self            ray
                new_start_point (3, 1) double
                new_direction   (3, 1) double
            end
            self.start_point = new_start_point;
            self.direction   = new_direction;
            self.end_point   = new_start_point + new_direction .* self.dist_to_detector;
        end

        function self = move_start_point(self, new_start_point)
            arguments
                self            ray
                new_start_point (3, 1) double
            end
            self.start_point = new_start_point;
            self.end_point = new_start_point + self.direction .* self.dist_to_detector;
        end
    end
end
