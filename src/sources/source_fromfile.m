classdef source_fromfile < source % could create a spectrum super class.
    %SOUCE_FROMFILE Create a source object from a file

    properties (SetAccess=immutable)
        ebins
        fluences
    end

    methods
        function self = source_fromfile(filename)
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
            
            self = self@source(num_energies);
            self.ebins = ebins;
            self.fluences = (fluences .* ebins) .* 100^2*units.cm2; % Convert to fluence per cm^2 at 1 cm
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
                weights = self.fluences(indices);
                
                % If all weights are zero, set them all to 1, we will not use them anyway
                if sum(weights) == 0; weights = ones(size(weights)); end
                 
                weights = weights / sum(weights);
                energies(i) = sum(self.ebins(indices) .* weights);
            end
        end

        function fluences = get_fluences(self, range, ~)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self
                range (:,2) double
                ~ % We do not use the ypixel argument
            end
            num_ranges = size(range,1);
            fluences = zeros(1, num_ranges);
            for i = 1:num_ranges
                indices = find(self.ebins >= range(i,1) & self.ebins < range(i,2));
                fluences(i) = sum(self.fluences(indices));%.* self.ebins(indices));
            end
        end

        function [emin, emax] = get_energy_range(self)
            emin = min(self.ebins);
            emax = max(self.ebins);
        end
    end
end
