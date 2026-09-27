Save Phantom Preview
====================

This allows a preview image to be generated when you create a custom phantom. The preview image can then be displayed on the GUI when your phantom is selected.

save_phantom_preview
--------------------

Purpose
~~~~~~~

The ``save_phantom_preview`` function generates a transparent PNG preview of a voxel phantom.

The function selects the central slice in the z direction and uses :func:`voxel_array.get_object_idxs` to determine which voxel object occupies each position in the slice. The object indices are used to look up material attenuation coefficients at a reference energy of 50 keV (arbitrary). Foreground attenuation values are normalised to grayscale values between 0.15 and 0.85.

Voxels whose object index is equal to :attr:`voxel_array.nobj` represent the world material and are made fully transparent. All voxels belonging to objects within the phantom are made fully opaque.

Arguments
~~~~~~~~~

.. attribute:: phantom
    (:class:`voxel_array`) The voxel array from which the preview image is generated.

.. attribute:: output_file
    (:class:`string`) The path at which the preview image is saved. The output image is written in PNG format.

Returns
~~~~~~~

.. attribute:: preview
    (:class:`double`) A two-dimensional grayscale image containing the central axial slice of the phantom. The values are normalised to the range ``[0, 1]``.

.. attribute:: alpha
    (:class:`double`) A two-dimensional alpha channel with the same dimensions as ``preview``. A value of ``0`` represents a fully transparent background pixel, while a value of ``1`` represents a fully opaque phantom pixel.

Functions
~~~~~~~~~

.. function:: save_phantom_preview(phantom, output_file)

    Generates and saves a preview image to ``output_file`` from the central axial slice of a voxel ``phantom``.

    The number of voxels in each dimension is calculated from :attr:`voxel_array.num_planes`. Because ``num_planes`` contains the voxel boundary planes, the number of voxel cells is given by ``num_planes - 1``.

    The function constructs the voxel indices for the central x-y slice and passes them to :func:`voxel_array.get_object_idxs`. This returns the index of the voxel object occupying each position.

    The object indices are reshaped into a two-dimensional image. Material attenuation coefficients at 50 keV are normalised to grayscale values in the range ``[0.15, 0.85]``. If all foreground voxels have the same attenuation coefficient, they are assigned a mid-grey value of ``0.5``. Positions containing the world material, identified by :attr:`voxel_array.nobj`, are assigned an alpha value of ``0`` and are therefore transparent in the saved PNG.

    :param phantom: The voxel array from which the preview is generated.
    :type phantom: :class:`voxel_array`
    :param output_file: The path at which the PNG preview is saved.
    :type output_file: :class:`string`

    :returns: A grayscale preview image and its corresponding alpha channel.
    :rtype: tuple(:class:`double`, :class:`double`)
