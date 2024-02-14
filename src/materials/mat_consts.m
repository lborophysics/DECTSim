classdef mat_consts
    %MATERIAL_CONSTANTS A class to store material constants used in 
    % material_attenuation so that these arrays are not copied every time
    % material_attenuation is called.
    properties (Constant)
        % Add new materials to the list alphabetically, this will allow the
        % material_attenuation class to "know" about the new material.
        known_materials = {'air'    ,'blood','bone','fat','lung','muscle','titanium','water'};
        known_densitys  = [1.205E-03, 1.06  , 1.92 , 0.95, 1.05 , 1.05   , 4.506    , 1.00  ];
        known_atomic_numbers = {...
            [6, 7, 8, 18],...                         % air
            [1, 6, 7, 8, 11, 15, 16, 17, 19, 26],...  % blood
            [1, 6, 7, 8, 11, 12, 15, 16, 20],...      % bone
            [1, 6, 7, 8, 11, 16, 17],...              % fat
            [1, 6, 7, 8, 11, 15, 16, 17, 19],...      % lung
            [1, 6, 7, 8, 11, 15, 16, 17, 19],...      % muscle
            22,...                                    % titanium
            [1, 8],...                                % water         
            };
        known_mass_fractions = {...
            [0.000124, 0.755268, 0.231781, 0.012827],...                              % air
            [0.102, 0.110, 0.033, 0.745, 0.001, 0.001, 0.002, 0.003, 0.002, 0.001],...% blood
            [0.034, 0.155, 0.042, 0.435, 0.001, 0.002, 0.103, 0.003, 0.225],...       % bone
            [0.114, 0.598, 0.007, 0.278, 0.001, 0.001, 0.001],...                     % fat
            [0.103, 0.105, 0.031, 0.749, 0.002, 0.002, 0.003, 0.003, 0.002],...       % lung
            [0.102, 0.143, 0.034, 0.710, 0.001, 0.002, 0.003, 0.001, 0.004],...       % muscle
            1.0,...                                                                   % titanium
            [0.111898, 0.888102],...                                                  % water
            };
        atomic_masses = [
            1.0080, 4.0026, 6.94, 9.0122, 10.81, 12.011, 14.007, 15.999, 18.998,...
            20.180, 22.990, 24.305, 26.982, 28.085, 30.974, 32.06, 35.45, 39.95,...
            39.098, 40.078, 44.956, 47.867, 50.942, 51.996, 54.938, 55.845, 58.933,...
            58.693, 63.546, 65.38, 69.723, 72.630, 74.922, 78.971, 79.904, 83.798,...
            85.468, 87.62, 88.906, 91.224, 92.906, 95.95, 97, 101.07, 102.91, 106.42,...
            107.87, 112.41, 114.82, 118.71, 121.76, 127.60, 126.90, 131.29, 132.9,...
            137.33, 138.91, 140.12, 140.91, 144.24, 145.0, 150.36, 151.96, 157.25,...
            158.93, 162.50, 164.93, 167.26, 168.93, 173.05, 174.97, 178.49, 180.95,...
            183.84, 186.21, 190.23, 192.22, 195.08, 196.97, 200.59, 204.38, 207.2,...
            ]; % g/mol up to atomic number 82 (Lead) Source: 
        % Prohaska, Thomas, Irrgeher, Johanna, Benefield, Jacqueline, Böhlke, John K.,
        % Chesson, Lesley A., Coplen, Tyler B., Ding, Tiping, Dunn, Philip J. H.,
        % Gröning, Manfred, Holden, Norman E., Meijer, Harro A. J., Moossen, Heiko,
        % Possolo, Antonio, Takahashi, Yoshio, Vogl, Jochen, Walczyk, Thomas,
        % Wang, Jun, Wieser, Michael E., Yoneda, Shigekazu, Zhu, Xiang-Kun and Meija, Juris.
        % "Standard atomic weights of the elements 2021 (IUPAC Technical Report)"
        % Pure and Applied Chemistry, vol. 94, no. 5, 2022, pp. 573-600.
        % https://doi.org/10.1515/pac-2019-0603
    end
end