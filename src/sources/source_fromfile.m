classdef source_fromfile < source % could create a spectrum super class.
    %SOUCE_FROMFILE Create a source object from a file

    properties (SetAccess=immutable)
        ebins    (:, 1) double % Energy bins
        fluences (:, 1) double % Fluences
    end

    methods
        function obj = source_fromfile(filename)
            % Read the file as a string
            file = fileread(filename);

            %Remove the header
            file = regexprep(file, '#[^\n]*\n', '');

            % Replace the semi-colons with spaces and new lines with semi-colons
            file = regexprep(file, ';', ' ');
            file = regexprep(file, '\n', ';');

            % Add matrix brackets
            file = ['[', file, ']'];

            % Evaluate the string as a matrix
            data = eval(file);

            % Extract the energy, fluence columns
            ebins = data(:,1);
            fluences = data(:,2);

            num_energies = length(ebins);
            
            obj = obj@source(num_energies);
            obj.ebins = ebins;
            obj.fluences = (fluences .* ebins) .* 100^2*units.cm2; % Convert to fluence per cm^2 at 1 cm
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
                weights = obj.fluences(indices);
                
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
            for i = 1:num_ranges
                indices = find(obj.ebins >= range(i,1) & obj.ebins < range(i,2));
                fluences(:, i) = sum(obj.fluences(indices));%.* obj.ebins(indices));
            end
        end

        function [emin, emax] = get_nrj_range(obj)
            emin = min(obj.ebins);
            emax = max(obj.ebins);
        end
    end
end
