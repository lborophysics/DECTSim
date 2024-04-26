classdef ideal_sensor < sensor    
    methods
        % The following function is an abstract method in the parent class
        % sensor. This is only an object for simplicity for the user. 
        % Also, most of this function could be implemented in the parent class. 
        % The only thing that needs to be implemented in the child class here is 
        % how the energy is multiplied before the count_array, so for an ideal sensor,
        % the energy is multiplied by 1.
        function signal = detector_response(self, energy_bin, count_array)
            lower_energy = self.energy_bins(energy_bin);
            upper_energy = self.energy_bins(energy_bin + 1);
            average_energy = (lower_energy + upper_energy) / 2;
            signal = count_array .* average_energy;
        end
    end
end