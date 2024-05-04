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

        function energies = get_energies(self, range)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self
                range (:,2) double
            end
            energies = zeros(1, size(range,1)) + self.energy; 
        end 
        
        function intensities = get_fluences(self, range, ypixels)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self 
                range   (:, 2) double
                ypixels (1, :) double
            end
            intensities = zeros(1, size(range,1)) + 1e6;
            intensities(self.energy < range(:,1) | self.energy >= range(:,2)) = 0;
            num_pixels = length(ypixels);
            intensities = repmat(intensities, num_pixels, 1);
        end 

        function [min, max] = get_energy_range(self)
            min = self.energy-1;
            max = self.energy+1;
        end
    end

end