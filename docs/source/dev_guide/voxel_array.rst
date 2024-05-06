Voxel Array
===========

Purpose
-------

This class is creates a 3D array of voxels. It is used to create your phantom from various shapes and materials.

Properties
----------

.. attribute:: array_position

    (:class:`3x1 double`) The position of the top left corner of the voxel array in the world coordinate system.

.. attribute:: num_planes

    (:class:`3x1 double`) The number of planes in the voxel array.

.. attribute:: dimensions

    (:class:`3x1 double`) The dimensions of each voxel in the voxel array.

.. attribute:: voxel_objs

    (:class:`1xN cell`) A cell array of all the voxel objects in the voxel array (see :doc:`voxel_shapes`).

.. attribute:: nobj

    (:class:`double`) The number of voxel objects in the array, equivalent to ``length(voxel_objs) + 1``. The last element is the world material.

.. attribute:: world_material

    (:class:`material_attenuation`) The material of the world in the array that is not occupied by any voxel objects.

Functions
---------

.. function:: voxel_array(centre, object_dims, voxel_size, voxel_objs,  world_material=material_attenuation("air"))

    The constructor for the voxel array. The arguments are as follows:

    :param centre: The position of the centre of the array in the world coordinate system. Used to calculate the position of the top left corner of the array.
    :param object_dims: The dimensions of the array in the x, y and z directions.
    :param voxel_size: The dimensions of each voxel in the array in the x, y and z directions, currently must be the same for all voxels, so is given as a single number.
    :param voxel_objs: A cell array of all the voxel objects in the array (see :doc:`voxel_shapes`).
    :param world_material: The material of the world in the array that is not occupied by any voxel objects, defaults to air.

    :type centre: 3x1 double
    :type object_dims: 3x1 double
    :type voxel_size: double
    :type voxel_objs: :class:`voxel_object` cell array
    :type world_material: material_attenuation

    :returns: **Voxel array** -- An instance of the voxel array class.
    :rtype: :class:`voxel_array`


Methods
-------

.. method:: update_voxel_size(obj, new_voxel_size)

    Updates the voxel size of the array to ``new_voxel_size`` by changing the number of planes and the dimensions of the array.

    :param new_voxel_size: The new dimensions of each voxel in the array in the x, y and z directions.
    :type new_voxel_size: double

    :returns: **Voxel array** -- An instance of the voxel array class with the updated voxel size.
    :rtype: :class:`voxel_array`

.. method:: precalculate_mus(obj, nrj_arr)

    Pre-calculates the linear attenuation coefficient for each voxel object in ``voxel_objs`` for each energy in ``nrjs``.

    :param nrj_arr: An array of energies in keV. This is an n-Dimensional array of energies, the output is the same shape as the input.
    :type nrjs: MxN double
  
    :returns: **mu_dict** -- A PxMxN double with the first dimension representing the index of the voxel object in your array, the other dimensions are the same as the input ``nrj_arr``. The values are the linear attenuation coefficients for each voxel object in ``voxel_objs`` at each energy in ``nrj_arr``. P is the number of voxel objects + 1, the last element is the linear attenuation coefficient of the world material.
    :rtype: :class:`PxMxN double`

.. method:: precalculate_mfps(obj, nrj_arr)

    Pre-calculates the Compton mean free path for each voxel object in ``voxel_objs`` for each energy in ``nrjs``.

    :param nrj_arr: An array of energies in keV. This is an n-Dimensional array of energies, the output is the same shape as the input.
    :type nrjs: MxN double

    :returns: **mfp_dict** -- A PxMxN double with the first dimension representing the index of the voxel object in your array, the other dimensions are the same as the input ``nrj_arr``. The values are the Compton mean free paths for each voxel object in ``voxel_objs`` at each energy in ``nrj_arr``. P is the number of voxel objects + 1, the last element is the Compton mean free path of the world material.
    :rtype: :class:`PxMxN double`

.. method:: get_object_idxs(obj, indices)

    Obtain the indices of the voxel objects at the indices in ``indices``.

    :param indices: List of indices of voxels to obtain which voxel object they belong to.
    :type indices: 3xN double

    :returns: **iobj** -- A 1xN array of the identifiers of the voxel objects at the indices in ``indices``. This is used along with the output of :meth:`precalculate_mus` and :meth:`precalculate_mfps` to obtain the linear attenuation coefficients and Compton mean free paths at the indices in ``indices``.
    :rtype: :class:`1xN double`

.. method:: get_mu_arr(obj, nrj)

    Obtain all the linear attenuation coefficients for each voxel object in ``voxel_objs`` at the energy ``nrj``.

    :param nrj: The photon energy (in :math:`keV`).
    :type nrj: double

    :returns: **mu_arr** -- A 1D array of the linear attenuation coefficients for each voxel object in ``voxel_objs`` at the energy ``nrj``.
    :rtype: :class:`1xN double`

.. method:: get_mfp_arr(obj, nrj)

    Obtain all the Compton mean free paths for each voxel object in ``voxel_objs`` at the energy ``nrj``.

    :param nrj: The energy in keV.
    :type nrj: double

    :returns: **mfp_arr** -- A 1D array of the Compton mean free paths for each voxel object in ``voxel_objs`` at the energy ``nrj``.
    :rtype: :class:`1xN double`

.. method:: get_saved_mu(obj, indices, dict)

    Obtain the linear attenuation coefficients at the indices in ``indices`` from the list of linear attenuation coefficients in ``dict``.

    :param indices: List of indices of voxels to obtain the linear attenuation coefficients for.
    :param dict: A list of linear attenuation coefficients, as returned by a single energy from the dictionary returned by :meth:`precalculate_mus`.
    :type indices: 3xN double
    :type dict: double
  
    :returns: **mus** -- A 1D array of the linear attenuation coefficients at the indices in ``indices``. It is the same length as the number of indices in ``indices``.
    :rtype: :class:`1xN double`

.. method:: get_saved_mfp(obj, indices, dict)

    Obtain the Compton mean free paths at the indices in ``indices`` from the list of Compton mean free paths in ``dict``.

    :param indices: List of indices of voxels to obtain the Compton mean free paths for.
    :param dict: A list of Compton mean free paths, as returned by a single energy from the dictionary returned by :meth:`precalculate_mfps`.
    :type indices: 3xN double
    :type dict: double
  
    :returns: **mfps** - A 1D array of the Compton mean free paths at the indices in ``indices``. It is the same length as the number of indices in ``indices``.
    :rtype: :class:`1xN double`


    