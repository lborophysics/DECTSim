function cs = cross_section(Z, nrjs)
    % CROSS_SECTION Get the cross section of the material for a given energy (CREDIT: Geant4)
    % The values, formulae and code is taken directly from
    % https://github.com/Geant4/geant4/blob/master/source/processes/electromagnetic/standard/src/G4KleinNishinaCompton.cc
    nz = numel(Z); % Number of elements in Z
    ne = numel(nrjs); % Number of elements in nrj
    cs = zeros(ne, nz); % Initialize the cross section array
    nrjs = reshape(nrjs, [ne, 1]); % Make sure that the energy is a column vector
    
    if all(nrjs < 100*units.eV); cs(:) = 0; return; end % Below 100 eV, we are beyond the limit of the cross section table -> 0
    % See https://geant4-userdoc.web.cern.ch/UsersGuides/PhysicsReferenceManual/html/electromagnetic/gamma_incident/compton/compton.html
    
    persistent a b c d1 d2 d3 d4 e1 e2 e3 e4 f1 f2 f3 f4
    if isempty(a) % Initialize the constants if they are not already
        a = 20.0; b = 230.0; c = 440.0; % Unitless
        d1= 2.7965e-1*units.barn; d2=-1.8300e-1*units.barn; % cm^2 (e-24 for the barn)
        d3= 6.7527   *units.barn; d4=-1.9798e+1*units.barn; % cm^2 (e-24 for the barn)
        e1= 1.9756e-5*units.barn; e2=-1.0205e-2*units.barn; % cm^2 (e-24 for the barn)
        e3=-7.3913e-2*units.barn; e4= 2.7079e-2*units.barn; % cm^2 (e-24 for the barn)
        f1=-3.9178e-7*units.barn; f2= 6.8241e-5*units.barn; % cm^2 (e-24 for the barn)
        f3= 6.0480e-5*units.barn; f4= 3.0274e-4*units.barn; % cm^2 (e-24 for the barn)
    end
    T0 = zeros(ne, nz) + 40 * units.keV; % Special case for hydrogen (KeV)
    T0(:, Z > 1.5) = 15 * units.keV; % For Z > 1.5, T0 = 15 KeV
    X = max(nrjs, T0) ./ constants.me_c2; % Unitless
    p1Z = Z.*(d1 + e1.*Z + f1.*Z.*Z); p2Z = Z.*(d2 + e2.*Z + f2.*Z.*Z); % cm^2
    p3Z = Z.*(d3 + e3.*Z + f3.*Z.*Z); p4Z = Z.*(d4 + e4.*Z + f4.*Z.*Z); % cm^2

    cs = p1Z.*log(1.+2.*X)./X + (p2Z + p3Z.*X + p4Z.*X.*X)./(1. + a.*X + b.*X.*X + c.*X.*X.*X); % cm^2
    if any(nrjs < T0)
        X = (T0+1) ./ constants.me_c2; % Unitless
        sigma = p1Z.*log(1.+2.*X)./X + (p2Z + p3Z.*X + p4Z.*X.*X)./(1. + a.*X + b.*X.*X + c.*X.*X.*X); % cm^2
        
        c1 = -T0.*(sigma-cs)./cs; % Unitless
        c2 = zeros(ne, nz) + 0.150;
        c2(:, Z > 1.5) = repmat(0.375-0.0556.*log(Z(Z>1.5)), [ne, 1]); % Unitless
        
        y = log(nrjs./T0); % Unitless
        adj = exp(-y.*(c1+c2.*y));
        corr = nrjs < T0;
        cs(corr) = cs(corr) .* adj(corr);
    end
    cs(nrjs < 100*units.eV, :) = 0; % Below 100 eV, we are beyond the limit of the cross section table -> 0
end