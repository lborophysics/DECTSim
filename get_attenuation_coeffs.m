function [attenuation_coeffs] = get_attenuation_coeffs(varargin) 
   
    %if inputting xray energy E, this must be the first imput argument
    %then list all materials for which coefficient is desired
    
    %covert input strings to character type
    args = matlab.images.internal.stringToChar(varargin);    

    %verify compatability of varagin type
    if numel(varargin{1})==1 
        E = varargin{1};
        m = 2;
        attenuation_coeffs = zeros(nargin-1, 1);
    else 
        m = 1;
        E = 0.008; %kV (setting default xray energy if none is entered by user)
        attenuation_coeffs = zeros(nargin, 1);
    end
   
    name = {'air', 'water', 'bone', 'fat', 'muscle', 'polyethylene', 'acrylic', 'titanium'};
    
    for i=m:nargin
        if ischar(args{i})         
            def = lower(args{i}); %make varargin lower case
            L = strlength(def);
            idx = strncmp(def, name,L);
            switch name{idx}
                case "air"
                    coeff = coeff_air(E);
                    attenuation_coeffs(i - m + 1) = coeff;
                    
                case "water"
                    coeff = coeff_water(E);
                    attenuation_coeffs(i - m + 1) = coeff;
                    
                case "bone"
                    coeff = coeff_bone(E);                    
                    attenuation_coeffs(i - m + 1) = coeff;
                    
                case "fat"
                    coeff = coeff_fat(E);
                    disp(coeff)
                    
                case "muscle"
                    coeff = coeff_muscle(E);
                    disp(coeff)
                    
                case "polyethylene"                    
                    coeff = coeff_polyethylene(E);                    
                    attenuation_coeffs(i - m + 1) = coeff;
            
                case "acrylic"
                    coeff = coeff_acrylic(E);               
                    attenuation_coeffs(i - m + 1) = coeff;
                    
                case "titanium"
                    coeff = coeff_titanium(E);
                    disp(coeff)
            end

        else
            error(message('get_attenuation_coeffs:invalidInputArgs'))
        end
    end
    
    %Normalise output coefficients to be between 0 and 1:
    %verify this:
%    M = max(attenuation_coeffs);
%    attenuation_coeffs = (1/M)*attenuation_coeffs;
    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Attenuation coefficients generating functions:

%Note: how to normalise mu to be between 0 and 1? This is the pixel value
%range of the phantoms.

%Could this be optimised by a for loop?
function air = coeff_air(E)
    
    %initialise materials class - only once per material:
    persistent materials_class    
    if isempty(materials_class)
        materials_class = Materials;
    end

    air = materials_class.extrapolate_value(E, "air");

function water = coeff_water(E)
    
    %initialise materials class - only once per material:
    persistent materials_class    
    if isempty(materials_class)
        materials_class = Materials;
    end

    water = materials_class.extrapolate_value(E, 'water'); 

function bone = coeff_bone(E)
    
    %initialise materials class - only once per material:
    persistent materials_class    
    if isempty(materials_class)
        materials_class = Materials;
    end

    bone = materials_class.extrapolate_value(E, 'bone'); 

function fat = coeff_fat(E)
    fat = "Data for this material not yet added to model.";
    
function muscle = coeff_muscle(E)
    muscle = "Data for this material not yet added to model.";

function polyethylene = coeff_polyethylene(E)
    
    %initialise materials class - only once per material:
    persistent materials_class    
    if isempty(materials_class)
        materials_class = Materials;
    end

    polyethylene = materials_class.extrapolate_value(E, 'polyethylene'); 
    
function acrylic = coeff_acrylic(E)

    %initialise materials class - only once per material:
    persistent materials_class    
    if isempty(materials_class)
        materials_class = Materials;
    end

    acrylic = materials_class.extrapolate_value(E, 'acrylic'); 
    
function titanium = coeff_titanium(E)
    titanium = "Data for this material not yet added to model.";
    

  