% Voxel array constants
vox_arr_center = zeros(3, 1); 
phantom_radius = 30;% In the x-y plane 
phantom_width = 50; % In the z direction
voxel_size = 0.1; % 1 mm

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material("water"));
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material("bone"));
blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material("blood"));
lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material("lung"));
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material("muscle"));

phantom = voxel_collection(water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder);

voxels = voxel_array(vox_arr_center, zeros(3, 1)+phantom_radius*2, voxel_size, phantom);

% Detector constants
dist_to_detector = 105; % cm
pixel_size = [0.1 0.1]; % cm (so pixel size = 1mm)
num_pixels = [900 1];
num_rotations = 180;

my_detector = parallel_detector(dist_to_detector, pixel_size, num_pixels, num_rotations);
sinogram = squeeze(my_detector.generate_image_p(voxels));

imwrite(mat2gray(sinogram), "sinograph_cylinder.png")

scan_angles = my_detector.get_scan_angles();    
[R, ~] = iradon(sinogram, scan_angles);%, "linear", "None");

imwrite(mat2gray(R), "cylinder.png")
scatter_factor = 1;
scatter_detector = parallel_detector(dist_to_detector, pixel_size, num_pixels, num_rotations, scatter_factor); 
scatter_sinogram = squeeze(scatter_detector.generate_image_p(voxels));

imwrite(mat2gray(scatter_sinogram), "scatter_sinograph_cylinder.png")
diff = scatter_sinogram - sinogram;
imwrite(mat2gray(diff), "diff_sinograph_cylinder.png")

[scatter_R, H] = iradon(scatter_sinogram, scan_angles);%, "linear", "None");

imwrite(mat2gray(scatter_R), "scatter_cylinder.png")
diff_R = scatter_R - R;
imwrite(mat2gray(diff_R), "diff_cylinder.png")