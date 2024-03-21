# Using the GUI

To change any of the parameters of the simulation, click on an object in the left panel. This will show a new panel with the parameters of the object with the available options. To hide the panel, click on the object again. Once you have set the parameters, click on the "Run" with the big green arrowhead to run the simulation.

The simulation by default will run with the following parameters, for understanding each term, please go to the section on this page that corresponds to the object you want to understand.
    - Source: 
        - Voltage: 40 kV
        - Parallel beam
    - Phantom:
        - 3D cylinder including air, water, bone, fat, blood and muscle
        - 1 cm voxel size
    - Detector:
        - 1D flat detector
        - 900 pixels
        - 1 mm wide pixels
        - Ideal sensor (has an equal response to all energies)
    - Reconstruction:
        - No filter
        - Interpolation method: Nearest neighbour
    - Scatter:
        - No scatter
    - Gantry:
        - 180 projections (2 degree steps)
        - 100 cm from source to detector

## Source
The source controls the energy and intensity of the x-ray beam. There are currently two source energies available: 40 kV and 80 kV. It is possible load a custom spectrum, this must be a '.mat' file containing an object called `source`, using the objects within the DECTSim backend. In the future, you should be able to create this new source within the GUI.

The source also controls the type of beam, with the options being parallel or cone. The parallel beam is where all the rays heading towards the phantom are parallel, and the cone beam is where all the rays are emitted from a single point.

## Phantom
The phantom is the object being imaged. It is the representation of the 3D object that the x-rays are passing through. The phantom is represented as a 3D matrix, split into cubes. Each cube, named a voxel, has a value representing the attenuation coefficient of the material at that point. The attenuation coefficient is a measure of how much the material reduces the intensity of the x-rays.

The voxel size is the size of each cube in the phantom, therefore, the smaller the voxel size, the more accurate the simulation will be, but the longer it will take to run the simulation.

It is possible to load a custom phantom, this must be a '.mat' file containing an object called `phantom`, using the objects within the DECTSim backend. In the future, you should be able to create this new phantom within the GUI.

### Phantom Examples

In the GUI, there are currently four phantom examples available, these are:
    - Modified Shepp-Logan
    - Example 2
    - Example 3
    - Example 4

The Modified Shepp-Logan phantom is a modified version of the Shepp-Logan phantom, which is a standard phantom used in medical imaging. The Modified Shepp-Logan phantom has been modified to include real materials, such as bone, brain matter, air and alanine. It is also three dimensional, so there are no actual overlapping of the materials (unlike the Shepp-Logan phantom).

Example two contains a cylinder of water with a radius of 15 cm and with a length of 30 cm. This cylinder has 4 different smaller cylinders inside it, each with a different material. The materials are, going from the top of the cylinder clockwise, bone, muscle, blood and fat. 

Example three contains a cylinder of water with a radius of 15 cm and with a length of 30 cm. This cylinder has 4 different smaller cylinders inside it, each with a different material. The materials are, going from the top of the cylinder clockwise, bone, muscle, titanium and fat.

Example four contains a cylinder of water with a radius of 30 cm and with a length of 30 cm. This cylinder has 3 different smaller cylinders inside it, each with a different material, getting smaller and smaller like a russian doll. The materials are, going from the top of the cylinder to the centre, bone, fat, titanium.

## Detector
The detector is the object that measures the x-rays after they have passed through the phantom. The detector is represented as a 1D or 2D array of pixels, each pixel measures the intensity of the x-rays that have passed through it. The detector also controls the sensor, which is the object that converts the intensity of the x-rays into a signal that can be used to create the sinogram.

In the GUI, only 1D detectors are available. Of the shapes of the detectors, only the flat and curved detectors are available. The *flat detector* is a 1D array of pixels, and the *curved detector* is a 1D array of pixels that are curved around the phantom, having the same radius as half the distance from the source to the detector. 

For the flat detector, the pixel width is the width of each pixel in the detector, and for the curved detector, this is the length of the arc of each pixel.
The number of pixels is self-explanatory, and the sensor controls how the intensity of the x-rays is converted into a signal.

Currently, only the ideal sensor is available, which has an equal response to all energies. In the future, more sensors will be available.

## Gantry
The gantry controls the movement of the detector around the phantom. By default, the gantry will always move 360 degrees around the phantom, with 2 degree steps, as the default number of rotations is 180. The number of rotations can be changed, increasing the number of rotations will increase the time taken to run the simulation, but will also reduce the artefacts in the reconstructed image. It currently is not possible to change the total angle of the rotation. 

The distance between the source and the detector can also be changed, this should be greater than the radius of the phantom, and the default is 100 cm.

## Reconstruction
The reconstruction is the process of creating an image of the phantom from the sinogram. The sinogram is a 2D array of the intensity of the x-rays that have passed through the phantom, it has the angle of the projection on the x-axis and pixel number on the y-axis. The reconstruction controls the filter and interpolation method used to create the image.

For further information on the reconstruction, please see the [MATLAB documentation](https://uk.mathworks.com/help/images/ref/iradon.html). This also contains information on the filter and interpolation method.

For a cone beam, the reconstruction is done using the `ifanbeam` function, which is a fan beam backprojection. In this reconstruction, it is necessary to perform a transform from the fan beam to parallel beam, and then use the `iradon` function to reconstruct the image.

## Scatter
Scatter is the process of x-rays being deflected from their original path. This can cause artefacts in the image, and therefore, it is important to include scatter in the simulation, for a more accurate image. There are currently three types of scatter models available: `none`, `fast` and `slow`. The default is `none`, but can be changed.

Scatter factor has a different effect depending on the scatter model. For `none`, the scatter factor has no effect. For `fast`, the scatter factor is a scaling of the scatter intensity, and for `slow`, the scatter factor increases the number of scatter photons and therefore the accuracy of the scatter model.

`none` means that no scatter is included in the simulation. `fast` means that a convolution model is used to include scatter, and `slow` means that a deterministic like model is used to include scatter. The `fast` model is faster and produces a good approximation of the scatter. The `slow` model is currently in development, but will produce a random scatter pattern, that as the scatter factor increases, will become more accurate. For the `slow` model, a scatter factor greater than 10 is not possible, as the scatter pattern becomes too slow to compute (potentially taking days to compute).




