Voxel Objects
=============

A voxel object is how the program represents a material in the phantom. By utilising the voxel object, we can create different shapes of within your phantom.

voxel_object
------------

Purpose
~~~~~~~

The voxel object is a class that is used to represent a material in the phantom. It contains a function to determine if a point is inside the object or not and a function to determine the linear attenuation coefficient of the material.

Properties
~~~~~~~~~~
All of these properties are immutable, therefore they cannot be changed after the object is created.

.. attribute:: is_in_object

    (:class:`function`) A function that takes a set of points ``(x, y, z)`` and returns a list of logical values indicating if the point is inside the object or not.

.. attribute:: material
    
    (:class:`material_attenuation`) The material of the object.

.. attribute:: get_mu
    :noindex:

    (:class:`function`) A function that takes an energy and returns the linear attenuation coefficient of the material at that energy.

Functions
~~~~~~~~~

.. function:: voxel_object(is_in_object, material)

        Returns a voxel object with the given ``is_in_object`` function and ``material``. ``get_mu`` is an anonymous function that returns the linear attenuation coefficient of the material at the given energy.

        :param is_in_object: A function that takes a set of points ``(x, y, z)`` and returns a list of logical values indicating if the point is inside the object or not.
        :type is_in_object: :class:`function`
        :param material: The material of the object.
        :type material: :class:`material_attenuation`
        
        :returns: **obj** - An instance of the voxel object class.
        :rtype: :class:`voxel_object`


Functions to create voxel objects
---------------------------------

There are several functions that can be used to create a voxel object. These are:

.. function:: voxel_cylinder(centre, radius, width, material)

    Returns a voxel object that represents a cylinder with the given ``centre``, ``radius``, ``width`` and ``material``.

    :param centre: The centre of the cylinder.
    :type centre: :class:`1x3 double`
    :param radius: The radius of the cylinder.
    :type radius: :class:`double`
    :param width: The width of the cylinder.
    :type width: :class:`double`
    :param material: The material of the cylinder.
    :type material: :class:`material_attenuation`

    :returns: **obj** - An instance of the voxel object class.
    :rtype: :class:`voxel_object`

.. function:: voxel_cube(cube_centre, cube_size, material)

    Returns a voxel object that represents a cube with the given ``cube_centre``, ``cube_size`` and ``material``.

    :param cube_centre: The centre of the cube.
    :type cube_centre: :class:`1x3 double`
    :param cube_size: The size of the cube.
    :type cube_size: :class:`double`
    :param material: The material of the cube.
    :type material: :class:`material_attenuation`

    :returns: **obj** - An instance of the voxel object class.
    :rtype: :class:`voxel_object`

.. function:: voxel_ellipsoid(centre, a, b, c, material)

    Returns a voxel object that represents an ellipsoid with the given ``centre``, ``a``, ``b``, ``c`` and ``material``.

    :param centre: The centre of the ellipsoid.
    :type centre: :class:`1x3 double`
    :param a: The semi-axis of the ellipsoid in the x-direction.
    :type a: :class:`double`
    :param b: The semi-axis of the ellipsoid in the y-direction.
    :type b: :class:`double`
    :param c: The semi-axis of the ellipsoid in the z-direction.
    :type c: :class:`double`
    :param material: The material of the ellipsoid.
    :type material: :class:`material_attenuation`

    :returns: **obj** - An instance of the voxel object class.
    :rtype: :class:`voxel_object`

.. function:: voxel_ellipsoid_rotated(centre, a, b, c, angle, material)


    Returns a voxel object that represents an ellipsoid rotated about the z-axis with the given ``centre``, ``a``, ``b``, ``c``, ``angle`` and ``material``.

    :param centre: The centre of the ellipsoid.
    :type centre: :class:`1x3 double`
    :param a: The semi-axis of the ellipsoid in the x-direction.
    :type a: :class:`double`
    :param b: The semi-axis of the ellipsoid in the y-direction.
    :type b: :class:`double`
    :param c: The semi-axis of the ellipsoid in the z-direction.
    :type c: :class:`double`
    :param angle: The angle of rotation about the z-axis.
    :type angle: :class:`double`
    :param material: The material of the ellipsoid.
    :type material: :class:`material_attenuation`

    :returns: **obj** - An instance of the voxel object class.
    :rtype: :class:`voxel_object`



