classdef (Abstract) sensor

    properties
        num_bins     (1, 1) double
        bin_width    (1, 1) double
        energy_range (1, 2) double
        energy_bins  (1, :) double
        num_samples  (1, 1) double
    end

    methods (Abstract) % These need to be implemented by the child class
        signal = detector_response(self, energy_bin, count_array)
    end

    methods
        function self = sensor(energy_range, num_bins, num_samples)
            arguments
                energy_range (2, 1) double {mustBeNonnegative}
                num_bins     (1, 1) double {mustBePositive, mustBeInteger}
                num_samples  (1, 1) double {mustBePositive, mustBeInteger} = 1;
            end
            self.energy_range = energy_range;
            assert(energy_range(1) < energy_range(2), 'sensor:IncorrectEnergyRange', 'Energy range must be increasing');
            
            self.num_bins = num_bins;
            self.num_samples = num_samples;
            self.bin_width = (energy_range(2) - energy_range(1)) / (num_bins);
            self.energy_bins = energy_range(1):self.bin_width:energy_range(2);
        end

        function range = get_range(self) % Not sure about the purpose of this function (could it be a property?)
            sub_energy_bins = linspace(self.energy_range(1), self.energy_range(2), ...
                self.num_bins*self.num_samples+1);
            range = [sub_energy_bins(1:end-1); sub_energy_bins(2:end)]';
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
    
    methods (Static)
        function image = get_image(signal, I0)
            % Normalize the intensity array before taking the log 
            % (Will I want any different behavior?) - Change this to add guassian noise
            signal = signal ./ I0;
            image = -reallog(signal);
        end
   end
end