classdef (Abstract) detector_array
    properties (SetAccess = protected)
        pixel_dims (1, 2) double % [width, height] of each pixel
        n_pixels   (1, 2) double % [n_x, n_y] number of pixels in each direction
    end

    methods (Abstract)
        % To calculate the ray vectors for each pixel in the detector array (ray tracing)
        pixel_generator = set_array_angle(self, detect_geom, angle_index, ray_per_pixel)
        
        % To calculate which pixel a ray hits in the detector array (scattering)
        [pixel, hit] = hit_pixel(self, detect_geom, angle_index)
    end

    methods
        function self = detector_array(pixel_dims, n_pixels)
            arguments
                pixel_dims      (1, 2) double {mustBePositive}
                n_pixels        (1, 2) double {mustBePositive, mustBeInteger}
            end
            self.pixel_dims = pixel_dims;
            self.n_pixels = n_pixels;
        end
    end
end