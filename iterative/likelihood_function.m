function L = likelihood_function(R_0)
    %need the projection f: vecotrs of reconstructed image 

    M = size(R_0, 1)* size(R_0,2); %Total number of projections taken at
    %OR M = size(R_0, 1) %number of detector elements (taken from sinogram simensions)
    %each angle (multiple pixels detected for each projection angle)
    % book : https://link.springer.com/chapter/10.1007/978-3-642-05368-9_6
    L = 1;
    p_av = %vector of averages of Poisson distribution
    % p_av = sum from i = 0:N A(j,i)*f(i)
    n = vector??
    
    %look into removing for loop, vectorisation?
    for i = 1:M
        L = L * ( ((p_av(i)^(n(i))) / factorial(n(i))) * exp(-p_av(i)) );
    end
    %MAximise the function??
end