classdef material
    properties
        mu
    end
    
    methods
        function obj = material(attenuation_coefficient)
            obj.mu = attenuation_coefficient;
        end
    end
end
