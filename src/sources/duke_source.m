classdef duke_source < source
    %SOUCE_FROMFILE Create a source object from a file

    properties (SetAccess=immutable)
        ebins
        spectrum
    end

    methods
        function self = duke_source(filename, num_energies, num_ypixels, msecs_per_frame)
            self = self@source(num_energies);
            
            % Read the file to matrix
            fileID = fopen(filename, 'r');
            spectrum = fread(fileID, 'float32');
            fclose(fileID);
            self.ebins = linspace(1, num_energies, num_energies);
            % self.spectrum = reshape(spectrum, [num_ypixels, num_energies]);
            self.spectrum = reshape(spectrum, [num_energies, num_ypixels])'*msecs_per_frame;
        end

        function energies = get_energies(self, range)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self
                range (:,2) double
            end
            num_ranges = size(range,1);
            energies = zeros(1, num_ranges);
            for i = 1:num_ranges
                indices = find(self.ebins >= range(i,1) & self.ebins < range(i,2));
                if isempty(indices)
                    error('No energies found in the range [%f, %f)', range(i,1), range(i,2));
                end
                weights = sum(self.spectrum(:, indices), 1);
                
                % If all weights are zero, set them all to 1, we will not use them anyway
                if sum(weights) == 0; weights = ones(size(weights)); end
                 
                weights = weights / sum(weights);
                energies(i) = sum(self.ebins(indices) .* weights);
            end
        end

        function fluences = get_fluences(self, range, ypixels)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self
                range   (:, 2) double
                ypixels (1, :) double
            end
            num_ranges = size(range,1);
            num_pixels = length(ypixels);
            
            fluences = zeros(num_pixels, num_ranges);
            spectrum_slice = self.spectrum(ypixels, :);
            for i = 1:num_ranges
                fluences(:, i) = sum(spectrum_slice(:, self.ebins >= range(i,1) & self.ebins < range(i,2)));
            end
        end

        function [emin, emax] = get_energy_range(self)
            emin = min(self.ebins);
            emax = max(self.ebins);
        end
    end
end
