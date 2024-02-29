classdef ideal_sensor < sensor    
    methods
        function signal = detector_response(self, energy_bin, count_array)
            lower_energy = self.energy_bins(energy_bin);
            upper_energy = self.energy_bins(energy_bin + 1);
            average_energy = (lower_energy + upper_energy) / 2;
            signal = count_array .* average_energy;
        end

        function image = get_image(~, signal)
            % Normalize the intensity array before taking the log 
            % (Should really use I0 for normalisation, but this is a simplification for now.)
            signal = signal ./ max(signal, [], 'all');
            image = -log(signal);
        end
    end
end