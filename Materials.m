
%to call class and extract fitted object:
%{

%initialise class:
materials_class = Materials;

%access fit data for desired key
%my_fit = materials_class.fits_map('air')

%get extrapolated attenuation:
E = 0.0079; %[MeV]
attenuation = materials_class.extrapolate_value(E, 'bone')

%get plots 
materials_class.plot_material_parameters('air')

%}

classdef Materials

    %data taken from NIST data tables on 23/02/2024:
    %url: https://physics.nist.gov/PhysRefData/XrayMassCoef/tab4.html

    properties (SetAccess = immutable) % property cant be changed after class creation    
        material  
    end        
    properties (SetAccess = private) % property cna only be accessed inside this class
        fits_map
    end

    methods (Access = public) %methods can be accessed by other function files 

        %import NIST data, create a struct containing data for each material
        function obj = Materials()           
                        
            obj.material = configureDictionary('char', 'struct');

            %read csv files
            folder = "NIST_data\";            
            NIST_air = readtable(folder + 'air');            
            NIST_water = readtable(folder + 'water');
            NIST_bone = readtable(folder + 'bone');
            NIST_polyethylene = readtable(folder + 'polyethylene');
            NIST_acrylic = readtable(folder + 'acrylic');
            
            %assign data to materials in a struct
            obj.material("air") = struct('energy', NIST_air{:,1} , 'attenuation', NIST_air{:,2}); 
            obj.material("water") = struct('energy', NIST_water{:,1} , 'attenuation', NIST_water{:,2});
            obj.material("bone") = struct('energy', NIST_bone{:,1} , 'attenuation', NIST_bone{:,2});
            obj.material("polyethylene") = struct('energy', NIST_polyethylene{:,1} , 'attenuation', NIST_polyethylene{:,2});                   
            obj.material("acrylic") = struct('energy', NIST_acrylic{:,1} , 'attenuation', NIST_acrylic{:,2});

            %get curve fittings: 
            obj.fits_map = containers.Map;
            fit_all_data(obj)
            
        end
        
        function fit_all_data(obj)

            key_set = keys(obj.material);
            for key = 1: size(key_set,1)
                add_fitted_object(obj, key_set{key})
            end

        end

        %fit curves to NIST data. Only run once - parameters are stored.
        function add_fitted_object(obj, name)

            %take NIST data and log it:
            NIST_data = get_NIST_data(obj, name);
            ln_e = log(NIST_data.energy);
            ln_a = log(NIST_data.attenuation);

            %fit type:
            fit_type = "fourier8";

            %generate fit object for data:
            obj.fits_map(name) = fit(ln_e, ln_a, fit_type);

        end
        

        %consider usit get. or set. for this function               
        %get attenuation coeff for input energy and materiasl
        function attenuation_coeff = extrapolate_value(obj, E, name) %user inputted photon energy

            %note:before running this function, the function fit all data
            %needs to be run first. add code to ensure this 
    
            %optimise 

            % Set limits to be maximum and mininum values of the data range
            % provided by NIST so it doesnt get extrapolated. 

            % photon energy limits for this model [MeV]: 
            %note: should this be converted to x-ray tube energy?
            NIST_data = get_NIST_data(obj, name);
            energy = NIST_data.energy;
            
            upper_lim = energy(end); 
            lower_lim = energy(1);
            
            %modify warnign to include correct units and xray values 
            if E<lower_lim || E>upper_lim
                warning(['Extrapolation of X-ray tube voltage.' ...
                    ' The input tube volatage value of (%0.0f kV) may lead to unreliable results as it extrapolates beyond the reasonable values used in the model (%.0f MeV to %.0f MeV).'], E, lower_lim, upper_lim)
            end
            
            ln_input_e = log(E);

            if isKey(obj.material, name)
                
                %load fitting parameters from fitd_map objects
                f = obj.fits_map(name);

                %find ln attenuation for user input energy
                ln_attenuation = f(ln_input_e);

                %convert out of logarithm:
                attenuation_coeff = exp(ln_attenuation); 
            else
                error('Material not found.');
            end
                      
        end        
        
        %access NIST data for chosen material
        function NIST_data = get_NIST_data(obj, name)

            if isKey(obj.material, name)
                NIST_data = obj.material(name);
            else
                error('Material not found.');
            end
        end
        
        %currently does not work - fix it 
        %plot NIST data for a specific material (on a logarithmic scale)
        function plot_material_parameters(obj, name)

            %only runs if fit_maps objects are already defined
            %how i code to ensure this? 

            if isKey(obj.material, name)

                NIST_data = get_NIST_data(obj, name);
                energy = NIST_data.energy;
                attenuation = NIST_data.attenuation;
              
                %plot                
                figure, plot(obj.fits_map(name), log(energy), log(attenuation) ), hold on;
                title(['Attenuation vs Energy for ' name]),
                xlabel('log Photon Energy [MeV]'), ylabel('log Attenuation [cm^2/g]'),
                hold off;   
                

            else
                error('Material not found.');
            end
            

        end
        
        %fix this function 
        function display_info(obj, name)

            NIST_data = get_NIST_data(obj, name);
            energy = NIST_data.energy;
            attenuation = NIST_data.attenuation;

            %fprintf('Material: %s, Photon Energy: %.2f MeV, Attenuatio: %.2f Units', name, energy, attenuation);
            fprintf('Material: %s', name);
            table(energy, attenuation, 'VariableNames', {'Photon Energy [MeV]', 'Attenuation [cm^2/g]'})
            
        end
        
    end
end    