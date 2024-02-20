rng(100);

% Create source and sensor
my_source = single_energy(30);
my_sensor = ideal_sensor([0; 100], 100);

% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 30/2;% In the x-y plane
phantom_width = 50; % In the z direction
voxel_size = 0.1/2; % 1 mm

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("bone"));
init_mat_pos = rot_mat_pos * init_mat_pos;
blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("fat"));
init_mat_pos = rot_mat_pos * init_mat_pos;
lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("blood"));
init_mat_pos = rot_mat_pos * init_mat_pos;
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("muscle"));

voxels = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
    voxel_size, {water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder});

% Detector constants
dist_to_detector = 105; % cm
pixel_size = [0.1 0.1]; % cm (so pixel size = 1mm)
num_pixels = [900 1];
num_rotations = 90;

my_detector = parallel_detector(my_source, my_sensor, dist_to_detector, ...
    pixel_size, num_pixels, num_rotations);
tic
sinogram = squeeze(my_detector.generate_image_p(voxels));
toc

imwrite(mat2gray(sinogram), "sinograph_cylinder.png")

scan_angles = my_detector.get_scan_angles();    
[R, ~] = iradon(sinogram, scan_angles);%, "linear", "None");

imwrite(mat2gray(R), "cylinder.png")
% seconds = 9.75 * scatter_factor + 40 ( i.e. an extra 10 seconds for every
% factor)
scatter_detector = parallel_detector(my_source, my_sensor, dist_to_detector, ...
    pixel_size, num_pixels, num_rotations, "slow", 10); 

tic
scatter_sinogram = squeeze(scatter_detector.generate_image_p(voxels));
toc

if scatter_detector.scatter_type == 1
    sinograph_save_str = "scatter_sinograph_cylinder_fast.png";
    image_save_str = "scatter_cylinder_fast.png";
elseif scatter_detector.scatter_type == 2
    sinograph_save_str = "scatter_sinograph_cylinder_slow.png";
    image_save_str = "scatter_cylinder_slow.png";
end

imwrite(mat2gray(scatter_sinogram), sinograph_save_str)
diff = scatter_sinogram - sinogram;

imwrite(mat2gray(diff), strcat("diff_", sinograph_save_str))

[scatter_R, H] = iradon(scatter_sinogram, scan_angles);%, "linear", "None");

imwrite(mat2gray(scatter_R), image_save_str)
diff_R = scatter_R - R;
imwrite(mat2gray(diff_R), strcat("diff_", image_save_str))