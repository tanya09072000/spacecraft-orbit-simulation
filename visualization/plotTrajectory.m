function plotTrajectory(Trajectory, C)
%PLOTTRAJECTORY Visualize propagated spacecraft trajectory.
%
% Input:
%   Trajectory - Propagated trajectory structure
%   C          - Physical constants

%% Extract state vector

x = Trajectory.state(:,1);
y = Trajectory.state(:,2);
z = Trajectory.state(:,3);

%% Compute altitude

r = vecnorm(Trajectory.state(:,1:3),2,2);
h = r - C.Re;

%% 3D trajectory

figure;
[Xe,Ye,Ze] = sphere(100);

surf(C.Re*Xe,...
     C.Re*Ye,...
     C.Re*Ze,...
     'FaceColor',[0.6 0.8 1],...
     'EdgeColor','none',...
     'FaceAlpha',0.4);

hold on
plot3(x, y, z, 'r','LineWidth', 1.5);
grid on;
axis equal;

xlabel('X [km]');
ylabel('Y [km]');
zlabel('Z [km]');

title('Spacecraft trajectory (ECI)');

%% Altitude

figure;
plot(Trajectory.time/3600, h, 'LineWidth', 1.5);
grid on;

xlabel('Time [hours]');
ylabel('Altitude [km]');

title('Altitude versus time');
end