classdef duke_sensor < sensor
    properties
        electronic_std    (1, 1) double {mustBeNonnegative} = 0 % Not used in the current implementation
        mean_det_response (:, 1) double
        var_det_response  (:, 1) double
        % total_variance
    end

    methods
        function obj = duke_sensor(num_energies, detector_response_file, electronic_std)
            arguments
                num_energies           (1, 1) double {mustBePositive, mustBeInteger}
                detector_response_file (1, 1) string
                electronic_std         (1, 1) double {mustBeNonnegative}
            end
            obj = obj@sensor([0.5 num_energies+0.5], num_energies, 1);
            obj.electronic_std = electronic_std;

            fileID = fopen(detector_response_file, 'r');
            mean_vars = fread(fileID, 'float32');
            fclose(fileID);
            detector_response = reshape(mean_vars, [num_energies, 2]);        
            obj.mean_det_response = detector_response(:, 1);
            obj.var_det_response  = detector_response(:, 2);
        end

        function signal = detector_response(obj, nrj_bin, count_array)
            % lower_nrj = obj.nrj_bins(nrj_bin);
            % upper_nrj = obj.nrj_bins(nrj_bin + 1);
            signal = count_array .* obj.mean_det_response(nrj_bin);
                % normrnd(obj.mean_det_response(nrj_bin), sqrt(obj.var_det_response(nrj_bin)));
        end

        % function image = get_image(obj, signal, I0)
        %     % Is there any way to do this wtihout the statiscal toolbox?
        %     if obj.electronic_std^2 + sum(obj.var_det_response) > 0
        %         signal = normrnd(signal, obj.electronic_std);
        %     end
        %     signal(:, :, 180)
        %     signal = signal ./ I0
        %     image = -reallog(signal);
        % end

    end
end