% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 300;% In the x-y plane
phantom_width = 250; % In the z direction
voxel_size = 0.5;

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_mimic(1));
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_mimic(2));
init_mat_pos = rot_mat_pos * init_mat_pos;
blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_mimic(3));
init_mat_pos = rot_mat_pos * init_mat_pos;
lung_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_mimic(4));
init_mat_pos = rot_mat_pos * init_mat_pos;
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_mimic(5));

voxels = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], voxel_size, ...
    water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder);
x_and_y = phantom_radius*2/voxel_size;
x_and_y_str = num2str(x_and_y);
mu_dict = voxels.get_mu_dict(1);
fileID = fopen(strcat('phantom_', x_and_y_str, '_', x_and_y_str, '_', num2str(phantom_width/voxel_size), '.bin'), 'w');
for z = 1:phantom_width/voxel_size
    for y = 1:x_and_y
        z_arr = zeros(1, x_and_y) + z;
        y_arr = zeros(1, x_and_y) + y;
        fwrite(fileID, voxels.get_saved_mu([y_arr;x_and_y:-1:1;z_arr], mu_dict), 'uint8');
    end
end
fclose(fileID);
