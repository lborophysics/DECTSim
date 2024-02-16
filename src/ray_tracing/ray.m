classdef ray
    properties (SetAccess=immutable)
        start_point (3, 1) double % 3D point
        v1_to_v2    (3, 1) double % Vector from start_point to end_point
        lengths            % Length of the ray in each voxel
        indices            % Indices of the voxels the ray intersects
    end

    properties (SetAccess=protected)
        energy             double % energy of the ray in KeV
        voxels             voxel_array % The voxel array the ray will be traced through
        mu_dict            % Dictionary of mu values for each material
    end

    properties (Access=private, Constant)
        use_mex = ~~exist('ray_trace_mex', 'file'); % Use the MEX implementation of the ray tracing if available
    end
    
    methods
        function self = ray(start_point, direction, dist_to_detector, voxels, energy)
            arguments
                start_point (3, 1) double
                direction   (3, 1) double
                dist_to_detector   double
                voxels             voxel_array
                energy             double = 30 %KeV
            end
            self.start_point      = start_point;
            self.v1_to_v2         = direction .* dist_to_detector;

            self.energy = energy;

            % Using the assumption that the ray's energy is constant
            % Create a dictionary of the values of mu for each material
            self.mu_dict = voxels.get_mu_arr(energy);
            [self.lengths, self.indices] = self.get_intersections(voxels);
            self.voxels = voxels;
        end

        function [lengths, indices] = get_intersections(self, voxels)
            arguments
                self   ray
                voxels voxel_array
            end
            if self.use_mex
                [lengths, indices] = ray_trace_mex(...
                        self.start_point, self.v1_to_v2, voxels.array_position, ...
                        voxels.dimensions, voxels.num_planes...
                    );
            else
                [lengths, indices] = ray_trace(...
                        self.start_point, self.v1_to_v2, voxels.array_position, ...
                        voxels.dimensions, voxels.num_planes...
                    );
            end
        end

        function mu = calculate_mu (self)
            % I don't see the point of this function if we precalculate everything else
            % Maybe for testing and consistency with the scattered ray class
            
            % Calculate the mu of the ray
            if isempty(self.lengths) % No intersections
                mu = 0;
            else
                mu = sum(self.lengths .* self.voxels.get_saved_mu(self.indices, self.mu_dict));
            end
        end

        function self = update_energy(self, new_energy)
            self.energy = new_energy;
            self.mu_dict = self.voxels.get_mu_arr(new_energy);
        end
    end
end
