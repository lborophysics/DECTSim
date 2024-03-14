classdef (Abstract) source
    %SOURCE Abstract class for a source of xrays

    properties (SetAccess=immutable)
        num_energies
    end

    methods (Abstract)
        % Using the non-inclusive range [min, max)
        energies = get_energies(self, range)
        intensities = get_fluences(self, range)
        [emin, emax] = get_energy_range(self)
    end

    methods
        function self = source(num_energies)
            self.num_energies = num_energies;
        end
    end
end