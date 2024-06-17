function my_phantom = get_phantom_var_energy(E, varargin) 
    
     
    args = matlab.images.internal.stringToChar(varargin);
    [circle,n] = parse_inputs(E, args{:});
    
    my_phantom = zeros(n);
    
    xax =  ( (0:n-1)-(n-1)/2 ) / ((n-1)/2); 
    xg = repmat(xax, n, 1);   % x coordinates, the y coordinates are rot90(xg)
    
    for k = 1:size(circle,1)  

       rsq = circle(k,2)^2;       % r^2
       x0 = circle(k,3);          % x offset
       y0 = circle(k,4);          % y offset
       A = circle(k,1);           % Amplitude change for this circle
       x=xg-x0;                   % Center the circle
       y=rot90(xg)-y0;  

       idx = find(((x.^2)./rsq + (y.^2)./rsq) <= 1);
       
       my_phantom(idx) = A;
     
    end 

function [circ,n] = parse_inputs(E, varargin)
    %  circ is the m-by-6 array which defines circles
    %  n is the size of the phantom brain image
    
    %get material attenuation values for input E: 
    a_air = get_attenuation_coeffs(E, 'air');
    a_bone = get_attenuation_coeffs(E, 'bone'); 
    a_water = get_attenuation_coeffs(E, 'water'); 
    a_polyethylene = get_attenuation_coeffs(E, 'polyethylene'); 
    a_acrylic = get_attenuation_coeffs(E, 'acrylic'); 

    n=256;     % The default size
    circ = [];
    defaults = {'circle', 'jzk', 'acr'};

    for i=1:nargin-1
        if ischar(varargin{i})         % Look for a default phantom
            def = lower(varargin{i});
            L = strlength(def);
            idx = strncmp(def, defaults,L);
            
            switch defaults{idx}
                case 'circle'
                    circ = generate_circle;
                case 'jzk'
                    %Jaszczak spherical phantom
                    circ = generate_jzk;
                case 'acr'
                    %Accreditation phantom ACR
                    circ = generate_acr(a_air, a_bone, a_water, a_polyethylene, a_acrylic);
            end
    
        elseif numel(varargin{i})==1 
            n = varargin{i};            % a scalar is the image size
        else
            error(message('images:phantom:invalidInputArgs'))
        end
    end


      
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  My Phantoms:   

function circle = generate_circle

%               A     r    x0    y0    
%             -----------------------
circle = [  1   .6    0     0   ];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function jzk = generate_jzk

r_phantom = 0.901;
half_r = r_phantom/2;
x_coords = half_r*cos(pi/6);
y_coords = half_r*sin(pi/6);

%               A     r    x0    y0    
%             -----------------------

jzk =      [ 1  r_phantom   0           0         %overall phantom
             0  0.0409      0           half_r
             0  0.0547      x_coords    y_coords
             0  0.0685      x_coords    -y_coords
             0  0.0823      0           -half_r
             0  0.109       -x_coords   -y_coords
             0  0.137       -x_coords   y_coords ];


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function acr = generate_acr(a_air, a_bone, a_water, a_polyethylene, a_acrylic)

%normalise variable: 
norm_factor = max([a_air, a_bone, a_water, a_polyethylene, a_acrylic]);
a_air = a_air/ norm_factor;
a_bone = a_bone/ norm_factor;
a_water = a_water /norm_factor;
a_polyethylene = a_polyethylene/ norm_factor;
a_acrylic = a_acrylic/norm_factor;

r_phantom = 0.9;
r_insert = r_phantom/5;
d = r_phantom/2 * cos(pi/4);

%               A     r    x0    y0    
%             -----------------------

acr = [ a_water         r_phantom   0    0         %overall phantom
        a_polyethylene  r_insert   -d    d
        a_bone          r_insert    d    d
        a_air           r_insert    d   -d 
        a_acrylic       r_insert   -d   -d]; 

