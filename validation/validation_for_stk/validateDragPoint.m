function validateDragPoint(Trajectory, Data, C)
%VALIDATEDRAGPOINT Validate atmospheric drag at a selected point.
%
% Compares the MATLAB drag model parameters at a selected trajectory
% point and prints the values required for comparison with STK.
%
% Input:
%   Trajectory - propagated spacecraft trajectory
%   Data       - simulation input data
%   C          - physical constants

%% Validation epoch

validationTime = datetime( ...
    2026, 5, 4, 16, 58, 38.600);

%% Interpolate trajectory at exact validation epoch

t = seconds( ...
    validationTime - Data.Scenario.separationTime);

y = interp1( ...
    Trajectory.time, ...
    Trajectory.state, ...
    t, ...
    'pchip');

r = y(1:3);
v = y(4:6);

%% Atmospheric altitude

altitude = norm(r) - C.Re;

if altitude < Data.Atmosphere.hMin
    altitude = Data.Atmosphere.hMin;
elseif altitude > Data.Atmosphere.hMax
    altitude = Data.Atmosphere.hMax;
end

%% Atmospheric density

rho = exp( ...
    Data.Atmosphere.rhoInterp(altitude));

%% Aerodynamic coefficient

switch Data.Aerodynamics.model

    case "Legacy"

        Cx = Data.Atmosphere.cxInterp(altitude);

    case "Sentman1961"

        Cx = calculateCx( ...
            Data.Atmosphere, ...
            y', ...
            Data.Spacecraft, ...
            Data.Aerodynamics, ...
            C);

    case "SchaafChambre"

        Cx = calculateCx( ...
            Data.Atmosphere, ...
            y', ...
            Data.Spacecraft, ...
            Data.Aerodynamics, ...
            C);

    otherwise

        error('Unknown aerodynamic model: %s.', ...
            Data.Aerodynamics.model);

end

%% Spacecraft parameters

Area = Data.Spacecraft.area;
Mass = Data.Spacecraft.mass;

areaMass = Area / Mass;

%% Relative velocity

r_si = r * 1000;
v_si = v * 1000;

v_atm = cross( ...
    [0; 0; C.omega], ...
    r_si);

v_rel = v_si - v_atm;

v_rel_norm = norm(v_rel);

%% Drag acceleration

a_drag_si = ...
    -0.5 * Cx * areaMass * rho * ...
    v_rel_norm * v_rel;

a_drag = a_drag_si / 1000;

a_drag_mag = norm(a_drag);

%% Print results

fprintf('\n');
fprintf('=====================================================\n');
fprintf('              DRAG VALIDATION POINT\n');
fprintf('=====================================================\n');

fprintf('\nEpoch\n');
fprintf('-----------------------------------------------------\n');

fprintf('Requested epoch      : %s UTC\n', ...
    datestr(validationTime, ...
    'dd-mmm-yyyy HH:MM:SS.FFF'));

fprintf('Actual MATLAB epoch  : %s UTC\n', ...
    datestr( ...
    Data.Scenario.separationTime + seconds(t), ...
    'dd-mmm-yyyy HH:MM:SS.FFF'));

fprintf('Time since separation: %.6f h\n', ...
    t / 3600);

fprintf('\nState\n');
fprintf('-----------------------------------------------------\n');

fprintf('x  = %.12f km\n', r(1));
fprintf('y  = %.12f km\n', r(2));
fprintf('z  = %.12f km\n', r(3));

fprintf('vx = %.12f km/s\n', v(1));
fprintf('vy = %.12f km/s\n', v(2));
fprintf('vz = %.12f km/s\n', v(3));

fprintf('\nAtmosphere\n');
fprintf('-----------------------------------------------------\n');

fprintf('Altitude             : %.9f km\n', ...
    altitude);

fprintf('Density              : %.12e kg/m^3\n', ...
    rho);

fprintf('\nAerodynamics\n');
fprintf('-----------------------------------------------------\n');

fprintf('Model                : %s\n', ...
    Data.Aerodynamics.model);

fprintf('Cx                   : %.12f\n', ...
    Cx);

fprintf('Area                 : %.9f m^2\n', ...
    Area);

fprintf('Mass                 : %.9f kg\n', ...
    Mass);

fprintf('Area/Mass             : %.12e m^2/kg\n', ...
    areaMass);

fprintf('\nVelocity\n');
fprintf('-----------------------------------------------------\n');

fprintf('V inertial           : %.9f m/s\n', ...
    norm(v_si));

fprintf('V atmosphere         : %.9f m/s\n', ...
    norm(v_atm));

fprintf('V relative           : %.9f m/s\n', ...
    v_rel_norm);

fprintf('\nDrag acceleration\n');
fprintf('-----------------------------------------------------\n');

fprintf('Ax                   : %.12e km/s^2\n', ...
    a_drag(1));

fprintf('Ay                   : %.12e km/s^2\n', ...
    a_drag(2));

fprintf('Az                   : %.12e km/s^2\n', ...
    a_drag(3));

fprintf('Magnitude             : %.12e km/s^2\n', ...
    a_drag_mag);

fprintf('\n');
fprintf('=====================================================\n');

end