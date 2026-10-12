function simulationSummary(Results)

%SIMULATIONSUMMARY Display simulation results in Command Window.
%
% The function displays:
%   - scenario information
%   - spacecraft parameters
%   - initial orbital state
%   - orbit decay
%   - orbital characteristics
%   - propagation information
%   - first communication session
%
% Orbit decay is evaluated between the first and last
% ascending nodes:
%   - semi-major axis
%   - perigee altitude
%   - apogee altitude

%% Extract data

S = Results.Summary;
Data = Results.Data;

%% Header

fprintf('\n');
fprintf('=====================================================\n');
fprintf('                SIMULATION SUMMARY\n');
fprintf('=====================================================\n');

%% Scenario

fprintf('\n');
fprintf('Scenario\n');
fprintf('-----------------------------------------------------\n');

fprintf('Start time          : %s\n', ...
    datestr(Data.Scenario.separationTime, ...
    'dd-mmm-yyyy HH:MM:SS'));

fprintf('Duration            : %.1f days\n', ...
    Data.Scenario.duration / days(1));

%% Models

fprintf('\n');
fprintf('Models\n');
fprintf('-----------------------------------------------------\n');

fprintf('Atmosphere          : %s\n', ...
    Data.Environment.model);

fprintf('Aerodynamics        : %s\n', ...
    Data.Aerodynamics.model);

fprintf('Dynamic model       : Full\n');

%% Spacecraft

fprintf('\n');
fprintf('Spacecraft\n');
fprintf('-----------------------------------------------------\n');

fprintf('Mass                : %.1f kg\n', ...
    Data.Spacecraft.mass);

fprintf('Reference area      : %.3f m^2\n', ...
    Data.Spacecraft.area);

%% Initial state

fprintf('\n');
fprintf('Initial state\n');
fprintf('-----------------------------------------------------\n');

fprintf('Source              : %s\n', ...
    Data.InitialState.source);

fprintf('Semi-major axis     : %.3f km\n', ...
    S.initialElements(1));

fprintf('Eccentricity        : %.6f\n', ...
    S.initialElements(2));

fprintf('Inclination         : %.4f deg\n', ...
    rad2deg(S.initialElements(3)));

%% Final orbital state

fprintf('\n');
fprintf('Final orbital state\n');
fprintf('-----------------------------------------------------\n');

fprintf('Reference point     : Last ascending node\n');

fprintf('Semi-major axis     : %.3f km\n', ...
    S.finalAscendingNodeElements(1));

fprintf('Eccentricity        : %.6f\n', ...
    S.finalAscendingNodeElements(2));

fprintf('Inclination         : %.4f deg\n', ...
    rad2deg(S.finalAscendingNodeElements(3)));

fprintf('RAAN                : %.4f deg\n', ...
    rad2deg(S.finalAscendingNodeElements(4)));

fprintf('Argument of perigee: %.4f deg\n', ...
    rad2deg(S.finalAscendingNodeElements(5)));

fprintf('True anomaly        : %.4f deg\n', ...
    rad2deg(S.finalAscendingNodeElements(6)));

%% Orbit evolution

fprintf('\n');
fprintf('Orbit evolution\n');
fprintf('-----------------------------------------------------\n');

fprintf('Reference interval  : First AN -> Last AN\n\n');

fprintf('Semi-major axis     : %.3f -> %.3f km (%+.3f km)\n', ...
    S.initialSemiMajorAxis, ...
    S.finalSemiMajorAxis, ...
    S.semiMajorAxisChange);

fprintf('Perigee altitude    : %.3f -> %.3f km (%+.3f km)\n', ...
    S.initialPerigeeAltitude, ...
    S.finalPerigeeAltitude, ...
    S.perigeeAltitudeChange);

fprintf('Apogee altitude     : %.3f -> %.3f km (%+.3f km)\n', ...
    S.initialApogeeAltitude, ...
    S.finalApogeeAltitude, ...
    S.apogeeAltitudeChange);

fprintf('Altitude at AN      : %.3f -> %.3f km (%+.3f km)\n', ...
    S.initialAscendingNodeAltitude, ...
    S.finalAscendingNodeAltitude, ...
    S.ascendingNodeAltitudeChange);

%% Orbital characteristics

fprintf('\n');
fprintf('Orbital characteristics\n');
fprintf('-----------------------------------------------------\n');

fprintf('Revolutions completed : %d\n', ...
    S.completedRevolutions);

fprintf('Total revolutions     : %.3f\n', ...
    S.totalRevolutions);

fprintf('Mean orbital period   : %.3f min\n', ...
    S.meanPeriod / 60);

fprintf('Keplerian period      : %.3f min\n', ...
    S.keplerPeriod / 60);

fprintf('Period difference     : %+.3f s\n', ...
    S.periodDifference);

fprintf('Relative difference   : %+.4f %%\n', ...
    S.periodDifferencePercent);

%% Propagation

fprintf('\n');
fprintf('Propagation\n');
fprintf('-----------------------------------------------------\n');

fprintf('First ascending node : %s\n', ...
    datestr(S.firstAscendingNode, ...
    'dd-mmm-yyyy HH:MM:SS.FFF'));

fprintf('Last ascending node : %s\n', ...
    datestr(S.lastAscendingNode, ...
    'dd-mmm-yyyy HH:MM:SS.FFF'));

fprintf('Integration points  : %d\n', ...
    S.integrationPoints);

%% First communication session

fprintf('\n');
fprintf('First communication session\n');
fprintf('-----------------------------------------------------\n');

firstSession = Results.Visibility.firstSession;

if ~isempty(firstSession)

    fprintf('Station             : %s\n', ...
        Results.Visibility.firstStationName);

    fprintf('Start UTC           : %s\n', ...
        datestr(firstSession.startTime, ...
        'dd-mmm-yyyy HH:MM:SS.FFF'));

    fprintf('End UTC             : %s\n', ...
        datestr(firstSession.endTime, ...
        'dd-mmm-yyyy HH:MM:SS.FFF'));

    fprintf('Duration            : %.3f s\n', ...
        firstSession.duration);

    fprintf('Max elevation       : %.3f deg\n', ...
        firstSession.maxElevation);

    fprintf('Max elevation UTC   : %s\n', ...
        datestr(firstSession.maxElevationTime, ...
        'dd-mmm-yyyy HH:MM:SS.FFF'));

else

    fprintf('No communication sessions found.\n');

end

%% Completion message

fprintf('\n');
fprintf('=====================================================\n');
fprintf('Simulation completed successfully.\n');
fprintf('=====================================================\n');
fprintf('\n');

end