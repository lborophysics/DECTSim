classdef parallel_detector < detector_array
   % The ray generator is probably wrong, it needs to have an angle for the z axis, rather than directly above it.
    methods
        function self = parallel_detector(pixel_dims, n_pixels)
            self = self@detector_array(pixel_dims, n_pixels);
        end

        function ray_generator = ray_at_angle(self, detect_geom, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                detect_geom    gantry
                angle_index    double
                ray_per_pixel  int32             = 1
            end
            assert(nargin<4, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Get the detector geometry
            rot_mat       = detect_geom.get_rot_mat(angle_index);
            d2detector    = detect_geom.dist_to_detector;

            % Calculate some useful vectors
            % detector_vec  = rotz(detect_geom.rot_angle * (angle_index - 1) - pi/2) * ...
            %                 detect_geom.to_source_vec;
            to_source_vec = rot_mat * detect_geom.to_source_vec;
            centre        = to_source_vec .* -d2detector/2;
            detector_vec  = rotz(-pi/2) * to_source_vec; % perpendicular to the source vector

            % Get the pixel information
            pixel_width  = self.pixel_dims(1);
            pixel_height = self.pixel_dims(2);
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);

            % Create the function which returns the information for each ray
            ray_generator = @generator; 
            function [ray_start, ray_dir, ray_length] = generator(y_pixel, z_pixel)
                pixel_centre = centre +  ... 
                            detector_vec .* (y_pixel - (ny_pixels+1)/2) .* pixel_width + ...
                            [0;0;pixel_height] .* (z_pixel - (nz_pixels+1)/2);
                ray_start  = pixel_centre + to_source_vec .* d2detector;
                ray_dir    = -to_source_vec;
                ray_length = d2detector;
            end
        end

        function [pixel, hit] = hit_pixel(self, ray_v1to2, ray_start, detector_vec)
            % Get the pixel which the xray hits
            hit = true; pixel = [0, 0];
            corner = self.centre - detector_vec .* self.pixel_dims(1) * self.ny_pixels/2 ...
                                 - [0;0;1]      .* self.pixel_dims(2) * self.nz_pixels/2;
            direction = ray_v1to2 ./ norm(ray_v1to2);
            ray_xy    = direction(1:2); det_xy = detector_vec(1:2);

            %Check the xy line intersects with the detector vector a.b = |a||b|cos(theta) (parallel -> cos(theta) = 1)
            if abs(dot(ray_xy, det_xy) -norm(det_xy)*norm(ray_xy)) < 1e-10
                hit = false; return;
            end

            % Get point on the detector vector where the ray intersects in xy plane
            dy = ray_xy(2) * (corner(1) - ray_start(1)) + ray_xy(1) * (ray_start(2) - corner(2)) / ...
                (ray_xy(1) * det_xy(2) - ray_xy(2) * det_xy(1));
            py = floor(dy / self.pixel_dims(1)) + 1;
            if py < 1 || py > self.ny_pixels; hit = false; return; end

            % Get point on the detector vector where the ray intersects in xz plane
            ry = det_xy(2) * (ray_start(1) - corner(1)) + det_xy(1) * (corner(2) - ray_start(2)) / ...
                (ray_xy(2) * det_xy(1) - ray_xy(1) * det_xy(2));
            ray_hit_point = ray_start + direction .* ry;
            pz = floor((ray_hit_point(3) - corner(3)) / self.pixel_dims(2)) + 1;
            if pz < 1 || pz > self.nz_pixels; hit = false; return; end
            
            pixel = [py, pz];
        end
    end
end
