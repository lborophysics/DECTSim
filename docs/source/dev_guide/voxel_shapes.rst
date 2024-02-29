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

    A function that takes a point ``(x, y, z)`` and returns a boolean value indicating if the point is inside the object or not.

.. attribute:: material
    
    The material of the object. This is a ``material_attenuation`` object.

.. attribute:: get_mu
    :noindex:

    A function that takes an energy and returns the linear attenuation coefficient of the material at that energy.

Functions
~~~~~~~~~

.. function:: voxel_object(is_in_object, material)

        Returns a voxel object with the given ``is_in_object`` function and ``material``. ``get_mu`` is an anonymous function that returns the linear attenuation coefficient of the material at the given energy.

Functions to create voxel objects
---------------------------------

There are several functions that can be used to create a voxel object. These are:

.. function:: voxel_cylinder(centre, radius, width, material)

    Returns a voxel object that represents a cylinder with the given ``centre``, ``radius``, ``width`` and ``material``.

.. function:: voxel_cube(cube_centre, cube_size, material)

    Returns a voxel object that represents a cube with the given ``cube_centre``, ``cube_size`` and ``material``.


