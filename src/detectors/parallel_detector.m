classdef parallel_detector < detector
   
    properties
        init_centre       (3, 1) double
        centre            (3, 1) double
        pixel_dims        (1, 2) double
        init_detector_vec (3, 1) double = [1;0;0] % Vector from left to right corner of detector
        detector_vec      (3, 1) double = [1;0;0] % Vector from left to right corner of detector
    end
    methods (Access=private, Static)
        function generator = get_ray_generator_static(ny_pixels, nz_pixels, centre, detector_vec, pixel_width, pixel_height, dist_to_detector, to_source_vec)
            generator = @get_ray_attrs; % Create the function which returns the rays
            function [xray] = get_ray_attrs(y_pixel, z_pixel)
                assert(y_pixel <= ny_pixels && y_pixel > 0 && z_pixel <= nz_pixels && z_pixel > 0, ...
                    "Pixel number must be between 1 and the number of pixels on the detector.")
                pixel_centre = centre +  ... 
                            detector_vec .* (y_pixel - (ny_pixels+1)/2) .* pixel_width + ...
                            [0;0;pixel_height] .* (z_pixel - (nz_pixels+1)/2);
                source_position = pixel_centre + to_source_vec * dist_to_detector;
                xray = ray(source_position, -to_source_vec, dist_to_detector);
            end
        end
    end

    methods
        function self = parallel_detector(dist_to_detector, pixel_dims, n_pixels, num_rotations, scatter_factor)
            arguments
                dist_to_detector         double
                pixel_dims        (1, 2) double
                n_pixels          (1, 2) double
                num_rotations            double = 180
                scatter_factor           double = 0
            end
            self@detector(dist_to_detector, num_rotations, n_pixels, pi, scatter_factor);
            self.pixel_dims = pixel_dims;
            
            % Only true for initial configuration
            self.centre = self.to_source_vec * -dist_to_detector/2;
            self.init_centre = self.centre;
        end

        function self = rotate(self) % How can I make this fast?
            % Rotate the detector and the source (better to do this than recalculate the source position?)
            self.detector_vec  = self.rot_mat * self.detector_vec;
            self.to_source_vec = self.rot_mat * self.to_source_vec;
            self.centre        = self.rot_mat * self.centre;
        end

        function ray_generator = get_ray_generator(self, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                ray_per_pixel  int32             = 1
            end
            assert(nargin==1, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")

            % Create the function which returns the rays
            ray_generator = parallel_detector.get_ray_generator_static(...
                self.ny_pixels, self.nz_pixels, self.centre, self.detector_vec, ...
                self.pixel_dims(1), self.pixel_dims(2), self.dist_to_detector, self.to_source_vec...
            );
        end
        function pixel_generator = get_pixel_generator(self, angle_index, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                angle_index    double
                ray_per_pixel  int32             = 1
            end
            assert(nargin==2, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")
            
            if angle_index == 1; rot_mat = eye(3);
            else               ; rot_mat = rotz(self.rot_angle * (angle_index - 1));
            end
            detector_vec  = rot_mat * self.init_detector_vec;
            to_source_vec = rot_mat * self.init_to_source_vec;
            centre        = rot_mat * self.init_centre;
            detector_response= @self.detector_response;

            % Create the function which returns the rays
            pixel_generator = @generator;
            static_ray_generator = parallel_detector.get_ray_generator_static(...
                self.ny_pixels, self.nz_pixels, centre, detector_vec, ...
                self.pixel_dims(1), self.pixel_dims(2), self.dist_to_detector, to_source_vec...
            );
            function pixel_value = generator(y_pixel, z_pixel, voxels)
                xray = static_ray_generator(y_pixel, z_pixel);
                pixel_value = detector_response(xray.calculate_mu(voxels));
            end
        end
    end
end
