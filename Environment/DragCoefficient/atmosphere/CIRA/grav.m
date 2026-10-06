function g = grav(z) 

%GRAV Compute gravitational acceleration.
%
% Input:
%   altitudeKm - Geometric altitude [km]
%
% Output:
%   gravity - Gravitational acceleration [m/s^2]

    g = 9.80665 / (1.0 + z / 6356.766)^2;
end