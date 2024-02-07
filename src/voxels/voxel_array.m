classdef voxel_array % The functions here need to be reviewed - are they all needed?
    properties
        array_position (3, 1) double % position of the top left corner of the array
        num_planes     (3, 1) double % number of planes in each dimension
        dimensions     (3, 1) double % dimensions of each voxel
        voxel_objs
        nobj           (1, 1) double
        is_collection  (1, 1) logical
    end

    properties (Constant, NonCopyable)
        air = material_attenuation("air");
    end

    methods
        function self = voxel_array(centre, object_dims, voxel_size, varargin)
            % Constructor method
            self.array_position = centre - object_dims ./ 2;

            assert(voxel_size > 0, 'Voxel dimensions must be greater than zero')
            self.dimensions = ones(3, 1) * voxel_size;

            assert(sum(object_dims ~= 0) == 3, 'There must be at least one length in each dimension')
            self.num_planes = object_dims ./ voxel_size + 1; % +1 to include the last plane (fence post problem)

            % In the future, I need to create this array based on the get_voxel_mu
            % nobj = nargin - 3;
            self.nobj = nargin - 3;
            for obj = varargin
                assert(isa(obj{1}, 'voxel_object'), 'All objects must be of type voxel_object')
            end
            self.voxel_objs = varargin;
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
            mu = zeros(1, length(i));
            for obj = self.voxel_objs
                mu(obj{1}.is_in_object(position(1, :), position(2, :), position(3, :))) =  ...
                    obj{1}.get_mu(energy);
            end
        end

        function mu_arr = get_mu_dict(self, energy)
            % Create a dictionary of mu values for each material
            mu_arr(self.nobj + 1) = self.air.get_mu(energy);
            % mu_arr = zeros(1, self.nobj + 1);
            for n = 1:self.nobj
                mu_arr(n) = self.voxel_objs{n}.get_mu(energy);
            end
        end

        function mu = get_saved_mu(self, i, j, k, dict)
            % Convert indices to position at centre of voxel
            position = self.get_point_position([i; j; k]) + self.dimensions ./ 2;

            % Get mu at position
            mu = zeros(1, length(i)); % + dict(self.nobj + 1); % Default to air
            for n = 1:self.nobj
                mu(self.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) =  ...
                    dict(n);
            end
        end

        function mfp_arr = get_mfp_dict(self, energy)
            % Create a dictionary of mfp values for each material
            mfp_arr(self.nobj + 1) = self.air.mean_free_path(energy);
            % mfp_arr = zeros(1, self.nobj + 1);
            for n = 1:self.nobj
                mfp_arr(n) = self.voxel_objs{n}.material.mean_free_path(energy);
            end
        end

        function mfp = get_saved_mfp(self, i, j, k, dict)
            % Convert indices to position at centre of voxel
            position = self.get_point_position([i; j; k]) + self.dimensions ./ 2;

            % Get material at position
            mfp = zeros(1, length(i)) + dict(self.nobj + 1); % Default to air
            for n = 1:self.nobj
                mfp(self.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) = ...
                    dict(n);
            end
        end
    end
end