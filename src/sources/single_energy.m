classdef single_energy < source
    %SINGLE_ENERGY A single energy source

    properties (SetAccess=immutable)
        energy
    end

    methods
        function self = single_energy(energy)
            self = self@source(1);
            self.energy = energy;
        end

        function [energies, intensities] = get_energies(self, range)
            % range is a 2-element vector [min_energy, max_energy)
            if self.energy < range(1) || self.energy >= range(2)
                intensities = []; energies = [];
            else
                intensities = 1 ; energies = self.energy;
            end
        end 
    end

end