Detector Movement
=================

The detector movement is controlled by the super class :class:`gantry`. The available classes are:

Gantry Class
------------

Purpose
~~~~~~~

The gantry class is used to control the movement of the gantry, it is used to store the parameters of the how your image will be created through the movement of the gantry.

The :func:`get_rot_mat` method is used to get the rotation matrix for the gantry, this is not intended to be used by the user but is used by classes which are intended to be attached to the gantry.

Properties
~~~~~~~~~~

.. attribute:: dist_to_detector

    (:class:`double`) from source to detector

.. attribute:: rot_radius

    (:class:`double`) The radius of rotation of the gantry. This is calculated as ``dist_to_detector/2``. This is a precalculation to save time in the method :meth:`get_rot_mat`.

.. attribute:: to_source_vec = [0;1;0]
    
    (:class:`3x1 double`) Vector from source to centre of detector. The initial value is [0;1;0] as the source will always start in the positive y position. This is used in the `detector_array` classes to calculate the ray paths for each projection.

.. attribute:: num_rotations
    
    (:class:`double`) Number of rotations the gantry will make, i.e. the number of projections. This is required in the function :func:`compute_sinogram` 
    
.. attribute:: rot_angle

    (:class:`double`) The angle of rotation for each projection. Calculated as ``total_rotation/num_rotations``. This is a precalculation to save time in the method :meth:`get_rot_mat`.

.. attribute:: scan_angles
    
    (:class:`double`) The angles at which the gantry will rotate to. This is for the user to get the scan angles for use with reconstruction algorithms. 
    

Functions
~~~~~~~~~

.. function:: gantry(dist_to_detector, num_rotations, total_rotation=2*pi)
    
        Constructor for the gantry class. 

        :param dist_to_detector: is the distance from the source to the detector.
        :type dist_to_detector: double
        :param num_rotations: is the number of rotations the gantry will make, i.e. the number of projections.
        :type num_rotations: double
        :param total_rotation: is the total rotation of the gantry in radians (default :math:`2\pi`).
        :type total_rotation: double

        :returns: **gantry** -- The gantry object.
        :rtype: :class:`gantry`


Methods
~~~~~~~~

.. method:: get_rot_mat()

        Returns the rotation matrix for the gantry. This is used to rotate any objects attached to the gantry.

        :returns: The rotation matrix for the gantry.
    
.. method:: get_source_pos(index, pixel_positions)

        :param index: The index rotation of the gantry.
        :type index: double
        :param pixel_positions: The position of the pixel on the detector.
        :type pixel_positions: 3xN double

        Returns the position of the source for every pixel position. This is used to calculate the ray paths for each projection. For this gantry, the source position is independent of the pixel position and a single point, dependent on the index of the rotation, so a list of the same source position the same size as the pixel position is returned.

        :returns: **source_pos** -- The positions of the source.
        :rtype: :class:`3xN double`

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

This class will likely be changed to be an abstract class, and then a new class will be created for each type of gantry. This will allow for more specific gantry types to be created, such as axial or helical gantry, and for the user to be able to create their own gantry types.

Parallel Gantry Class
---------------------

Purpose
~~~~~~~

The parallel gantry class is a subclass of the gantry class. It has the same properties and methods as the gantry class, but has a different method for getting the source position. This is because the source position is dependent on the pixel position for the parallel gantry.

Methods
~~~~~~~

.. function:: get_source_pos(index, pixel_positions)

        :param index: The index rotation of the gantry.
        :type index: double
        :param pixel_positions: The position of the pixel on the detector.
        :type pixel_positions: 3x1 double

        Returns the positions of the source, directly above the pixel positions. This is used to calculate the ray paths for each projection. For this gantry, the source position is dependent on the pixel position, so the source position is calculated for each pixel position.

        :returns: **source_pos** -- The position of the source relative to each pixel position.
        :rtype: :class:`3xN double`