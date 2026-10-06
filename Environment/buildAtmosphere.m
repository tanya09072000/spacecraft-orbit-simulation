function Atmosphere = buildAtmosphere(Data, current_dt, r, C)
%BUILDATMOSPHERE Build atmospheric and aerodynamic models.
%
% Computes atmospheric properties and the drag coefficient over the
% specified altitude range using the selected atmospheric model.
% The results are stored as interpolation functions for use during
% orbital propagation.

%% Input validation

if ~isa(current_dt,'datetime')
    error('current_dt must be a datetime object.');
end

%% Spacecraft geodetic position

[lat_deg, lon_deg] = eciToGeodetic(r, current_dt);

%% Altitude grid

Atmosphere.hMin = 150;       % Minimum altitude [km]
Atmosphere.hMax = 700;       % Maximum altitude [km]
Atmosphere.step = 5;         % Altitude step [km]

h_grid = Atmosphere.hMin : Atmosphere.step : Atmosphere.hMax;

rho_grid = zeros(size(h_grid));
cx_grid  = zeros(size(h_grid));

dateString = datestr(current_dt,'yyyy-mm-dd');

%% Atmospheric model

switch Data.Environment.model

    case "NRLMSISE"

        atmosphere = nrlWrapper( ...
            h_grid, ...
            current_dt, ...
            lat_deg, ...
            lon_deg);

    case "CIRA"

        atmosphere = ciraMain( ...
            h_grid, ...
            dateString);

    case "Exponential"

        ...

    otherwise

        error('Unknown atmospheric model: %s.', ...
            Data.Environment.model);

end

%% Atmospheric properties and drag coefficient

for k = 1:length(h_grid)

    h = h_grid(k);

    % Atmospheric density
    rho_grid(k) = atmosphere.density(k);

    % Mean molecular mass [kg]
    m = atmosphere.meanMolecularMass(k) * C.aem;

    % Exospheric temperature [K]
    Tinf = atmosphere.temperature.exospheric(k);

    % Approximate orbital velocity [m/s]
    V = sqrt(C.mu / (C.Re + h)) * 1000;

    % Spacecraft wall temperature [K]
    Tw = 0.000201*h^3 ...
       - 0.1164*h^2 ...
       + 24.217*h ...
       - 1525;

    % Speed ratios
    S  = V / sqrt((2*C.k_b*Tinf) / m);
    Sw = V / sqrt((2*C.k_b*Tw) / m);

    % Auxiliary terms for the aerodynamic model
    S1 = exp(-S^2);
    S2 = sqrt(pi)*S*(1 + 1/(2*S^2))*erf(S);
    S3 = pi*S/Sw;

    % Drag coefficient
    cx_grid(k) = ...
        (2/(sqrt(pi)*S)) * (S1 + S2 + S3);

end

%% Store atmospheric data

Atmosphere.height = h_grid;
Atmosphere.rho    = rho_grid;
Atmosphere.cx     = cx_grid;

%% Interpolation functions

% Logarithmic interpolation of atmospheric density
Atmosphere.rhoInterp = griddedInterpolant( ...
    h_grid, ...
    log(rho_grid), ...
    'pchip', ...
    'nearest');

% Interpolation of drag coefficient
Atmosphere.cxInterp = griddedInterpolant( ...
    h_grid, ...
    cx_grid, ...
    'pchip', ...
    'nearest');

end