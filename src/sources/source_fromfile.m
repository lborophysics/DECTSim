classdef source_fromfile < source
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
            self.fluences = fluences;
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
                energies(i) = mean(self.ebins(indices));
            end
        end

        function intensities = get_fluences(self, range)
            % range is a Nx2-element vector with N rows of [min_energy, max_energy) 
            arguments
                self
                range (:,2) double
            end
            num_ranges = size(range,1);
            flist = zeros(1, num_ranges);
            for i = 1:num_ranges
                indices = find(self.ebins >= range(i,1) & self.ebins < range(i,2));
                flist(i) = sum(self.fluences(indices).* self.ebins(indices));
            end
            intensities = flist .* 1e4; % Make fluence from source (by default, the fluence is at 100 cm)
        end
    end
end
