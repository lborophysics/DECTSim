classdef parallel_detector < flat_array
   % The ray generator is probably wrong, it needs to have an angle for the z axis, rather than directly above it.
    methods
        function ray_generator = ray_at_angle(self, detect_geom, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
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
    end
end
