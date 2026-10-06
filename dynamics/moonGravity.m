function aMoon = moonGravity(r, rMoon, C)
%MOONGRAVITY Compute gravitational perturbation due to the Moon.
%
% Input:
%   r     - Spacecraft position vector in ECI [km]
%   rMoon - Moon position vector in ECI [km]
%   C     - Structure with physical constants
%
% Output:
%   aMoon - Moon perturbation acceleration [km/s^2]

aMoon = thirdBodyAcceleration(r, rMoon, C.muMoon);

end