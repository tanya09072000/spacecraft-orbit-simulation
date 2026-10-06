function plotPerturbations(Trajectory)
%PLOTPERTURBATIONS Plot perturbing accelerations.
%
% Input:
%   Trajectory - Propagated trajectory with perturbation accelerations

%% Time [days]

time = Trajectory.time / 86400;

%% Figure

figure('Name','Perturbing Accelerations','NumberTitle','off');

semilogy(time, Trajectory.accelerations.norm.J2, ...
    'LineWidth',1.5);
hold on

semilogy(time, Trajectory.accelerations.norm.drag, ...
    'LineWidth',1.5);

semilogy(time, Trajectory.accelerations.norm.SRP, ...
    'LineWidth',1.5);

semilogy(time, Trajectory.accelerations.norm.sun, ...
    'LineWidth',1.5);

semilogy(time, Trajectory.accelerations.norm.moon, ...
    'LineWidth',1.5);

grid on
box on

xlabel('Time [days]');
ylabel('Acceleration [km/s^2]');

title('Perturbing Accelerations');

legend( ...
    'J2', ...
    'Atmospheric drag', ...
    'Solar radiation pressure', ...
    'Sun gravity', ...
    'Moon gravity', ...
    'Location','best');