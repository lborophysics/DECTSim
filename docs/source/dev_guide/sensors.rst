Sensors
=======

To convert the photon intensity to a signal, sensors are required. 

Sensor
------

Purpose
~~~~~~~

This class is a template for all sensors. It is not meant to be used directly, as it is an abstract class. 

Properties
~~~~~~~~~~

.. attribute:: num_bins

    (:class:`double`) The number of energy bins the sensor has.

.. attribute:: bin_width

    (:class:`double`) The width of each energy bin in the sensor.

.. attribute:: nrj_range

    (:class:`1x2 double`) The range of energies the sensor can detect.

.. attribute:: nrj_bins

    (:class:`1xN double`) A 1xnum_bins array of the energy bins the sensor has.

.. attribute:: num_samples

    (:class:`double`) The number of energy samples to take in each energy bin of the sensor.

Functions
~~~~~~~~~

.. function:: sensor(nrj_range, num_bins, num_samples=1)

    This function returns a sensor object. The parameters are as follows:

    :param nrj_range: An array representing the range of energies the sensor can detect.
    :param num_bins: The number of energy bins the sensor has.
    :param num_samples: The number of energy samples to take in each energy bin of the sensor. (default = 1)
    :type nrj_range: 2x1 double
    :type num_bins: double
    :type num_samples: double

    :returns: **sensor** -- An instance of the sensor class.
    :rtype: :class:`sensor`


Abstract Methods
~~~~~~~~~~~~~~~~

.. method:: detector_response(obj, nrj_bin, count_array)

    This method is meant to be overridden by the child class. It should take in an index referring to the energy bin and an array of photon counts in that energy bin. It should then return the signal from the sensor in response to the counts in the energy bin.

    :param nrj_bin: A single value representing the index of the energy bin.
    :param count_array: An array of dimensions [ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in the energy bin.
    :type nrj_bin: double
    :type count_array: MxNxP double

    :returns: **signal** -- should be of the same shape as ``count_array``, and should represent the signal from the sensor in response to the counts in the energy bin.
    :rtype: :class:`MxNxP double`

Methods
~~~~~~~

.. method:: get_range(obj)

    This method returns an array representing the range of energies the sensor can detect. This may be converted to an attribute in the future.

    :returns: **range** -- an array representing the range of energies the sensor can detect.
    :rtype: :class:`Nx2 double`

.. method:: get_nrj_bin(obj, nrj)

    This method takes in an energy and returns the index of the energy bin that the energy falls into.

    :param nrj: A single value representing the energy.
    :type nrj: double

    :returns: **ebin** -- is a single value representing the index of the energy bin that the energy falls into.
    :rtype: :class:`double`

.. method:: get_signal(obj, photon_counts)

    This method takes in an array of dimensions [nrj_bins, ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in each nrj bin, and returns the signal from the sensor using the :meth:`detector_response` method.

    :param photon_counts: An array of dimensions [nrj_bins, ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in each energy bin.
    :type photon_counts: MxNxPxQ double

    :returns: **signal** -- the signal from the sensor in response to the photon counts. It should essentially be the sum of the signals from each energy bin, with weights based on the energy of the bin, calculated using the :meth:`detector_response` method.
    :rtype: :class:`NxPxQ double`

.. method:: get_image(~, signal, I0)

    This method takes in the final signal and the air scan and returns :math:`-\ln{\frac{S}{I0}}`, where ``signal`` is the signal from primary and scatter rays and ``I0`` is the air scan. It is expected that other sensors can override this method, for example, to add noise to the signal.

    :param signal: An array of dimensions [ny_pix, nz_pix, nrotation] representing the signal from the sensor.
    :type signal: MxNxP double

    :returns: **image** -- should be of the same shape as ``signal``, and should represent the image from the sensor in response to the signal.
    :rtype: :class:`MxNxP double`

Potential Changes
~~~~~~~~~~~~~~~~~

The current implementation of get_image does not add noise to the signal. This may be added in the future.

:func:`get_range` may be converted to an attribute in the future.


Ideal Sensor
------------

Purpose
~~~~~~~

This class is a subclass of :class:`sensor` and represents a sensor that reacts equally to all energies.

Methods
~~~~~~~

.. method:: ideal_sensor.detector_response(obj, nrj_bin, count_array)

    This method takes in an index referring to the energy bin and an array of photon counts in that energy bin, and returns the count_array multiplied by the average energy of the energy bin. See the parameters and return values from :meth:`detector_response`.

    :param nrj_bin: A single value representing the index of the energy bin.
    :param count_array: An array of dimensions [ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in the energy bin.
    :type nrj_bin: double
    :type count_array: MxNxP double

    :returns: **signal** -- :code:`count_array` multiplied by the average energy of the energy bin.
    :rtype: :class:`MxNxP double`
