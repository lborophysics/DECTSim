function f_n_plus_1 = update_function(f_n, S, A, p)
    %S is the sensitivity matrix?
    %wtf is A
    %p is poisson distribution
    %elementwise product and division: .* and ./
    f_n_plus_1 = f_n ./ S .* A.' * (p ./ (A * f_n));
    
    
    %f represents each image estimate
    %Check: image estimate dimensions:
    %disp(size(f_n_plus_1))
end