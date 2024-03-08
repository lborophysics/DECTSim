classdef (Abstract) flat_array < detector_array
     methods
         function hit_pixel_at_angle = hit_pixel(self, detect_geom, angle_index)
             % Get the detector geometry
             rot_mat       = detect_geom.get_rot_mat(angle_index);
             to_source_vec = rot_mat * detect_geom.to_source_vec;
             detector_vec  = rotz(-pi/2) * to_source_vec; % perpendicular to the source vector
             centre        = to_source_vec .* -detect_geom.dist_to_detector/2;
             
            % Get the pixel information
             npy = self.n_pixels(1); 
             npz = self.n_pixels(2);
             pixel_width = self.pixel_dims(1); 
             pixel_height = self.pixel_dims(2);
 
             corner = centre - detector_vec .* pixel_width  * npy/2 ...
                                  - [0;0;1] .* pixel_height * npz/2;
             det_xy = detector_vec(1:2);
             hit_pixel_at_angle = @at_angle;
             function [pixel, ray_len, hit] = at_angle(ray_starts, ray_dirs)
                assert(all(abs(sum(ray_dirs.^2, 1) - 1) < 1e-14), "All ray directions must be unit vectors")
                assert(size(ray_starts, 2) == size(ray_dirs, 2), "The number of ray starts must match the number of ray directions")
                
                num_rays = size(ray_dirs, 2);
                ray_xy = ray_dirs(1:2, :); hit = true(1, num_rays); 
                pixel = zeros(2, num_rays); ray_len = zeros(1, num_rays);

                %Check the xy line intersects with the detector vector a.b = |a||b|cos(theta) (parallel -> cos(theta) = 1)
                no_hit = abs(sum(ray_xy .* det_xy, 1) - sum(det_xy.^2, 1)*sum(ray_xy.^2, 1)).^2 < 1e-10;
                
                % Check that the ray is heading towards the detector
                no_hit = no_hit | acos(sum(ray_dirs .* to_source_vec, 1)) < pi/2;

                hit(no_hit) = false; 
                if all(~hit); return; end

                % Get point on the detector vector where the ray intersects in xy plane
                dy = ray_xy(2, :) .* (corner(1) - ray_starts(1, :)) + ray_xy(1, :) ...
                    .* (ray_starts(2, :) - corner(2)) ./ ...
                    (ray_xy(1, :) .* det_xy(2) - ray_xy(2, :) .* det_xy(1));
                py = floor(dy ./ pixel_width) + 1;
                hit(py < 1 | py > npy) = false;
                if all(~hit); return; end
                
                hit_xy_coord = centre + detector_vec .* (py - (npy+1)/2) .* pixel_width;
                ray_len = sqrt(sum((ray_starts(1:2, :) - hit_xy_coord(1:2, :)).^2, 1));
                ray_len(~hit) = 0;
                
                % Get point on the detector vector where the ray intersects in z direction
                ray_hit_point = ray_starts + ray_dirs .* ray_len;
                pz = floor((ray_hit_point(3, :) - corner(3)) ./ pixel_height) + 1;
                hit(pz < 1 | pz > npz) = false;
                ray_len(~hit) = 0;
                if all(~hit); return; end

                pixel(:, hit) = [py(hit); pz(hit)];
            end
         end
     end
 end