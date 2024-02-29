Ray Tracing
===========

.. function:: ray_trace(ray_start, v1_to_v2, init_plane, v_dims, num_planes)

    Ray trace through a uniform grid of planes, using `Siddon's algorithm <https://doi.org/10.1118/1.595715>`_. The grid is defined by the initial plane (``init_plane``), which is the coordinate of the top left corner of the voxel cube, the dimensions of each voxel in the voxel grid (``v_dims``), and the number of planes in the grid (``num_planes``). The ray is defined by the starting point (``ray_start``) and the direction vector from the starting point to the end point (``v1_to_v2``).

    * ``ray_start``: A 3x1 array representing the coordinates of the starting point of the ray.
    * ``v1_to_v2``: A 3x1 array representing the direction vector from the starting point to the end point of the ray.
    * ``init_plane``: A 3x1 array representing the coordinates of the top left corner of the voxel cube.
    * ``v_dims``: A 3x1 array representing the dimensions of each voxel in the voxel grid.
    * ``num_planes``: A 3x1 array representing the number of planes in the grid.

    **Returns**: :code:`[lengths, indices]`.

    * ``lengths``: A 1xN array representing the lengths of the ray in each voxel.
    * ``indices``: A 3xN array representing the 3D indices of the voxels that the ray passes through.

.. function:: ray_trace_many(ray_start, v1_to_v2, init_plane, v_dims, num_planes)

    Perform many ray traces through a uniform grid of planes, using `Siddon's algorithm <https://doi.org/10.1118/1.595715>`_. The parameters are defined as follows:

    * ``ray_start``: A 3xM array representing the coordinates of the starting points of the rays.
    * ``v1_to_v2``: A 3xM array representing the direction vectors from the starting points to the end points of the rays.
    * ``init_plane``: A 3x1 array representing the coordinates of the top left corner of the voxel cube.
    * ``v_dims``: A 3x1 array representing the dimensions of each voxel in the voxel grid.
    * ``num_planes``: A 3x1 array representing the number of planes in the grid.
  
    **Returns**: :code:`[lengths, indices]`.

    * ``lengths``: A 1xM cell array, where each cell is a 1xN array representing the lengths of the ray in each voxel.
    * ``indices``: A 1xM cell array, where each cell is a 3xN array representing the 3D indices of the voxels that the ray passes through.

Both of these functions use the same algorithm, but the second function is optimised for many rays. They are also able to be converted to MEX files for faster computation, using the MATLAB Coder app.