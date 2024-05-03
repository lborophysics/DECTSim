classdef flat_detector < detector_array
     methods

        function pixel_positions = set_array_angle(self, detect_geom, angle_index)
            % Create a function which returns the rays which should be fired to hit each pixel.
            arguments
                self           flat_detector
                detect_geom    gantry
                angle_index    double
            end

            % Get the detector geometry
            rot_mat       = detect_geom.get_rot_mat(angle_index);
            d2detector    = detect_geom.dist_to_detector;

            % Calculate some useful vectors
            to_source_vec = rot_mat * detect_geom.to_source_vec;
            centre        = to_source_vec .* -d2detector/2;
            detector_vec  = rotz(-pi/2) * to_source_vec; % perpendicular to the source vector

            % Get the pixel information
            half_y       = (self.n_pixels(1) + 1) / 2;
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);

            z_shift = zeros(3, 1, nz_pixels);
            z_shift(3, 1, :) = self.pixel_dims(2) * ((1:nz_pixels) - (nz_pixels+1)/2);
            z_shift = repmat(z_shift, 1, ny_pixels, 1);

            pixel_centre = centre + detector_vec .* self.pixel_dims(1)  * ((1:ny_pixels) - half_y);
            pixel_centre = repmat(pixel_centre, 1, 1, nz_pixels);
            
            pixel_positions = pixel_centre + z_shift;
            pixel_positions = reshape(pixel_positions, 3, ny_pixels * nz_pixels);
        end

        function hit_pixel_at_angle = hit_pixel(self, detect_geom, angle_index)
            % Get the detector geometry
            rot_mat       = detect_geom.get_rot_mat(angle_index);
            to_source_vec = rot_mat * detect_geom.to_source_vec;
            detector_vec  = rotz(-pi/2) * to_source_vec; % perpendicular to the source vector
            normal_vec    = -to_source_vec;
            centre        = normal_vec .* detect_geom.dist_to_detector/2;
            
            % Get the pixel information
            npy = self.n_pixels(1); 
            npz = self.n_pixels(2);
            pixel_width = self.pixel_dims(1); 
            pixel_height = self.pixel_dims(2);

            corner = centre - detector_vec .* pixel_width  * npy/2 ...
                                - [0;0;1] .* pixel_height * npz/2;

            D = dot(normal_vec, corner); % D as in Ax + By + Cz = D (where A, B, C are the components of the normal vector to the plane)
            hit_pixel_at_angle = @at_angle;
            function [pixel, ray_len, angles, hit] = at_angle(ray_starts, ray_dirs)
                assert(all(abs(sum(ray_dirs.^2, 1) - 1) < 1e-14), "All ray directions must be unit vectors")
                assert(size(ray_starts, 2) == size(ray_dirs, 2), "The number of ray starts must match the number of ray directions")
                
                num_rays = size(ray_dirs, 2);
                hit     = true (1, num_rays); 
                pixel   = zeros(2, num_rays); 
                ray_len = (D - sum(ray_starts .* normal_vec, 1)) ...
                    ./ sum(ray_dirs .* normal_vec, 1);
                ray_hits = ray_starts + ray_dirs .* ray_len;
                angles = acos(sum(ray_dirs .* normal_vec, 1));
                
                % Calculate the pixel number
                if abs(detector_vec(1)) > 0
                    ypix = floor((ray_hits(1, :) - corner(1)) ...
                        ./ detector_vec(1) ./ pixel_width) + 1;
                else
                    ypix = floor((ray_hits(2, :) - corner(2)) ...
                        ./ detector_vec(2) ./ pixel_width) + 1;
                end

                zpix = floor((ray_hits(3,:) - corner(3)) ./ pixel_height) + 1;             

                hit = hit & (zpix >= 1) & (zpix <= npz) & ...
                            (ypix >= 1) & (ypix <= npy) & (ray_len > 0);

                % Is it necessary to return 0s for the pixels which are not hit?
                pixel(1, hit) = ypix(hit);
                pixel(2, hit) = zpix(hit);
                ray_len(~hit) = 0;
                angles (~hit) = 0;
            end
        end
    end
 end