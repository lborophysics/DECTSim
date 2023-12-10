function func = voxel_collection(varargin)
    % This function returns a function handle that can be used to create a box of size box_size
    all_funcs = varargin;
    func = @all_voxels;
    function result = all_voxels(i, j, k, energy)
        result = zeros(1, length(i));
        for f = all_funcs
            voxels = f{1}(i, j, k, energy);
            non_zero = ~~voxels;
            result(non_zero) = voxels(non_zero);
        end
    end
end