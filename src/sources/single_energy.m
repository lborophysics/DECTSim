classdef single_energy < source
    %SINGLE_ENERGY A single energy source

    properties (SetAccess=immutable)
        energy (1, 1) double % Energy of the source
    end

    methods
        function obj = single_energy(energy)
            obj = obj@source(1);
            obj.energy = energy;
        end

        function energies = get_energies(obj, range)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                obj
                range (:,2) double
            end
            energies = zeros(1, size(range,1)) + obj.energy; 
        end 
        
        function intensities = get_fluences(obj, range, ypixels)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                obj 
                range   (:, 2) double
                ypixels (1, :) double
            end
            intensities = zeros(1, size(range,1)) + 1e6;
            intensities(obj.energy < range(:,1) | obj.energy >= range(:,2)) = 0;
            num_pixels = length(ypixels);
            intensities = repmat(intensities, num_pixels, 1);
        end 

        function [min, max] = get_nrj_range(obj)
            min = obj.energy-1;
            max = obj.energy+1;
        end
    end

end