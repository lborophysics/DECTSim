function the_source = get_duke_source(path_to_duke_out)
    % Needs Spectrum_Duke1_120kV_900_1mAs_1ms_calibrated.bin - Taken from the folder when given DukeSim
    [~, params] = dukesim_parser(path_to_duke_out);
    
    num_energies = str2double(params("NumberOfEnergies"));
    ny_pixels = str2double(params("scanner_Y_pixels"));
    msecs_per_frame = str2double(params("msecs_per_revolution")) / str2double(params("P"));
    the_source = duke_source("Spectrum_Duke1_120kV_900_1mAs_1ms_calibrated.bin", num_energies, ny_pixels, msecs_per_frame);
end