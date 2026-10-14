Extract Slice For Image
====================

this generates a grayscale image from an axial slice of a voxel phantom, which can then be displayed as a preview in the GUI.

extract_slice_for_image
--------------------

Purpose
~~~~~~~

The function selects the chosen slice in the z direction and uses :func:`voxel_array.get_object_idxs` to determine which voxel object occupies each position in the slice. The object indices are used to look up material attenuation coefficients at a reference energy of 50 keV (arbitrary). Foreground attenuation values are normalised to grayscale values between 0.15 and 0.85.

Voxels whose object index is equal to :attr:`voxel_array.nobj` represent the world material and are made fully transparent. All voxels belonging to objects within the phantom are made fully opaque.

Arguments
~~~~~~~~~

.. attribute:: phantom
    (:class:`voxel_array`) The voxel array from which the preview image is generated.

.. attribute:: slice
    (:class:`double`, optional) The index of the axial slice to extract.
    Defaults to the central slice if not specified.
    Must be a finite whole number between 1 and the total number of z slices.
    Invalid values raise a ``DECTSim:InvalidSlice`` error.

Returns
~~~~~~~

.. attribute:: preview
    (:class:`double`) A two-dimensional grayscale image containing the central axial slice of the phantom. The values are normalised to the range ``[0, 1]``.

.. attribute:: alpha
    (:class:`double`) A two-dimensional alpha channel with the same dimensions as ``preview``. A value of ``0`` represents a fully transparent background pixel, while a value of ``1`` represents a fully opaque phantom pixel.