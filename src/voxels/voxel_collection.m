classdef voxel_collection
    properties
        voxel_objs   % cell array of voxel objects
    end

    methods
        function self = voxel_collection(varargin)
            for i = 1:length(varargin)
                if ~(isa(varargin{i}, 'voxel_object') || isa(varargin{i}, 'voxel_collection'))
                    error('MATLAB:InvalidInput', 'All inputs must be of type voxel_object or voxel_collection.');
                end
            end
            self.voxel_objs = varargin;
        end
        
        function mu = get_mu(self, i, j, k, energy)
            mu = zeros(1, length(i));
            for v = self.voxel_objs
                mu(v{1}.is_in_object(i, j, k)) = v{1}.get_mu(i, j, k, energy);
            end
        end

        function mat = get_material(self, i, j, k)
            arguments
                self
                i (1, 1) double
                j (1, 1) double
                k (1, 1) double
            end
            for v = self.voxel_objs
                if v{1}.is_in_object(i, j, k)
                    mat = v{1}.material;
                end
            end
        end
    end
end