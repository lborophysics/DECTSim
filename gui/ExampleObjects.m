% Voxel array constants
phantom_scale = 30*units.cm; % In the x-y plane
voxel_size = 0.5 * units.mm;

efields_a = create_struct([ 0   ; 0    ; 0 ], 0.69  , 0.92 , 0.9  , 0  , 1  );
efields_b = create_struct([ 0   ; 0    ; 0 ], 0.6624, 0.874, 0.88 , 0  ,-0.8);
efields_c = create_struct([-0.22; 0    ; 0 ], 0.41  , 0.16 , 0.21 , 108,-0.2); % -0.25 
efields_d = create_struct([ 0.22; 0    ; 0 ], 0.31  , 0.11 , 0.22 , 72 ,-0.2); % -0.25 
efields_e = create_struct([ 0   ; 0.35 ; 0 ], 0.21  , 0.25 , 0.5  , 0  , 0.2); % -0.25 
efields_f = create_struct([ 0   ; 0.1  ; 0 ], 0.046 , 0.046, 0.046, 0  , 0.2); % -0.25 
efields_g = create_struct([-0.08;-0.65 ; 0 ], 0.046 , 0.023, 0.02 , 0  , 0.1); % -0.25 
efields_h = create_struct([ 0.06;-0.65 ; 0 ], 0.046 , 0.023, 0.02 , 90 , 0.1); % -0.25 
efields_i = create_struct([ 0.06;-0.105; 0 ], 0.056 , 0.04 , 0.1  , 90 , 0.2); %  0.625
efields_j = create_struct([ 0   ; 0.1  ; 0 ], 0.056 , 0.056, 0.1  , 0  ,-0.2); %  0.625


efields_a = multiply_fields(efields_a, phantom_scale);
efields_b = multiply_fields(efields_b, phantom_scale);
efields_c = multiply_fields(efields_c, phantom_scale);
efields_d = multiply_fields(efields_d, phantom_scale);
efields_e = multiply_fields(efields_e, phantom_scale);
efields_f = multiply_fields(efields_f, phantom_scale);
efields_g = multiply_fields(efields_g, phantom_scale);
efields_h = multiply_fields(efields_h, phantom_scale);
efields_i = multiply_fields(efields_i, phantom_scale);
efields_j = multiply_fields(efields_j, phantom_scale);

brain = material_attenuation("brain", [1, 6, 7, 8, 11, 15, 16, 17, 19], ...
    [0.107, 0.145, 0.022, 0.712, 0.002, 0.004, 0.002, 0.003, 0.003], 1.04);
alanine = material_attenuation("alanine", [1, 6, 7, 8], ...
    [0.079192, 0.404437, 0.157213, 0.359157], 1.424);
bone = material_attenuation("bone");
air = material_attenuation("air");

% Create voxel array
ellipse_a = voxel_ellipse(efields_a.center, efields_a.a, efields_a.b, efields_a.c, bone);
ellipse_b = voxel_ellipse(efields_b.center, efields_b.a, efields_b.b, efields_b.c, brain);
ellipse_c = voxel_ellipse_rotated(efields_c.center, efields_c.a, efields_c.b, efields_c.c, efields_c.phi, air);
ellipse_d = voxel_ellipse_rotated(efields_d.center, efields_d.a, efields_d.b, efields_d.c, efields_d.phi, air);
ellipse_e = voxel_ellipse(efields_e.center, efields_e.a, efields_e.b, efields_e.c, alanine);
ellipse_f = voxel_ellipse(efields_f.center, efields_f.a, efields_f.b, efields_f.c, alanine);
ellipse_g = voxel_ellipse(efields_g.center, efields_g.a, efields_g.b, efields_g.c, alanine);
ellipse_h = voxel_ellipse(efields_h.center, efields_h.a, efields_h.b, efields_h.c, alanine);
ellipse_i = voxel_ellipse(efields_i.center, efields_i.a, efields_i.b, efields_i.c, alanine);
ellipse_j = voxel_ellipse(efields_j.center, efields_j.a, efields_j.b, efields_j.c, alanine);


a_shepp_logan = {ellipse_a, ellipse_b, ellipse_c, ellipse_d, ellipse_e, ellipse_f, ellipse_g, ellipse_h, ellipse_i, ellipse_j};

phantom = voxel_array([0;0;0], zeros(3, 1)+2*phantom_scale, ...
    voxel_size, a_shepp_logan);

% Save the phantom
save gui/PhantomExample1.mat phantom

% Example 2!

% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 30/2 * units.cm; % In the x-y plane
phantom_width = 50 * units.cm; % In the z direction
voxel_size = 0.5 * units.mm;

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("bone"));
init_mat_pos = rot_mat_pos * init_mat_pos;
fat_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("fat"));
init_mat_pos = rot_mat_pos * init_mat_pos;
blood_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("blood"));
init_mat_pos = rot_mat_pos * init_mat_pos;
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("muscle"));

phantom = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
    voxel_size, {water_cylinder, bone_cylinder, fat_cylinder, blood_cylinder, muscle_cylinder});

save gui/PhantomExample2.mat phantom

% Example 3!
% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 30/2 * units.cm; % In the x-y plane
phantom_width = 50 * units.cm; % In the z direction
voxel_size = 0.5 * units.mm;

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; phantom_radius/2; 0];
bone_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("bone"));
init_mat_pos = rot_mat_pos * init_mat_pos;
fat_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("fat"));
init_mat_pos = rot_mat_pos * init_mat_pos;
ti_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("titanium"));
init_mat_pos = rot_mat_pos * init_mat_pos;
muscle_cylinder = voxel_cylinder(init_mat_pos, phantom_radius/5, phantom_width, material_attenuation("muscle"));

phantom = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
    voxel_size, {water_cylinder, bone_cylinder, fat_cylinder, ti_cylinder, muscle_cylinder});

save gui/PhantomExample3.mat phantom

% Example 4!
% Voxel array constants
vox_arr_center = zeros(3, 1);
phantom_radius = 30 * units.cm; % In the x-y plane
phantom_width = 50 * units.cm; % In the z direction
voxel_size = 0.5 * units.mm;

% Create voxel array
water_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, material_attenuation("water"));
bone_cylinder = voxel_cylinder(vox_arr_center, phantom_radius*3/4, phantom_width, material_attenuation("bone"));
fat_cylinder = voxel_cylinder(vox_arr_center, phantom_radius/2, phantom_width, material_attenuation("fat"));
ti_cylinder = voxel_cylinder(vox_arr_center, phantom_radius/4, phantom_width, material_attenuation("titanium"));

phantom = voxel_array(vox_arr_center, [zeros(2, 1)+phantom_radius*2; phantom_width], ...
    voxel_size, {water_cylinder, bone_cylinder, fat_cylinder, ti_cylinder});

save gui/PhantomExample4.mat phantom

source_40kvp = source_fromfile('40kvp.spk');
source_80kvp = source_fromfile('80kvp.spk');

source = source_40kvp;
save gui/SourceExample40kvp.mat source

source = source_80kvp;
save gui/SourceExample80kvp.mat source

function new_struct = create_struct(center, a, b, c, phi, mag)
    new_struct.center = center;
    new_struct.a = a;
    new_struct.b = b;
    new_struct.c = c;
    new_struct.phi = deg2rad(phi);
    new_struct.mag = mag;
end

function new_struct = multiply_fields(struct, factor)
    new_struct = struct;
    new_struct.center = struct.center .* factor;
    new_struct.a = struct.a * factor;
    new_struct.b = struct.b * factor;
    new_struct.c = struct.c * factor;
end