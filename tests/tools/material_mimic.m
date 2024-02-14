classdef material_mimic
    % A class to mimic the material class
    properties
        mu
    end
    methods
        function self = material_mimic(mu)
            self.mu = mu;
        end
        function mu = get_mu(self, e)
            mu = self.mu;
        end
    end
end