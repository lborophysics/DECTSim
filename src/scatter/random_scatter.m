function [direction, energy] = random_scatter(direction, E_0)
    % This function generates a random scatter event for a particle with 
    % initial energy "E_0" and direction "direction". The function returns the
    % new direction and the energy of the scattered particle.

    % Source for the algorithm:
    

    % Initialize some constants
    e_0 = constants.em_ee / (constants.em_ee + 2*E_0); 
    e_02 = e_0^2; 
    twolog1_e_0 = 2*log(1/e_0); 
    
    
    insuitable = true; % A flag to indicate if the new direction is suitable
    while insuitable
        if rand < twolog1_e_0/(twolog1_e_0 - e_02 + 1)
            e = e_0^rand;
        else
            e = sqrt(e_02 + (1 - e_02) * rand);
        end
        t = (constants.em_ee * (1 - e) / (E_0 * e));
        cos_theta = 1 - t;
        sin2_theta = t * (2 - t);
        insuitable = 1 - (e*sin2_theta)/(1 + e^2) >= rand;
    end
    sin_theta = sqrt(sin2_theta);
    phi = 2 * pi * rand;

    change_frame = false; % This is to prevent gimbal lock from z-axis rotation
    if max(abs(direction)) == abs(direction(3))
         change_frame = true;
         direction = roty(pi/2) * direction;
    end

    direction = rotateUz(direction, sin_theta, cos_theta, phi);

    if change_frame; direction = roty(-pi/2) * direction; end

    energy = ((constants.em_ee * E_0) / (constants.em_ee + E_0 * (1 - cos_theta)));
end

function u = rotateUz(u, sin_theta, cos_theta, phi)
    % Sourced from CLHEP:
    % https://apc.u-paris.fr/~franco/g4doxy4.10/html/_three_vector_8cc_source.html#l00072
    u1 = u(1); u2 = u(2); u3 = u(3);
    up = u1*u1 + u2*u2;

    if up > 0
        up = sqrt(up);
        px = sin_theta*cos(phi); 
        py = sin_theta*sin(phi);
        pz = cos_theta;
        u(1) = (u1*u3*px - u2*py)/up + u1*pz;
        u(2) = (u2*u3*px + u1*py)/up + u2*pz;
        u(3) = -up*px + u3*pz;
    elseif u3 < 0
        u(1) = -u(1);
        u(3) = -u(3);  % phi=0  theta=pi
    end
end