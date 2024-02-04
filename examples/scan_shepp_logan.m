% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_size = 500; 
voxel_size = 1;
water = material("water");

% Create voxel array
voxel_generator = voxel_shepp_logan(vox_arr_center, phantom_size, voxel_size);

% voxel_generator = voxel_box(vox_arr_center, phantom_size, material);
% voxel_generator = voxel_cylinder(vox_arr_center, phantom_size/2, 2, material);

voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_size, voxel_size, voxel_generator);


% Detector constants
dist_to_detector = 1050;
pixel_size = [1 1];
num_pixels = [900 1];
num_rotations = 180;
do_parallel = true;
do_curved = false;


if do_parallel 
    % profile on
    tic
    my_detector = parallel_detector(dist_to_detector, pixel_size, num_pixels, num_rotations);
    sinogram = my_detector.generate_image_p(voxels);
    sinogram = squeeze(sum(sinogram, 2));
    imwrite(sinogram, "sinograph_p.png")


    scan_angles = my_detector.get_scan_angles();
    [R, H] = iradon(sinogram, scan_angles);%, "linear", "None");

    imwrite(mat2gray(R), "shepp_logan_reproduced_p.png")
    toc
    % profile viewer
end

if do_curved
    % profile on
    % Fan beam detector (curved) constants
    my_detector = curved_detector(dist_to_detector, pixel_size, num_pixels, num_rotations);
    % sinogram = my_detector.generate_image(voxels);
    image = my_detector.generate_image_p(voxels);


    imwrite(sinogram, "sinograph_c.png")

    pixel_angle = my_detector.pixel_angle;
    rotation_angle = my_detector.rot_angle;
    [P,paraSensorPos,paraRotAngles] = fan2para(sinogram, dist_to_detector/2, 'FanSensorSpacing', rad2deg(pixel_angle), 'FanRotationIncrement', rad2deg(rotation_angle));%, "ParallelCoverage", "cycle");

    scan_angles = my_detector.get_scan_angles();
    [R, H] = iradon(P, paraRotAngles);%, "linear", "None");

    imwrite(mat2gray(R), "shepp_logan_reproduced_c.png")
    % profile viewer
end