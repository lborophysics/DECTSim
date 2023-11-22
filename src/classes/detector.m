classdef detector
    properties
        pixel_width (1, 1) double
        width       (1, 1) double
        centre      (3, 1) double
        num_pixels         double
        num_rotations      double
    end

    methods

        function ray_generator = get_ray_generator(self, ray_per_pixel)
            % get_ray_generator  Get a ray generator for this detector template
            error('Not implemented for base class, must be implemented in subclass');
        end

        function rotate(self)
            % rotate  Rotate the detector by one rotation
            error('Not implemented for base class, must be implemented in subclass');
        end

        function pixel = detector_response(~, attenuation)
            % detector_response  Calculate the detector response for a given attenuation coefficient
            arguments
                ~
                attenuation (1, 1) double
            end
            pixel = exp(-attenuation);
        end

        function image = generate_image(self, voxels)
            image = zeros(self.num_rotations, self.num_pixels);
            for i = 1:self.num_rotations
                ray_generator = self.get_ray_generator();
                for j = 1:self.num_pixels
                    
                    ray = ray_generator(j);
                    
                    mu = ray.calculate_mu(voxels);
                    
                    image(i, j) = self.detector_response(mu);
                end
                self = self.rotate();
            end
            image = mat2gray(-log(image'));
        end            
    end
end