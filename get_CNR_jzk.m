%For Jaszczak phantom
%'one' to 'six' indicates phantom inserts from smallest to largest.
%'zero' indicates main phnatom body
%input material 

%% NEEDS FINISHING

function CNR = get_CNR_jzk(image, varargin) 
    
    %generalise this later to make it into one call and make use of the
    %varargin feature and vector output of the get_attenuation_coeffs func
    %[attenuation_coeffs] = get_attenuation_coeffs(varargin) 
   
    args = matlab.images.internal.stringToChar(varargin);
    [circle,n] = parse_inputs(image, args{:});
    
    my_mask = zeros(n);
    
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
       
       my_mask(idx) = A;
    end 
        defaults = {'zero', 'one', 'two', 'three', 'four', 'five', 'six'};

        for i=1:nargin-1
            if ischar(varargin{i})         % Look for a default phantom
                def = lower(varargin{i});
                L = strlength(def);
                idx = strncmp(def, defaults,L);
                
                switch defaults{idx}
                    case 'zero'
                        CNR = zero_CNR(image, my_mask);
                    case 'one'
                        CNR = one_CNR(image, my_mask);
                    case 'two'
                        CNR = two_CNR(image, my_mask);
                    case 'three'
                        CNR = three_CNR(image, my_mask);
                    case 'four'
                        CNR = four_CNR(image, my_mask);
                    case 'five'
                        CNR = five_CNR(image, my_mask);
                    case 'six'
                        CNR = six_CNR(image, my_mask);
                end
        
            elseif numel(varargin{i})==1 
                n = varargin{i};            % a scalar is the image size
            else
                error(message('images:phantom:invalidInputArgs'))
            end
        end

function [circ,n] = parse_inputs(image, varargin)
    %  circ is the m-by-6 array which defines circles
    %  n is the size of the phantom

    n=256;     % The default size
    circ = [];
    defaults = {'zero', 'one', 'two', 'three', 'four', 'five', 'six'};

    for i=1:nargin-1
        if ischar(varargin{i})         % Look for a default phantom
            def = lower(varargin{i});
            L = strlength(def);
            idx = strncmp(def, defaults,L);
            
            switch defaults{idx}
                case 'zero'
                    circ = get_zero_mask;
                case 'one'
                    circ = get_one_mask;
                case 'two'
                    circ = get_two_mask;
                case 'three'
                    circ = get_three_mask;
                case 'four'
                    circ = get_four_mask;
                case 'five'
                    circ = get_five_mask;
                case 'six'
                    circ = get_six_mask;
            end
    
        elseif numel(varargin{i})==1 
            n = varargin{i};            % a scalar is the image size
        else
            error(message('images:phantom:invalidInputArgs'))
        end
    end


      
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% get masks for input material
function mask_air = get_air_mask
r_phantom = 0.9;
r_insert = r_phantom/5;
d = r_phantom/2 * cos(pi/4);
%               A     r    x0    y0    
%             -----------------------
mask_air = [  1   r_insert   d    -d ];


function mask_bone = get_bone_mask
r_phantom = 0.9;
r_insert = r_phantom/5;
d = r_phantom/2 * cos(pi/4);
%               A     r    x0    y0    
%             -----------------------
mask_bone = [ 1   r_insert   d    d ];


function mask_pol = get_pol_mask
r_phantom = 0.9;
r_insert = r_phantom/5;
d = r_phantom/2 * cos(pi/4);
%               A     r    x0    y0    
%             -----------------------
mask_pol = [  1  r_insert   -d   d ];


function mask_acryl = get_acryl_mask
r_phantom = 0.9;
r_insert = r_phantom/5;
d = r_phantom/2 * cos(pi/4);
%               A     r    x0    y0    
%             -----------------------
mask_acryl = [ 1   r_insert   -d   -d]; 


function mask_water = get_water_mask
r_phantom = 0.9;
r_insert = r_phantom/5;
d = r_phantom/2 * cos(pi/4);
%               A     r    x0    y0    
%             -----------------------
mask_water = [ 1   r_phantom   0    0
               0   r_insert   -d   d
               0   r_insert   d    d
               0   r_insert   d    -d 
               0   r_insert   -d   -d]; 



