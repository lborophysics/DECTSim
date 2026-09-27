function [preview, alpha] = save_phantom_preview( ...
        phantom, output_file)
%SAVE_PHANTOM_PREVIEW Save the central axial phantom slice as a PNG.
%
%   SAVE_PHANTOM_PREVIEW(PHANTOM, OUTPUT_FILE) evaluates the central
%   x-y slice of a voxel_array. Different phantom objects are shown as
%   grayscale levels, while the world/background material is transparent.
%
%   [PREVIEW, ALPHA] = SAVE_PHANTOM_PREVIEW(...) also returns the image
%   and alpha arrays.

    arguments
        phantom (1, 1) voxel_array
        output_file (1, 1) string
    end

    % num_planes counts boundaries, so subtract one to get voxel cells.
    num_voxels = phantom.num_planes - 1;
    nx = num_voxels(1);
    ny = num_voxels(2);
    nz = num_voxels(3);

    % Select the central z voxel.
    z_index = ceil(nz / 2);

    % Construct every x-y voxel index on the central slice.
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

    output_folder = fileparts(output_file);

    if output_folder ~= "" && ~isfolder(output_folder)
        mkdir(output_folder);
    end

    imwrite( ...
        preview, ...
        output_file, ...
        "png", ...
        "Alpha", alpha);
end
