function passed = validateDrag(Trajectory, Data, C)
%VALIDATEDRAG Validate atmospheric drag acceleration.
%
% Checks the drag acceleration calculated by the production
% drag() function against an independent analytical calculation.

%% Select validation point

k = round(size(Trajectory.state,1) / 2);

t = Trajectory.time(k);

r = Trajectory.state(k,1:3)';

v = Trajectory.state(k,4:6)';

%% Atmospheric parameters

altitude = norm(r) - C.Re;

if altitude < Data.Atmosphere.hMin

    altitude = Data.Atmosphere.hMin;

elseif altitude > Data.Atmosphere.hMax

    altitude = Data.Atmosphere.hMax;

end

rho = exp(Data.Atmosphere.rhoInterp(altitude));

%% Aerodynamic coefficient

switch Data.Aerodynamics.model

    case "Legacy"

        Cx = Data.Atmosphere.cxInterp(altitude);

    otherwise

        y = [r; v];

        Cx = calculateCx( ...
            Data.Atmosphere, ...
            y, ...
            Data.Spacecraft, ...
            Data.Aerodynamics, ...
            C);

end

%% Relative atmospheric velocity

r_si = r * 1000;
v_si = v * 1000;

v_atm = cross( ...
    [0; 0; C.omega], ...
    r_si);

v_rel = v_si - v_atm;

v_rel_norm = norm(v_rel);

%% Independent drag acceleration

Area = Data.Spacecraft.area;
Mass = Data.Spacecraft.mass;

ballistic = Cx * Area / Mass;

a_ref_si = ...
    -0.5 * ballistic * rho * ...
    v_rel_norm * v_rel;

a_ref = a_ref_si / 1000;

%% Production drag acceleration

a_model = drag( ...
    t, ...
    r, ...
    v, ...
    Data, ...
    C);

%% Difference

deltaA = a_model - a_ref;

relativeError = ...
    norm(deltaA) / norm(a_ref) * 100;

%% Output

fprintf('\n');
fprintf('=====================================================\n');
fprintf('                  DRAG VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\nValidation point\n');
fprintf('-----------------------------------------------------\n');

fprintf('Time               : %.3f h\n', ...
    t / 3600);

fprintf('Altitude           : %.3f km\n', ...
    norm(r) - C.Re);

fprintf('Density            : %.6e kg/m^3\n', ...
    rho);

fprintf('Cx                 : %.6f\n', ...
    Cx);

fprintf('Relative velocity  : %.3f m/s\n', ...
    v_rel_norm);

fprintf('\nDrag acceleration\n');
fprintf('-----------------------------------------------------\n');

fprintf('Reference |aDrag|  : %.6e km/s^2\n', ...
    norm(a_ref));

fprintf('Model     |aDrag|  : %.6e km/s^2\n', ...
    norm(a_model));

fprintf('Difference         : %.6e km/s^2\n', ...
    norm(deltaA));

fprintf('Relative error     : %.6e %%\n', ...
    relativeError);

%% Specific mechanical energy

nPoints = size(Trajectory.state,1);

energy = zeros(nPoints,1);

for k = 1:nPoints

    r = Trajectory.state(k,1:3)';
    v = Trajectory.state(k,4:6)';

    rNorm = norm(r);
    vNorm = norm(v);

    energy(k) = ...
        0.5 * vNorm^2 - C.mu / rNorm;

end

energyChange = energy - energy(1);

%% Energy output

fprintf('\nEnergy change due to drag\n');
fprintf('-----------------------------------------------------\n');

fprintf('Initial energy       : %.12f km^2/s^2\n', ...
    energy(1));

fprintf('Final energy         : %.12f km^2/s^2\n', ...
    energy(end));

fprintf('Energy change        : %.6e km^2/s^2\n', ...
    energy(end) - energy(1));

fprintf('Maximum |delta E|    : %.6e km^2/s^2\n', ...
    max(abs(energyChange)));

%% Validation result

passed = relativeError < 1e-10;

fprintf('\n');

if passed

    fprintf('Result             : PASS\n');

else

    fprintf('Result             : FAIL\n');

end

fprintf('\n');
fprintf('=====================================================\n');

%% Plot energy change

figure;

plot( ...
    Trajectory.time / 3600, ...
    energyChange, ...
    'LineWidth', 1.0);

grid on;

xlabel('Time [h]');
ylabel('\Delta E [km^2/s^2]');

title('Drag validation — Specific mechanical energy');

end