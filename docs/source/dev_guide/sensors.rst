Sensors
=======

To convert the photon intensity to a signal, sensors are required. 

sensor
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

    * ``energy_range``: A 2x1 array representing the range of energies the sensor can detect in keV.
    * ``num_bins``: The number of energy bins the sensor has.
    * ``num_samples``: The number of energy samples to take in each energy bin of the sensor. (default = 1)


Abstract Methods
~~~~~~~~~~~~~~~~

.. method:: detector_response(self, energy_bin, count_array)

    This method is meant to be overridden by the child class. It should take in an index referring to the energy bin and an array of photon counts in that energy bin. It should then return the signal from the sensor in response to the counts in the energy bin. The parameters are as follows:

    * ``energy_bin``: A single value representing the index of the energy bin.
    * ``count_array``: An array of dimensions [ny_pix, z_pix, rotation] representing the number of photons in each pixel and rotation in the energy bin.

    **Returns**: :code:`signal`.

    The return value should be of the same shape as ``count_array``, and should represent the signal from the sensor in response to the counts in the energy bin.

.. method:: get_image(self, signal)

    This method is meant to be overridden by the child class. It should take in the signal from the sensor and return an image from the signal. The parameters are as follows:

    * ``signal``: An array of dimensions [ny_pix, z_pix, rotation] representing the signal from the sensor.

    **Returns**: :code:`image`.

    The return value should be of the same shape as ``signal``, and should represent the image from the sensor in response to the signal.

Methods
~~~~~~~

.. method:: sample_source(self, source)

    This method samples a :class:`source` object and returns the energies and intensities of the photons sampled from the source. The parameters are as follows:

    * ``source``: A :class:`source` object representing the x-ray source.

    **Returns**: :code:`[energies, intensities]`.

    The return values are two arrays of length [1, num_bins*num_samples], representing the energies and intensities of the photons sampled from the source. 

.. method:: get_energy_bin(self, energy)

    This method takes in an energy in keV and returns the index of the energy bin that the energy falls into. The parameters are as follows:

    * ``energy``: A single value representing the energy in keV.

    **Returns**: :code:`ebin`.

    The return value is a single value representing the index of the energy bin that the energy falls into.

.. method:: get_signal(self, array)

    This method takes in an array of dimensions [energy_bins, ny_pix, z_pix, rotation] representing the number of photons in each pixel and rotation in each energy bin, and returns the signal from the sensor using the :meth:`detector_response` method. The parameters are as follows:

    * ``array``: An array of dimensions [energy_bins, ny_pix, z_pix, rotation] representing the number of photons in each pixel and rotation in each energy bin.

    **Returns**: :code:`signal`.

    The return value will be [ny_pix, z_pix, rotation], and will represent the signal from the sensor in response to the counts in each energy bin.


ideal_sensor
------------

Purpose
~~~~~~~

This class is a subclass of :class:`sensor` and represents a sensor that reacts equally to all energies.

Methods
~~~~~~~

.. method:: ideal_sensor.detector_response(self, energy_bin, count_array)

    This method takes in an index referring to the energy bin and an array of photon counts in that energy bin, and returns the count_array multiplied by the average energy of the energy bin. See the parameters and return values from :meth:`detector_response`.

.. method:: ideal_sensor.get_image(self, signal)
    
        This method takes in the final signal and returns :math:`-\ln{S}`, where ``S`` is the signal. See the parameters and return values from :meth:`get_image`.

