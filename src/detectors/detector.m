classdef detector
    % DETECTOR is a class that represents a detector in a CT system.
    % It is composed of a gantry, a detector array and a sensor unit.
    % The detector is simply a container for these objects and allows for 
    % the validation of the input objects.

    properties(SetAccess=private)
        gantry
        detector_array
        sensor
    end

    methods
        function self = detector(the_gantry, detector_array, sensor)
            assert(isa(the_gantry, 'gantry'), 'gantry must be a gantry object');
            assert(isa(detector_array, 'detector_array'), 'detector_array must be a detector_array object');
            assert(isa(sensor, 'sensor'), 'sensor must be a sensor object');
            self.gantry = the_gantry;
            self.detector_array = detector_array;
            self.sensor = sensor;
        end
    end
end