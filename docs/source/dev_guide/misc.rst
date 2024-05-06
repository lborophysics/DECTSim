Miscellaneous
=============

Note all angles are in radians.

rotz
----

.. function:: rotz(angle)

   :param angle: The angle of rotation in radians.
   :type angle: double
   
   :returns: **R** -- The rotation matrix for a rotation about the z-axis.
   :rtype: :class:`3x3 double`

rotz_vec
--------

.. function:: rotz_vec(angles)

   :param: angle: The angles of rotation in radians.
   :type angle: 1xN double

   :returns: **R** -- The rotation matrix for a rotation about the z-axis for each angle.
   :rtype: :class:`3x3xN double`
   
roty
----

.. function:: roty(angle)

   :param angle: The angle of rotation in radians.
   :type angle: double

   :returns: **R** -- The rotation matrix for a rotation about the y-axis.
   :rtype: :class:`3x3 double`

chord2ang
---------

.. function:: chord2ang(chord, diameter)

   :param chord: The chord length.
   :type chord: double
   :param diameter: The diameter of the circle.
   :type diameter: double

   :returns: **angle** -- The angle subtended by the chord of the circle.
   :rtype: :class:`double`