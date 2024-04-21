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

    The number of energy bins the sensor has.

.. attribute:: bin_width

    The width of each energy bin in the sensor in keV.

.. attribute:: energy_range

    The range of energies the sensor can detect in keV.

.. attribute:: energy_bins

    A 1xnum_bins array of the energy bins the sensor has.

.. attribute:: num_samples

    The number of energy samples to take in each energy bin of the sensor.

Functions
~~~~~~~~~

.. function:: sensor(energy_range, num_bins, num_samples=1)

    This function returns a sensor object. The parameters are as follows:

    :param energy_range: An array representing the range of energies the sensor can detect in keV.
    :param num_bins: The number of energy bins the sensor has.
    :param num_samples: The number of energy samples to take in each energy bin of the sensor. (default = 1)
    :type energy_range: 2x1 double
    :type num_bins: double
    :type num_samples: double


Abstract Methods
~~~~~~~~~~~~~~~~

.. method:: detector_response(self, energy_bin, count_array)

    This method is meant to be overridden by the child class. It should take in an index referring to the energy bin and an array of photon counts in that energy bin. It should then return the signal from the sensor in response to the counts in the energy bin. The parameters are as follows:

    :param energy_bin: A single value representing the index of the energy bin.
    :param count_array: An array of dimensions [ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in the energy bin.
    :type energy_bin: double
    :type count_array: MxNxP double

    :returns: :code:`signal` should be of the same shape as ``count_array``, and should represent the signal from the sensor in response to the counts in the energy bin.

Methods
~~~~~~~

.. method:: get_range(self)

    This method returns an Nx2 array representing the range of energies the sensor can detect. This may be converted to an attribute in the future.

    :returns: :code:`range` is an Nx2 array representing the range of energies the sensor can detect.

.. method:: get_energy_bin(self, energy)

    This method takes in an energy in keV and returns the index of the energy bin that the energy falls into.

    :param energy: A single value representing the energy in keV.
    :type energy: double

    :returns: :code:`ebin` is a single value representing the index of the energy bin that the energy falls into.

.. method:: get_signal(self, array)

    This method takes in an array of dimensions [energy_bins, ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in each energy bin, and returns the signal from the sensor using the :meth:`detector_response` method.

    :param array: An array of dimensions [energy_bins, ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in each energy bin.
    :type array: MxNxPxQ double

    :returns: :code:`signal` will be [ny_pix, nz_pix, nrotation], and will represent the signal from the sensor in response to the counts in each energy bin.

Static Methods
~~~~~~~~~~~~~~

.. method:: get_image(signal, I0)

    This method takes in the final signal and the air scan and returns :math:`-\ln{\frac{S}{I0}}`, where ``S`` is the signal from primary and scatter rays and ``I0`` is the total unattenuated signal.

    :param signal: An array of dimensions [ny_pix, nz_pix, nrotation] representing the signal from the sensor.
    :type signal: MxNxP double

    :returns: :code:`image` should be of the same shape as ``signal``, and should represent the image from the sensor in response to the signal.


Ideal Sensor
------------

Purpose
~~~~~~~

This class is a subclass of :class:`sensor` and represents a sensor that reacts equally to all energies.

Methods
~~~~~~~

.. method:: ideal_sensor.detector_response(self, energy_bin, count_array)

    This method takes in an index referring to the energy bin and an array of photon counts in that energy bin, and returns the count_array multiplied by the average energy of the energy bin. See the parameters and return values from :meth:`detector_response`.

.. method:: ideal_sensor.get_image(self, signal)
    

