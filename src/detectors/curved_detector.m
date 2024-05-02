classdef curved_detector < detector_array
    methods
        function pixel_generator = set_array_angle(self, detect_geom, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            
            % THIS FUNCTION NEEDS CHANGING. In the future, this function should be vectorised
            % meaning that all of the pixel positions at a given angle should be calculated at once, 
            % rather than return a function which calculates the pixel position for each pixel.
            arguments
                self           curved_detector
                detect_geom    gantry
                angle_index    double {mustBePositive, mustBeInteger}    
                ray_per_pixel  int32  {mustBePositive, mustBeInteger} = 1
            end
            assert(ray_per_pixel==1, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Get the detector properties
            rot_radius       = detect_geom.rot_radius;
            dist_to_detector = detect_geom.dist_to_detector; % Distance from the source to the detector == 2 * rot_radius
          
            % Get the pixel information
            % pixel_angle  = self.pixel_dims(1) / rot_radius; % angle = arc_length / radius
            pixel_angle  = single(chord2ang(self.pixel_dims(1), dist_to_detector)); % angle = 2 * asin(arc_length / (2 * radius))
            pixel_height = self.pixel_dims(2);
            half_z = pixel_height * (self.n_pixels(2) + 1) / 2;
            
            % Correct the radius to the radius of the chords
            rot_radius  = realsqrt(rot_radius^2 - (self.pixel_dims(1)/2)^2); % Correct to the radius of the chords

            % Calculate information about the source position and direction
            to_detect_vec = detect_geom.get_rot_mat(angle_index) ...
                * -detect_geom.to_source_vec * rot_radius;

            % Calculate the edge of the detector
            detect_edge = rotz(-pixel_angle * ((self.n_pixels(1) - 1) / 2)) * to_detect_vec;
            
            % Create the function which returns the information for each ray
            pixel_generator = @generator;
            function pixel_centre = generator(y_pixel, z_pixel)
                z_shift = pixel_height * z_pixel - half_z;

                pixel_centre = rotz(pixel_angle * (y_pixel - 1)) * detect_edge + ...
                    [0; 0; z_shift];
            end
        end

        function hit_pixel_at_angle = hit_pixel(self, detect_geom, angle_index)
            dist_to_detector = detect_geom.dist_to_detector; % Distance from the source to the detector == 2 * rot_radius

            % Get the detector radius
            rot_radius  = realsqrt(detect_geom.rot_radius^2 - (self.pixel_dims(1)/2)^2); % Correct to the radius of the chords
            r2 = rot_radius^2;

            % Calculate information about the source position and direction
            to_detect_vec = detect_geom.get_rot_mat(angle_index) ...
                * -detect_geom.to_source_vec;
            
            % Get the pixel information
            % pixel_angle  = self.pixel_dims(1) / rot_radius; % angle = arc_length / radius
            pixel_angle  = chord2ang(self.pixel_dims(1), dist_to_detector); % angle = 2 * asin(arc_length / (2 * radius))
            pixel_height = self.pixel_dims(2);
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);
            
            % Calculate the angle of the left edge of the detector
            left_edge   = rotz(-pixel_angle * ny_pixels / 2) * to_detect_vec .* rot_radius;
            left_edge   = left_edge(1:2);
            norm_right   = sqrt(sum(left_edge.^2));

            % Calculate the half height of the detector
            half_z     = nz_pixels / 2;

            % Calculate the normal vectors to each pixel
            normal_vecs = zeros(3, ny_pixels);
            pixel_rot   = rotz(pixel_angle);
            detect_edge = rotz(-pixel_angle * (ny_pixels+1) / 2) * to_detect_vec;
            for i = 1:ny_pixels
                normal_vecs(:, i) = pixel_rot^i * detect_edge;
            end

            hit_pixel_at_angle = @at_angle;
            function [pixel, ray_len, angles, hit] = at_angle(ray_starts, ray_dirs)
                num_rays = size(ray_dirs, 2);
                hit      = true (1, num_rays); 
                pixel    = zeros(2, num_rays);
                ray_len  = zeros(1, num_rays);
                angles   = zeros(1, num_rays);

                % First calculate the norm squared of the ray directions in the x-y plane
                dx = ray_dirs(1, :);
                dy = ray_dirs(2, :);
                dr2 = dx.^2 + dy.^2;
                
                % Check if the ray is parallel to the detector
                hit(dr2 < 1e-14) = false;
                if ~any(hit); return; end
                
                % Calculate the discriminant
                x1 = ray_starts(1, :);
                y1 = ray_starts(2, :);
                discriminant = r2 .* dr2 - (dx .* y1 - dy .* x1).^2;

                % Check if the ray hits the cylinder
                hit(discriminant <= 0) = false;
                if ~any(hit); return; end
                
                % Remove the rays that don't hit the detector
                x1 = x1(hit); y1 = y1(hit);
                dx = dx(hit); dy = dy(hit);
                dirs = ray_dirs(:, hit);
                
                dr2 = dr2(hit);
                sqrt_discriminant = sqrt(discriminant(hit));

                % Calculate the two possible hit distances for the rays                
                d1 = (-(dx .* x1 + dy .* y1) + sqrt_discriminant) ./ dr2;
                d2 =-( (dx .* x1 + dy .* y1) + sqrt_discriminant) ./ dr2;
                
                % Calculate the hit points in the detector
                point1 = ray_starts(:, hit) + d1 .* dirs;
                point2 = ray_starts(:, hit) + d2 .* dirs;

                % Calculate the z pixel number
                zpix1 = ceil(half_z + point1(3, :) ./ pixel_height);
                zpix2 = ceil(half_z + point2(3, :) ./ pixel_height);

                norm1 = sqrt(sum(point1(1:2, :).^2, 1));
                norm2 = sqrt(sum(point2(1:2, :).^2, 1));

                % Calculate the y pixel number by finding the angle of intersection with respect to the left edge
                angle1 = acos(sum(point1(1:2, :) .* left_edge, 1) ./ (norm_right * norm1));
                angle2 = acos(sum(point2(1:2, :) .* left_edge, 1) ./ (norm_right * norm2));

                ypix1 = ceil(angle1 ./ pixel_angle); % Don't like this numerical instability
                ypix2 = ceil(angle2 ./ pixel_angle); % Don't like this numerical instability

                cross1 = point1(2, :) .* left_edge(1) - point1(1, :) .* left_edge(2);
                cross2 = point2(2, :) .* left_edge(1) - point2(1, :) .* left_edge(2);
                
                % Check if the hit is within the detector arc
                first_hit  = zpix1 >= 1 & zpix1 <= nz_pixels & ypix1 >= 1 & ypix1 <= ny_pixels & d1 > 0 & cross1 >= 0;
                second_hit = zpix2 >= 1 & zpix2 <= nz_pixels & ypix2 >= 1 & ypix2 <= ny_pixels & d2 > 0 & cross2 >= 0;

                assert(~any(first_hit == 1 & second_hit == 1), 'Both first and second hit are true, this should not happen');

                % Check if any rays hit the detector
                if ~any(first_hit | second_hit)
                    hit(:) = false;
                    return;
                end
                                
                % Extend the hit arrays
                hit1 = false(1, num_rays);
                hit2 = false(1, num_rays);
                hit1(hit) = first_hit;
                hit2(hit) = second_hit;
                
                % Set the hit pixels, ray lengths and angles
                if any(hit1)
                    pixel(:, hit1) = [ypix1(first_hit ); zpix1(first_hit )];
                    ray_len( hit1) = d1(first_hit);
                    angles ( hit1) = acos(sum(dirs(:, first_hit ) .* normal_vecs(:, ypix1(first_hit )), 1));
                end
                if any(hit2)
                    pixel(:, hit2) = [ypix2(second_hit); zpix2(second_hit)]; 
                    ray_len( hit2) = d2(second_hit);
                    angles ( hit2) = acos(sum(dirs(:, second_hit) .* normal_vecs(:, ypix2(second_hit)), 1));
                end

                % Set the hit flag
                hit = hit1 | hit2;           
            end
        end
    end
end
