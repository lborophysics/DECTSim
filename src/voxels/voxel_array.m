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
        function obj = voxel_array(centre, object_dims, voxel_size, voxel_objs, world_material)
            arguments
                centre      (3, 1) double {mustBeReal}
                object_dims (3, 1) double {mustBePositive}
                voxel_size  (1, 1) double {mustBePositive} % Needs updating to [x;y;z]
                voxel_objs         cell 
                world_material     material_attenuation = material_attenuation("air");
            end
            % Constructor method
            obj.array_position = centre - object_dims ./ 2;

            assert(voxel_size > 0, 'Voxel dimensions must be greater than zero')
            obj.dimensions = zeros(3, 1) + voxel_size;

            assert(sum(object_dims ~= 0) == 3, 'There must be at least one length in each dimension')
            obj.num_planes = round(object_dims ./ voxel_size + 1, 10); % +1 to include the last plane (fence post problem)
            assert(all(floor(obj.num_planes) == obj.num_planes), 'The number of planes must be an integer')

            % In the future, I need to create this array based on the get_voxel_mu
            % nobj = nargin - 3;
            obj.nobj = length(voxel_objs) + 1; % +1 for the world material
            for o = voxel_objs
                assert(isa(o{1}, 'voxel_object'), 'All objects must be of type voxel_object')
            end
            obj.voxel_objs = voxel_objs;

            obj.world_material = world_material;
        end

        function obj = update_voxel_size(obj, new_voxel_size)
            % Update the voxel size
            obj.num_planes = (obj.num_planes - 1) .* (obj.dimensions ./ new_voxel_size) + 1;
            obj.num_planes = round(obj.num_planes, 10); 
            assert(all(floor(obj.num_planes) == obj.num_planes), 'The number of planes must be an integer')
            obj.dimensions = zeros(3, 1) + new_voxel_size;
        end

        function mu_dict = precalculate_mus(obj, nrj_arr)
            % Return a 3D matrix of mu values using the 2D array of nrj values
            num_nrjs = numel(nrj_arr);
            mu_dict = zeros(obj.nobj, num_nrjs);
            lin_nrjs = reshape(nrj_arr, 1, num_nrjs);
            for n = 1:obj.nobj-1
                mu_dict(n, :) = obj.voxel_objs{n}.get_mu(lin_nrjs);
            end
            mu_dict(obj.nobj, :) = obj.world_material.get_mu(lin_nrjs);
            mu_dict = reshape(mu_dict, [obj.nobj, size(nrj_arr)]);
        end

        function mfp_dict = precalculate_mfps(obj, nrj_arr)
            % Create a dictionary of mfp values for each material
            num_nrjs = numel(nrj_arr);
            mfp_dict = zeros(obj.nobj, num_nrjs);
            lin_nrjs = reshape(nrj_arr, num_nrjs, 1);
            for n = 1:obj.nobj-1
                mfp_dict(n, :) = obj.voxel_objs{n}.material.mean_free_path(lin_nrjs);
            end
            mfp_dict(obj.nobj, :) = obj.world_material.mean_free_path(lin_nrjs);
            mfp_dict = reshape(mfp_dict, [obj.nobj, size(nrj_arr)]);            
        end

        function iobj = get_object_idxs(obj, indices)
            % Convert indices to position at centre of voxel
            position = obj.array_position + (indices - 0.5) .* obj.dimensions;

            % Get mus at position
            iobj = zeros(1, size(indices, 2)) + obj.nobj; % Default to air
            for n = 1:obj.nobj-1
                iobj(obj.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) = n;
            end
        end
    
        function mu_arr = get_mu_arr(obj, nrj)
            % Create a dictionary of mu values for each material
            arguments
                obj; nrj (1, 1) double
            end
            mu_arr(obj.nobj) = obj.world_material.get_mu(nrj);
            for n = 1:obj.nobj-1
                mu_arr(n) = obj.voxel_objs{n}.get_mu(nrj);
            end
        end

        function mus = get_saved_mu(obj, indices, dict)
            % Convert indices to position at centre of voxel
            position = obj.array_position + (indices - 0.5) .* obj.dimensions;

            % Get mus at position
            mus = zeros(1, size(indices, 2)) + dict(obj.nobj); % Default to air
            for n = 1:obj.nobj-1
                mus(obj.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) =  ...
                    dict(n);
            end
        end

        function mfp_arr = get_mfp_arr(obj, nrj)
            % Create a dictionary of mfp values for each material
            arguments
                obj; nrj (1, 1) double
            end
            mfp_arr(obj.nobj) = obj.world_material.mean_free_path(nrj);
            % mfp_arr = zeros(1, obj.nobj + 1);
            for n = 1:obj.nobj-1
                mfp_arr(n) = obj.voxel_objs{n}.material.mean_free_path(nrj);
            end
        end

        function mfps = get_saved_mfp(obj, indices, dict)
            % Convert indices to position at centre of voxel
            position = obj.array_position + (indices - 0.5) .* obj.dimensions;

            % Get material at position
            mfps = zeros(1, size(indices, 2)) + dict(obj.nobj); % Default to air
            for n = 1:obj.nobj-1
                mfps(obj.voxel_objs{n}.is_in_object(position(1, :), position(2, :), position(3, :))) = ...
                    dict(n);
            end
        end
    end
end