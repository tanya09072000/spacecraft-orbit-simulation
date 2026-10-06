function a = drag(t, r, v, Data, C)
%DRAG Aerodynamic drag acceleration.
%
% Input:
%   t    - Time since separation [s]
%   r    - Position vector in ECI frame [km]
%   v    - Velocity vector in ECI frame [km/s]
%   Data - Simulation input data
%   C    - Physical constants
%
% Output:
%   a    - Atmospheric drag acceleration [km/s^2]

%% Geocentric altitude

altitude = norm(r) - C.Re;

%% Spacecraft

Area = Data.Spacecraft.area;
Mass = Data.Spacecraft.mass;

%% Limit altitude to atmosphere grid

if altitude < Data.Atmosphere.hMin
    altitude = Data.Atmosphere.hMin;
elseif altitude > Data.Atmosphere.hMax
    altitude = Data.Atmosphere.hMax;
end

%% Atmospheric density

rho = exp(Data.Atmosphere.rhoInterp(altitude));

switch Data.Aerodynamics.model

    case "Legacy"

        Cx = Data.Atmosphere.cxInterp(altitude);

    case "Sentman1961"

        y = [r; v];
        Cx = calculateCx( ...
            Data.Atmosphere,...
            y,...
            Data.Spacecraft,...
            Data.Aerodynamics,...
            C);

     case "SchaafChambre"

        y = [r; v];
        Cx = calculateCx( ...
            Data.Atmosphere,...
            y,...
            Data.Spacecraft,...
            Data.Aerodynamics,...
            C);

    otherwise

        error('Unknown aerodynamic model: %s.', ...
            Data.Aerodynamics.model);

end

%% Convert to SI units
r_si = r * 1000;   % Position [m]
v_si = v * 1000;   % Velocity [m/s]

v_atm      = cross([0; 0; C.omega], r_si);   % Atmospheric velocity [m/s]
v_rel      = v_si - v_atm;                 % Relative velocity [m/s]
v_rel_norm = norm(v_rel);

%% Aerodynamic drag

ballistic = Cx * Area / Mass;
a_si = -0.5 * ballistic * rho * v_rel_norm * v_rel;
a = a_si / 1000;      % m/s² → km/s²

end