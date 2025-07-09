% ----------------------------------------------------------------------------------------------------------------
% CTP404

% Voxel array constants
phantom_scale = 40*units.cm; % In the x-y plane

%mat list
water = material_attenuation("water");
air = material_attenuation("air");
teflon = material_attenuation("teflon", [6, 9], ...
    [0.240183, 0.759817], 2.2); % https://physics.nist.gov/cgi-bin/Star/compos.pl?matno=227
acrylic = material_attenuation("acrylic", [1, 6, 8], ...
    [0.080538, 0.599848, 0.319614], 1.19); % https://physics.nist.gov/cgi-bin/Star/compos.pl?refer=ap&matno=223
polystyrene = material_attenuation("polystyrene", [1, 6], ...
    [0.077418, 0.922582], 1.06); % https://physics.nist.gov/cgi-bin/Star/compos.pl?matno=226
ldpe = material_attenuation("ldpe", [1, 6], ...
    [0.1437, 0.8563], 0.945); %
pmp = material_attenuation("pmp", [1, 6], ...
    [0.1437, 0.8563], 0.853); %
delrin = material_attenuation("delrin", [6, 9], ...
    [0.240183, 0.759817], 1.363); %using mass fractions of Teflon but density of Delrin
pmma = material_attenuation("pmma", [1, 6, 8], ...
    [0.080538, 0.599848, 0.319614], 1.19); %https://physics.nist.gov/cgi-bin/Star/compos.pl?refer=ap&matno=223

% Voxel array constants
%vox_arr_center = zeros(3, 1);
vox_arr_center = [0, (0 * units.mm), 0];
phantom_radius = 150/2 * units.mm; % In the x-y plane
water_radius = 100 * units.mm;
phantom_width = 20 * units.mm; % In the z direction - NEED TO CHANGE THIS
voxel_size = 0.1 * units.mm;


% Create voxel array

% Air Cube
air_cube = voxel_cube(vox_arr_center, (40*units.cm), air);

% Main Cylinder

main_water_cylinder = voxel_cylinder(vox_arr_center, water_radius, phantom_width, material_attenuation("water"));
main_cylinder = voxel_cylinder(vox_arr_center, phantom_radius, phantom_width, pmma);

% Air/Teflon Spatial Square
num_materials = 4;
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [(25 * units.mm); ((25) * units.mm); 0];
air_1_cylinder = voxel_cylinder([(25 * units.mm); ((25) * units.mm); 0], (1.5 * units.mm), phantom_width, material_attenuation("air"));
%init_mat_pos = rot_mat_pos * init_mat_pos;
air_2_cylinder = voxel_cylinder([(-25 * units.mm); ((25) * units.mm); 0], (1.5 * units.mm), phantom_width, material_attenuation("air"));
%init_mat_pos = rot_mat_pos * init_mat_pos;
air_3_cylinder = voxel_cylinder([(25 * units.mm); ((-25) * units.mm); 0], (1.5 * units.mm), phantom_width, material_attenuation("air"));
%init_mat_pos = rot_mat_pos * init_mat_pos;
teflon_1_cylinder = voxel_cylinder([(-25 * units.mm); ((-25) * units.mm); 0], (1.5 * units.mm), phantom_width, teflon);

% Changing Size Spheres
num_spheres = 5;
rot_mat_pos = rotz(2*pi/num_spheres);
init_mat_pos = [0; ((-15) * units.mm); 0]; % starting from 180 degree, 10mm sphere
sphere_10 = voxel_ellipsoid(init_mat_pos, (5 * units.mm), (5 * units.mm), (5 * units.mm), acrylic);
init_mat_pos = rot_mat_pos * init_mat_pos;
sphere_2 = voxel_ellipsoid(init_mat_pos, (1 * units.mm), (1 * units.mm), (1 * units.mm), acrylic);
init_mat_pos = rot_mat_pos * init_mat_pos;
sphere_4 = voxel_ellipsoid(init_mat_pos, (2 * units.mm), (2 * units.mm), (2 * units.mm), acrylic);
init_mat_pos = rot_mat_pos * init_mat_pos;
sphere_6 = voxel_ellipsoid(init_mat_pos, (3 * units.mm), (3 * units.mm), (3 * units.mm), acrylic);
init_mat_pos = rot_mat_pos * init_mat_pos;
sphere_8 = voxel_ellipsoid(init_mat_pos, (4 * units.mm), (4 * units.mm), (4 * units.mm), acrylic);

% Sensitometry Cylinders
num_materials = 12;
sensitometry_dist = 57.5 * units.mm;
sensitometry_rad = 6.25 * units.mm; 
rot_mat_pos = rotz(2*pi/num_materials);
init_mat_pos = [0; ((57.5) * units.mm); 0];
water_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, material_attenuation("air")); % can be changed to water
init_mat_pos = rot_mat_pos * init_mat_pos;
acrylic_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, acrylic);
init_mat_pos = rot_mat_pos * init_mat_pos;
init_mat_pos = rot_mat_pos * init_mat_pos;
delrin_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, delrin);
init_mat_pos = rot_mat_pos * init_mat_pos;
init_mat_pos = rot_mat_pos * init_mat_pos;
teflon_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, teflon);
init_mat_pos = rot_mat_pos * init_mat_pos;
air_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, material_attenuation("air"));
init_mat_pos = rot_mat_pos * init_mat_pos;
pmp_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, pmp);
init_mat_pos = rot_mat_pos * init_mat_pos;
init_mat_pos = rot_mat_pos * init_mat_pos;
ldpe_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, ldpe);
init_mat_pos = rot_mat_pos * init_mat_pos;
init_mat_pos = rot_mat_pos * init_mat_pos;
poly_cylinder = voxel_cylinder((init_mat_pos + [0; 0*units.mm; 0]), sensitometry_rad, phantom_width, polystyrene);
init_mat_pos = rot_mat_pos * init_mat_pos;


% Saving
phantom = voxel_array(vox_arr_center, [zeros(2, 1)+water_radius*2; phantom_width], ...
    voxel_size, {main_water_cylinder, main_cylinder, ...
    air_1_cylinder, air_2_cylinder, air_3_cylinder, teflon_1_cylinder, ...
    sphere_2, sphere_4, sphere_6, sphere_8, sphere_10, ...
    water_cylinder, poly_cylinder, ldpe_cylinder, pmp_cylinder, air_cylinder, teflon_cylinder, delrin_cylinder, acrylic_cylinder});

save PhantonCTP404_V12.mat phantom
% ----------------------------------------------------------------------------------------------------------------