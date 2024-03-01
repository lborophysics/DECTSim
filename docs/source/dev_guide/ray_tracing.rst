Ray Tracing
===========

.. function:: ray_trace(ray_start, v1_to_v2, init_plane, v_dims, num_planes)

    Ray trace through a uniform grid of planes, using `Siddon's algorithm <https://doi.org/10.1118/1.595715>`_. The grid is defined by the initial plane (``init_plane``), which is the coordinate of the top left corner of the voxel cube, the dimensions of each voxel in the voxel grid (``v_dims``), and the number of planes in the grid (``num_planes``). The ray is defined by the starting point (``ray_start``) and the direction vector from the starting point to the end point (``v1_to_v2``).

    :param ray_start: The coordinates of the starting point of the ray.
    :param v1_to_v2: The direction vector from the starting point to the end point of the ray.
    :param init_plane: The coordinates of the top left corner of the voxel cube.
    :param v_dims: The dimensions of each voxel in the voxel grid.
    :param num_planes: The number of planes in the grid.
    :type ray_start: 3x1 double
    :type v1_to_v2: 3x1 double
    :type init_plane: 3x1 double
    :type v_dims: 3x1 double
    :type num_planes: 3x1 double

    :returns:
        - **lengths** (:class:`1xN double`) - The lengths of the ray in each voxel.
        - **indices** (:class:`3xN double`) - The 3D indices of the voxels that the ray passes through.

.. function:: ray_trace_many(ray_start, v1_to_v2, init_plane, v_dims, num_planes)

    Perform many ray traces through a uniform grid of planes, using `Siddon's algorithm <https://doi.org/10.1118/1.595715>`_. The parameters are defined as follows:

    :param ray_start: The coordinates of the starting points of the rays.
    :param v1_to_v2: The direction vectors from the starting points to the end points of the rays.
    :param init_plane: The coordinates of the top left corner of the voxel cube.
    :param v_dims: The dimensions of each voxel in the voxel grid.
    :param num_planes: The number of planes in the grid.
    :type ray_start: 3xM double
    :type v1_to_v2: 3xM double
    :type init_plane: 3x1 double
    :type v_dims: 3x1 double
    :type num_planes: 3x1 double
  
    :returns:
        - **lengths** (:class:`1xM cell`) - A cell array where each cell is a 1xN array representing the lengths of the ray in each voxel.
        - **indices** (:class:`1xM cell`) - A cell array where each cell is a 3xN array representing the 3D indices of the voxels that the ray passes through.

Both of these functions use the same algorithm, but the second function is optimised for many rays. They are also able to be converted to MEX files for faster computation, using the MATLAB Coder app.
