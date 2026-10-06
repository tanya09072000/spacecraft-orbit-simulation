function Cx = calculateCx(atmosphere, y, Spacecraft, Aerodynamics, C)
%CALCULATECX Calculate the aerodynamic drag coefficient.
%
% Selects the configured aerodynamic model and calculates Cx.
%
% Input:
%   atmosphere    - Atmospheric properties
%   y             - Spacecraft state vector
%   Spacecraft    - Spacecraft properties
%   Aerodynamics  - Aerodynamic model settings
%   C             - Physical constants
%
% Output:
%   Cx            - Aerodynamic drag coefficient

%% Select aerodynamic model

switch Aerodynamics.model

    case "Legacy"

        Cx = cx_legacy( ...
            atmosphere, ...
            y, ...
            Spacecraft, ...
            C);

    case "Sentman1961"

        error('Sentman1961 model is not implemented yet.');

    case "SchaafChambre"

        error('Schaaf-Chambre model is not implemented yet.');

    otherwise

        error('Unknown aerodynamic model: %s.', ...
            Aerodynamics.model);

end

end