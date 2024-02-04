classdef voxel_object
    properties
        is_in_object    % A function handle that determines whether a point is in the object
        material        % The material of the object
    end
    methods
        function self = voxel_object(is_in_object, material)
            self.is_in_object = is_in_object;
            self.material = material;
        end

        function mu = get_mu(self, i, j, k, energy)
            mu = zeros(1, length(i));
            is_in = self.is_in_object(i, j, k);
            mu(is_in) = self.material.get_mu(energy);
        end
    end
end
