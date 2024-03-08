classdef constants
    properties (Constant)
        % Physical constants
        me_c2 = 510.99895 .* units.keV; % KeV, Source: https://pml.nist.gov/cgi-bin/cuu/Value?mec2mev
        N_A = 6.02214076 * 10^23; % atoms/mol, Source: https://pml.nist.gov/cgi-bin/cuu/Value?na
        c = 299792458 .* units.m / units.s; % m/s, Source: https://pml.nist.gov/cgi-bin/cuu/Value?c
    end
end
