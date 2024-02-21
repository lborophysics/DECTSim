classdef ideal_sensor < sensor    
    methods
        function self = ideal_sensor(energy_range, num_bins, num_samples)
            assert(nargin > 1, 'MATLAB:invalid_argument', 'Not enough arguments, need at least energy_range and num_bins')
            if nargin < 3; num_samples = 1; end
            self = self@sensor(energy_range, num_bins, num_samples);
        end

        function signal = detector_response(self, energy_bin, count_array)
            lower_energy = self.energy_bins(energy_bin);
            upper_energy = self.energy_bins(energy_bin + 1);
            average_energy = (lower_energy + upper_energy) / 2;
            signal = count_array .* average_energy;
        end

        function [energies, intensities] = sample_source(self, xray_source)
            arguments
                self ; xray_source source
            end
            sub_energy_bins = linspace(self.energy_range(1), self.energy_range(2), ...
                self.num_bins*self.num_samples+1);
            range = [sub_energy_bins(1:end-1); sub_energy_bins(2:end)]';
            [energies, intensities] = xray_source.get_energies(range);

            energies = reshape(energies, self.num_bins, self.num_samples);
            intensities = reshape(intensities, self.num_bins, self.num_samples);
        end

        function image = get_image(~, signal)
            % Normalize the intensity array before taking the log 
            % (Should really use I0 for normalisation, but this is a simplification for now.)
            signal = signal ./ max(signal, [], 'all');
            image = -log(signal);
        end
    end
end