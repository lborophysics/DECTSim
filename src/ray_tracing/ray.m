classdef ray < handle
    properties (SetAccess=protected)
        start_point (3, 1) double % 3D point
        end_point   (3, 1) double % 3D point
        direction   (3, 1) double % unit vector

        energy             double % energy of the ray in KeV
    end

    properties (Access=private)
        dist_to_detector double % distance to the detector
        v1_to_v2  (3, 1) double % Vector from start_point to end_point
    end

    properties (Access=private, Constant)
        use_mex = ~~exist('ray_trace_mex', 'file'); % Use the MEX implementation of the photon_attenuation package if available
    end
    
    methods
        function self = ray(start_point, direction, dist_to_detector, energy)
            arguments
                start_point (3, 1) double
                direction   (3, 1) double
                dist_to_detector   double
                energy             double = 30 %KeV
            end
            self.start_point      = start_point;
            self.direction        = direction;
            self.dist_to_detector = dist_to_detector;
            self.v1_to_v2         = direction .* dist_to_detector;
            self.end_point        = start_point + direction .* dist_to_detector;

            self.energy = energy;
        end

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            if self.use_mex
                [lengths, indices] = ray_trace_mex(...
                        self.start_point, self.v1_to_v2, voxels.array_position, ...
                        voxels.get_point_position(voxels.num_planes), ...
                        voxels.dimensions, voxels.num_planes...
                    );
            else
                [lengths, indices] = ray_trace(...
                        self.start_point, self.v1_to_v2, voxels.array_position, ...
                        voxels.get_point_position(voxels.num_planes), ...
                        voxels.dimensions, voxels.num_planes...
                    );
            end
        end

        function mu = calculate_mu (self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            % Using the assumption that the ray's energy is constant
            % Create a dictionary of the values of mu for each material
            mu_dict = voxels.get_mu_dict(self.energy);

            % Calculate the mu of the ray
            [lengths, indices] = self.get_intersections(voxels);
            if isempty(lengths) % No intersections
                mu = 0;
            else
                mu = sum(lengths .* voxels.get_saved_mu(indices(1, :), indices(2, :), indices(3, :), mu_dict));
            end
        end

        function update_parameters(self, new_start_point, new_direction)
            arguments
                self            ray
                new_start_point (3, 1) double
                new_direction   (3, 1) double
            end
            self.start_point = new_start_point;
            self.direction   = new_direction;
            self.end_point   = new_start_point + new_direction .* self.dist_to_detector;
        end

        function move_start_point(self, new_start_point)
            arguments
                self            ray
                new_start_point (3, 1) double
            end
            self.start_point = new_start_point;
            self.end_point = new_start_point + self.direction .* self.dist_to_detector;
        end
    end
end
