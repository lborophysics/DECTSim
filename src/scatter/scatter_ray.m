classdef scatter_ray < ray
    properties (SetAccess = private)
        n_mfp              double     % A number indicating the number of mean free paths until the next scatter event
        mu                 double = 0 % A number indicating the attenuation coefficient of the ray
        scatter_event      double = 0 % A number indicating the current scatter event 
        direction   (3, 1) double % 3D direction
        end_point   (3, 1) double % 3D point
        mfp_dict           % Dictionary of mfp values for each material
    end

    methods
        function self = scatter_ray(start_point, direction, dist_to_detector, voxels, energy)
            arguments
                start_point        double
                direction          double
                dist_to_detector   double
                voxels             voxel_array
                energy             double = 30 % The energy of the ray in keV
            end
            self@ray(start_point, direction, dist_to_detector, voxels, energy);          
            self.direction = direction;
            self.end_point = start_point + self.v1_to_v2;

            self.mfp_dict = voxels.get_mfp_dict(energy);
            self.n_mfp = -log(rand); % Control with rng(seed) for reproducibility
        end

        function self = calculate_mu (self) % I have broken symmetry with the ray class -> maybe always return ray?
            
            if isempty(self.lengths); return; end % If there are no intersections, exit
            ls = self.lengths; idxs = self.indices; % Get the lengths and indices of the intersections
            mfps = self.voxels.get_saved_mfp(idxs, self.mfp_dict); % Get the mean free path of the first intersection

            for i = 1:length(ls)
                self.n_mfp = self.n_mfp - ls(i) / mfps(i); % Update the number of mean free paths until the next scatter event

                if self.n_mfp < 0 % If the number of mean free paths is less than 0, scatter the ray
                    % Calculate the mu of the ray until the end of the current voxel
                    self.mu = self.mu + sum(ls(1:i) .* self.voxels.get_saved_mu(idxs(:, 1:i), self.mu_dict));

                    % Remove the mu of the current voxel up to the scatter event
                    self.mu = self.mu + mfps(i) * self.n_mfp * self.voxels.get_saved_mu(idxs(i), self.mu_dict);

                    % Get the new direction and energy of the ray, and update the start point
                    [ndirection, energy] = self.scatter();
                    start_point = self.start_point + (sum(ls(1:i)) + self.n_mfp * mfps(i)) .* self.direction; 
                    
                    % Create a new ray with the new direction, energy, and start point
                    new_ray = scatter_ray(start_point, ndirection, sum(ls), self.voxels, energy);
                    new_ray.mu = self.mu; % Set the mu of the new ray to the mu of the old ray
                    new_ray.scatter_event = self.scatter_event + 1; % Update the scatter event of the new ray
                    self = new_ray.calculate_mu(); % Get the mu of the new ray
                    return % Return the mu of the new ray
                end
            end

            self.mu = self.mu + sum(ls .* self.voxels.get_saved_mu(idxs, self.mu_dict));  % This case only occurs if the ray does not scatter
        end

        function [direction, energy] = scatter(self) % Not sure if this needs to be separate?
            % Scatter the ray
            E_0 = self.energy; % Initial energy
            direction = self.direction; % Initial direction

            e_0 = constants.em_ee / (constants.em_ee + 2*E_0); % Initial energy fraction
            e_02 = e_0^2; % Initial energy fraction squared
            twolog1_e_0 = 2*log(1/e_0); 
            insuitable = true; % A flag to indicate if the new direction is suitable
            while insuitable
                if rand < twolog1_e_0/(twolog1_e_0 - e_02 + 1)
                    e = e_0^rand;
                else
                    e = sqrt(e_02 + (1 - e_02) * rand);
                end
                t = (constants.em_ee * (1 - e) / (E_0 * e));
                cos_theta = 1 - t;
                sin2_theta = t * (2 - t);
                insuitable = 1 - (e*sin2_theta)/(1 + e^2) >= rand;
            end
            sin_theta = sqrt(sin2_theta);
            phi = 2 * pi * rand;

            change_frame = false; % This is to prevent gimbal lock from z-axis rotation
            if max(abs(direction)) == abs(direction(3))
                 change_frame = true;
                 direction = roty(pi/2) * direction;
            end

            direction = rotateUz(direction, sin_theta, cos_theta, phi);

            if change_frame; direction = roty(-pi/2) * direction; end

            energy = ((constants.em_ee * E_0) / (constants.em_ee + E_0 * (1 - cos_theta)));
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

function R = roty(angle)
    arguments
        angle (1,1) double
    end
    % Computes the y-rotation matrix for a given angle in radians
    % Input:
    %   angle - the angle of rotation in radians
    % Output:
    %   R - the corresponding y-rotation matrix
    
    R = [cos(angle), 0, sin(angle); 0, 1, 0; -sin(angle), 0, cos(angle)];
end    


function u = rotateUz(u, sin_theta, cos_theta, phi)
    % Sourced from CLHEP:
    % https://apc.u-paris.fr/~franco/g4doxy4.10/html/_three_vector_8cc_source.html#l00072
    u1 = u(1); u2 = u(2); u3 = u(3);
    up = u1*u1 + u2*u2;

    if up > 0
        up = sqrt(up);
        px = sin_theta*cos(phi); 
        py = sin_theta*sin(phi);
        pz = cos_theta;
        u(1) = (u1*u3*px - u2*py)/up + u1*pz;
        u(2) = (u2*u3*px + u1*py)/up + u2*pz;
        u(3) = -up*px + u3*pz;
    elseif u3 < 0
        u(1) = -u(1);
        u(3) = -u(3);  % phi=0  theta=pi
    end
end