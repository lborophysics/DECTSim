%ROI and CNR calculator: started 26.04.2024

%function: input phantom choice as varargin, other inoput it image
%reconstruction from whuch we want to obtain CNR
%make sure inputted reconstruction image is the same as the varargin for
%binary masks
%output can be a string giving CNR for each different material insert in
%the phantom
%switch function - same as for phantoms but produces binary masks

%binary mask is all zeros with 1's in the ROI
%multiply binary mask by image
%calculate mean and standard deviation of ROI (excluding zero entries)

%input material 
function CNR = get_CNR_acr(image, varargin) 
    
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
        defaults = {'air', 'bone', 'polyethylene', 'acrylic', 'water'};

        for i=1:nargin-1
            if ischar(varargin{i})         % Look for a default phantom
                def = lower(varargin{i});
                L = strlength(def);
                idx = strncmp(def, defaults,L);
                
                switch defaults{idx}
                    case 'air'
                        CNR = get_air_CNR(image, my_mask);
                    case 'bone'
                        CNR = get_bone_CNR(image, my_mask);
                    case 'polyethylene'
                        CNR = get_pol_CNR(image, my_mask);
                    case 'acrylic'
                        CNR = get_acryl_CNR(image, my_mask);
                    case 'water'
                        CNR = get_water_CNR(image, my_mask);
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
    defaults = {'air', 'bone', 'polyethylene', 'acrylic', 'water'};

    for i=1:nargin-1
        if ischar(varargin{i})         % Look for a default phantom
            def = lower(varargin{i});
            L = strlength(def);
            idx = strncmp(def, defaults,L);
            
            switch defaults{idx}
                case 'air'
                    circ = get_air_mask;
                case 'bone'
                    circ = get_bone_mask;
                case 'polyethylene'
                    circ = get_pol_mask;
                case 'acrylic'
                    circ = get_acryl_mask;
                case 'water'
                    circ = get_water_mask;
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
