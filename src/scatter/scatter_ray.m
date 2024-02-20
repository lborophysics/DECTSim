classdef scatter_ray < ray
    properties (SetAccess = private)
        start_point (3, 1) double % 3D point
        direction   (3, 1) double % 3D direction
        d2detector  (1, 1) double % Distance to the detector
        lengths     (1, :) double % Length of the ray in each voxel
        indices     (3, :) double % Indices of the voxels the ray intersects
        voxels             voxel_array % The array of voxels the ray is passing through
        mfp_arr     (1, :) double % Array of mfp values for each material indexing specific to voxels
        mu_arr      (1, :) double % Array of mu values for each material indexing specific to voxels
        n_mfp              double % A number indicating the number of mean free paths until the next scatter event
        mu                 double = 0 % A number indicating the attenuation coefficient of the ray
        scatter_event      double = 0 % A number indicating the current scatter event 
    end

    methods
        function self = scatter_ray(start_point, direction, dist_to_detector, ray_tracing, voxels, energy)
            % self@ray(start_point, direction, dist_to_detector, voxels, energy);          
            self.start_point = start_point;
            self.direction = direction;
            self.d2detector = dist_to_detector;

            [ls, idxs] = ray_tracing(start_point, direction * dist_to_detector, ...
                voxels.array_position, voxels.dimensions, voxels.num_planes);
            self.lengths = ls;
            self.indices = idxs;
            self.voxels = voxels;

            self.mfp_dict = voxels.get_mfp_arr(energy);
            self.mu_dict = voxels.get_mu_arr(energy);
            self.n_mfp = -log(rand);
        end

        function self = calculate_mu (self)
            
            % If there are no intersections, exit
            if isempty(self.lengths)
                if self.scatter_event > 0; self.mu = NaN; end
                return
            end

            % Get the lengths and indices of the intersections
            ls = self.lengths; idxs = self.indices; 
            
            % Get the mean free path of the first intersection
            mfps = self.voxels.get_saved_mfp(idxs, self.mfp_dict);
            
            % Check if the ray scatters at all
            ray_nmfp = self.n_mfp - cumsum(ls ./ mfps);
            check_nmfp = ray_nmfp < 0;
            
            if any(check_nmfp) % If the ray scatters
                % Get the index of the scatter event
                i = find(check_nmfp, 1, "first");
                
                % Calculate the mu of the ray until the end of the current voxel
                mu_to_scatter = self.voxels.get_saved_mu(idxs(:, 1:i), self.mu_dict);
                self.mu = self.mu + sum(ls(1:i) .* mu_to_scatter) + ...
                    (mfps(i) * ray_nmfp(i)) * mu_to_scatter(i); % Remove the mu of the current voxel up to the scatter event

                % Get the new direction and energy of the ray, and update the start point
                nstart_point = self.start_point + (sum(ls(1:i)) + ray_nmfp(i) * mfps(i)) .* self.direction; 
                [ndirection, energy] = self.scatter();
                
                % Create a new ray with the new direction, energy, and start point
                new_ray = scatter_ray(nstart_point, ndirection, norm(self.v1_to_v2), self.voxels, energy);
                
                % Set the mu of the new ray to the mu of the old ray and update the scatter event
                new_ray.mu = self.mu;
                new_ray.scatter_event = self.scatter_event + 1;

                % Now repeat the process for the new ray
                self = new_ray.calculate_mu();
            else
                self.mu = self.mu + sum(ls .* self.voxels.get_saved_mu(idxs, self.mu_dict));  % This case only occurs if the ray does not scatter
            end
        end

        function self = randomise_n_mfp(self)
            self.n_mfp = -log(rand);
        end
    end
end

%{
Now I have a scatter function, I need to determine, how to change the length of the ray, 
and how to check if the ray has intersected with the detector. I will likely need to have a scatter detector class.
%}