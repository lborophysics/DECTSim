classdef detector
    % DETECTOR is a class that represents a detector in a CT system.
    % It is composed of a gantry, a detector array and a sensor unit.
    % The detector is simply a container for these objects and allows for 
    % the validation of the input objects.

    properties(SetAccess=private)
        the_gantry 
        the_array  
        the_sensor 
    end

    methods
        function obj = detector(the_gantry, the_array, the_sensor)
            assert(isa(the_gantry, 'gantry'), 'gantry must be a gantry object');
            assert(isa(the_array, 'detector_array'), 'detector_array must be a detector_array object');
            assert(isa(the_sensor, 'sensor'), 'sensor must be a sensor object');
            obj.the_gantry = the_gantry;
            obj.the_array  = the_array ;
            obj.the_sensor = the_sensor;
        end
    end
end