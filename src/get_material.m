classdef material
    %MATERIAL A class to represent a material and its properties necessary 
    % for ray tracing and scattering
    
    properties
        atomic_numbers
        mass_fractions
        get_mu
        density
    end

    properties (Access=private)
        known_materials = {'air','blood','bone','lung','muscle','water'};
        known_densitys = [1.205E-03, 1.06, 1.92, 1.05, 1.05, 1.00];
        known_atomic_numbers = {...
            [6, 7, 8, 18],...
            [1, 6, 7, 8, 11, 15, 16, 17, 19, 26],...
            [1, 6, 7, 8, 11, 12, 15, 16, 20],...
            [1, 6, 7, 8, 11, 15, 16, 17, 19],...
            [1, 6, 7, 8, 11, 15, 16, 17, 19],...
            [1, 8],...
        };
        known_mass_fractions = {...
            [0.000124, 0.755268, 0.231781, 0.012827],...
            [0.102, 0.110, 0.033, 0.745, 0.001, 0.001, 0.002, 0.003, 0.002, 0.001],...
            [0.034, 0.155, 0.042, 0.435, 0.001, 0.002, 0.103, 0.003, 0.225],...
            [0.103, 0.105, 0.031, 0.749, 0.002, 0.002, 0.003, 0.003, 0.002],...
            [0.102, 0.143, 0.034, 0.710, 0.001, 0.002, 0.003, 0.001, 0.004],...
            [0.111898, 0.888102],...
        };
        atomic_masses = [
            1.0080, 4.0026, 6.94, 9.0122, 10.81, 12.011, 14.007, 15.999, 18.998,...
            20.180, 22.990, 24.305, 26.982, 28.085, 30.974, 32.06, 35.45, 39.95,...
            39.098, 40.078, 44.956, 47.867, 50.942, 51.996, 54.938, 55.845, 58.933,...
            58.693, 63.546, 65.38, 69.723, 72.630, 74.922, 78.971, 79.904, 83.798,...
            85.468, 87.62, 88.906, 91.224, 92.906, 95.95
            ]; % g/mol Source: 
            % Prohaska, Thomas, Irrgeher, Johanna, Benefield, Jacqueline, Böhlke, John K.,
            % Chesson, Lesley A., Coplen, Tyler B., Ding, Tiping, Dunn, Philip J. H., 
            % Gröning, Manfred, Holden, Norman E., Meijer, Harro A. J., Moossen, Heiko, 
            % Possolo, Antonio, Takahashi, Yoshio, Vogl, Jochen, Walczyk, Thomas, 
            % Wang, Jun, Wieser, Michael E., Yoneda, Shigekazu, Zhu, Xiang-Kun and Meija, Juris.
            % "Standard atomic weights of the elements 2021 (IUPAC Technical Report)" 
            % Pure and Applied Chemistry, vol. 94, no. 5, 2022, pp. 573-600. 
            % https://doi.org/10.1515/pac-2019-0603
        avogadro_number = 6.02214076 * 10^23; % atoms/mol, Source: https://pml.nist.gov/cgi-bin/cuu/Value?na
    end

    methods
        function self = material(varargin)
            %MATERIAL Construct a material object
            %   material("material_name") creates a material object with the properties of the given material, if it is available
            %   material(atomic_numbers, mass_fractions, density) creates a material object with the given properties, using the PhotonAttenuation package
            if nargin < 1
                aac = matlab.lang.correction.AppendArgumentsCorrection('"blood"');
                error(aac, 'MATLAB:notEnoughInputs', 'Not enough input arguments.') 
            elseif nargin == 1
                material_name = varargin{1};
                assert(isstring(material_name), 'When only one input is given, it should be a string with the name of the material');
                material_index = find(self.known_materials == lower(material_name));
                if any(material_index)
                    self.atomic_numbers = self.known_atomic_numbers{material_index};
                    self.mass_fractions = self.known_mass_fractions{material_index};
                    self.density = self.known_densitys(material_index);
                else
                    aac = matlab.lang.correction.AppendArgumentsCorrection('"blood"');
                    list_available_materials = strjoin(self.known_materials, ', ');
                    error(aac, 'MATLAB:invalidMaterial', ...
                        'The material %s is not available. Available materials are: %s', ...
                        material_name, list_available_materials);
                end
            elseif nargin == 3
                self.atomic_numbers = varargin{1};
                self.mass_fractions = varargin{2};
                self.mass_fractions = self.mass_fractions / sum(self.mass_fractions); 
                self.density = varargin{3};
                assert(isnumeric(self.density) && isscalar(self.density), 'The density should be a scalar number');
                assert(isvector(self.atomic_numbers), 'The atomic numbers should be a vector');
                assert(isvector(self.mass_fractions), 'The mass fractions should be a vector');
                assert(length(self.atomic_numbers) == length(self.mass_fractions), 'The atomic numbers and mass fractions should have the same length');
            else
                error('MATLAB:invalidInput', 'Invalid number of input arguments');
            end
            self.get_mu = @(E) sum(PhotonAttenuationQ(self.atomic_numbers, E, 1) .* self.mass_fractions) * self.density;
        end
    end
end
