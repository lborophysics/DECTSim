classdef curved_detector < detector_array
    methods
        function pixel_positions = set_array_angle(self, detect_geom, angle_index)
            % Returns the pixel positions for a given angle_index
            arguments
                self           curved_detector
                detect_geom    gantry
                angle_index    double {mustBePositive, mustBeInteger}    
            end

            % Get the detector properties
            rot_radius       = detect_geom.rot_radius;
            dist_to_detector = detect_geom.dist_to_detector; % Distance from the source to the detector == 2 * rot_radius
          
            % Get the pixel information
            % pixel_angle  = self.pixel_dims(1) / rot_radius; % angle = arc_length / radius
            pixel_angle  = chord2ang(self.pixel_dims(1), dist_to_detector); % angle = 2 * asin(arc_length / (2 * radius))
            
            % Correct the radius to the radius of the chords
            rot_radius  = realsqrt(rot_radius^2 - (self.pixel_dims(1)/2)^2); % Correct to the radius of the chords

            % Calculate information about the source position and direction
            to_detect_vec = detect_geom.get_rot_mat(angle_index) ...
                * -detect_geom.to_source_vec * rot_radius;

            ny_pixels = self.n_pixels(1);
            nz_pixels = self.n_pixels(2);

            % Create the all the pixel positions for the detector
            z_shift = zeros(3, 1, nz_pixels);
            z_shift(3, 1, :) = self.pixel_dims(2) * ((1:nz_pixels) - (nz_pixels+1)/2);
            z_shift = repmat(z_shift, 1, ny_pixels, 1);

            pixel_centre = pagemtimes(...
                rotz_vec(pixel_angle/2 * (2.*(1:ny_pixels) - ny_pixels - 1)), to_detect_vec);
            pixel_centre = repmat(squeeze(pixel_centre), 1, 1, nz_pixels);

            pixel_positions = pixel_centre + z_shift;
        end

        function hit_pixel_at_angle = hit_pixel(self, detect_geom, angle_index)
            dist_to_detector = detect_geom.dist_to_detector; % Distance from the source to the detector == 2 * rot_radius

            % Get the detector radius
            r2 = detect_geom.rot_radius^2 - (self.pixel_dims(1)/2)^2; % Correct to the radius of the chords
            rot_radius  = realsqrt(r2);

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
                % hit      = true (1, num_rays); 
                pixel    = zeros(2, num_rays);
                ray_len  = zeros(1, num_rays);
                angles   = zeros(1, num_rays);

                % First calculate the norm squared of the ray directions in the x-y plane
                dx = ray_dirs  (1, :);
                dy = ray_dirs  (2, :);
                x1 = ray_starts(1, :); 
                y1 = ray_starts(2, :);
                dr2 = dx.^2 + dy.^2;
                
                % Calculate the discriminant
                discriminant = (dr2 .* r2) - ...
                    (dx .* ray_starts(2, :) - dy .* ray_starts(1, :)).^2;

                % Check if the ray hits the cylinder
                if all(discriminant <= 0)
                    hit = false(1, num_rays);
                    return
                end
                
                sqrt_discriminant = sqrt(discriminant);

                % Calculate the two possible hit distances for the rays                
                d1 = (-(dx .* x1 + dy .* y1) + sqrt_discriminant) ./ dr2;
                d2 = (-(dx .* x1 + dy .* y1) - sqrt_discriminant) ./ dr2;
                
                % Calculate the hit points in the detector
                point1 = ray_starts + d1 .* ray_dirs;
                point2 = ray_starts + d2 .* ray_dirs;

                % Calculate the z pixel number
                zpix1 = ceil(half_z + point1(3, :) ./ pixel_height);
                zpix2 = ceil(half_z + point2(3, :) ./ pixel_height);
                
                % Calculate the y pixel number by finding the angle of intersection with respect to the left edge
                ypix1 = ceil(acos(1 - sum((left_edge - point1(1:2, :)).^2, 1) ./ (2*r2)) ./ pixel_angle); % Don't like this numerical instability
                ypix2 = ceil(acos(1 - sum((left_edge - point2(1:2, :)).^2, 1) ./ (2*r2)) ./ pixel_angle); % Don't like this numerical instability
                ypix2(ypix2 == ypix1) = -1; % If the angles are the same, set the second pixel to -1, so we only hit one pixel

                cross1 = point1(2, :) .* left_edge(1) - point1(1, :) .* left_edge(2);
                cross2 = point2(2, :) .* left_edge(1) - point2(1, :) .* left_edge(2);

                % Check if the hit is within the detector arc
                first_hit  = discriminant > 0 & zpix1 >= 1 & zpix1 <= nz_pixels & ypix1 >= 1 & ypix1 <= ny_pixels & d1 > 0 & cross1 >= 0;
                second_hit = discriminant > 0 & zpix2 >= 1 & zpix2 <= nz_pixels & ypix2 >= 1 & ypix2 <= ny_pixels & d2 > 0 & cross2 >= 0;
                
                assert(~any(first_hit == 1 & second_hit == 1), 'Both first and second hit are true, this should not happen');

                % Check if any rays hit the detector
                if ~any(first_hit | second_hit)
                    hit = false(1, num_rays);
                    return;
                end
                
                % Set the hit pixels, ray lengths and angles
                if any(first_hit)
                    pixel(:, first_hit) = [ypix1(first_hit ); zpix1(first_hit )];
                    ray_len( first_hit) = d1(first_hit);
                    angles ( first_hit) = acos(sum(ray_dirs(:, first_hit ) .* normal_vecs(:, ypix1(first_hit )), 1));
                end
                if any(second_hit)
                    pixel(:, second_hit) = [ypix2(second_hit); zpix2(second_hit)]; 
                    ray_len( second_hit) = d2(second_hit);
                    angles ( second_hit) = acos(sum(ray_dirs(:, second_hit) .* normal_vecs(:, ypix2(second_hit)), 1));
                end

                % Set the hit flag
                hit = first_hit | second_hit;      
            end
        end
    end
end
