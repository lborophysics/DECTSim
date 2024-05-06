Comparing with DukeSim
======================

In order to perform validation of the code, some classes and functions were created to compare the results of the DukeSim with the results of the code. 

Classes
-------


duke_sensor
~~~~~~~~~~~

Purpose
^^^^^^^

This class is used to replicate the behavior of the DukeSim sensor, using the same data. This class inherits from the class :class:`sensor`.

Properties
^^^^^^^^^^

.. attribute:: electronic_std

    (:class:`double`) The standard deviation of the electronic noise of the sensor. Currently not used, but it is a property of the DukeSim sensor, and could be implemented for better comparison.

.. attribute:: mean_det_response

    (:class:`Nx1 double`) The mean detector response at each energy.

.. attribute:: var_det_response

    (:class:`Nx1 double`) The variance of the detector response at each energy. Currently not used, but it is a property of the DukeSim sensor, and could be implemented for better comparison.

Functions
^^^^^^^^^

.. function:: duke_sensor(num_energies, detector_response_file, electronic_std)

    Constructor of the class. It receives the number of energies, the file with the detector response and the electronic standard deviation to create the list of mean detector responses and variance at each energy.

    :param num_energies: The number of energies in the detector response file.
    :type num_energies: double
    :param detector_response_file: The file with the detector response.
    :type detector_response_file: string
    :param electronic_std: The electronic standard deviation of the sensor.
    :type electronic_std: double

    :returns: **obj** - An instance of the class.
    :rtype: :class:`duke_sensor`

Methods
^^^^^^^

.. method:: duke_sensor.detector_response(obj, nrj_bin, count_array)

    Multiplies the count array by the mean detector response at the energy bin.

    :param nrj_bin: A single value representing the index of the energy bin.
    :param count_array: An array of dimensions [ny_pix, nz_pix, nrotation] representing the number of photons in each pixel and rotation in the energy bin.
    :type nrj_bin: double
    :type count_array: MxNxP double

    :returns: **signal** -- The detector response at the energy bin.
    :rtype: :class:`MxNxP double`

Potential Future Changes
^^^^^^^^^^^^^^^^^^^^^^^^

The DukeSim sensor has a standard deviation of the electronic noise and a variance of the detector response at each energy. These properties could be implemented in the class to make the comparison more accurate.

duke_source
~~~~~~~~~~~

Purpose
^^^^^^^

This class is used to replicate the behavior of the DukeSim source, using the same data. This class inherits from the class :class:`source`.

Properties
^^^^^^^^^^

.. attribute:: ebins
    :noindex:

    (:class:`1xN double`) The energy bins of the source.

.. attribute:: spectrum

    (:class:`NxM double`) The spectrum of the source for each energy at each pixel.

Functions
^^^^^^^^^

.. function:: duke_source(filename, num_energies, num_ypixels, msecs_per_frame)

    Constructor of the class. It receives the file with the source spectrum and splits it into the energy bins and the spectrum using the number of energies, number of pixels in the y direction. Then the spectrum is multiplied by the msecs_per_frame to get the number of photons per pixel per frame.

    :param filename: The file with the source spectrum.
    :type filename: string
    :param num_energies: The number of energies in the source spectrum.
    :type num_energies: double
    :param num_ypixels: The number of pixels in the y direction.
    :type num_ypixels: double
    :param msecs_per_frame: The number of milliseconds per frame.
    :type msecs_per_frame: double

    :returns: **obj** - An instance of the class.
    :rtype: :class:`duke_source`

Methods
^^^^^^^

.. method:: duke_source.get_energies(obj, range)

        This method returns the energies of the xrays if they are within the range. If they are not, it errors, as it is up to the user to give the correct sensor to the source.

        :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
        :type range: Nx2 double

        :returns: **energies** - The weighted mean of the energies within the range. 
        :rtype: :class:`1xN double`

.. method:: duke_source.get_fluences(obj, range, ypixels)

    This method returns the fluences of the xrays if they are within the range for each pixel. If they are not, it returns 0.

    :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
    :type range: Nx2 double
    :param ypixels: The index of the pixels in the y direction.
    :type ypixels: 1xM double

    :returns: **fluences**  -- The sum of the fluences of the xrays within the range in units of photons/cm^2 at 1m. 
    :rtype: :class:`MxN double`

.. method:: duke_source.get_nrj_range(obj)

    This method returns the range of energies of the source spectrum.

    :returns: 
        - **min** (:class:`double`) -- The minimum energy bin of the spectrum file.
        - **max** (:class:`double`) -- The maximum energy bin of the spectrum file.


Functions
---------

.. function:: duke_parser(path_to_duke_out)

    This function returns the simulated sinogram and parameters from the DukeSim output folder. The argument ``path_to_duke_out`` is the path to the DukeSim output folder, and equivalent to the ``MainDir`` parameter in the DukeSim input file. 

    :param path_to_duke_out: The path to the DukeSim output folder.
    :type path_to_duke_out: string

    :returns: 
        - **sinogram** (:class:`MxNxP double`) -- The simulated sinogram with dimensions [ny_pix, nz_pix, nrotation].
        - **params** (:class:`dict`) -- A dictionary with the parameters of the simulation.

.. function:: get_duke_source(path_to_duke_out)

    This function returns a :class:`duke_source`  by calling :func:`duke_parser` with the path to the DukeSim output folder and using the resultant parameters to create the source. A file that is necessary for the source is the ``Spectrum_Duke1_120kV_900_1mAs_1ms_calibrated.bin`` file, which can be found in the DukeSim input folder when running the DukeSim simulation. In the future, this function could be modified to receive the path to the source spectrum file.

    :param path_to_duke_out: The path to the DukeSim output folder.
    :type path_to_duke_out: string

    :returns: **the_source** - The source created from the DukeSim output folder.
    :rtype: :class:`duke_source`

.. function:: get_duke_detector(path_to_duke_out)

    This function returns a :class:`detector` object containing a :class:`gantry`, a :class:`curved_detector` or a :class:`flat_detector` and a :class:`duke_sensor` by calling :func:`duke_parser` with the path to the DukeSim output folder and using the resultant parameters to create the detector. A file that is necessary for the detector is the ``DetResponse_Duke1_120kV_final.bin`` file, which can be found in the DukeSim input folder when running the DukeSim simulation. In the future, this function could be modified to receive the path to the detector response file.

    :param path_to_duke_out: The path to the DukeSim output folder.
    :type path_to_duke_out: string

    :returns: **the_detector** - The detector created from the DukeSim output folder.
    :rtype: :class:`detector`
     

Files
-----

.. function:: dukesim_voxel_creator

    This file creates the phantom for the DukeSim simulation. It uses the :class:`voxel_array` within this package to define the phantom and then saves it in the format required by DukeSim. Currently it is doing a specific phantom, but it could be modified to create any phantom, as long as it can be defined by the :class:`voxel_array`.