function a = gravityJ2(r, C)
%GRAVITYJ2 Acceleration due to Earth's oblateness (J2).
%
% Input:
%   r - Position vector in ECI frame [km]
%   C - Orbital constants
%
% Output:
%   a - J2 perturbation acceleration in the ECI frame [km/s^2]

%% Position magnitude

r_norm = norm(r);

%% Normalized Z-coordinate

zr_ratio = (r(3) / r_norm)^2;

%% J2 acceleration

a = ((-3 * C.J2 * C.mu * C.Re^2) / (2 * r_norm^5)) * ...
    [ r(1) * (1 - 5 * zr_ratio);
    r(2) * (1 - 5 * zr_ratio);
    r(3) * (3 - 5 * zr_ratio) ];

end