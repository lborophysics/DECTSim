% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_size = 0.4; 
voxel_size = 1e-4;

% Create voxel array
voxel_generator = voxel_shepp_logan(vox_arr_center, phantom_size, voxel_size);
% voxel_generator = voxel_box(vox_arr_center, phantom_size);
voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_size, voxel_size, voxel_generator);

% Detector constants
dist_to_detector = 10;
detector_width = 0.8;
pixel_width = 2e-3;
detector_angle = deg2rad(1);

my_detector = parallel_detector(dist_to_detector, detector_width, pixel_width, detector_angle);
image = my_detector.generate_image(voxels);

imwrite(image, "sinograph.png")

scan_angles = my_detector.get_scan_angles();
[R, H] = iradon(image, scan_angles);%, "linear", "None");

imwrite(mat2gray(R), "shepp_logan_reproduced.png")
