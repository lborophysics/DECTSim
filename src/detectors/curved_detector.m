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
                        
            % Get the source and detector positions
            rot_mat       = detect_geom.get_rot_mat(angle_index);
            d2detector    = detect_geom.dist_to_detector;
            
            % Calculate information about the source position and direction
            to_source_vec = rot_mat * detect_geom.to_source_vec;
            source_pos    = to_source_vec .* d2detector/2;
            
            % Get the pixel information
            pixel_angle  = self.pixel_dims(1) / d2detector;
            pixel_height = self.pixel_dims(2);
            ny_pixels    = self.n_pixels(1);
            nz_pixels    = self.n_pixels(2);
            
            % Create the function which returns the information for each ray
            pixel_generator = @generator;
            function pixel_centre = generator(y_pixel, z_pixel)
                z_shift = pixel_height * (z_pixel - (nz_pixels+1)/2);
                final_length = sqrt(d2detector.^2 + z_shift.^2);
                pixel_vec = (rotz(pixel_angle * (y_pixel - (ny_pixels+1)/2)) * to_source_vec.*d2detector - ...
                            [0;0;z_shift]) ./ final_length;
                
                % - as we rotate the vector towards the source
                pixel_centre = source_pos - pixel_vec .* final_length; 
            end
        end

        function [pixel, hit] = hit_pixel(self, ray_v1to2, ray_start, detector_vec)
            % Get the pixel which the xray hits
            error("Not implemented")
        end
    end
end
