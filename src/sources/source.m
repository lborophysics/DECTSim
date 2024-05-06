classdef (Abstract) source
    %SOURCE Abstract class for a source of xrays

    properties (SetAccess=immutable)
        num_energies (1, 1) double
    end

    methods (Abstract)
        % Using the non-inclusive range [min, max)
        energies = get_energies(obj, range)
        intensities = get_fluences(obj, range, ypixels)
        [emin, emax] = get_nrj_range(obj)
    end

    methods
        function obj = source(num_energies)
            arguments
                num_energies (1, 1) double {mustBePositive, mustBeInteger}
            end
            obj.num_energies = num_energies;
        end
    end
end