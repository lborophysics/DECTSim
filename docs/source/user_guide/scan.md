# Scanning A Shepp-Logan Phantom

This example demonstrates how to scan a Shepp-Logan phantom using the features within the `DECTSim` package. The phantom is scanned using a single energy level and a single detector. The phantom is then reconstructed using the MATLAB image processing toolbox.

## Creating the Phantom
First the phantom must be generated. This is done using the `voxel_shepp_logan` function, which returns a function to generate the voxel array. The voxels are then generated using the `voxel_array` function. 

```Matlab
% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_size = 0.4; 
voxel_size = 1e-4;

% Create voxel array
voxel_generator = voxel_shepp_logan(vox_arr_center, phantom_size, voxel_size);
voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_size, voxel_size, voxel_generator);
```

The variables that can change the code is the `vox_arr_center`, `phantom_size`, and `voxel_size`. The `vox_arr_center` is the center of the voxel array, this changes where the phantom is located in resultant image. The `phantom_size` is the size of the phantom in the voxel array in metres and determines the size of the phantom in the resultant image. The `voxel_size` is the size of each voxel in the voxel array in metres and determines the resolution of the resultant image.

## Parallel Detector
Then we create either a parallel detector or a curved detector using the `parallel_detector` and `curved_detector` functions to observe to phantom. Below shows the code for the parallel detector.

```Matlab
    % Parallel Detector constants
    dist_to_detector = 10;
    detector_width = 0.8;
    pixel_width = 2e-3;
    rotation_angle = pi/180;

    my_detector = parallel_detector(dist_to_detector, detector_width, pixel_width, rotation_angle);
    image = my_detector.generate_image(voxels);

    imwrite(image, "sinograph_p.png")

    scan_angles = my_detector.get_scan_angles();
    [R, H] = iradon(image, scan_angles);

    imwrite(mat2gray(R), "shepp_logan_reproduced_p.png")
```

The variables that can change the code is the `dist_to_detector`, `detector_width`, `pixel_width`, and `rotation_angle`. 
- `dist_to_detector` is the distance from the centre of the source plane to the center of the detector in metres, for a parallel detector this does not have a significant effect, however it needs to be far enough away to be outside the voxel array.
- `detector_width` is the width of the detector in metres, this determines the height of the resultant image, this should be large enough to capture the entire phantom. 
- `pixel_width` is the width of each pixel in the detector in metres, this determines the resolution of the resultant image. 
- `rotation_angle` is the angle the detector is rotated by in radians at each step until reaching 180 degrees, this determines the width of the resultant image and has a significant effect reducing artifacts from the reconstruction.

The code then generates the sinograph and saves it as `sinograph_p.png`. The sinograph is then reconstructed using the `iradon` function from the MATLAB image processing toolbox. The reconstructed image is then saved as `shepp_logan_reproduced_p.png`.

## Curved Detector
Below shows the code for the curved detector.

```Matlab
    % Fan beam detector (curved) constants
    dist_to_detector = 10;
    detector_angle = pi/20;
    pixel_angle = detector_angle/500;
    rotation_angle = pi/720;

    my_detector = curved_detector(dist_to_detector, detector_angle, pixel_angle, rotation_angle);
    image = my_detector.generate_image(voxels);

    imwrite(image, "sinograph_c.png")

    [P,paraSensorPos,paraRotAngles] = fan2para(image, dist_to_detector/2, 'FanSensorSpacing', rad2deg(pixel_angle), 'FanRotationIncrement', rad2deg(rotation_angle));

    scan_angles = my_detector.get_scan_angles();
    [R, H] = iradon(P, paraRotAngles);

    imwrite(mat2gray(R), "shepp_logan_reproduced_c.png")
```

The variables that can change the code is the `dist_to_detector`, `detector_angle`, `pixel_angle`, and `rotation_angle`.
- `dist_to_detector` is the distance from the source point to the center of the detector in metres, this determines the height of the resultant image and affects how the fan beam travels through the phantom.
- `detector_angle` is the angle of the detector in radians, this determines the width of the resultant image and affects how the fan beam is projected through the phantom.
- `pixel_angle` is the angle of each pixel in the detector in radians, this determines the resolution of the resultant image.
- `rotation_angle` is the the same as the parallel detector but since the detector is curved it, the source rotates 360 degrees in around the phantom. 

As we are using a fan beam, we are required to convert the sinograph to a parallel sinograph using the `fan2para` function from the MATLAB image processing toolbox. The sinograph is then reconstructed using the `iradon` function from the MATLAB image processing toolbox. The reconstructed image is then saved as `shepp_logan_reproduced_c.png`.