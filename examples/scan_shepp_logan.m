% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_size = 0.4; 
voxel_size = 1e-4;

% Create voxel array
voxel_generator = voxel_shepp_logan(vox_arr_center, phantom_size, voxel_size);
% voxel_generator = voxel_box(vox_arr_center, phantom_size);
voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_size, voxel_size, voxel_generator);

do_parallel = true;
do_curved = false;

if do_parallel 
    profile on
    % Parallel Detector constants
    dist_to_detector = 10;
    detector_width = 0.8;
    pixel_width = 2e-3;
    rotation_angle = pi/180;

    my_detector = parallel_detector(dist_to_detector, detector_width, pixel_width, rotation_angle);
    image = my_detector.generate_image(voxels);

    imwrite(image, "sinograph_p.png")

    scan_angles = my_detector.get_scan_angles();
    [R, H] = iradon(image, scan_angles);%, "linear", "None");

    imwrite(mat2gray(R), "shepp_logan_reproduced_p.png")
    profile viewer
end

if do_curved
    % profile on
    % Fan beam detector (curved) constants
    dist_to_detector = 10;
    detector_angle = pi/20;
    pixel_angle = detector_angle/500;
    rotation_angle = pi/720;

    my_detector = curved_detector(dist_to_detector, detector_angle, pixel_angle, rotation_angle);
    image = my_detector.generate_image(voxels);

    imwrite(image, "sinograph_c.png")

    [P,paraSensorPos,paraRotAngles] = fan2para(image, dist_to_detector/2, 'FanSensorSpacing', rad2deg(pixel_angle), 'FanRotationIncrement', rad2deg(rotation_angle), "ParallelCoverage", "cycle");

    scan_angles = my_detector.get_scan_angles();
    [R, H] = iradon(P, paraRotAngles);%, "linear", "None");

    imwrite(mat2gray(R), "shepp_logan_reproduced_c.png")
    % profile viewer
end