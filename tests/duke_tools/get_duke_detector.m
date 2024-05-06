function the_detector = get_duke_detector(path_to_duke_out)
    % Needs DetResponse_Duke1_120kV_final.bin - Taken from the folder when given DukeSim
    [~, params] = dukesim_parser(path_to_duke_out);

    dist_to_detector = str2double(params("SID")) * units.mm;
    ypix_size = str2double(params("scanner_Y_pixel_size")) * units.mm;
    ny_pixels = str2double(params("scanner_Y_pixels"));
    zpix_size = str2double(params("scanner_Z_pixel_size")) * units.mm;
    nz_pixels = str2double(params("scanner_Z_pixels"));
    num_rotations = str2double(params("P"));
    num_energies = str2double(params("NumberOfEnergies"));
    electronicStd = str2double(params("ElectronicStd"));

    g = gantry(dist_to_detector, num_rotations, 2*pi);
    if params("detector_shape") == "cylinder"
        a = curved_detector([ypix_size, zpix_size], [ny_pixels, nz_pixels]);
    else
        a = flat_detector([ypix_size, zpix_size], [ny_pixels, nz_pixels]);
    end
    s = duke_sensor(num_energies, "DetResponse_Duke1_120kV_final.bin", electronicStd);
    the_detector = detector(g, a, s);
end