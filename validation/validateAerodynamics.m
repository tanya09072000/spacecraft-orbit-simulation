function Validation = validateAerodynamics(Results, referenceCx)
%VALIDATEAERODYNAMICS Validate aerodynamic drag coefficient model.
%
% Inputs:
%   Results      - Simulation results structure
%   referenceCx - Optional reference Cx value, e.g. STK value
%
% Output:
%   Validation - Aerodynamic validation results
%
% The function:
%   - plots Cx as a function of altitude
%   - calculates Cx statistics
%   - evaluates Cx at the initial orbital altitude
%   - optionally compares it with a reference Cx value

%% Input validation

if nargin < 2
    referenceCx = [];
end

if ~isfield(Results, 'Atmosphere')
    error('Results does not contain atmospheric data.');
end

if ~isfield(Results.Atmosphere, 'height') || ...
   ~isfield(Results.Atmosphere, 'cx')

    error('Atmosphere does not contain Cx data.');
end

%% Atmospheric data

h = Results.Atmosphere.height;
Cx = Results.Atmosphere.cx;

%% Cx statistics

Validation.minimumCx = min(Cx);
Validation.maximumCx = max(Cx);

%% Initial orbital altitude

r0 = Results.Trajectory.state(1,1:3);

initialAltitude = ...
    norm(r0) - Results.Constants.Re;

Validation.initialAltitude = initialAltitude;

%% Cx at initial altitude

Validation.initialCx = ...
    Results.Atmosphere.cxInterp(initialAltitude);

%% Reference comparison

if ~isempty(referenceCx)

    Validation.referenceCx = referenceCx;

    Validation.referenceDifference = ...
        Validation.initialCx - referenceCx;

    Validation.referenceDifferencePercent = ...
        (Validation.initialCx - referenceCx) / ...
        referenceCx * 100;

else

    Validation.referenceCx = NaN;
    Validation.referenceDifference = NaN;
    Validation.referenceDifferencePercent = NaN;

end

%% Display results

fprintf('\n');
fprintf('=====================================================\n');
fprintf('          AERODYNAMIC MODEL VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\n');
fprintf('Cx statistics\n');
fprintf('-----------------------------------------------------\n');

fprintf('Minimum Cx         : %.6f\n', ...
    Validation.minimumCx);

fprintf('Maximum Cx         : %.6f\n', ...
    Validation.maximumCx);

fprintf('Initial altitude   : %.3f km\n', ...
    Validation.initialAltitude);

fprintf('Cx at initial alt. : %.6f\n', ...
    Validation.initialCx);

if ~isempty(referenceCx)

    fprintf('\n');
    fprintf('Reference comparison\n');
    fprintf('-----------------------------------------------------\n');

    fprintf('Reference Cx       : %.6f\n', ...
        Validation.referenceCx);

    fprintf('Difference         : %+.6f\n', ...
        Validation.referenceDifference);

    fprintf('Relative difference: %+.3f %%\n', ...
        Validation.referenceDifferencePercent);

end

%% Plot Cx versus altitude

figure;

plot( ...
    h, ...
    Cx, ...
    'LineWidth', 1.5);

hold on;

legendEntries = {'MATLAB model'};

if ~isempty(referenceCx)

    yline( ...
        referenceCx, ...
        '--');

    legendEntries{end+1} = ...
        sprintf('STK reference: C_x = %.2f', referenceCx);

end

xline( ...
    initialAltitude, ...
    ':');

legendEntries{end+1} = ...
    sprintf('Initial altitude: %.1f km', initialAltitude);

grid on;

xlabel('Altitude [km]');
ylabel('C_x');

title('Aerodynamic drag coefficient versus altitude');

legend( ...
    legendEntries, ...
    'Location', 'best');

hold off;

end