%% get CNR metrics for each material

function CNR = get_air_CNR(image, my_mask)
size(my_mask)
size(image)
image_air = image.*my_mask;
%mean attenuation of ROI
mean_air = sum(image_air,'all') ./ sum(image_air~=0,'all');

%convert zero entries to NaN
image_air(image_air==0)=NaN;
%get standard deviation (How is this normalised)
sd_air = std(image_air, 0, 'all', "omitmissing");

%display output as strings:
sprintf('Air has mean attenuation %f and standard deviation %f', mean_air, sd_air)
%store outputs as array
CNR = [ mean_air  sd_air];
%~~~~~~~~~~~~~~~~~~~~~~~~~

function CNR = get_bone_CNR(image, my_mask)
image_bone = image.*my_mask;
%mean attenuation of ROI
mean_bone = sum(image_bone,'all') ./ sum(image_bone~=0,'all');


%convert zero entries to NaN
image_bone(image_bone==0)=NaN;
%get standard deviation (How is this normalised)
sd_bone = std(image_bone, 0, 'all', "omitmissing");

%display output as strings:
sprintf('Bone has mean attenuation %f and standard deviation %f', mean_bone, sd_bone)

%store outputs as array
CNR = [ mean_bone    sd_bone];
%~~~~~~~~~~~~~~~~~~~~~~~~~

function CNR = get_pol_CNR(image, my_mask)
image_pol = image.*my_mask;
%mean attenuation of ROI
mean_pol = sum(image_pol,'all') ./ sum(image_pol~=0,'all');

%convert zero entries to NaN
image_pol(image_pol==0)=NaN;
%get standard deviation (How is this normalised)
sd_pol = std(image_pol, 0, 'all', "omitmissing");

%display output as strings:
sprintf('Polyethylene has mean attenuation %f and standard deviation %f', mean_pol, sd_pol)

%store outputs as array
CNR = [ mean_pol    sd_pol];
%~~~~~~~~~~~~~~~~~~~~~~~~~

function CNR = get_acryl_CNR(image, my_mask)
image_acryl = image.*my_mask;
%mean attenuation of ROI
mean_acryl = sum(image_acryl,'all') ./ sum(image_acryl~=0,'all');

%convert zero entries to NaN
image_acryl(image_acryl==0)=NaN;
%get standard deviation (How is this normalised)
sd_acryl = std(image_acryl, 0, 'all', "omitmissing");

%display output as strings:
sprintf('Acrylic has mean attenuation %f and standard deviation %f', mean_acryl, sd_acryl)

%store outputs as array
CNR = [mean_acryl  sd_acryl];
%~~~~~~~~~~~~~~~~~~~~~~~~~

function CNR = get_water_CNR(image, my_mask)
image_water = image.*my_mask;
%mean attenuation of ROI
mean_water = sum(image_water,'all') ./ sum(image_water~=0,'all');

%convert zero entries to NaN
image_water(image_water==0)=NaN;
%get standard deviation (How is this normalised)
sd_water = std(image_water, 0, 'all', "omitmissing");

%display output as strings:
sprintf('Water has mean attenuation %f and standard deviation %f', mean_water, sd_water)

%store outputs as array
CNR = [mean_water  sd_water];
%~~~~~~~~~~~~~~~~~~~~~~~~~




%~~~~~~~~~~~~~~~~~~~~~~~~~
function j_sphere = generate_j_sphere

r_phantom = 0.901;
half_r = r_phantom/2;
x_coords = half_r*cos(pi/6);
y_coords = half_r*sin(pi/6);

%               A     r    x0    y0    
%             -----------------------

j_sphere = [ 1  r_phantom   0           0         %overall phantom
             0  0.0409      0           half_r
             0  0.0547      x_coords    y_coords
             0  0.0685      x_coords    -y_coords
             0  0.0823      0           -half_r
             0  0.109       -x_coords   -y_coords
             0  0.137       -x_coords   y_coords ];