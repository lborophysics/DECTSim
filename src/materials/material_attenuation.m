classdef get_material
    %MATERIAL A class to represent a material and its properties necessary
    % for ray tracing and scattering

    properties
        get_mu % Function handle to get the linear attenuation coefficient of the material for a given energy
        id     % Unique identifier of the material, generated from the material name
    end

    properties (Access=protected)
        atomic_numbers % Atomic numbers of the elements in the material
        mass_fractions % Mass fractions of the elements in the material
        density        % Density of the material in g/cm^3
    end

    properties (Access=private, Constant)
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
            85.468, 87.62, 88.906, 91.224, 92.906, 95.95, 101.07, 102.91, 106.42,...
            107.87, 112.41, 114.82, 118.71, 121.76, 127.60, 126.90, 131.29, 132.9
            ]; % g/mol up to atomic number 55. Source: 
        % Prohaska, Thomas, Irrgeher, Johanna, Benefield, Jacqueline, Böhlke, John K.,
        % Chesson, Lesley A., Coplen, Tyler B., Ding, Tiping, Dunn, Philip J. H.,
        % Gröning, Manfred, Holden, Norman E., Meijer, Harro A. J., Moossen, Heiko,
        % Possolo, Antonio, Takahashi, Yoshio, Vogl, Jochen, Walczyk, Thomas,
        % Wang, Jun, Wieser, Michael E., Yoneda, Shigekazu, Zhu, Xiang-Kun and Meija, Juris.
        % "Standard atomic weights of the elements 2021 (IUPAC Technical Report)"
        % Pure and Applied Chemistry, vol. 94, no. 5, 2022, pp. 573-600.
        % https://doi.org/10.1515/pac-2019-0603
    end

    methods
        function self = get_material(material_name, varargin)
            %MATERIAL Construct a material object
            %   material("material_name") creates a material object with the properties of the given material, if it is available
            %   material("material_name", atomic_numbers, mass_fractions, density) creates a material object with the given properties, using the PhotonAttenuation package
            assert(isstring(material_name), 'assert:failure', 'The material name must be a string.');
            if nargin == 1
                material_index = find(self.known_materials == lower(material_name));
                if any(material_index)
                    self.atomic_numbers = self.known_atomic_numbers{material_index};
                    self.mass_fractions = self.known_mass_fractions{material_index};
                    self.density = self.known_densitys(material_index);
                else
                    error('MATLAB:invalidMaterial', ...
                        'The material %s is not available. Available materials are: %s', ...
                        material_name, strjoin(self.known_materials, ', '));
                end
            elseif nargin == 4
                self.atomic_numbers = varargin{1};
                self.mass_fractions = varargin{2};
                self.density = varargin{3};
                assert(isvector(self.atomic_numbers), 'assert:failure', 'The atomic numbers should be a vector.');
                assert(isvector(self.mass_fractions), 'assert:failure', 'The mass fractions should be a vector.');
                assert(length(self.atomic_numbers) == length(self.mass_fractions), 'assert:failure', 'The atomic numbers and mass fractions should have the same length.');
                assert(isnumeric(self.density) && isscalar(self.density), 'assert:failure', 'The density should be a scalar number.');
                self.mass_fractions = self.mass_fractions / sum(self.mass_fractions);
            else
                error('MATLAB:invalidInput', 'Invalid number of input arguments. Use either material("material_name") or material("material_name", atomic_numbers, mass_fractions, density).');
            end
            % Create a unique identifier for the material (spend time in creating this, but save time in the future by not having to compare strings)
            alphabet = 'abcdefghijklmnopqrstuvwxyz'; Map(alphabet) = 1:length(alphabet);
            self.id = bin2dec(convertCharsToStrings(dec2bin(Map(convertStringsToChars(lower(material_name))))));

            % Set the function handle to get the linear attenuation coefficient
            self.get_mu = photon_attenuation(self.atomic_numbers, self.mass_fractions, self.density); %Convert energy from MeV to KeV
        end

        function mfp = get_mean_free_path(self, E)
            % GET_MEAN_FREE_PATH Get the mean free path of the material for a given energy
            imfp = 0;
            for i = 1:length(self.atomic_numbers)
                imfp = imfp + ...
                    (constants.avogadro_number * self.density * self.mass_fractions(i) ...
                    * get_material.get_cross_section(self.atomic_numbers(i), E) ...
                    / self.atomic_masses(self.atomic_numbers(i)));
            end
            mfp = 1 / imfp; % cm
        end
    end

    methods (Static, Access=private)
        function cs = get_cross_section(Z, E)
            %GET_CROSS_SECTION Get the cross section of the material for a given energy (CREDIT: Geant4)
            % The values, formulae and code is taken directly from
            % https://github.com/Geant4/geant4/blob/master/source/processes/electromagnetic/standard/src/G4KleinNishinaCompton.cc
            if E < 0.1; cs = 0; return; end % Below 100 eV, we are beyond the limit of the cross section table -> 0
            % See https://geant4-userdoc.web.cern.ch/UsersGuides/PhysicsReferenceManual/html/electromagnetic/gamma_incident/compton/compton.html

            a = 20.0; b = 230.0; c = 440.0; % Unitless
            d1= 2.7965e-25; d2=-1.8300e-25; % cm^2 (e-24 for the barn)
            d3= 6.7527e-24; d4=-1.9798e-23; % cm^2 (e-24 for the barn)
            e1= 1.9756e-29; e2=-1.0205e-26; % cm^2 (e-24 for the barn)
            e3=-7.3913e-26; e4= 2.7079e-26; % cm^2 (e-24 for the barn)
            f1=-3.9178e-31; f2= 6.8241e-29; % cm^2 (e-24 for the barn)
            f3= 6.0480e-29; f4= 3.0274e-28; % cm^2 (e-24 for the barn)
            if Z < 1.5; T0 = 40; % Special case for hydrogen (KeV)
            else;       T0 = 15; % KeV
            end

            X = max(E, T0) / constants.em_ee; % Unitless
            p1Z = Z*(d1 + e1*Z + f1*Z*Z); p2Z = Z*(d2 + e2*Z + f2*Z*Z); % cm^2
            p3Z = Z*(d3 + e3*Z + f3*Z*Z); p4Z = Z*(d4 + e4*Z + f4*Z*Z); % cm^2

            cs = p1Z*log(1.+2.*X)/X + (p2Z + p3Z*X + p4Z*X*X)/(1. + a*X + b*X*X + c*X*X*X); % cm^2

            if E < T0
                X = (T0+1) / constants.em_ee; % Unitless
                sigma = p1Z*log(1.+2.*X)/X + (p2Z + p3Z*X + p4Z*X*X)/(1. + a*X + b*X*X + c*X*X*X); % cm^2
                c1 = -T0*(sigma-cs)/cs; % Unitless
                if Z > 1.5; c2 = 0.375-0.0556*log(Z); %Unitless
                else;       c2 = 0.150;               %Unitless
                end
                y = log(E/T0); % Unitless
                cs = cs * exp(-y*(c1+c2*y)); % cm^2
            end
        end
    end
end