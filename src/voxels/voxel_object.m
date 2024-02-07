classdef voxel_object
    properties
        is_in_object    % A function handle that determines whether a point is in the object
        material        % The material of the object
        get_mu          % A function handle that returns the attenuation coefficient of the material
    end
    methods
        function self = voxel_object(is_in_object, material)
            self.is_in_object = is_in_object;
            self.material = material;
            self.get_mu = @(energy) material.get_mu(energy);
        end
    end
end
