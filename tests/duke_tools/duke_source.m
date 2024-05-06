classdef duke_source < source
    %SOUCE_FROMFILE Create a source object from a file

    properties (SetAccess=immutable)
        ebins    (1, :) double % Energy bins
        spectrum (:, :) double % Fluences ne x ny
    end

    methods
        function obj = duke_source(filename, num_energies, num_ypixels, msecs_per_frame)
            obj = obj@source(num_energies);
            
            % Read the file to matrix
            fileID = fopen(filename, 'r');
            spectrum = fread(fileID, 'float32');
            fclose(fileID);
            obj.ebins = linspace(1, num_energies, num_energies);
            obj.spectrum = reshape(spectrum, [num_energies, num_ypixels])'*msecs_per_frame;
        end

        function energies = get_energies(obj, range)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                obj
                range (:,2) double
            end
            num_ranges = size(range,1);
            energies = zeros(1, num_ranges);
            for i = 1:num_ranges
                indices = find(obj.ebins >= range(i,1) & obj.ebins < range(i,2));
                if isempty(indices)
                    error('No energies found in the range [%f, %f)', range(i,1), range(i,2));
                end
                weights = sum(obj.spectrum(:, indices), 1);
                
                % If all weights are zero, set them all to 1, we will not use them anyway
                if sum(weights) == 0; weights = ones(size(weights)); end
                 
                weights = weights / sum(weights);
                energies(i) = sum(obj.ebins(indices) .* weights);
            end
        end

        function fluences = get_fluences(obj, range, ypixels)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                obj
                range   (:, 2) double
                ypixels (1, :) double
            end
            num_ranges = size(range,1);
            num_pixels = length(ypixels);
            
            fluences = zeros(num_pixels, num_ranges);
            spectrum_slice = obj.spectrum(ypixels, :);
            for i = 1:num_ranges
                fluences(:, i) = sum(spectrum_slice(:, obj.ebins >= range(i,1) & obj.ebins < range(i,2)), 2);
            end
        end

        function [emin, emax] = get_nrj_range(obj)
            emin = min(obj.ebins);
            emax = max(obj.ebins);
        end
    end
end
