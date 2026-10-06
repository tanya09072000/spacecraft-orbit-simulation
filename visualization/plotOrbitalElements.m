function plotOrbitalElements(History)
%PLOTORBITALELEMENTS Plot the evolution of orbital elements.
%
% Input:
%   AscendingHistory - Orbital elements at ascending node crossings

%% Time [hours]

time = History.time / 3600;

%% Figure

figure('Name','Orbital Elements','NumberTitle','off');
tiledlayout(4,2,'TileSpacing','compact','Padding','compact');

%% Semi-major axis

nexttile;
plot(time, History.a, 'LineWidth', 1.5);
grid on;
ylabel('a [km]');
title('Semi-major axis');

%% Altitude

nexttile;
plot(time, History.height, 'LineWidth', 1.5);
grid on;
ylabel('h [km]');
title('Altitude');

%% Eccentricity

nexttile;
plot(time, History.e, 'LineWidth', 1.5);
grid on;
ylabel('e');
title('Eccentricity');

%% Inclination

nexttile;
plot(time, History.i, 'LineWidth', 1.5);
grid on;
ylabel('i [deg]');
title('Inclination');

%% Right ascension of ascending node

nexttile;
plot(time, History.raan, 'LineWidth', 1.5);
grid on;
ylabel('RAAN [deg]');
title('Right ascension of ascending node');

%% Argument of perigee

nexttile;
plot(time, History.argPerigee, 'LineWidth', 1.5);
grid on;
ylabel('Argument of perigee [deg]');
title('Argument of perigee');

%% True anomaly

nexttile;
plot(time, History.trueAnomaly, 'LineWidth', 1.5);
grid on;
ylabel('nu [deg]');
title('True anomaly');

end