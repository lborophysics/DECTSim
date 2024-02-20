classdef (Abstract) source
    %SOURCE Abstract class for a source of xrays

    properties (SetAccess=immutable)
        num_energies
    end

    methods (Abstract)
        [energies, intensities] = get_energies(self, range) % Using the non-inclusive range [min, max)
    end

    methods
        function self = source(num_energies)
            self.num_energies = num_energies;
        end
    end
end