classdef voxel_array % The functions here need to be reviewed - are they all needed?
    properties
        array_position (3, 1) double % position of the top left corner of the array
        num_planes     (3, 1) double % number of planes in each dimension
        dimensions     (3, 1) double % dimensions of each voxel
        voxel_objs
        nobj           (1, 1) double
        world_material        material_attenuation % The default material of the world.
    end

    methods
        function self = voxel_array(centre, object_dims, voxel_size, voxel_objs, world_material)
            arguments
                centre      (3, 1) double {mustBeReal}
                object_dims (3, 1) double {mustBePositive}
                voxel_size  (1, 1) double {mustBePositive} % Needs updating to [x;y;z]
                voxel_objs         cell 
                world_material     material_attenuation = material_attenuation("air");
            end
            % Constructor method
            self.array_position = centre - object_dims ./ 2;

            assert(voxel_size > 0, 'Voxel dimensions must be greater than zero')
            self.dimensions = zeros(3, 1) + voxel_size;

            assert(sum(object_dims ~= 0) == 3, 'There must be at least one length in each dimension')
            self.num_planes = object_dims ./ voxel_size + 1; % +1 to include the last plane (fence post problem)

            % In the future, I need to create this array based on the get_voxel_mu
            % nobj = nargin - 3;
            self.nobj = length(voxel_objs);
            for obj = voxel_objs
                assert(isa(obj{1}, 'voxel_object'), 'All objects must be of type voxel_object')
            end
            self.voxel_objs = voxel_objs;

            self.world_material = world_material;
        end

        function mu_dict = precalculate_mus(self, nrj_arr)
            % Return a 3D matrix of mu values using the 2D array of nrj values
            num_nrjs = numel(nrj_arr);
            mu_dict = zeros(self.nobj + 1, size(nrj_arr, 1), size(nrj_arr, 2));
            for n = 1:num_nrjs
                [i, j] = ind2sub(size(nrj_arr), n);
                mu_dict(:, i, j) = self.get_mu_arr(nrj_arr(i));
            end
        end

        function mfp_dict = precalculate_mfps(self, nrj_arr)
            % Create a dictionary of mfp values for each material
            num_nrjs = numel(nrj_arr);
            mfp_dict = zeros(self.nobj + 1, size(nrj_arr, 1), size(nrj_arr, 2));
            for n = 1:num_nrjs
                [i, j] = ind2sub(size(nrj_arr), n);
                mfp_dict(:, i, j) = self.get_mfp_arr(nrj_arr(i));
            end
        end

        function mu_arr = get_mu_arr(self, nrj)
            % Create a dictionary of mu values for each material
            mu_arr(self.nobj + 1) = self.world_material.get_mu(nrj);
            % mu_arr = zeros(1, self.nobj + 1);
            for n = 1:self.nobj
                mu_arr(n) = self.voxel_objs{n}.get_mu(nrj);
            end
        end

        function mus = get_saved_mu(self, indices, dict)
            % Convert indices to position at centre of voxel
            position = self.array_position + (indices - 0.5) .* self.dimensions;

            % Get mus at position
            mus = zeros(1, size(indices, 2)) + dict(self.nobj + 1); % Default to air
            for n = 1:self.nobj
                mus(self.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) =  ...
                    dict(n);
            end
        end

        function iobj = get_object_idxs(self, indices)
            % Convert indices to position at centre of voxel
            position = self.array_position + (indices - 0.5) .* self.dimensions;

            % Get mus at position
            iobj = zeros(1, size(indices, 2)) + self.nobj + 1; % Default to air
            for n = 1:self.nobj
                iobj(self.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) = n;
            end
        end

        function mfp_arr = get_mfp_arr(self, nrj)
            % Create a dictionary of mfp values for each material
            mfp_arr(self.nobj + 1) = self.world_material.mean_free_path(nrj);
            % mfp_arr = zeros(1, self.nobj + 1);
            for n = 1:self.nobj
                mfp_arr(n) = self.voxel_objs{n}.material.mean_free_path(nrj);
            end
        end

        function mfps = get_saved_mfp(self, indices, dict)
            % Convert indices to position at centre of voxel
            position = self.array_position + (indices - 0.5) .* self.dimensions;

            % Get material at position
            mfps = zeros(1, size(indices, 2)) + dict(self.nobj + 1); % Default to air
            for n = 1:self.nobj
                mfps(self.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) = ...
                    dict(n);
            end
        end
    end
end