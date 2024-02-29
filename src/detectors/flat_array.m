classdef (Abstract) flat_array < detector_array
     methods
         function [pixel, hit] = hit_pixel(self, ray_start, ray_dir, detect_geom, angle_index)
             % Get the detector geometry
             assert(abs(norm(ray_dir) - 1) < 1e-14, "Ray direction must be a unit vector")
             rot_mat       = detect_geom.get_rot_mat(angle_index);
             to_source_vec = rot_mat * detect_geom.to_source_vec;
             detector_vec  = rotz(-pi/2) * to_source_vec; % perpendicular to the source vector
             centre        = to_source_vec .* -detect_geom.dist_to_detector/2;
 
             % Get the pixel which the xray hits
             hit = true; pixel = [0, 0];
             corner = centre - detector_vec .* self.pixel_dims(1) * self.n_pixels(1)/2 ...
                                  - [0;0;1] .* self.pixel_dims(2) * self.n_pixels(2)/2;
             ray_xy = ray_dir(1:2); det_xy = detector_vec(1:2);
 
             %Check the xy line intersects with the detector vector a.b = |a||b|cos(theta) (parallel -> cos(theta) = 1)
             if abs(dot(ray_xy, det_xy) -norm(det_xy)*norm(ray_xy)) < 1e-10
                 hit = false; return;
             end
 
             % Check that the ray is heading towards the detector
             if acos(dot(ray_dir, to_source_vec))  < pi/2
                 hit = false; return;
             end                
 
             % Get point on the detector vector where the ray intersects in xy plane
             dy = ray_xy(2) * (corner(1) - ray_start(1)) + ray_xy(1) * (ray_start(2) - corner(2)) / ...
                 (ray_xy(1) * det_xy(2) - ray_xy(2) * det_xy(1));
             py = floor(dy / self.pixel_dims(1)) + 1;
             if py < 1 || py > self.n_pixels(1); hit = false; return; end
             
             ray_hit_point = ray_start + ray_dir .* dy;
             pz = floor((ray_hit_point(3) - corner(3)) / self.pixel_dims(2)) + 1;
             if pz < 1 || pz > self.n_pixels(2); hit = false; return; end
             
             pixel = [py, pz];
         end
     end
 end
 