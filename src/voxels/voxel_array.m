classdef voxel_array
    properties
        array_position (3, 1) double % position of the top left corner of the array
        num_planes     (3, 1) double % number of planes in each dimension
        dimensions     (3, 1) double % dimensions of each voxel
        voxel_obj
        is_collection  (1, 1) logical
    end
    
    methods
        function self = voxel_array(centre, object_dims, voxel_size, voxel_obj)
            arguments
                centre       (3, 1) double
                object_dims  (3, 1) double 
                voxel_size   (1, 1) double
                voxel_obj    
            end
            % Constructor method
            self.array_position = centre - object_dims ./ 2;
            
            assert(voxel_size > 0, 'Voxel dimensions must be greater than zero')
            self.dimensions = ones(3, 1) * voxel_size;

            assert(sum(object_dims ~= 0) == 3, 'There must be at least one length in each dimension')            
            self.num_planes = object_dims ./ voxel_size + 1; % +1 to include the last plane (fence post problem)
            
            % In the future, I need to create this array based on the get_voxel_mu
            self.voxel_obj = voxel_obj;
            self.is_collection = isa(voxel_obj, 'voxel_collection');
        end

        function position = get_point_position(self, indices)
            position = self.array_position + (indices - 1) .* self.dimensions;
        end

        function position = get_points_position(self, i, j, k)
            position = self.array_position + ([i;j;k] - 1) .* self.dimensions;
        end

        function plane = get_single_coord(self, coord, index)
            assert(coord <= 3 && coord >= 1, 'assert:failure', 'coord must be between 1 and 3')
            %assert(index <= self.num_planes(coord) && index >= 1, 'index must be between 1 and N(coord)')
            plane = self.array_position(coord) + (index - 1) * self.dimensions(coord);
        end

        function mu = get_mu(self, i, j, k, energy)
            % Convert indices to position at centre of voxel
            position = self.get_point_position([i; j; k]) + self.dimensions ./ 2;

            % Get mu at position
            mu = self.voxel_obj.get_mu(position(1, :), position(2, :), position(3, :), energy);
        end
        
        function [mat, id] = get_material(self, i, j, k)
            % Get material at position
            if self.is_collection
                [mat, id] = self.voxel_obj.get_material(i, j, k);
            else
                mat = self.voxel_obj.material;
                id = self.voxel_obj.id;
            end
        end

        function mfp = get_mean_free_path(self, i, j, k, energy)
            % Get mean free path of material at position
            if self.is_collection; mfp = self.voxel_obj.get_mean_free_path(i, j, k, energy);
            else;                  mfp = self.voxel_obj.get_mean_free_path(energy);
            end
        end
    end
end