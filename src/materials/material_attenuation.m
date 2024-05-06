classdef material_attenuation
    %MATERIAL A class to represent a material and its properties necessary
    % for ray tracing and scattering

    properties (SetAccess=immutable)
        name           string % Name of the material
        atomic_numbers (1, :) double % % Atomic numbers of the elements in the material
        mass_fractions (1, :) double % Mass fractions of the elements in the material (sum to 1)
        density        (1, 1) double % Density of the material (g/cm^3)
        mu_from_energy % A function handle to get the linear attenuation coefficient from energy. Only used if use_mex is false
    end

    properties (SetAccess=private)
        atomic_masses (1, :) double % Atomic masses of the elements in the material (g/mol)
    end


    properties (Access=private, Constant, NonCopyable)
        use_mex = ~~exist('photon_attenuation_mex', 'file');
    end

    methods
        function obj = material_attenuation(material_name, varargin)
            %MATERIAL Construct a material object
            %   mat = material("material_name") creates a material object with the properties of the given material, if it is available
            %   
            %   mat = material("material_name", atomic_numbers, mass_fractions, density) creates a material object with the given properties, using the PhotonAttenuation package
            assert(isstring(material_name), 'assert:failure', 'The material name must be a string.');
            obj.name = material_name;
            if nargin == 1
                material_index = find(mat_consts.known_materials == lower(material_name));
                if any(material_index)
                    obj.atomic_numbers = mat_consts.known_atomic_numbers{material_index};
                    obj.mass_fractions = mat_consts.known_mass_fractions{material_index};
                    obj.density = mat_consts.known_densities(material_index);
                else
                    error('MATLAB:invalidMaterial', ...
                        'The material %s is not available. Available materials are: %s', ...
                        material_name, strjoin(mat_consts.known_materials, ', '));
                end
            elseif nargin == 4
                obj.atomic_numbers = varargin{1};
                obj.mass_fractions = varargin{2};
                obj.density = varargin{3};
                assert(length(obj.atomic_numbers) == length(obj.mass_fractions), 'assert:failure', 'The atomic numbers and mass fractions should have the same length.');
                assert(~isnan(obj.density), 'assert:failure', 'The density should be a scalar number.');
                obj.mass_fractions = obj.mass_fractions / sum(obj.mass_fractions);
            else
                error('MATLAB:invalidInput', 'Invalid number of input arguments. Use either material("material_name") or material("material_name", atomic_numbers, mass_fractions, density).');
            end
            obj.density = obj.density * units.g / units.cm^3;
            obj.atomic_masses = mat_consts.atomic_masses(obj.atomic_numbers) .* units.g; % in g/mol (mol handled by cross_section)
            if ~obj.use_mex
                obj.mu_from_energy = get_photon_attenuation(obj.atomic_numbers);
            end
        end

        function mu = get_mu(obj, nrj)
            % GET_MU Get the linear attenuation coefficient of the material for a given energy
            if obj.use_mex
                mu = photon_attenuation_mex(obj.atomic_numbers, obj.mass_fractions, obj.density, nrj);
            else
                mus = obj.mu_from_energy(log(nrj));
                mu = sum(exp(mus).*obj.mass_fractions, 2)' .* obj.density;
            end
        end

        function mfp = mean_free_path(obj, nrjs)
            % MEAN_FREE_PATH Get the mean free path of the material a set of energies
            mfp = 1 ./ (constants.N_A .* obj.density .* ...
                sum(obj.mass_fractions .* cross_section(obj.atomic_numbers, nrjs) ...
                    ./ obj.atomic_masses, 2));
        end
    end

    methods (Static)
        function materials = get_materials(filename)
            % GET_MATERIALS Get the materials from a file, such as an excel file - used for DukeSim robustness
            assert(isfile(filename), 'assert:failure', 'The file %s does not exist.', filename);
            data = readtable(filename);
            
            materials = cell(1, height(data)-1);
            atomic_numbers = data{1, 2:end-2};
            for i = 2:height(data)
                material_name = string(data{i, 1});
                mass_fractions = data{i, 2:end-2};
                density = data{i, end-1};

                zero_fraction = mass_fractions == 0;
                z_numbers = atomic_numbers(~zero_fraction);
                mass_fractions(zero_fraction) = [];

                id = data{i, end};
                materials{id+1} = material_attenuation(material_name, z_numbers, mass_fractions, density);
            end
        end
    end
            
end