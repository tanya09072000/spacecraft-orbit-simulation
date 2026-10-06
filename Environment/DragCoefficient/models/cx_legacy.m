function Cx = cx_legacy(atmosphere, y, Spacecraft, C)
%CX_LEGACY Calculate aerodynamic drag coefficient using the legacy model.
%
% Input:
%   atmosphere  - Atmospheric properties
%   y           - Spacecraft state vector
%   Spacecraft  - Spacecraft aerodynamic parameters
%   C           - Physical constants
%
% Output:
%   Cx          - Aerodynamic drag coefficient

%% Orbital state

r = norm(y(1:3));
altitudeKm = r - C.Re;
V = norm(y(4:6)) * 1000;      % [m/s]

%% Input validation

if altitudeKm < 80
    error('Altitude must be greater than 80 km.');
end

alphaDeg = Spacecraft.angleOfAttack;

if alphaDeg < 0 || alphaDeg > 180
    error('Angle must be between 0 and 180 degrees.');
end

alpha = deg2rad(alphaDeg);

%% Atmospheric properties

Tinf = atmosphere.temperature(1);
m = atmosphere.meanMolecularMass * C.aem;

%% Shock-layer temperature

Tw = 0.000201 * altitudeKm^3 ...
   - 0.1164 * altitudeKm^2 ...
   + 24.217 * altitudeKm ...
   - 1525;

%% Molecular speed ratios

S = V / sqrt((2 * C.kB * Tinf) / m);
Sw = V / sqrt((2 * C.kB * Tw) / m);

%% Drag coefficient terms

cosAlpha = cos(alpha);

S1 = exp(-(S * cosAlpha)^2);

S2 = sqrt(pi) * S * cosAlpha ...
   * (1 + 1/(2 * S^2)) ...
   * erf(S * cosAlpha);

S3 = (pi * S / Sw) * cosAlpha^2;

%% Drag coefficient

Cx = (2 / (sqrt(pi) * S)) * (S1 + S2 + S3);

end