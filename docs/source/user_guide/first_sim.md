# Running a script (No GUI)

To run a simulation, there are 5 main ingredients required:
1. The x-ray source, giving information about the energy and intensity of the x-rays at given positions. Currently, only `single_energy` and `source_fromfile` is available, but more will be added in the future.
2. The phantom, which is the object being imaged. 
3. The movement of your detector - controlled by the `gantry` object
4. Your detector array, indicating the geometry of the sources and sensors. There are currently only two types available: `curved_detector` and `flat_detector`.
5. The sensor, controlling how intensities and energies are converted into signals and then to sinograms. Currently, only `ideal_sensor` is available, but more will be added in the future.

There is one more optional ingredient, which is whether you would like to include scatter in the simulation. There exists three types of scatter models: `"none"`, `"fast"` and `"slow"`. The default is `"none"`, but can be changed.

## Step 0: The units system
Before we start, it is important to note that all functions are intended to be operated independently of units. Therefore, for the user to know if they are using the correct units, they must use the `units` class. Any number that is input into a function must be multiplied by the unit, for example, 80 keV would be input as `80*units.keV`. With this in mind, all input variables will be consistent with what the function expects.

## Step 1: The x-ray source

### Single energy source
To create a single energy source, you only need to specify the energy of the x-rays. For example, to create a source with 80 keV x-rays, you would use the following code:

```MATLAB
src = single_energy(80*units.keV);
```

### Source from file
To create a source from a file, you need to specify the path to the file. The file must be a '.spk' file created using the SpekPy package. To create the spectrum file using SpekPy, you would use the following code in Python:

```python
    import spekpy as sp

    s = sp.Spek(kvp=80,th=12, dk=1) # Generate a spectrum (80 kV, 12 degree tube angle)
    s.filter('Al', 4.0) # Filter by 4 mm of Al

    s.export_spectrum('spectrum.spk') # Export the spectrum to a file
```

Then once this spectrum file has been created, you can use the following code to create a source from the file:

```MATLAB
src = source_fromfile("spectrum.spk");
```

## Step 2: The phantom
The phantom is the object being imaged. It is represented as a 3D matrix, split into cubes. Each cube, or voxel, has a value representing the attenuation coefficient of the material at that point. 
To create your phantom, you use the `voxel_array` object, by defining the following parameters:
- `centre`: a 3x1 vector representing the centre of the phantom
- `object_dims`: a 3x1 vector representing the total size of your world
- `voxel_size`: a scalar representing the size of each voxel
- `voxel_objs`: a cell array of `voxel_object`s, each representing a different material in your phantom
- `world_material`: a `material_attenuation` object representing the material of the world outside of your voxel objects

### Materials
To create a material, you use the `material_attenuation` object, this can be done in one of two ways:
1. By specifying the name of the material, for example:
```MATLAB
water = material_attenuation("water");
```
The available materials are:
- "air"
- "blood"
- "bone"
- "fat"
- "lung" (tissue)
- "muscle"
- "titanium"
- "water"
- "vacuum"

