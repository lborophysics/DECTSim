classdef curved_detector < detector_array
    methods
        function pixel_generator = set_array_angle(self, detect_geom, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
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

            % Calculate information about the source position and direction
            to_detect_vec = detect_geom.get_rot_mat(angle_index) ...
                * -detect_geom.to_source_vec;
            
            % Get the pixel information
            % pixel_angle  = self.pixel_dims(1) / rot_radius; % angle = arc_length / radius
            pixel_angle  = chord2ang(self.pixel_dims(1), dist_to_detector); % angle = 2 * asin(arc_length / (2 * radius))
            pixel_height = self.pixel_dims(2);
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);
            
            % Calculate the edge of the detector
            pixel_rot   = rotz(pixel_angle);
            detect_edge = rotz(-pixel_angle * (ny_pixels+1) / 2) * to_detect_vec;
            rot_radius  = realsqrt(rot_radius^2 - (self.pixel_dims(1)/2)^2); % Correct to the radius of the chords
            
            % Create the function which returns the information for each ray
            pixel_generator = @generator;
            function pixel_centre = generator(y_pixel, z_pixel)
                z_shift = pixel_height * (z_pixel - (nz_pixels+1)/2);

                pixel_centre = pixel_rot^y_pixel * detect_edge .* rot_radius + ...
                    [0; 0; z_shift];
            end
        end

        function hit_pixel_at_angle = hit_pixel(self, detect_geom, angle_index)
            % Get the detector properties
            dist_to_detector = detect_geom.dist_to_detector; % Distance from the source to the detector == 2 * rot_radius

            % Calculate information about the source position and direction
            to_detect_vec = detect_geom.get_rot_mat(angle_index) ...
                * -detect_geom.to_source_vec;
            
            % Get the pixel information
            % pixel_angle  = self.pixel_dims(1) / rot_radius; % angle = arc_length / radius
            pixel_angle  = chord2ang(self.pixel_dims(1), dist_to_detector); % angle = 2 * asin(arc_length / (2 * radius))
            pixel_height = self.pixel_dims(2);
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);
            
            % Calculate the edge of the detector
            left_edge = rotz(-pixel_angle * (ny_pixels+1) / 2) * to_detect_vec;
            left_angle = atan2(left_edge(2), left_edge(1));
            total_angle = pixel_angle * ny_pixels;
            rot_radius       = detect_geom.rot_radius - ... 
                realsqrt(detect_geom.rot_radius^2 - (self.pixel_dims(1)/2)^2);
            r2 = rot_radius^2;

            hit_pixel_at_angle = @at_angle;
            function [pixel, ray_len, hit] = at_angle(ray_starts, ray_dirs)
                num_rays = size(ray_dirs, 2);
                hit     = true (1, num_rays); 
                pixel   = zeros(2, num_rays);
                ray_len = zeros(1, num_rays);

                x1 = ray_starts(1, :);
                y1 = ray_starts(2, :);
                dx = ray_dirs(1, :);
                dy = ray_dirs(2, :);
                
                x2 = x1 + dx;
                y2 = y1 + dy;
                dr2 = dx.^2 + dy.^2;
                D = x1 .* y2 - x2 .* y1;

                discriminant = r2 * dr2 - D.^2;
                hit(discriminant <= 0) = false;
                if ~any(hit); return; end
                
                x1 = x1(hit); y1 = y1(hit); z1 = ray_starts(3, hit);
                dx = dx(hit); dy = dy(hit); dz = ray_dirs(3, hit);
                dr2 = dr2(hit); D = D(hit); 
                discriminant = discriminant(hit); 

                sqrt_discriminant = sqrt(discriminant);
                sign_dy = sign(dy);
                sign_dy(sign_dy == 0) = 1;

                xhit1 = ( D .* dy + sign_dy .* dx .* sqrt_discriminant) ./ dr2;
                yhit1 = (-D .* dx + abs(dy)       .* sqrt_discriminant) ./ dr2;
                
                xhit2 = ( D .* dy - sign_dy .* dx .* sqrt_discriminant) ./ dr2;
                yhit2 = (-D .* dx - abs(dy)       .* sqrt_discriminant) ./ dr2; 

                % Get the angle of the hit
                angle1 = atan2(yhit1, xhit1);
                angle2 = atan2(yhit2, xhit2);

                % Check if the hit is within the detector
                first_hit = angle1 >= left_angle & angle1 <= left_angle + total_angle;
                second_hit = angle2 >= left_angle & angle2 <= left_angle + total_angle;
                if ~any(first_hit | second_hit); return; end
                
                % Get the distance to the hit
                xray1 = x1 - xhit1; yray1 = y1 - yhit1;
                xray2 = x1 - xhit2; yray2 = y1 - yhit2;
                hit_ray_len = sqrt(xray1.^2 + yray1.^2);
                hit_ray_len(second_hit) = sqrt(xray2(second_hit).^2 + yray2(second_hit).^2);
               
                % Get the pixel
                hit_pixel = pixel(:, hit);
                hit_pixel(1, first_hit ) = floor((angle1(first_hit ) - left_angle) ./ pixel_angle) + 1;
                hit_pixel(1, second_hit) = floor((angle2(second_hit) - left_angle) ./ pixel_angle) + 1;

                % Get the z position
                zhit1 = z1(first_hit ) + dz(first_hit ) .* hit_ray_len(first_hit );
                zhit2 = z1(second_hit) + dz(second_hit) .* hit_ray_len(second_hit);
                
                zpix1 = floor(zhit1 / pixel_height + nz_pixels/2) + 1;
                zpix2 = floor(zhit2 / pixel_height + nz_pixels/2) + 1;

                % Get the pixel
                hit_pixel(2, first_hit ) = zpix1;
                hit_pixel(2, second_hit) = zpix2;

                % Set the hit pixels
                pixel(:, hit) = hit_pixel;
                ray_len(hit) = hit_ray_len;
                hit(pixel(1, :) < 1 | pixel(1, :) > ny_pixels | ...
                    pixel(2, :) < 1 | pixel(2, :) > nz_pixels) = false;
                ray_len(~hit) = 0;
                pixel(:, ~hit) = 0;
            end
        end
    end
end
