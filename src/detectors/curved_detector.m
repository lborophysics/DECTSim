classdef curved_detector < detector
    properties
        init_source_pos    (3, 1) double % The initial position of the source
        source_position    (3, 1) double % The position of the source
        pixel_angle        (1, 1) double % The angle covered by each pixel in y
        pixel_height       (1, 1) double % The height of each pixel in z
    end
    methods (Access=private, Static)
        function generator = get_ray_generator_static(ny_pixels, nz_pixels, pixel_angle, pixel_height, dist_to_detector, to_source_vec, source_pos)
            generator = @get_ray_attrs; % Create the function which returns the rays
            function [xray] = get_ray_attrs(y_pixel, z_pixel)
                assert(y_pixel <= ny_pixels && y_pixel > 0 && z_pixel <= nz_pixels && z_pixel > 0, ...
                        "Pixel number must be between 1 and the number of pixels on the detector.")
                z_shift = pixel_height * (z_pixel - (nz_pixels+1)/2);
                final_length = sqrt(dist_to_detector.^2 + z_shift.^2);
                pixel_vec = (rotz(pixel_angle * (y_pixel - (ny_pixels+1)/2)) * to_source_vec.*dist_to_detector - ...
                            [0;0;z_shift]) ./ final_length;
                xray = ray(source_pos, -pixel_vec, final_length);
            end
        end
    end

    methods
        function self = curved_detector(dist_to_detector, pixel_dims, n_pixels, num_rotations, scatter_type, scatter_factor)
            arguments
                dist_to_detector double
                pixel_dims       (1, 2) double
                n_pixels         (1, 2) double
                num_rotations    double = 360
                scatter_type     string = "none"
                scatter_factor   double = 0
            end
            self@detector(dist_to_detector, num_rotations, n_pixels, 2*pi, scatter_type, scatter_factor);
            self.pixel_angle =  pixel_dims(1) / dist_to_detector;
            self.pixel_height = pixel_dims(2);
            
            % Only true for initial configuration
            self.init_source_pos    = self.to_source_vec * dist_to_detector/2; 
            self.source_position    = self.init_source_pos;
            self.init_to_source_vec = self.to_source_vec;
        end

        function rotate(self)
            % rotate the detector by the rotation angle
            self.to_source_vec   = self.rot_mat * self.to_source_vec;
            self.source_position = self.rot_mat * self.source_position;
        end

        function reset(self)
            % reset the detector to its initial position
            self.to_source_vec   = self.init_to_source_vec;
            self.source_position = self.init_source_pos;
        end

        function ray_generator = get_ray_generator(self, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           curved_detector
                ray_per_pixel  int32             = 1
            end
            assert(nargin==1, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Create the function which returns the rays
            ray_generator = self.get_ray_generator_static(...
                self.ny_pixels, self.nz_pixels, self.pixel_angle, self.pixel_height, ...
                self.dist_to_detector, self.to_source_vec, self.source_position...
            );
        end
        function pixel_generator = get_pixel_generator(self, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           curved_detector
                angle_index    double
                ray_per_pixel  int32             = 1
            end
            assert(nargin==2, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")
            
            if angle_index == 1; rot_mat = eye(3); 
            else               ; rot_mat = rotz(self.rot_angle * (angle_index - 1));
            end
            to_source_vec = rot_mat * self.init_to_source_vec;
            source_pos    = rot_mat * self.init_source_pos;

            % Create the function which returns the rays
            pixel_generator = @generator;
            static_ray_generator = curved_detector.get_ray_generator_static(...
                self.ny_pixels, self.nz_pixels, self.pixel_angle, self.pixel_height, ...
                self.dist_to_detector, to_source_vec, source_pos...
            );
            function pixel_value = generator(y_pixel, z_pixel, voxels)
                xray = static_ray_generator(y_pixel, z_pixel);
                pixel_value = xray.calculate_mu(voxels);
            end
        end

        function pixel_hit = hit_pixel(self, xray)
            % Get the pixel which the xray hits
            error("Not implemented")
        end
    end
end
