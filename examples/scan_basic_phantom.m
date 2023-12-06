% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_radius = 0.2; 
voxel_size = 1e-4;

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, 2, @water);
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, 2, @bone);
init_mat_pos = rot_mat_pos * init_mat_pos;
blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, 2, @blood);
init_mat_pos = rot_mat_pos * init_mat_pos;
lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, 2, @lung);
init_mat_pos = rot_mat_pos * init_mat_pos;
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, 2, @muscle);

phantom = voxel_collection(water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder);

voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_radius*2, voxel_size, phantom);

% profile on
% Parallel Detector constants
dist_to_detector = 10;
detector_width = 0.8;
pixel_width = 1e-3;
rotation_angle = pi/180;

my_detector = parallel_detector(dist_to_detector, detector_width, pixel_width, rotation_angle);
image = my_detector.generate_image(voxels);

imwrite(image, "sinograph_cylinder.png")

scan_angles = my_detector.get_scan_angles();
[R, H] = iradon(image, scan_angles);%, "linear", "None");

imwrite(mat2gray(R), "cylinder.png")
% profile viewer
