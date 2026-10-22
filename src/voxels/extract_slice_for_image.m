
function [preview, alpha] = extract_slice_for_image(phantom, options)
%EXTRACT_SLICE_FOR_IMAGE Extract an axial phantom slice as an image.
%
%   [PREVIEW, ALPHA] = EXTRACT_SLICE_FOR_IMAGE(PHANTOM)
%   extracts the central axial slice.
%
%   [PREVIEW, ALPHA] = EXTRACT_SLICE_FOR_IMAGE(PHANTOM, slice=N)
%   extracts axial slice N without saving a file.

    arguments
        phantom (1, 1) voxel_array
        options.slice double = []
    end



    % num_planes counts boundaries, so subtract one to get voxel cells.
    num_voxels = phantom.num_planes - 1;
    nx = num_voxels(1);
    ny = num_voxels(2);
    nz = num_voxels(3);

    % Select requested slice

    if isempty(options.slice)
        z_index = ceil(nz / 2);
    else
        z_index = options.slice;
    end

    % Validate the requested slice.
    if ~isscalar(z_index) || ~isreal(z_index) || ...
            ~isfinite(z_index) || z_index < 1 || ...
            z_index > nz || z_index ~= floor(z_index)

        error("DECTSim:InvalidSlice", ...
            "Invalid slice. Please enter a finite whole number " + ...
            "between 1 and %d.", nz);
    end



    % Construct every x-y voxel index on the selected slice.
    [x_indices, y_indices] = ndgrid(1:nx, 1:ny);

    indices = [
        x_indices(:).'
        y_indices(:).'
        repmat(z_index, 1, numel(x_indices))
    ];

    % Obtain the object/material ID at each voxel.
    object_indices = phantom.get_object_idxs(indices);

    % Convert vector back to a 2-D image.
    %
    % reshape gives rows=x, columns=y; rot90 both swaps the axes (so rows=y,
    % columns=x) and flips y so row 1 is the maximum y, matching image row
    % order (row 1 at the top) rather than plain axis-swapping transpose.
    object_slice = reshape(object_indices, nx, ny);
    object_slice = rot90(object_slice, 1);

    % phantom.nobj is the world material, which is air by default.
    foreground = object_slice ~= phantom.nobj;

    preview = zeros(size(object_slice), "double");

    if any(foreground, "all")
        % Map each object index to its material attenuation coefficient (arbitrary energy)
        reference_energy = 50;
        mu_values = double(phantom.get_mu_arr(reference_energy));
        foreground_values = mu_values(object_slice(foreground));

        minimum_value = min(foreground_values);
        maximum_value = max(foreground_values);

        % Keep the phantom between dark grey and light grey.
        minimum_grey = 0.15;
        maximum_grey = 0.85;

        if maximum_value > minimum_value
            preview(foreground) = minimum_grey + ...
                (maximum_grey - minimum_grey) .* ...
                mat2gray(foreground_values, [minimum_value, maximum_value]);
        else
            preview(foreground) = (minimum_grey + maximum_grey) / 2;
        end
    end

    % Fully transparent background, fully opaque phantom.
    alpha = double(foreground);

end
