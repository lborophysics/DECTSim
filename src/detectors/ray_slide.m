classdef ray_slide < ray    
    methods(Static, Access=private)
        function [lengths, indices, n] = update_lengths_indices(lengths, indices, n, length, index)
            lengths(n) = length;
            indices(:, n) = index;
            n = n + 1;
        end
    end
    methods
        function obj = ray_slide(start_point, direction, dist_to_detector)
            arguments
                start_point      (3, 1) double
                direction        (3, 1) double
                dist_to_detector        double
            end
            obj@ray(start_point, direction, dist_to_detector);
        end

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray_slide
                voxels voxel_array
            end
            if self.end_point(3) ~= self.start_point(3)
                [lengths, indices] = get_intersections@ray(self, voxels);
                return % This algorithm is only 2D
            end
            [lengths, indices] = get_intersections@ray(self, voxels);
        end

        function mu = calculate_mu (self, voxels)
            arguments
                self   ray_slide
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

    end
end
