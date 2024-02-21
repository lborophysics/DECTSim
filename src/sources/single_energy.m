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
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self
                range (:,2) double
            end
            energies = zeros(1, size(range,1)) + self.energy; 
            intensities = ones(1, size(range,1));
            energies(self.energy < range(:,1) | self.energy >= range(:,2)) = NaN;
            intensities(self.energy < range(:,1) | self.energy >= range(:,2)) = NaN;
        end 
    end

end