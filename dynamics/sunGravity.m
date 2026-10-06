function aSun = sunGravity(r, rSun, C)
%SUNGRAVITY Compute gravitational perturbation due to the Sun.
%
% Input:
%   r    - Spacecraft position vector in ECI [km]
%   rSun - Sun position vector in ECI [km]
%   C    - Structure with physical constants
%
% Output:
%   aSun - Sun perturbation acceleration [km/s^2]

aSun = thirdBodyAcceleration(r, rSun, C.muSun);

end