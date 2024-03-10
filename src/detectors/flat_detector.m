classdef flat_detector < detector_array
     methods

        function pixel_generator = set_array_angle(self, detect_geom, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           flat_detector
                detect_geom    gantry
                angle_index    double
                ray_per_pixel  int32             = 1
            end
            assert(ray_per_pixel==1, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Get the detector geometry
            rot_mat       = detect_geom.get_rot_mat(angle_index);
            d2detector    = detect_geom.dist_to_detector;

            % Calculate some useful vectors
            to_source_vec = rot_mat * detect_geom.to_source_vec;
            centre        = to_source_vec .* -d2detector/2;
            detector_vec  = rotz(-pi/2) * to_source_vec; % perpendicular to the source vector

            % Get the pixel information
            pixel_width  = self.pixel_dims(1);
            pixel_height = self.pixel_dims(2);
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);

            % Create the function which returns the information for each ray
            pixel_generator = @generator; 
            function pixel_centre = generator(y_pixel, z_pixel)
                pixel_centre = centre +  ... 
                            detector_vec .* (y_pixel - (ny_pixels+1)/2) .* pixel_width + ...
                            [0;0;pixel_height] .* (z_pixel - (nz_pixels+1)/2);
            end
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
            function [pixel, ray_len, hit] = at_angle(ray_starts, ray_dirs)
                assert(all(abs(sum(ray_dirs.^2, 1) - 1) < 1e-14), "All ray directions must be unit vectors")
                assert(size(ray_starts, 2) == size(ray_dirs, 2), "The number of ray starts must match the number of ray directions")
                
                num_rays = size(ray_dirs, 2);
                hit     = true (1, num_rays); 
                pixel   = zeros(2, num_rays); 
                ray_len = (D - sum(ray_starts .* normal_vec, 1)) ...
                    ./ sum(ray_dirs .* normal_vec, 1);
                ray_hits = ray_starts + ray_dirs .* ray_len;
                
                zpix = floor((ray_hits(3,:) - corner(3)) ./ pixel_height) + 1;
                
                xy_dist = sqrt(sum((ray_hits(1:2,:) - corner(1:2)).^2, 1));
                xypix = floor(xy_dist ./ pixel_width) + 1;

                hit = hit & (zpix  >= 1) & (zpix  <= npz) & ...
                            (xypix >= 1) & (xypix <= npy) & (ray_len > 0);

                % Is it necessary to return 0s for the pixels which are not hit?
                pixel(1, hit) = xypix(hit);
                pixel(2, hit) = zpix(hit);
                ray_len(~hit) = 0;
            end
        end
    end
 end