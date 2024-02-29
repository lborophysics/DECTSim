Materials
=========

This page will list all the functions and classes related to the materials that are used in the code.

Functions
---------

.. function:: cross_section(Z, nrj) 

    :param Z: An array of atomic numbers.
    :param nrj: The photon energy (in :math:`keV`).

    Given an array of atomic numbers and a photon energy, this function returns the compton cross section for each element in the array. The method is taken from `Geant4 Compton Scattering <https://geant4-userdoc.web.cern.ch/UsersGuides/PhysicsReferenceManual/html/electromagnetic/gamma_incident/compton/compton.html>`_, has been translated to MATLAB, and extended to use arrays of atomic numbers.

    :returns: ``cs``, an array of the same size as ``Z``, containing the compton cross section for each element in the array.

.. function:: photon_attenuation(Z, fracs, density, nrj)

    :param Z: An array of atomic numbers.
    :param fracs: An array of mass fractions.
    :param density: The density of the material (in :math:`g/cm^3`).
    :param nrj: The photon energy (in :math:`keV`).

    The arrays ``Z`` and ``fracs`` must be the same size. This function is based on `PhotonAttenuation <https://uk.mathworks.com/matlabcentral/fileexchange/12092-photonattenuation>`_ package available on the MATLAB File Exchange, but has been heavily reduced in size and simplified for the purposes of this code. The function is not directly used in the code, but is converted to a MEX file using `MATLAB Coder <https://uk.mathworks.com/products/matlab-coder.html>`_, which is then used in the code.

    :returns: ``att``, is the linear attenuation coefficient in :math:`cm^{-1}` for the material at the given energy.

.. function:: get_photon_attenuation(Z)

    :param Z: An array of atomic numbers.

    Given an array of atomic numbers, this function returns a gridded interpolant of the attenuation coefficients for the elements in the array. This function is significantly faster than the :code:`photon_attenuation` function, when run in MATLAB, as it only needs to be run once for each element in the array. However, the gridded interpolant is a large object and so is not suitable for use in the MEX file, if parallel processing is to be used.

    :returns: ``att_fun``, is a gridded interpolant of the attenuation coefficients for the elements in the array. This gridded interpolant returns the mass attenuation coefficients for the elements when given a photon energy. These values can then be converted to linear attenuation coefficients using the atomic fractions and density of the material.

mat_consts
----------

Purpose
~~~~~~~

This class is used to store the constants that are used in the materials functions. This is done to reduce the size of various classes that may be copied, and to make the code more readable.

Properties
~~~~~~~~~~

.. attribute:: known_materials

    This is a cell array of chars, containing the names of the materials that are known to the code. This is used to check that the user has entered a valid material name. The index of the material in this array is used to access the other properties of the material.

.. attribute:: known_densities

    This is a vector of the densities of the materials in :math:`g/cm^3`.

.. attribute:: known_atomic_numbers

    This is a cell array of vectors, containing the atomic numbers of the elements in the materials.

.. attribute:: known_mass_fractions

    This is a cell array of vectors, containing the mass fractions of the elements in the materials.

.. attribute:: atomic_masses

    This is a vector of the atomic masses of every element in the periodic table, up to lead (Z = 82). The atomic masses are in :math:`g/mol`.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

It is expected that the known_materials, known_densities, known_atomic_numbers, and known_mass_fractions properties will be updated to include more materials. It is possible that these attributes could be merged together, introducing each material as a separate attribute instead of relying on the index of the material in the known_materials cell array.

material_attenuation
--------------------

Purpose
~~~~~~~

This class is used to provide the user with a "material" object, which contains the properties of the material that are used in the code (linear attenuation coefficient and compton mean free path). 

Properties
~~~~~~~~~~

.. attribute:: atomic_numbers

    This is a vector of the atomic numbers of the elements in the material.

.. attribute:: mass_fractions

    This is a vector of the mass fractions of the elements in the material (must be the same size as atomic_numbers).

.. attribute:: density

    This is a scalar value of the density of the material in :math:`g/cm^3`.

.. attribute:: mu_from_energy

    This is a function handle that returns the linear attenuation coefficient of the material at a given energy. This attribute will only be defined if the `photon_attenuation_mex` function is available.

.. attribute:: use_mex

    This is a boolean value that is true if the `photon_attenuation_mex` function is available, and false otherwise.

Functions
~~~~~~~~~

.. function:: material_attenuation(material_name, varargin)

    :param material_name: The name of the material.
    :param varargin: The atomic numbers, mass fractions, and density of the material, or omitted if the material is known.

    This function is used to create a "material" object, which contains the properties of the material that are used in the code. 
    
    If only the ``material_name`` is given, the function will use the known_materials property of the :class:`mat_consts` class to find the material properties, and will error if the material name is not found, otherwise it will return the material object. 

    If the ``material_name``, ``atomic_numbers``, ``mass_fractions``, and ``density`` (in that order) are given, the function will create a material object using the given properties. The function will error if the ``atomic_numbers`` and ``mass_fractions`` are not vectors of the same size, or if the ``density`` is not a scalar value.

Methods
~~~~~~~

.. method:: get_mu(self, energy)

    :param energy: The photon energy (in :math:`keV`).

    This method returns the linear attenuation coefficient of the material at a given energy. If the :func:`photon_attenuation_mex` function is available, the method will use the ``mu_from_energy`` attribute (the result of :func:`get_photon_attenuation`) to return the linear attenuation coefficient. Otherwise, the method will use the MEX of the :func:`photon_attenuation` function to return the linear attenuation coefficient.

.. method:: mean_free_path(self, energy)

    :param energy: The photon energy (in :math:`keV`).

    This method returns the compton mean free path of the material at a given energy. The method uses the :func:`cross_section` function to return the compton mean free path.



