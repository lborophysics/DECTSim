classdef detector
    % DETECTOR is a class that represents a detector in a CT system.
    % It is composed of a gantry, a detector array and a sensor unit.
    % The detector is simply a container for these objects and allows for 
    % the validation of the input objects.

    properties(SetAccess=private)
        gantry
        detector_array
        sensor_unit
    end

    methods
        function self = detector(gantry, detector_array, sensor_unit)
            assert(isa(gantry, 'gantry'), 'gantry must be a gantry object');
            assert(isa(detector_array, 'detector_array'), 'detector_array must be a detector_array object');
            assert(isa(sensor_unit, 'sensor'), 'sensor_unit must be a sensor_unit object');
            self.gantry = gantry;
            self.detector_array = detector_array;
            self.sensor_unit = sensor_unit;
        end
    end
end