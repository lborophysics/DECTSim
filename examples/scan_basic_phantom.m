rng(200);

% Create source and sensor
% my_source = single_energy(50);
my_source = source_fromfile('spectrum.spk');

% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 30/2 * units.cm; % In the x-y plane
phantom_width = 50 * units.cm; % In the z direction
voxel_size = 1 * units.mm;

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
dist_to_detector = 1.05 * units.m;
pixel_size = [1 1] .* units.mm;
num_pixels = [900 1];
num_rotations = 180;

dgantry = parallel_gantry(dist_to_detector, num_rotations, pi);
darray = flat_detector(pixel_size, num_pixels);
dsensor = ideal_sensor([1; 80], 30, 1);
d = detector(dgantry, darray, dsensor);

tic
sinogram = squeeze(compute_sinogram(my_source, voxels, d));
toc
    
imwrite(mat2gray(sinogram), "sinograph_cylinder.png")

scan_angles = rad2deg(dgantry.scan_angles);
[R, ~] = iradon(sinogram, scan_angles);%, "linear", "None");

imwrite(mat2gray(R), "cylinder.png")

scatter_type = "slow";
tic
scatter_sinogram = squeeze(compute_sinogram(my_source, voxels, d, scatter_type, 1));
toc

if strcmp(scatter_type, "fast")
    sinograph_save_str = "scatter_sinograph_cylinder_fast.png";
    image_save_str = "scatter_cylinder_fast.png";
elseif strcmp(scatter_type, "slow")
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