% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 10*units.cm;% In the x-y plane
phantom_width = 10*units.cm; % In the z direction
voxel_size = 0.25*units.mm;

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


act_size = [zeros(2, 1) + phantom_radius * 3; 20]; 
voxels = voxel_array(vox_arr_center, act_size, voxel_size, ...
    {water_cylinder, bone_cylinder, blood_cylinder, lung_cylinder, muscle_cylinder});
x_and_y = act_size(1)./ voxel_size;
z_size = act_size(3)./ voxel_size;
x_and_y_str = num2str(x_and_y);
mu_dict = voxels.get_mu_arr(1);
fileID = fopen(strcat('phantom_', x_and_y_str, '_', x_and_y_str, '_', num2str(z_size), '.bin'), 'w');
out_matrix = zeros(x_and_y, x_and_y, z_size);
for i = 1:x_and_y
    for j = 1:x_and_y
        is = repmat(i, 1, z_size);
        js = repmat(j, 1, z_size);
        obj_idxs = voxels.get_object_idxs([is; js; 1:z_size]);
        obj_idxs = mod(obj_idxs, 6);
        out_matrix(i, j, :) = obj_idxs;
    end
end

fwrite(fileID, out_matrix, 'uint8');
fclose(fileID);
