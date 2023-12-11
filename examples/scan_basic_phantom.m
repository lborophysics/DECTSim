% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_radius = 300;% In the x-y plane 
phantom_width = 500; % In the z direction
voxel_size = 1;

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, @water);
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, @bone);
init_mat_pos = rot_mat_pos * init_mat_pos;
blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, @blood);
init_mat_pos = rot_mat_pos * init_mat_pos;
lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, @lung);
init_mat_pos = rot_mat_pos * init_mat_pos;
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, @muscle);

phantom = voxel_collection(water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder);

voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_radius*2, voxel_size, phantom);

% profile on
% Detector constants
dist_to_detector = 1050;
pixel_size = [1 1];
num_pixels = [900 1];
num_rotations = 180;

my_detector = parallel_detector(dist_to_detector, pixel_size, num_pixels, num_rotations);
sinogram = squeeze(my_detector.generate_image(voxels));

imwrite(sinogram, "sinograph_cylinder.png")

scan_angles = my_detector.get_scan_angles();
[R, H] = iradon(sinogram, scan_angles);%, "linear", "None");

imwrite(mat2gray(R), "cylinder.png")
% profile viewer
