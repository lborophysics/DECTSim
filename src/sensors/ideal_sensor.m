classdef ideal_sensor < sensor    
    methods
        function signal = detector_response(self, energy_bin, count_array)
            lower_energy = self.energy_bins(energy_bin);
            upper_energy = self.energy_bins(energy_bin + 1);
            average_energy = (lower_energy + upper_energy) / 2;
            signal = count_array .* average_energy;
        end
    end
end