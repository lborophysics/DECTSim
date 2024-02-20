classdef (Abstract) sensor

    properties
        num_bins     (1, 1) double
        bin_width    (1, 1) double
        energy_range (1, 2) double
        energy_bins  (:, 1) double
    end

    methods (Abstract) % These need to be implemented by the child class
        range = get_range(self, bin_index)
        signal = detector_response(self, energy_bin, count_array)
        image = get_image(self, signal) 
    end

    methods
        function self = sensor(energy_range, num_bins)
            self.energy_range = energy_range;
            assert(energy_range(1) < energy_range(2), 'Energy range must be increasing');
            
            self.num_bins = num_bins;
            assert(num_bins > 0 && mod(num_bins, 1) == 0, 'Number of bins must be a positive integer');
            
            self.bin_width = (energy_range(2) - energy_range(1)) / (num_bins);
            self.energy_bins = energy_range(1):self.bin_width:energy_range(2);
        end

        function ebin = get_energy_bin(self, energy)
            ebin = floor((energy - self.energy_range(1)) ./ self.bin_width) + 1;
        end
        
        function signal = get_signal(self, array)
            array_size = size(array); % Of the form [energy_bins, y_pix, z_pix, rotation]
            new_size = array_size(2:4);
            signal = zeros(new_size);
            for i = 1:array_size(1)
                signal = signal + ...
                    self.detector_response(i, reshape(array(i,:,:,:), new_size));
            end
        end
   end
end