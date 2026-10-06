function shadow = isInShadow(r, rSun, C)
%ISINSHADOW Check whether spacecraft is inside Earth's cylindrical shadow.
%
% Input:
% Input:
%   r    - Spacecraft position in ECI [km]
%   rSun - Sun position in ECI [km]
%   C    - Physical constants
%
% Output:
%   shadow - true if spacecraft is in Earth's shadow

eSun = rSun / norm(rSun);
projection = dot(r, eSun);

% Spacecraft must be behind Earth
if projection >= 0
    shadow = false;
    return
end

% Distance from spacecraft to the Earth-Sun axis 
distance = norm(r - projection * eSun);

shadow = distance <= C.Re;

end