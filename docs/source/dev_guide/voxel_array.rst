Voxel Array
===========

Purpose
-------

This class is creates a 3D array of voxels. It is used to create your phantom from various shapes and materials.

Properties
----------

.. attribute:: array_position

    The position of the top left corner of the array in the world coordinate system.

.. attribute:: num_planes

    The number of planes in the array.

.. attribute:: dimensions

    The dimensions of each voxel in the array.

.. attribute:: voxel_objs

    A cell array of all the voxel objects in the array (see :doc:`voxel_shapes`).

.. attribute:: nobj

    The number of voxel objects in the array, equivalent to ``length(voxel_objs)``.

.. attribute:: world_material

    The material of the world in the array that is not occupied by any voxel objects.

Functions
---------

.. function:: voxel_array(centre, object_dims, voxel_size, voxel_objs,  world_material=material_attenuation("air"))

    The constructor for the voxel array. The arguments are as follows:

    :param centre: The position of the centre of the array in the world coordinate system. Used to calculate the position of the top left corner of the array.
    :param object_dims: The dimensions of the array in the x, y and z directions.
    :param voxel_size: The dimensions of each voxel in the array in the x, y and z directions, currently must be the same for all voxels, so is given as a single number.
    :param voxel_objs: A cell array of all the voxel objects in the array (see :doc:`voxel_shapes`).
    :param world_material: The material of the world in the array that is not occupied by any voxel objects, defaults to air.

Methods
-------

.. method:: precalculate_mus(self, nrjs)

    Pre-calculates the linear attenuation coefficient for each voxel object in ``voxel_objs`` for each energy in ``nrjs``.

    :param nrjs: A list of energies in keV.
  
    :returns: :code:`mu_dict` is a dictionary with the keys being the energies in ``nrjs`` as strings and the values being a 1D array of the linear attenuation coefficients for each voxel object in ``voxel_objs`` at that energy.

.. method:: precalculate_mfps(self, nrjs)

    Pre-calculates the Compton mean free path for each voxel object in ``voxel_objs`` for each energy in ``nrjs``.

    :param nrjs: A list of energies in keV.

    :returns: :code:`mfp_dict` is a dictionary with the keys being the energies in ``nrjs`` as strings and the values being a 1D array of the Compton mean free paths for each voxel object in ``voxel_objs`` at that energy.

.. method:: get_mu_arr(self, nrj)

    Obtain all the linear attenuation coefficients for each voxel object in ``voxel_objs`` at the energy ``nrj``.

    :param nrj: The energy in keV.

    :returns: :code:`mu_arr` is a 1D array of the linear attenuation coefficients for each voxel object in ``voxel_objs`` at the energy ``nrj``.

.. method:: get_mfp_arr(self, nrj)

    Obtain all the Compton mean free paths for each voxel object in ``voxel_objs`` at the energy ``nrj``.

    :param nrj: The energy in keV.

    returns :code:`mfp_arr` is a 1D array of the Compton mean free paths for each voxel object in ``voxel_objs`` at the energy ``nrj``.

.. method:: get_saved_mu(self, indices, dict)

    Obtain the linear attenuation coefficients at the indices in ``indices`` from the list of linear attenuation coefficients in ``dict``.

    :param indices: A 3xN list of indices.
    :param dict: A list of linear attenuation coefficients, as returned by a single energy from the dictionary returned by :meth:`precalculate_mus`.
  
    :returns: :code:`mus` is a 1D array of the linear attenuation coefficients at the indices in ``indices``. It is the same length as the number of indices in ``indices``.

.. method:: get_saved_mfp(self, indices, dict)

    Obtain the Compton mean free paths at the indices in ``indices`` from the list of Compton mean free paths in ``dict``.

    :param indices: A 3xN list of indices.
    :param dict: A list of Compton mean free paths, as returned by a single energy from the dictionary returned by :meth:`precalculate_mfps`.
  
    :returns: :code:`mfps` is a 1D array of the Compton mean free paths at the indices in ``indices``. It is the same length as the number of indices in ``indices``.


    