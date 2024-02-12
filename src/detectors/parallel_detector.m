classdef parallel_detector < detector
   % The ray generator is probably wrong, it needs to have an angle for the z axis, rather than directly above it.
    properties (SetAccess = private)
        init_centre       (3, 1) double           % Initial centre of the detector
        centre            (3, 1) double           % Centre of the detector
        pixel_dims        (1, 2) double           % [width, height] of each pixel
        init_detector_vec (3, 1) double = [1;0;0] % Vector from left to right corner of detector
        detector_vec      (3, 1) double = [1;0;0] % Vector from left to right corner of detector
    end
    methods (Access=private, Static)
        function generator = get_ray_generator_static(ray, ny_pixels, nz_pixels, centre, detector_vec, pixel_width, pixel_height, dist_to_detector, to_source_vec, voxels)
            generator = @get_ray_attrs; % Create the function which returns the rays
            function [xray] = get_ray_attrs(y_pixel, z_pixel)
                assert(y_pixel <= ny_pixels && y_pixel > 0 && z_pixel <= nz_pixels && z_pixel > 0, ...
                    "Pixel number must be between 1 and the number of pixels on the detector.")
                pixel_centre = centre +  ... 
                            detector_vec .* (y_pixel - (ny_pixels+1)/2) .* pixel_width + ...
                            [0;0;pixel_height] .* (z_pixel - (nz_pixels+1)/2);
                source_position = pixel_centre + to_source_vec .* dist_to_detector;
                xray = ray(source_position, -to_source_vec, dist_to_detector, voxels);
            end
        end
    end

    methods
        function self = parallel_detector(dist_to_detector, pixel_dims, n_pixels, num_rotations, scatter_type, scatter_factor)
            arguments
                dist_to_detector         double
                pixel_dims        (1, 2) double
                n_pixels          (1, 2) double
                num_rotations            double = 180
                scatter_type             string = "none"
                scatter_factor           double = 1
            end
            self@detector(dist_to_detector, num_rotations, n_pixels, pi, scatter_type, scatter_factor);
            self.pixel_dims = pixel_dims;
            
            % Only true for initial configuration
            self.centre = self.to_source_vec * -dist_to_detector/2;
            self.init_centre = self.centre;
        end

        function rotate(self) % How can I make this fast?
            % Rotate the detector and the source (better to do this than recalculate the source position?)
            self.detector_vec  = self.rot_mat * self.detector_vec;
            self.to_source_vec = self.rot_mat * self.to_source_vec;
            self.centre        = self.rot_mat * self.centre;
        end

        function reset(self)
            % Reset the detector to its initial position
            self.detector_vec  = self.init_detector_vec;
            self.to_source_vec = self.init_to_source_vec;
            self.centre        = self.init_centre;
        end

        function ray_generator = get_ray_generator(self, voxels, ray_type, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                voxels         voxel_array
                ray_type                         = @ray
                ray_per_pixel  int32             = 1
            end
            assert(nargin<4, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")
            % Create the function which returns the rays
            ray_generator = parallel_detector.get_ray_generator_static(...
                ray_type, self.ny_pixels, self.nz_pixels, self.centre, self.detector_vec, ...
                self.pixel_dims(1), self.pixel_dims(2), self.dist_to_detector, ...
                self.to_source_vec, voxels...
            );
        end
        function pixel_generator = get_pixel_generator(self, angle_index, voxels, ray_type, ray_per_pixel)
            % Create a function which returns the rays which should be fired to hit each pixel.
            % Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.
            arguments
                self           parallel_detector
                angle_index    double
                voxels         voxel_array
                ray_type                         = @ray
                ray_per_pixel  int32             = 1
            end
            assert(nargin<5, "Only 1 ray per pixel is supported at the moment, as anti-aliasing techniques are not yet implemented.")
            
            if angle_index == 1; rot_mat = eye(3);
            else               ; rot_mat = rotz(self.rot_angle * (angle_index - 1));
            end
            current_dv = rot_mat * self.init_detector_vec;
            current_sv = rot_mat * self.init_to_source_vec;
            current_c  = rot_mat * self.init_centre;

            % Create the function which returns the rays
            static_ray_generator = parallel_detector.get_ray_generator_static(...
                ray_type, self.ny_pixels, self.nz_pixels, current_c, current_dv, ...
                self.pixel_dims(1), self.pixel_dims(2), self.dist_to_detector, ...
                current_sv, voxels...
            );

            ray_type_str = func2str(ray_type); % Get the name of the ray type
            if     ray_type_str == "ray";         pixel_generator = @generator;
            elseif ray_type_str == "scatter_ray"; pixel_generator = @scatter_generator;
            else; error('parallel_detector:InvalidRayType', "Must be either 'ray' or 'scatter_ray'.");
            end

            function pixel_value = generator(y_pixel, z_pixel)
                xray = static_ray_generator(y_pixel, z_pixel);
                pixel_value = xray.calculate_mu();
            end

            function [pixel_values, pixels, scattered] = scatter_generator(y_pixel, z_pixel)
                xray = static_ray_generator(y_pixel, z_pixel);
                pixel_values = zeros(self.scatter_factor, 1);
                pixels = zeros(self.scatter_factor, 2);
                scattered = zeros(self.scatter_factor, 1);

                for i = 1:self.scatter_factor
                    new_ray = xray.calculate_mu();
                    
                    this_scatter = new_ray.scatter_event > 0;
                    
                    hit = true;
                    if this_scatter; [pixel, hit] = self.hit_pixel(new_ray, current_dv);
                    else;             pixel       = [y_pixel, z_pixel];
                    end
                    pixels(i, :) = pixel;
                    scattered(i) = this_scatter;
                    if hit; pixel_values(i) = new_ray.mu; 
                    else;   pixel_values(i) = NaN;
                    end
                    % xray = xray.randomise_n_mfp();
                end
            end
        end

        function [pixel, hit] = hit_pixel(self, xray, detector_vec)
            % Get the pixel which the xray hits
            hit = true; pixel = [0, 0];
            corner = self.centre - detector_vec .* self.pixel_dims(1) * self.ny_pixels/2 ...
                                 - [0;0;1]      .* self.pixel_dims(2) * self.nz_pixels/2;
            direction = xray.v1_to_v2 ./ norm(xray.v1_to_v2);
            ray_xy    = direction(1:2); det_xy = detector_vec(1:2);
            ray_start = xray.start_point;

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
