classdef material_attenuation
    %MATERIAL A class to represent a material and its properties necessary
    % for ray tracing and scattering

    properties (Access=private)
        atomic_numbers % Atomic numbers of the elements in the material
        mass_fractions % Mass fractions of the elements in the material
        density        % Density of the material in g/cm^3
        mu_from_energy % A function handle to get the linear attenuation coefficient from energy. Only used if use_mex is false
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

    methods
        function self = material_attenuation(material_name, varargin)
            %MATERIAL Construct a material object
            %   mat = material("material_name") creates a material object with the properties of the given material, if it is available
            %   
            %   mat = material("material_name", atomic_numbers, mass_fractions, density) creates a material object with the given properties, using the PhotonAttenuation package
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
            if ~exist('photon_attenuation_mex', 'file')
                self.mu_from_energy = photon_attenuation(self.atomic_numbers);
            else
                self.mu_from_energy = photon_attenuation_mex(self.atomic_numbers);
            end
        end

        function mu = get_mu(self, energy)
            % GET_MU Get the linear attenuation coefficient of the material for a given energy
            mus = self.mu_from_energy(log(energy));
            mu = sum(exp(mus).*self.mass_fractions) * self.density;
        end

        function mfp = mean_free_path(self, E)
            % MEAN_FREE_PATH Get the mean free path of the material for a given energy
            mfp = 1 / (constants.N_A * self.density * ...
                sum(self.mass_fractions .* cross_section(self.atomic_numbers, E) ...
                    ./ self.atomic_masses(self.atomic_numbers)));
        end
    end
end