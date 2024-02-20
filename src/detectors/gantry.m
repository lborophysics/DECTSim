classdef gantry < handle
    properties
        % Detector geometry
        dist_to_detector   (1, 1) double % Distance from source to detector

        % Vector from the centre of the detector to the source 
        to_source_vec      (3, 1) double = [0;1;0] % Vector from source to centre of detector

        % Detector movement
        num_rotations      (1, 1) double % Number of rotations around the object
        rot_mat            (3, 3) double % Matrix for each individual rotation of the detector around the object
        rot_angle          (1, 1) double
        total_rotation     (1, 1) double % The maximum rotation of the detector around the object
    end
    methods
        function self = detector(dist_to_detector, num_rotations, total_rotation)
            % detector  Construct a detector object
            arguments
                dist_to_detector (1, 1) double
                num_rotations    (1, 1) double
                total_rotation   (1, 1) double
            end
            % Detector Geometry
            self.dist_to_detector = dist_to_detector;
            self.total_rotation   = total_rotation;
            
            % Set the detector movement properties
            self.rot_angle      = total_rotation / num_rotations;
            self.rot_mat        = rotz(self.rot_angle);
            self.num_rotations  = num_rotations;
        end

        function scan_angles = get_scan_angles(self)
            % Get the angles at which the detector should be rotated to scan the object (in degrees)
            scan_angles = rad2deg(linspace(0, self.total_rotation, self.num_rotations+1));
            scan_angles = scan_angles(1:end-1);
        end

        function rot_mat = get_rot_mat(self, index)
            % Get the rotation matrix for the detector at a given angular index
            if index == 1; rot_mat = eye(3); 
            else         ; rot_mat = rotz(self.rot_angle * (index - 1));
            end
        end
    end
end
