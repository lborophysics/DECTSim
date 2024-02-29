Sources
=======

To generate the intensities and energies of the xrays, a source needs to be instantiated.

source
------

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

    This method is meant to be overridden by the child classes. It should return two lists, one with the energies of the xrays and the other with the intensities of the xrays.

    :param range: A Nx2-element vector with N rows of [min_energy, max_energy).

    **Returns**: :code:`[energies, intensities]`.

    The energies and intensities are lists of length N. If the source is not able to generate the energies in the range, it should return ``NaNs`` in place.
    
single_energy
-------------

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

    This method returns the energy and intensity of the xray if it is within the range. If it is not, it returns NaNs.

    :param range: A Nx2-element vector with N rows of [min_energy, max_energy).

    **Returns**: :code:`[energies, intensities]`.

    The energies and intensities are lists of length N. If the single energy is not within the range, ``NaNs`` are returned.

