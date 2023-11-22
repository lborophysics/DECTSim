The Detector Class
==================

The detector class is a base class to build detector types on top of, using inheritance. It is not intended to be used directly and will raise an error if you try to do so.

Attributes
----------

The list of attributes is as follows:

.. literalinclude:: ../../../src/classes/detector.m
    :lines: 2-10
    :linenos:

These attributes are all set in the constructor, which is called when you create a new detector object and can only be accessed by inheriting classes.

Constructor
-----------

The constructor is called when you create a new detector object. It is called with the following arguments:

.. literalinclude:: ../../../src/classes/detector.m
    :lines: 13-32
    :linenos:

This constructor is called by the constructor of the inheriting class, which is called when you create a new detector object. An example of this is shown below. The purpose of this constructor is to set the protected attributes of the detector object and perform some basic checks on the input arguments. 

.. literalinclude:: ../../../src/classes/parallel_detector.m
    :lines: 1, 11, 12, 19, 26, 64, 65
    :linenos:

Methods
-------

The list of methods is as follows:

:func:`generate_image`
  This function generates an image from the given voxels. It loops through each rotation and each pixel of the detector. At each angle, the method :func:`get_ray_generator` is called to get a ray generator object. The result is then called for each pixel in the detector returning a ray that performs the ray tracing through the voxels returning the attenuation value. Finally the attenuation values are passed into the :func:`detector_response` method to get the pixel values. The code is shown below:

    .. literalinclude:: ../../../src/classes/detector.m
        :lines: 39-53
        :linenos:

  This function is the same for all detector types and is not intended to be overridden, unless you require additional actions to be performed. Methods that are intended to be overridden includes :func:`get_ray_generator` and :func:`detector_response`, allowing you to change the way the ray tracing is performed and the way the attenuation values are converted into pixel values through inheritance.

:func:`get_ray_generator`
    This method throws an error if called directly and is intended to be overridden by inheriting classes. It is called by the :func:`generate_image` method to get a ray generator object. 

:func:`detector_response`
    This method by default returns :math:`exp(-attenuation)` but can be overridden by inheriting classes to change the way the attenuation values are converted into pixel values, being called by the :func:`generate_image` method.

:func:`get_scan_angles`
    This method returns the scan angles for the detector. It is intended to be called by the user in order to get the scan angles for reconstruction of the image.

:func:`rotate`
    This method throws an error if called directly and is intended to be overridden by inheriting classes. It is called by the :func:`generate_image` method at the end of each rotation to rotate the detector to the next angle.

Detector Types
--------------

The following detector types are available:
  - :class:`parallel_detector`
  - :class:`curved_detector`

These are all inherited from the :class:`detector` class and override the :func:`get_ray_generator` and :func:`rotate` methods to mimic the behaviour of the different detector types.