The details of the materials have been taken from the NIST database [here](https://physics.nist.gov/PhysRefData/XrayMassCoef/tab2.html). In the future, all materials in this database will be available.

2. By specifying the atomic numbers, mass fractions and density of the material. The list of atomic numbers and mass fractions must be the same length, and the density must be a scalar. For example:

```MATLAB
water = material_attenuation([1, 8], [0.111894, 0.888106], 1.0*units.g/units.cm^3);
```

### Voxel objects
A voxel object is how the program represents a material in the phantom. Only two arguments are required to create a voxel object:
- `is_in_object`: a function handle that takes in 3 arguments (x, y, z) and returns a boolean indicating whether the point is inside the object. `x`, `y` and `z` are the coordinates of the centre of the voxel, in cm. These coordinates **must** be able to be vectorised, therefore, the boolean returned must be the same size as `x`, `y` and `z`.
- `material`: a `material_attenuation` object representing the material of the voxel object

#### Available voxel objects
There are currently only two types of voxel objects available:
- `voxel_cylinder(centre, radius, width, material)`: This function returns a voxel object representing a cylinder. The arguments are:
    - `centre`: a 3x1 vector representing the centre of the cylinder
    - `radius`: a scalar representing the radius of the cylinder
    - `width`: a scalar representing the width of the cylinder
    - `material`: a `material_attenuation` object representing the material of the cylinder
- `voxel_cube(centre, side_length, material)`: This function returns a voxel object representing a cube. The arguments are:
    - `centre`: a 3x1 vector representing the centre of the cube
    - `side_length`: a scalar representing the side length of the cube
    - `material`: a `material_attenuation` object representing the material of the cube

#### Using voxel objects
An example of a two cylinders in a world of water is shown below:
```MATLAB
bone_cylinder = voxel_cylinder(zeros(3, 1), 15*units.cm, 50*units.cm, material_attenuation("bone"));
blood_cylinder = voxel_cylinder(zeros(3, 1), 5*units.cm, 50*units.cm, material_attenuation("blood"));

world = voxel_array(zeros(3, 1), [50, 50, 50].*units.cm, 1*units.mm, {bone_cylinder, blood_cylinder}, material_attenuation("water"));
```

In this example, we have created two cylinders, one representing bone and the other representing blood. Due to the order of these cylinders in the cell array, the bone cylinder will be drawn first, and the blood cylinder will be drawn on top of it. The world is 50x50x50 cm, and the voxel size is 1mm.

<span style="color:red">Include an image of the above.</span>

## Step 3: The movement of your detector
The movement of the detector is controlled by the `gantry` object. This object is created by specifying the following parameters:
- `dist_to_detector`: a scalar representing the distance from the source to the detector in cm.
- `num_rotations`: a scalar representing the number steps the detector will take as it rotates around the phantom.
- `total_angle`: a scalar representing the total angle the detector will rotate through in degrees in radians. (Default: 2*pi) 

There are currently two types of gantries available: `gantry` and `parallel_gantry`. The `gantry` object is used for cone beam simulations, and the `parallel_gantry` object is used for parallel beam simulations.

For example, to create a cone beam gantry with a detector 100cm from the source, rotating 180 degrees in 10 steps, you would use the following code:

```MATLAB
g = gantry(1*units.m, 10, pi);
```

This object contains useful attributes for reconstructing the sinogram into an image, such as `scan_angles`. This function returns a 1xN vector of the angles the detector will be at for each rotation.

## Step 4: Your detector array
The detector array specifies the geometry of the sources and sensors. There are currently only two types available: `curved_detector` and `flat_detector`. A `curved_detector` can be thought of as a section of a cylinder with a point source in the centre of rotation, and a `flat_detector` can be thought of as a section of a plane.

### Curved detector
The `curved_detector` object is created by specifying the following parameters:
- `pixel_dims`: a 1x2 vector representing the dimensions of each pixel in the detector in cm
- `num_pixels`: a 1x2 vector representing the number of pixels in the detector in the x and y directions

For example, to create a curved detector with 900 pixels in the x direction and 64 pixels in the y direction, with each pixel being 1x1mm, you would use the following code:

```MATLAB
cd = curved_detector([1, 1].*units.mm, [900, 64]);
```

### Flat detector
The `flat_detector` object is created by specifying the following parameters:
- `pixel_dims`: a 1x2 vector representing the dimensions of each pixel in the detector in cm
- `num_pixels`: a 1x2 vector representing the number of pixels in the detector in the x and y directions

For example, to create a flat detector with 900 pixels in the x direction and 64 pixels in the y direction, with each pixel being 1x1mm, you would use the following code:

```MATLAB
pd = flat_detector([1, 1].*units.mm, [900, 64]);
```

## Step 5: The sensor
The sensor controls how intensities and energies are converted into signals and then to sinograms. There are currently only one type of sensor available: `ideal_sensor`.

### Ideal sensor
The `ideal_sensor` object is created by specifying the following parameters:
- energy_range: a 1x2 vector representing the minimum and maximum energies the sensor can detect in keV.
- `num_energy_bins`: a scalar representing the number of energy bins the sensor will use.
- `num_samples`: a scalar representing the number of samples of each energy bin the sensor will take. (Default: 1)

For example, to create an ideal sensor that can detect energies between 20 and 140 keV, with 100 energy bins and 4 samples per energy bin, you would use the following code:

```MATLAB
s = ideal_sensor([20, 140].*units.keV, 100, 4);
```


## Step 6:  Putting it all together
Now that we have all the ingredients, we can put them together to run the simulation. 

For the validation of the input objects, it is necessary to first create a `detector` object. This is done by specifying the following parameters:
- gantry: a `gantry` object
- detector_array: a `curved_detector` or `flat_detector` object
- sensor: an `ideal_sensor` object

For example, to create a detector with the gantry, flat detector and ideal sensor we created earlier, you would use the following code:

```MATLAB
d = detector(g, pd, s);
```

Now that we have the detector, we can run the simulation. This is done by calling the `compute_sinogram(source, phantom, detector)` function. For example, to run the simulation with the source, phantom and detector we created earlier, you would use the following code:

```MATLAB
sinogram = compute_sinogram(src, world, d);
```

The sinogram is a 3D matrix, with the first two dimensions representing the detector pixels, and the third dimension representing the index of the rotation.

This sinogram can be reconstructed into an image using the default MATLAB reconstruction algorithms, such as `iradon` or `ifanbeam`.

```MATLAB
reconstruction = iradon(sinogram, g.get_scan_angles());
```