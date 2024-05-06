Detector Pixel Arrays
=====================

The detector pixel arrays are used to store the data about the shape of the pixel array and position of the source. This is used to calculate the ray paths for each projection, and which pixel that a ray may intersect.

Detector Array
--------------

Purpose
~~~~~~~

This class is a template for all detector pixel arrays and should hold all the information that is the same for across each detector type.

Properties
~~~~~~~~~~

.. attribute:: pixel_dims
    
    (:class:`1x2 double`) The dimensions of the pixel array in the x and y directions.
    
.. attribute:: n_pixels
    
    (:class:`1x2 double`) The number of pixels in the x and y directions.

Functions
~~~~~~~~~

.. function:: detector_array(pixel_dims, n_pixels)

        Constructor for the detector_array class. This just sets the class attributes to the input values.

        :param pixel_dims: is the dimensions of the pixel array in the x and y directions.
        :type pixel_dims: 1x2 double
        :param n_pixels: is the number of pixels in the x and y directions.
        :type n_pixels: 1x2 double
        
        :returns: **detector_array** -- an instance of the detector_array class.
        :rtype: :class:`detector_array`

Abstract Methods
~~~~~~~~~~~~~~~~

.. function:: set_array_angle(self, detect_geom, angle_index)

        This method is used to generate all the pixel positions for a given angle. The returned array must be a 3xNxM array, where N and M is the number of pixels in the y and z directions respectively. 

        :param detect_geom: is the detector geometry, so an instance of :class:`gantry`.
        :type detect_geom: gantry
        :param angle_index: is the index of the angle that the gantry is at.
        :type angle_index: double
        :type ray_per_pixel: double

        :returns: **pixel_positions** -- a list of the pixel positions for each pixel in the array, where N is the number of pixels in the y direction and M is the number of pixels in the z direction.
        :rtype: :class:`3xNxM double`

.. function:: hit_pixel(self, detect_geom, angle_index)

        This method is used to generate a function which calculates which pixel a ray may intersect. This is an abstract method and should be implemented in the subclasses, so cannot be called from this class.
        If you create a new detector array, and you do not plan to use it with the :func:`deterministic_scatter` function, then you can simply call a not implemented error.

        :param detect_geom: an instance of the :class:`gantry`.
        :type detect_geom: gantry
        :param angle_index: is the index of the angle that the gantry is at.
        :type angle_index: double

        :returns: **hit_pixel_at_angle** -- a function that calculates the intersected pixel for a given ray. See :func:`hit_pixel_at_angle` for more information.
        :rtype: :class:`function`


Nested Functions
~~~~~~~~~~~~~~~~

.. function:: hit_pixel_at_angle(ray_starts, ray_dirs)

        This function is used to calculate which pixel a ray may intersect. This is a nested function that must be returned from the :meth:`hit_pixel` method.

        :param ray_starts: An array of the starting positions of the rays.
        :type ray_starts: 3xN double
        :param ray_dirs: An array of the directions of the rays.
        :type ray_dirs: 3xN double

        :returns: 
            - **pixel** (:class:`2xN double`) -- the :math:`(y, z)` pixels that the rays intersect, with zeros for each of the ray does not intersect any pixel.
            - **ray_len** (:class:`1xN double`) -- the lengths of the rays to the pixel, with zeros if the ray does not intersect any pixel.
            - **angles** (:class:`1xN double`) -- the angles of the rays with respect to he normal vector to the pixel, with zeros if the ray does not intersect any pixel.
            - **hit** (:class:`1xN logical`) -- a logical array, where true means that the ray intersects a pixel, and false means that the ray does not intersect a pixel.
        
Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

A ``ray_per_pixel`` parameter in the :meth:`set_array_angle` is not implemented yet. This could be implemented in the future for anti-aliasing purposes.

Passing the detector geometry is a shortcut to getting a lot of information. This could be changed to passing vector from the detector array to the source centre and distance from the source to the detector array. 

The available classes for the detector pixel arrays are:


Flat Detector
-------------

Purpose
~~~~~~~

The flat_detector class is a subclass of the class :class:`flat_array`. The geometry of this is a flat detector panel, with the source emmitting rays perpendicular to the direction of the array.

Functions
~~~~~~~~~

.. function:: flat_detector(pixel_dims, n_pixels)

        Constructor for the flat_detector class. Identical to :class:`detector_array`

        :param pixel_dims: is the dimensions of the pixel array in the x and y directions.
        :type pixel_dims: 1x2 double
        
        :param n_pixels: is the number of pixels in the x and y directions.
        :type n_pixels: 1x2 double

        :returns: **flat_detector** -- an instance of the flat_detector class.
        :rtype: :class:`flat_detector`

Methods
~~~~~~~

.. method:: flat_detector.set_array_angle(detect_geom, angle_index, ray_per_pixel=1)

    :param detect_geom: an instance of the :class:`gantry`.
    :type detect_geom: gantry
    :param angle_index: is the index of the angle that the gantry is at.
    :type angle_index: double

    :returns: **pixel_positions** -- all the pixel positions for a given angle for a flat detector panel.
    :rtype: :class:`3xNxM double`


.. method:: flat_detector.hit_pixel(detect_geom, angle_index)

    :param detect_geom: an instance of the :class:`gantry`.
    :type detect_geom: gantry
    :param angle_index: is the index of the angle that the gantry is at.
    :type angle_index: double

    :returns: **hit_pixel_at_angle** -- a function that calculates the intersected pixel for a given ray. See :func:`hit_pixel_at_angle` for more information.



Curved Detector
---------------

Purpose
~~~~~~~

The curved_detector class is a subclass of the class :class:`detector_array`. The geometry of this is a cylindrical detector panel, where the array of sensors is placed along an arc. The width of the pixel is considered a chord length of the arc, so the angle subtended by each pixel is calculated using this chord length.

Functions
~~~~~~~~~

.. function:: curved_detector(pixel_dims, n_pixels)

        Constructor for the curved_detector class. Identical to :class:`detector_array`

        :param pixel_dims: is the dimensions of the pixel array in the x and y directions.
        :type pixel_dims: 1x2 double
        :param n_pixels: is the number of pixels in the x and y directions.
        :type n_pixels: 1x2 double

        :returns: **curved_detector** -- an instance of the curved_detector class.
        :rtype: :class:`curved_detector`

Methods
~~~~~~~

.. method:: curved_detector.set_array_angle(detect_geom, angle_index)

    This method returns all the pixel positions for a given angle for a curved detector panel.

    :param detect_geom: an instance of the :class:`gantry`.
    :type detect_geom: gantry
    :param angle_index: is the index of the angle that the gantry is at.
    :type angle_index: double

    :returns: **pixel_positions** -- all the pixel positions for a given angle for a curved detector panel.
    :rtype: :class:`3xNxM double`


.. method:: curved_detector.hit_pixel(detect_geom, angle_index)

    This method returns a function that calculates the position of the pixel at a given angle for a curved detector panel, along with the length of the ray and the angle of the ray with respect to the normal vector to the pixel. It uses the cyclinder intersection method `here <https://en.wikipedia.org/wiki/Line-cylinder_intersection>`_.

    :param detect_geom: an instance of the :class:`gantry`.
    :type detect_geom: gantry
    :param angle_index: is the index of the angle that the gantry is at.
    :type angle_index: double

    :returns: **hit_pixel_at_angle** -- a function that calculates the intersected pixel for a given ray. See :func:`hit_pixel_at_angle` for more information.
