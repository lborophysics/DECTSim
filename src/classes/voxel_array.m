classdef voxel_array
    properties
        array_position (3, 1) double % position of the top left corner of the array
        num_planes     (3, 1) double % number of planes in each dimension
        dimensions     (3, 1) double % dimensions of each voxel
        get_voxel_mu   
    end
    
    methods
        function obj = voxel_array(centre, object_dims, voxel_size, get_voxel_mu)
            arguments
                centre       (3, 1) double
                object_dims  (3, 1) double
                voxel_size   (1, 1) double
                get_voxel_mu
            end
            % Constructor method
            obj.array_position = centre - object_dims ./ 2;
            
            assert(voxel_size > 0, 'Voxel dimensions must be greater than zero')
            obj.dimensions = ones(3, 1) * voxel_size;

            assert(sum(object_dims ~= 0) == 3, 'There must be at least one length in each dimension')            
            obj.num_planes = object_dims ./ voxel_size + 1; % +1 to include the last plane (fence post problem)
            
            % In the future, I need to create this array based on the get_voxel_mu
            obj.get_voxel_mu = get_voxel_mu;
        end

        function position = get_point_position(obj, indices)
            position = obj.array_position + (indices - 1) .* obj.dimensions;
        end

        function position = get_points_position(obj, i, j, k)
            position = obj.array_position + ([i;j;k] - 1) .* obj.dimensions;
        end

        function plane = get_single_coord(obj, coord, index)
            assert(coord <= 3 && coord >= 1, 'assert:failure', 'coord must be between 1 and 3')
            %assert(index <= obj.num_planes(coord) && index >= 1, 'index must be between 1 and N(coord)')
            plane = obj.array_position(coord) + (index - 1) * obj.dimensions(coord);
        end

        function mu = get_mu(obj, i, j, k)
            % Convert indices to position at centre of voxel
            position = obj.get_point_position([i; j; k]) + obj.dimensions ./ 2;

            % Get mu at position
            mu = obj.get_voxel_mu(position(1, :), position(2, :), position(3, :));
        end
    end
end