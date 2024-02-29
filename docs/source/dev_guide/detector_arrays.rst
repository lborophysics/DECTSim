Detector Pixel Arrays
=====================

The detector pixel arrays are used to store the data about the shape of the pixel array and position of the source. This is used to calculate the ray paths for each projection, and which pixel that a ray may intersect.

detector_array
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

.. function:: ray_at_angle(self, detect_geom, angle_index, ray_per_pixel=1)

        This method is used to calculate the ray paths for each projection. This is an abstract method and should be implemented in the subclasses, so cannot be called from this class.

        * ``detect_geom`` is the detector geometry, so an instance of the gantry class.
        * ``angle_index`` is the index of the angle that the gantry is at.
        * ``ray_per_pixel`` is the number of rays that will be cast per pixel (default 1 - Not implemented yet). The purpose of this will be to include anti-aliasing techniques in the future, to improve the quality of the simulation.

        **Returns**: :code:`ray_generator`.
        
        The return value is a function that takes in the pixel in the y and z directions and returns `ray_start` (start point), `ray_dir` (direction) and `ray_length`. This is used to calculate the ray paths for each projection.

.. function:: hit_pixel(self, ray_start, ray_dir, detect_geom, angle_index)

        This method is used to calculate which pixel a ray may intersect. This is an abstract method and should be implemented in the subclasses, so cannot be called from this class.

        * ``ray_start`` is the starting position of the ray.
        * ``ray_dir`` is the unit vector of the ray, i.e. the direction of the ray.
        * ``detect_geom`` is the detector geometry, so an instance of the gantry class.
        * ``angle_index`` is the index of the angle that the gantry is at.

        **Returns**: :code:`[pixel, hit]`.

        The return value is the pixel that was hit (a 1x2 array of the pixel index) and hit (a boolean value of whether the ray intersects the pixel at all).

The available classes for the detector pixel arrays are:


flat_array
-------------

Purpose
~~~~~~~

The flat_array class is a subclass of the class :class:`detector_array`. This class is also an abstract class, and so cannot be called directly. It adds a single method to the :class:`detector_array` class, which is the method :meth:`hit_pixel`, which is consistent across all flat detector arrays.

Methods
~~~~~~~

.. method:: flat_detector.hit_pixel(ray_start, ray_dir, detect_geom, angle_index)

    This method calculates the intersected pixel for a flat detector panel, therefore, could be generalised for any future detector panels that are flat, but do not have the same source.

parallel_detector
-----------------

Purpose
~~~~~~~

The parallel_detector class is a subclass of the class :class:`flat_array`. The geometry of this is a flat detector panel, with the source emmitting rays directly above each pixel, landing in the centre of each pixel. This results in many parallel rays being cast for each projection.


Methods
~~~~~~~

.. method:: parallel_detector.ray_at_angle(detect_geom, angle_index, ray_per_pixel=1)

    This method produces rays with varying starting positions, depending on each pixel, yet all rays have the same direction for each rotation of the gantry and the same length. This is because the source is directly above the centre of the detector panel, so the rays are parallel.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

The ``ray_per_pixel`` parameter in the :meth:`ray_at_angle` is not implemented yet.


curved_detector
---------------

Purpose
~~~~~~~

The curved_detector class is a subclass of the class :class:`detector_array`. The geometry of this is a cylindrical detector panel, with the source emmitting from a single point, and the rays landing on the detector panel at varying distances from the source. 

Methods
~~~~~~~

.. method:: curved_detector.ray_at_angle(detect_geom, angle_index, ray_per_pixel=1)

    This method produces rays starting from the same point for each projection, but with varying directions and lengths, depending on the position of the pixel on the detector panel. This is because the source is at a single point, so the rays are not parallel and any reconstruction algorithm will need to take this into account.

.. method:: curved_detector.hit_pixel(ray_start, ray_dir, detect_geom, angle_index)

    Not implemented yet, but will be used to calculate the intersected pixel for a curved detector panel.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

The ``ray_per_pixel`` parameter in the :meth:`ray_at_angle` is not implemented yet, as well as the :meth:`hit_pixel` method for the :class:`curved_detector` class. 