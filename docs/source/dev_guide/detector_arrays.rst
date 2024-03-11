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
    
    The dimensions of the pixel array in the x and y directions.
    
.. attribute:: n_pixels
    
    The number of pixels in the x and y directions.

Functions
~~~~~~~~~

.. function:: detector_array(pixel_dims, n_pixels)

        Constructor for the detector_array class. This simply sets the class attributes to the input values.

Abstract Methods
~~~~~~~~~~~~~~~~

.. function:: set_array_angle(self, detect_geom, angle_index, ray_per_pixel=1)

        This method is used to generate a function which calculates the position of the pixel using the pixel index, at a given angle. This is an abstract method and should be implemented in the subclasses, so cannot be called from this class.

        :param detect_geom: is the detector geometry, so an instance of the gantry class.
        :type detect_geom: gantry
        :param angle_index: is the index of the angle that the gantry is at.
        :type angle_index: double
        :param ray_per_pixel: is the number of rays that will be cast per pixel (default 1 - Not implemented yet). The purpose of this will be to include anti-aliasing techniques in the future, to improve the quality of the simulation.
        :type ray_per_pixel: double

        :returns: ``pixel_generator``, a function that takes in the pixel in the y and z directions and returns the pixel centre, so that the ray can be cast from the source to the pixel.

.. function:: hit_pixel_at_angle = hit_pixel(self, detect_geom, angle_index)

        This method is used to generate a function which calculates which pixel a ray may intersect. This is an abstract method and should be implemented in the subclasses, so cannot be called from this class.

        :param detect_geom: is the detector geometry, so an instance of the gantry class.
        :type detect_geom: gantry
        :param angle_index: is the index of the angle that the gantry is at.
        :type angle_index: double

        :returns: ``hit_pixel_at_angle``, a function that takes in a 3xN array of ray start points and a 3xN array of ray directions. The return must be the pixels that were hit as an Nx2 array, a 1xN array of the length that the ray will travel to reach the pixel, and a 1xN array of the length that the ray will travel to reach the pixel.

The available classes for the detector pixel arrays are:


Flat Detector
-------------

Purpose
~~~~~~~

The flat_detector class is a subclass of the class :class:`flat_array`. The geometry of this is a flat detector panel, with the source emmitting rays directly above each pixel, landing in the centre of each pixel. This results in many parallel rays being cast for each projection.

Functions
~~~~~~~~~

.. function:: flat_detector(pixel_dims, n_pixels)

        Constructor for the flat_detector class. Identical to :class:`detector_array`

Methods
~~~~~~~

.. method:: flat_detector.hit_pixel(detect_geom, angle_index)

    This method is used to generate a function which calculates which pixel a ray may intersect for a flat detector panel.

.. method:: flat_detector.set_array_angle(detect_geom, angle_index, ray_per_pixel=1)

    This method returns a function that calculates the position of the pixel at a given angle for a flat detector panel.


Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

The ``ray_per_pixel`` parameter in the :meth:`set_array_angle` is not implemented yet.


Curved Detector
---------------

Purpose
~~~~~~~

The curved_detector class is a subclass of the class :class:`detector_array`. The geometry of this is a cylindrical detector panel, with the source emmitting from a single point, and the rays landing on the detector panel at varying distances from the source. 

Functions
~~~~~~~~~

.. function:: curved_detector(pixel_dims, n_pixels)

        Constructor for the curved_detector class. Identical to :class:`detector_array`

Methods
~~~~~~~

.. method:: curved_detector.set_array_angle(detect_geom, angle_index, ray_per_pixel=1)

    This method is used to generate a function which calculates the position of the pixel using the pixel index, at a given angle for a curved detector panel.

.. method:: curved_detector.hit_pixel(detect_geom, angle_index)

    Not implemented yet, but will be used to calculate the intersected pixel for a curved detector panel.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

The ``ray_per_pixel`` parameter in the :meth:`set_array_angle` is not implemented yet, as well as the :meth:`hit_pixel` method for the :class:`curved_detector` class. 