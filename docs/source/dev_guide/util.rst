Constants & Units
=================

The constants class contains a number of useful constants, accessible as through the class itself. For example, to access the speed of light, you would use `constants.c`. 

Available constants
-------------------

- ``c`` : speed of light in a vacuum
- ``me_c2``:  electron mass energy equivalent in keV
- ``N_A``: Avogadro's number

The units class is a collection of useful units that converts to the units of the program. This means that the whole program is consistent with the units used, independent of the units used as default. It is expected any number that is input must have a unit attached to it. If not, it is in the default unit, but these are deliberately omitted from the documentation, as these could change, so the user should always specify the unit.

Available units
---------------
- Distance (m, cm (default), mm, um, nm)
- Area (m2, cm2 (default), mm2, um2, nm2, barn)
- Mass (kg, g (default), mg, ug)
- Energy (MeV, keV (default), eV, meV)

Possible future improvements
----------------------------
- Add more constants
- Add more units
- Use the units in the code to make it more readable