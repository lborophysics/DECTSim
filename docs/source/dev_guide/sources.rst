Sources
=======

To generate the intensities and energies of the xrays, a source needs to be instantiated.

Source Class
------------

Purpose
~~~~~~~

This class is a template for all the sources. It is not meant to be used directly, as it is an abstract class.

Properties
~~~~~~~~~~
The attributes of this abstract class are immutable and are set at the time of instantiation.

.. attribute:: num_energies

    The number of energies that the source will generate.

Functions
~~~~~~~~~

.. function:: source(num_energies)

    This is the constructor for the source class. It sets the number of energies that the source will generate.

Abstract Methods
~~~~~~~~~~~~~~~~

.. method:: get_energies(self, range)

    This method is meant to be overridden by the child classes. It should return the energies of the xrays that the source will generate within each range provided.

    :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
    :type range: Nx2 double

    :returns: :code:`energies` lists of length N. If the source is not able to generate the energies in the range, it should error, or give a valid energy with a zero fluence. It is up to the user to give the correct sensor to the source.
    
.. method:: get_fluences(self, range)

    This method is meant to be overridden by the child classes. It should return the fluences of the xrays that the source will generate within each range provided.

    :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
    :type range: Nx2 double

    :returns: :code:`fluences` lists of length N of the fluences in units of photons/cm^2 at 1m. (Use the units library to ensure the conversion is correct).

    
Single Energy Source
--------------------

Purpose
~~~~~~~

This is a subclass of the :class:`source` class. It represents a source that generates a single energy.

Properties
~~~~~~~~~~
All the properties from the :class:`source` class are inherited and also the following:

.. attribute:: energy

    The energy of the xray that the source will generate.


Functions
~~~~~~~~~

.. function:: single_energy(energy)

    This is the constructor for the single_energy class. It sets the energy of the xray that the source will generate.

Methods
~~~~~~~

.. method:: single_energy.get_energies(self, range)

    This method returns a list of energies of the xrays, independent of the range. If the energy is not within the range, we use a fluence of 0.

    :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
    :type range: Nx2 double

    :returns: :code:`energies` is a list of length N, with every element being the energy of the xray, independent of the range. 

.. method:: single_energy.get_fluences(self, range)
    
        This method returns the fluence of the xray if it is within the range. If it is not, it returns 0.
    
        :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
        :type range: Nx2 double
    
        :returns: :code:`fluences` is a list of length N, with the fluence being :math:`1\times10^6` if the energy is within the range, and 0 if it is not.


Source from Spectrum File
-------------------------

Purpose
~~~~~~~

This is a subclass of the :class:`source` class. It represents a source that generates the xrays from a spectrum file. The spectrum file is expected to be in the format produced by the SpekPy library. The following code is an example of how to generate a spectrum file:

.. code-block:: python

    import spekpy as sp

    s = sp.Spek(kvp=80,th=12, dk=1) # Generate a spectrum (80 kV, 12 degree tube angle)
    s.filter('Al', 4.0) # Filter by 4 mm of Al

    s.export_spectrum('spectrum.spk') # Export the spectrum to a file

At the moment, the code is limited in producing different fluences at different angles. This is a limitation of the code and not the library. In the future, it is expected that the code will have an algorithm to calculate the fluences at different angles.

Properties
~~~~~~~~~~

All the properties from the :class:`source` class are inherited and also the following:

.. attribute:: ebins

    The energy bins of the spectrum file.

.. attribute:: fluences

    The fluences of the spectrum file.

Functions
~~~~~~~~~

.. function:: source_fromfile(file)

    This is the constructor for the source_fromfile class. It reads the spectrum file and sets the energy bins and fluences.

Methods
~~~~~~~

.. method:: source_fromfile.get_energies(self, range)

    This method returns the energies of the xrays if they are within the range. If they are not, it errors, as it is up to the user to give the correct sensor to the source.

    :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
    :type range: Nx2 double

    :returns: :code:`energies` is a list of length N, returning the weighted mean of the energies within the range. 

.. method:: source_fromfile.get_fluences(self, range)

    This method returns the fluences of the xrays if they are within the range. If they are not, it returns 0.

    :param range: A vector with N rows of [min_energy, max_energy) indicating the range of energies that the source should generate.
    :type range: Nx2 double

    :returns: :code:`fluences` is a list of length N, returning the sum of the fluences of the xrays within the range in units of photons/cm^2 at 1m. (This function uses the units library to ensure the conversion is correct).


