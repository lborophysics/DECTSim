function my_phantom = custom_phantom(varargin)

    args = matlab.images.internal.stringToChar(varargin);
    [circle,n] = parse_inputs(args{:});
    
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
      % my_phantom(idx) = my_phantom(idx) + A;
    end
       

function [circ,n] = parse_inputs(varargin)
    %  circ is the m-by-6 array which defines circles
    %  n is the size of the phantom brain image
    
    n=256;     % The default size
    circ = [];
    defaults = {'small_circ', 'one', 'j_sphere', 'j_rods', 'acr'};

    for i=1:nargin
        if ischar(varargin{i})         % Look for a default phantom
            def = lower(varargin{i});
            L = strlength(def);
            idx = strncmp(def, defaults,L);
            
            switch defaults{idx}
                case 'small_circ'
                    circ = test_small_dot;
                case 'one'
                    circ = test_one;
                case 'j_sphere'
                    circ = generate_j_sphere;
                case 'j_rods'
                    circ = generate_j_rods;
                case 'acr'
                    circ = generate_acr;
            end
    
        elseif numel(varargin{i})==1 
            n = varargin{i};            % a scalar is the image size
        else
            error(message('images:phantom:invalidInputArgs'))
        end
    end


      
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  My Phantoms:   

function small_circ= test_small_dot
%
%               A     r    x0    y0    
%             -----------------------
small_circ = [  1   .9    0     0   ];

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

%{
function j_rods = generate_j_rods
r_phantom = 0.901;

r1 = 0.0207;
r2 = 0.0276;
r3 = 0.0361;
r4 = 0.0409;
r5 = 0.0478;
r6 = 0.0547;

A_vec = ones(11,1);
A_vec(2:end) = -1;
x0_vec = zeros(11,1);
y0_vec = zeros(11,1);
R = zeros(11,1);
R(1,1) = r_phantom;
R(2:end,1) = r1;

for i = 1:10
    dr = 3*r1;
    y0 = i*dr;
    x0 = -2/3 * y0 + dr;

    y0_vec(1+i,1) = y0;
    x0_vec(1+i,1) = x0;
end

j_rods = horzcat(A_vec, R, x0_vec, y0_vec);

%}


function acr = generate_acr
r_phantom = 0.9;
r_insert = r_phantom/5; %replace this with literature value
d = r_phantom/2 * cos(pi/4);
%               A     r    x0    y0    
%             -----------------------

acr = [ 0.5             r_phantom   0    0         %overall phantom
        0.5-0.095/2     r_insert   -d   d
        0.5+0.955/2     r_insert   d    d
        0               r_insert   d    -d 
        0.5 + 0.120/2   r_insert   -d   -d];


function one= test_one
%
%         A     r    x0    y0    
%        -----------------------
one = [  1   .92    0     0     
        -.98 .8740   0  -.0184
        -.02 .3100  .22    0  
        -.02 .4100 -.22    0  
         .01 .2500   0    .35 
         .01 .0460   0    .1  
         .01 .0460   0   -.1  
         .01 .0230 -.08  -.605 
         .01 .0230   0   -.606
         .01 .0460  .06  -.605   ];
      
      