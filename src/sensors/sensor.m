classdef (Abstract) sensor

    properties
        num_bins    (1, 1) double
        bin_width   (1, 1) double
        nrj_range   (1, 2) double
        nrj_bins    (1, :) double
        num_samples (1, 1) double
    end

    methods (Abstract) % These need to be implemented by the child class
        signal = detector_response(obj, nrj_bin, count_array)
    end

    methods
        function obj = sensor(nrj_range, num_bins, num_samples)
            arguments
                nrj_range (2, 1) double {mustBeNonnegative}
                num_bins     (1, 1) double {mustBePositive, mustBeInteger}
                num_samples  (1, 1) double {mustBePositive, mustBeInteger} = 1
            end
            obj.nrj_range = nrj_range;
            assert(nrj_range(1) < nrj_range(2), 'sensor:IncorrectEnergyRange', 'Energy range must be increasing');
            
            obj.num_bins = num_bins;
            obj.num_samples = num_samples;
            obj.bin_width = (nrj_range(2) - nrj_range(1)) / (num_bins);
            obj.nrj_bins = nrj_range(1):obj.bin_width:nrj_range(2);
        end

        function range = get_range(obj) % Not sure about the purpose of this function (could it be a property?)
            sub_nrj_bins = linspace(obj.nrj_range(1), obj.nrj_range(2), ...
                obj.num_bins*obj.num_samples+1);
            range = [sub_nrj_bins(1:end-1); sub_nrj_bins(2:end)]';
        end

        function ebin = get_nrj_bin(obj, nrj)
            ebin = floor((nrj - obj.nrj_range(1)) ./ obj.bin_width) + 1;
        end
        
        function signal = get_signal(obj, photon_counts)
            counts_size = size(photon_counts); % Of the form [nrj_bins, y_pix, z_pix, rotation]
            new_size = counts_size(2:4);
            signal = zeros(new_size);
            for i = 1:counts_size(1)
                signal = signal + ...
                    obj.detector_response(i, reshape(photon_counts(i,:,:,:), new_size));
            end
        end

        function image = get_image(~, signal, I0)
            % Normalize the intensity array before taking the log 
            % (Will I want any different behavior?) - Change this to add guassian noise
            signal = signal ./ I0;
            image = -reallog(signal);
        end
   end
end