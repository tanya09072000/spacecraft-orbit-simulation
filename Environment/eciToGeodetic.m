function [lat_deg, lon_deg, h] = eciToGeodetic(r_eci, current_dt)
%ECITOGEODETIC Convert ECI position to geodetic coordinates.
%
% Input:
%   r_eci      - Position vector in ECI frame [km]
%   current_dt - Epoch [datetime]
%
% Output:
%   lat_deg    - Geodetic latitude [deg]
%   lon_deg    - Geodetic longitude [deg]
%   h          - Geodetic altitude [km]

%% Input validation

if numel(r_eci) ~= 3
    error('r_eci must contain three components.');
end

if ~isa(current_dt,'datetime')
    error('current_dt must be a datetime object.');
end

r_eci = r_eci(:);

%% ECI -> ECEF

DCM = dcmeci2ecef('IAU-2000/2006', current_dt);

r_ecef = DCM * r_eci;

x = r_ecef(1);
y = r_ecef(2);
z = r_ecef(3);

%% WGS-84 parameters

a = 6378.137;                 % Equatorial radius [km]
f = 1 / 298.257223563;        % Flattening
e2 = f * (2 - f);             % Eccentricity squared

%% Longitude

lon = atan2(y, x);

%% Geodetic latitude

p = hypot(x, y);

lat = atan2(z, p * (1 - e2));

for k = 1:10

    N = a / sqrt(1 - e2 * sin(lat)^2);

    h = p / cos(lat) - N;

    lat_new = atan2( ...
        z, ...
        p * (1 - e2 * N / (N + h)));

    if abs(lat_new - lat) < 1e-12
        lat = lat_new;
        break
    end

    lat = lat_new;

end

%% Final altitude

N = a / sqrt(1 - e2 * sin(lat)^2);

h = p / cos(lat) - N;

%% Convert to degrees

lat_deg = rad2deg(lat);
lon_deg = rad2deg(lon);

%% Normalize longitude

lon_deg = mod(lon_deg + 180, 360) - 180;

end