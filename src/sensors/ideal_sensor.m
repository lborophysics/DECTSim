classdef ideal_sensor < sensor
    methods
        function self = ideal_sensor(energy_range, num_bins)
            self = self@sensor(energy_range, num_bins);
        end

        function range = get_range(self, bin_index)
            range = [self.energy_bins(bin_index); self.energy_bins(bin_index + 1)];
        end

        function signal = detector_response(self, energy_bin, count_array)
            signal = count_array .* sum(self.get_range(energy_bin), 1)/2;
        end

        function image = get_image(~, signal)
            % Normalize the intensity array before taking the log 
            % (Should really use I0 for normalisation, but this is a simplification for now.)
            signal = signal ./ max(signal, [], 'all');
            image = -log(signal);
        end
    end
end