classdef duke_sensor < sensor
    properties
        electronicStd
        mean_det_response
        var_det_response
        % total_variance
    end

    methods
        function self = duke_sensor(num_energies, detector_response_file, electronicStd)
            arguments
                num_energies           (1, 1) double {mustBePositive, mustBeInteger}
                detector_response_file (1, 1) string
                electronicStd          (1, 1) double {mustBeNonnegative}
            end
            self = self@sensor([0.5 num_energies+0.5], num_energies, 1);
            self.electronicStd = electronicStd;

            fileID = fopen(detector_response_file, 'r');
            mean_vars = fread(fileID, 'float32');
            fclose(fileID);
            detector_response = reshape(mean_vars, [num_energies, 2]);        
            self.mean_det_response = detector_response(:, 1);
            self.var_det_response  = detector_response(:, 2);
        end

        function signal = detector_response(self, energy_bin, count_array)
            lower_energy = self.energy_bins(energy_bin);
            upper_energy = self.energy_bins(energy_bin + 1);
            signal = count_array .* self.mean_det_response(energy_bin);
                % normrnd(self.mean_det_response(energy_bin), sqrt(self.var_det_response(energy_bin)));
        end

        % function image = get_image(self, signal, I0)
        %     % Is there any way to do this wtihout the statiscal toolbox?
        %     if self.electronicStd^2 + sum(self.var_det_response) > 0
        %         signal = normrnd(signal, self.electronicStd);
        %     end
        %     signal(:, :, 180)
        %     signal = signal ./ I0
        %     image = -reallog(signal);
        % end

    end
end