classdef (Abstract) detector_1d < detector
    methods
        function self = detector_1d(dist_to_detector, rotation_angle, num_pixels, total_rotation)
            self = self@detector(dist_to_detector, rotation_angle, num_pixels, 1, total_rotation);
        end        

        function image = generate_image(self, voxels)
            image = mat2gray(squeeze(generate_image@detector(self, voxels)));
        end
        
        function image = generate_image_p(self, voxels)
            image = mat2gray(squeeze(generate_image_p@detector(self, voxels)));
        end
    end
end