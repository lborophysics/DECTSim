The Detector Class
==================

The detector class is a container for the gantry, detector pixel array and the sensor (see :doc:`sensors`)

Purpose
-------

The only purpose of :class:`detector` is to collect all the objects that are required to simulate a detector, and to do some basic checks on the input data.

Properties
----------
`gantry`
    The gantry object that the detector is attached to.

`detector_array`
    The detector pixel array object that the detector is using.

`sensor`
    The sensor object that the detector is using.

Functions
---------

.. function:: detector(gantry, detector_array, sensor)

    The constructor for the detector class. It takes a gantry, a detector pixel array and a sensor as input. It checks that the input data is of the correct type and then assigns the input data to the properties of the class.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

This class does not seem to have significant potential, and therefore may be removed in the future, in favor of directly using the gantry, detector pixel array and sensor objects, or having the gantry include the detector and sensor objects - to be decided.
