function plotAtmosphere(Atmosphere, Environment)

%% Density

figure;
semilogy(Atmosphere.height,...
         Atmosphere.rho,...
         'LineWidth',1.5);

grid on;

xlabel('Altitude [km]');
ylabel('Density [kg/m^3]');

title(sprintf('Atmospheric density (%s)', Environment.model));

%% Drag coefficient

figure;
plot(Atmosphere.height,...
     Atmosphere.cx,...
     'LineWidth',1.5);

grid on;

xlabel('Altitude [km]');
ylabel('C_x');

title(sprintf('Free-molecular drag coefficient (%s)', ...
              Environment.model));

end