The Detector Class
==================

The detector class is a container for the gantry, detector pixel array and the sensor (see :doc:`sensors`)

Purpose
-------

The only purpose of :class:`detector` is to collect all the objects that are required to simulate a detector, and to do some basic checks on the input data.

Properties
----------
.. attribute:: the_gantry
    :noindex:
    
    (:class:`gantry`) The gantry object that the detector is attached to.

.. attribute:: the_array
    
    (:class:`detector_array`) The detector pixel array object that the detector is using.

.. attribute:: the_sensor
    
    (:class:`sensor`) The sensor object that the detector is using.

Functions
---------

.. function:: detector(the_gantry, the_array, the_sensor)

    The constructor for the detector class. It takes a gantry, a detector pixel array and a sensor as input. It checks that the input data is of the correct type and then assigns the input data to the properties of the class.

    :param the_gantry: The gantry object that the detector is attached to.
    :type gantry: gantry
    :param the_array: The detector pixel array object that the detector is using.
    :type the_array: detector_array
    :param the_sensor: The sensor object that the detector is using.
    :type the_sensor: sensor

    :returns: **obj** - An instance of the detector class.
    :rtype: :class:`detector`


Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

This class does not seem to have significant potential, and therefore may be removed in the future, in favor of directly using the gantry, detector pixel array and sensor objects, or having the gantry include the detector and sensor objects - to be decided.
