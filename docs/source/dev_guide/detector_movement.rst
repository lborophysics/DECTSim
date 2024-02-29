Detector Movement
=================

The detector movement is controlled by the super class :class:`gantry`. The available classes are:

gantry
------

Purpose
~~~~~~~

The gantry class is used to control the movement of the gantry, it is used to store the parameters of the how your image will be created through the movement of the gantry.

The :func:`get_rot_mat` method is used to get the rotation matrix for the gantry, this is not intended to be used by the user but is used by classes which are intended to be attached to the gantry.

Properties
~~~~~~~~~~

    `dist_to_detector` : (1, 1) double
        Distance from source to detector

    `to_source_vec`: (3, 1) double = [0;1;0]
        Vector from source to centre of detector. The initial value is [0;1;0] as the source will always start above the detector pixel array. This is used in the `detector_array` classes to calculate the ray paths for each projection.

    `num_rotations` : (1, 1) double
        Number of rotations the gantry will make, i.e. the number of projections. This is required in the funciton :func:`compute_sinogram` 
    
    `rot_angle` : (1, 1) double
        The angle of rotation for each projection. Calculated as `total_rotation/num_rotations`. This is a precalculation to save time in the method :meth:`get_rot_mat`.

    `scan_angles` : (1, :) double
        The angles at which the gantry will rotate to. This is for the user to get the scan angles for use with reconstruction algorithms. 
    

Functions
~~~~~~~~~

.. function:: gantry(dist_to_detector, num_rotations, total_rotation=2*pi)
    
        Constructor for the gantry class. 

        * `dist_to_detector` is the distance from the source to the detector.
        * `num_rotations` is the number of rotations the gantry will make, i.e. the number of projections.
        * `total_rotation` is the total rotation of the gantry in radians (default :math:`2\pi`).


Methods
~~~~~~~~

.. function:: get_rot_mat()

        Returns the rotation matrix for the gantry. This is used to rotate any objects attached to the gantry.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

This class will likely be changed to be an abstract class, and then a new class will be created for each type of gantry. This will allow for more specific gantry types to be created, such as axial or helical gantry, and for the user to be able to create their own gantry types.