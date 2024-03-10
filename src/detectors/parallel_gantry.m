classdef parallel_gantry < gantry
    %PARALLEL_GANTRY The same as a gantry class, but with a parallel beam (instead of a cone beam)
    methods
        function source_pos = get_source_pos(self, index, pixel_pos)
            % Get the position of the source at a given angular index
            source_pos = pixel_pos + self.get_rot_mat(index) * ...
                (self.to_source_vec .* self.dist_to_detector);
        end
    end
end
