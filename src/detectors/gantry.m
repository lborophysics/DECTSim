classdef gantry < handle
    properties
        % Detector geometry
        dist_to_detector   (1, 1) double % Distance from source to detector
        rot_radius         (1, 1) double % Radius of rotation of the detector

        % Vector from the centre of the detector to the source 
        to_source_vec      (3, 1) double = [0;1;0] % Vector from source to centre of detector

        % Detector movement
        num_rotations      (1, 1) double % Number of rotations around the object
        rot_angle          (1, 1) double

        % Scan angles
        scan_angles        (1, :) double
    end
    methods
        function self = gantry(dist_to_detector, num_rotations, total_rotation)
            % detector  Construct a detector object
            arguments
                dist_to_detector (1, 1) double
                num_rotations    (1, 1) double
                total_rotation   (1, 1) double = 2*pi
            end
            % Detector Geometry
            assert(dist_to_detector > 0, 'Distance to detector must be greater than 0');
            assert(num_rotations > 0 && mod(num_rotations, 1) == 0, 'Number of rotations must be a positive integer');
            assert(total_rotation > 0 && total_rotation <= 2*pi, 'Total rotation must be between 0 and 2*pi');
            
            % Set the detector movement properties
            self.rot_angle        = total_rotation / num_rotations;
            self.dist_to_detector = dist_to_detector;
            self.rot_radius       = dist_to_detector / 2;
            self.num_rotations    = num_rotations;
            
            % Get the angles at which the detector should be rotated to scan the object (in degrees)
            scan_angles = linspace(0, total_rotation, num_rotations+1);
            self.scan_angles = scan_angles(1:end-1);
        end

        function source_pos = get_source_pos(self, index, ~)
            % Get the position of the source at a given angular index
            % Third argument is the pixel position, which is not used here, useful for 
            % parallel beams.
            source_pos = self.get_rot_mat(index) * (self.to_source_vec .* self.rot_radius);
        end

        function rot_mat = get_rot_mat(self, index)
            % Get the rotation matrix for the detector at a given angular index
            if index == 1; rot_mat = eye(3); 
            else         ; rot_mat = rotz(self.rot_angle * (index - 1));
            end
        end
    end
end
