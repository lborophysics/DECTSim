classdef scatter_ray < ray
    properties (SetAccess = private)
        num_scatter_events double     % A number indicating the maximum number of scatter events
        n_mfp              double     % A number indicating the number of mean free paths until the next scatter event
        mu                 double = 0 % A number indicating the attenuation coefficient of the ray
        scatter_event      double = 0 % A number indicating the current scatter event
    end
    
    methods
        function self = scatter_ray(start_point, direction, dist_to_detector, energy, num_scatter_events)
            arguments
                start_point        double
                direction          double
                dist_to_detector   double
                energy             double = 30 % The energy of the ray in keV
                num_scatter_events double = 1
            end
            self@ray(start_point, direction, dist_to_detector, energy);
            assert(num_scatter_events > 0, "The number of scatter events must be greater than 0, use ray class if no scattering is required.");
            
            self.num_scatter_events = num_scatter_events;
            self.n_mfp = -log(rand); % Control with rng(seed) for reproducibility
        end

        function [self, mu] = calculate_mu (self, voxels) % Improve this by creating a new ray and tracking that
            arguments
                self   ray
                voxels voxel_array
            end
            % Get material mu and mean free path dictionaries
            mu_dict = voxels.get_mu_dict(self.energy);
            mfp_dict = voxels.get_mfp_dict(self.energy);

            % Calculate the mu of the ray
            [ls, idxs] = self.get_intersections(voxels);
            if isempty(ls); mu = 0; return; end % If there are no intersections, return 0, as we will not scatter the ray
            
            i = 1; % Initialize the index of the intersection
            mfps = voxels.get_saved_mfp(idxs(1, :), idxs(2, :), idxs(3, :), mfp_dict); % Get the mean free path of the first intersection

            while i < length(ls)
                self.n_mfp = self.n_mfp - ls(i) / mfps(i); % Update the number of mean free paths until the next scatter event

                if self.n_mfp < 0 % If the number of mean free paths is less than 0, scatter the ray
                    % Calculate the mu of the ray up to the current intersection
                    self.mu = self.mu + sum(ls(1:i) .* voxels.get_saved_mu(idxs(1, 1:i), idxs(2, 1:i), idxs(3, 1:i), mu_dict));

                    % Scatter the ray - this will update the energy and direction of the ray
                    self.scatter();

                    % Update the dictionaries as the energy has changed
                    mu_dict = voxels.get_mu_dict(self.energy);
                    mfp_dict = voxels.get_mfp_dict(self.energy);

                    % Regenerate the ray up to the current intersection by updating the start and end points
                    self.start_point = self.start_point + sum(ls(1:i)) .* self.direction; 
                    self.end_point = self.start_point + self.direction .* sum(ls);

                    % Get the new ray trajectory
                    [ls, idxs] = self.get_intersections(voxels);
                    if isempty(ls); mu = 0; return; end % If there are no intersections, return 0, as the scattered not does not reach the detector

                    % Stop scattering if the number of scatter events is reached
                    if self.scatter_event >= self.num_scatter_events; break; end 
                    
                    % Create a new number of mean free paths until the next scatter event and reset length index
                    self.n_mfp = -log(rand); i = 0;

                    % Due to scattering, the energy will change, so we need to update the mean free path
                    mfps = voxels.get_saved_mfp(idxs(1, :), idxs(2, :), idxs(3, :), mfp_dict);
                end

                i = i + 1; % Move to the next intersection
            end

            if isempty(ls)
                mu = self.mu; 
            else
                mu = self.mu + sum(ls .* voxels.get_saved_mu(idxs(1, :), idxs(2, :), idxs(3, :), mu_dict)); 
            end
        end

        function scatter(self) % Not sure if this needs to be separate?
            % Scatter the ray
            E_i = self.energy; % Initial energy
            e_0 = constants.em_ee / (constants.em_ee + E_i); % Initial energy fraction
            e_02 = e_0^2; % Initial energy fraction squared
            twolog1_e_0 = 2*log(1/e_0); 
            insuitable = true; % A flag to indicate if the new direction is suitable
            while insuitable
                if rand < twolog1_e_0/(twolog1_e_0 - e_02 + 1)
                    e = power(e_0, rand);
                else
                    e = sqrt(e_02 + (1 - e_02) * rand);
                end
                t = (constants.em_ee * (1 - e) / (E_i * e));
                cos_theta = 1 - t;
                sin2_theta = t * (2 - t);
                insuitable = 1 - (e/(1 + e^2))*sin2_theta >= rand;
            end
            sin_theta = sqrt(sin2_theta);
            phi = 2 * pi * rand;

            self.direction = rotateUz(self.direction, sin_theta, cos_theta, phi);
            self.energy = E_i * constants.em_ee / (constants.em_ee + E_i * (1 - cos_theta));
            self.scatter_event = self.scatter_event + 1;
        end
    end
end


%{
Now I have a scatter function, I need to determine, how to change the length of the ray, 
and how to check if the ray has intersected with the detector. I will likely need to have a scatter detector class.
%}


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