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
            
            % Create the function which returns the information for each ray
            pixel_generator = @generator;
            function pixel_centre = generator(y_pixel, z_pixel)
                z_shift = pixel_height * (z_pixel - (nz_pixels+1)/2);

                pixel_centre = pixel_rot^y_pixel * detect_edge .* rot_radius + ...
                    [0; 0; z_shift];
            end
        end

        function [pixel, hit] = hit_pixel(self, ray_v1to2, ray_start, detector_vec)
            % Get the pixel which the xray hits
            error("Not implemented")
        end
    end
end
