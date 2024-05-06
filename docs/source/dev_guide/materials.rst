Materials
=========

This page will list all the functions and classes related to the materials that are used in the code.

Functions
---------

.. function:: cross_section(Z, nrj) 

    :param Z: An array of atomic numbers.
    :type Z: 1xN double
    :param nrj: The photon energy.
    :type nrj: Mx1 double

    Given an array of atomic numbers and a set of photon energies, this function returns the Compton cross section for each element in the array. The method is taken from `Geant4 Compton Scattering <https://geant4-userdoc.web.cern.ch/UsersGuides/PhysicsReferenceManual/html/electromagnetic/gamma_incident/compton/compton.html>`_, has been translated to MATLAB, and extended to use arrays of atomic numbers. 
    The photon energy does not need to be a column vector, and could be a row vector, but the array of atomic numbers must be a row vector.

    :returns: **cs** -- an array containing the Compton cross section for each ``Z`` at each energy in ``nrj``. 
    :rtype: :class:`Mx1 double`


.. function:: photon_attenuation(Z, fracs, density, nrj)

    :param Z: An array of atomic numbers.
    :type Z: 1xN double
    :param fracs: An array of mass fractions.
    :type fracs: 1xN double
    :param density: The density of the material.
    :type density: double
    :param nrj: The photon energies.
    :type nrj: 1xM double

    The arrays ``Z`` and ``fracs`` must be the same size. This function is based on `PhotonAttenuation <https://uk.mathworks.com/matlabcentral/fileexchange/12092-photonattenuation>`_ package available on the MATLAB File Exchange, but has been heavily reduced in size and simplified for the purposes of this code. The function is not directly used in the code, but is converted to a MEX file using `MATLAB Coder <https://uk.mathworks.com/products/matlab-coder.html>`_, which is then used in the code.

    :returns: **att** -- The linear attenuation coefficient for the material at each energy in ``nrj``.
    :rtype: :class:`1xM double`

.. function:: get_photon_attenuation(Z)

    :param Z: An array of atomic numbers.
    :type Z: 1xN double

    Given an array of atomic numbers, this function returns a gridded interpolant of the attenuation coefficients for the elements in the array. This function is significantly faster than the :func:`photon_attenuation` function, when run in MATLAB, as it only needs to be run once for each element in the array. However, the gridded interpolant is a large object and so is not suitable for use in the MEX file, if parallel processing is to be used.

    :returns: **att_fun** -- A gridded interpolant of the attenuation coefficients for the elements in the array. This gridded interpolant returns the mass attenuation coefficients for the elements when given a photon energy. These values can then be converted to linear attenuation coefficients using the atomic fractions and density of the material.
    :rtype: :class:`griddedInterpolant`

mat_consts
----------

Purpose
~~~~~~~

This class is used to store the constants that are used in the materials functions. This is done to reduce the size of various classes that may be copied, and to make the code more readable.

Properties
~~~~~~~~~~

.. attribute:: known_materials

    :class:`(1xN cell)` This is a cell array of chars, containing the names of the materials that are known to the code. This is used to check that the user has entered a valid material name. The index of the material in this array is used to access the other properties of the material.

.. attribute:: known_densities

    (:class:`1xN double`) This is a vector of the densities of the materials.

.. attribute:: known_atomic_numbers

    (:class:`1xN cell`) This is a cell array of vectors, containing the atomic numbers of the elements in the materials.

.. attribute:: known_mass_fractions

    (:class:`1xN cell`) This is a cell array of vectors, containing the mass fractions of the elements in the materials.

.. attribute:: atomic_masses

    (:class:`1x82 double`) This is a vector of the atomic masses of every element in the periodic table, up to lead (Z = 82). The atomic masses are in :math:`g/mol`.

Potential Future Changes
~~~~~~~~~~~~~~~~~~~~~~~~

It is expected that the known_materials, known_densities, known_atomic_numbers, and known_mass_fractions properties will be updated to include more materials. It is possible that these attributes could be merged together, introducing each material as a separate attribute instead of relying on the index of the material in the known_materials cell array.

material_attenuation
--------------------

Purpose
~~~~~~~

This class is used to provide the user with a "material" object, which contains the properties of the material that are used in the code (linear attenuation coefficient and Compton mean free path). 

Properties
~~~~~~~~~~

.. attribute:: name

    (:class:`string`) This is the name of the material.

.. attribute:: atomic_numbers

    (:class:`1xN double`) This is a vector of the atomic numbers of the elements in the material.

.. attribute:: mass_fractions

    (:class:`1xN double`) This is a vector of the mass fractions of the elements in the material (must be the same size as atomic_numbers).

.. attribute:: density

    (:class:`double`) This is a scalar value of the density of the material in :math:`g/cm^3`.

.. attribute:: mu_from_energy

    (:class:`handle`) This is a function handle that returns the linear attenuation coefficient of the material at a given energy. This attribute will only be defined if the `photon_attenuation_mex` function is available.

.. attribute:: use_mex

    (:class:`logical`) This is a boolean value that is true if the `photon_attenuation_mex` function is available, and false otherwise.

Functions
~~~~~~~~~

.. function:: material_attenuation(material_name, varargin)

    :param material_name: The name of the material.
    :type material_name: string
    :param varargin: The atomic numbers, mass fractions, and density of the material, or omitted if the material is known.

    This function is used to create a "material_attenuation" object, which contains the properties of the material that are used in the code. 
    
    If only the ``material_name`` is given, the function will use the known_materials property of the :class:`mat_consts` class to find the material properties, and will error if the material name is not found, otherwise it will return the material object. 

    If the ``material_name``, ``atomic_numbers``, ``mass_fractions``, and ``density`` (in that order) are given, the function will create a material object using the given properties. The function will error if the ``atomic_numbers`` and ``mass_fractions`` are not vectors of the same size, or if the ``density`` is not a scalar value.

    :returns: **material** -- a material object that contains the properties of the material that are used in the code.
    :rtype: :class:`material_attenuation`

Methods
~~~~~~~

.. method:: get_mu(obj, nrj)

    :param nrj: The photon energy.
    :type nrj: 1xN double

    This method returns the linear attenuation coefficient of the material at a given energy. If the :func:`photon_attenuation_mex` function is available, the method will use the ``mu_from_energy`` attribute (the result of :func:`get_photon_attenuation`) to return the linear attenuation coefficient. Otherwise, the method will use the MEX of the :func:`photon_attenuation` function to return the linear attenuation coefficient.

    :returns: **mu** -- the linear attenuation coefficient of the material at each energy in ``nrj``.
    :rtype: :class:`1xN double`

.. method:: mean_free_path(obj, nrj)

    :param nrj: The photon energy.
    :type nrj: double

    This method returns the Compton mean free path of the material at a given energy. The method uses the :func:`cross_section` function to return the Compton mean free path.

    :returns: **mfp** -- the Compton mean free path of the material at each energy in ``nrj``.
    :rtype: :class:`Nx1 double`


Static Methods
~~~~~~~~~~~~~~

.. staticmethod:: get_materials(filename)

    Given a file that can be read using the :func:`readtable` function, this static method will return a cell array of material objects. In this file, the first column should contain the names of the materials, with the header "Name". From the second column onwards, the first row should contain the atomic numbers of the elements in the material, while the following rows are the mass fractions of the elements in the material specified in the first column. The second to last row should contain the density of the material, with the header "Density". The last row should contain an index of the material, with the header "Organ ID", starting from 0. The returned cell array will contain the material objects in the order of the value contained in "Organ ID" column.

    :returns: **materials** -- a cell array of material objects.
    :rtype: :class:`1xN cell`

