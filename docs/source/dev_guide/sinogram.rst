Computing the Sinogram
======================

To generate the sinogram of the phantom, there is a single function to call.

.. function:: compute_sinogram(xray_source, phantom, detector_obj, scatter, sfactor)
    
    Compute the sinogram of the phantom, given the source and detector, and optionally, the scatter model.

    :param xray_source: the source object, this returns a sample of the source spectrum
                        giving energy and intensities of the photons. 
    :param phantom: the phantom object, this allows you to determine the following:
                    - How the world is divided into voxels, for ray tracing
                    - What material is in each voxel
                    - Determine the attenuation and mean free path of the materials
    :param detector_obj: the detector object, which includes the following:
                         - Gantry: How the detector is positioned and moves
                         - Ray generation: Determines where the rays are directed from the source
                         - Sensor: Determines how the rays are detected
    :param scatter: A string that determines the scatter model to use. If not provided,
                    no scatter is used. The following are the available scatter models:
                    - 'none': no scatter is used
                    - 'fast': the convolution scatter model is used
                    - 'slow': the Monte Carlo scatter model is used
    :param sfactor: For the Monte Carlo scatter model, the number of scatter
                    events to simulate for each photon. For the convolution
                    scatter model, it is the strength of the scatter. (default: 1)
    :type xray_source: source
    :type phantom: voxel_array
    :type detector_obj: detector
    :type scatter: string
    :type sfactor: double
    :return: the sinogram of the phantom, given the source and detector
             and optionally, the scatter model

