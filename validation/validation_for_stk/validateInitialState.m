function validateInitialState(Data, C)
%VALIDATEINITIALSTATE Check consistency of initial state.

elements = stateVectorToOrbitalElements( ...
    Data.InitialState.y0, C);

fprintf('\n');
fprintf('=====================================================\n');
fprintf('           INITIAL STATE VALIDATION\n');
fprintf('=====================================================\n');

fprintf('\nInitial orbital elements\n');
fprintf('-----------------------------------------------------\n');

fprintf('a    = %.9f km\n', elements(1));
fprintf('e    = %.12f\n', elements(2));
fprintf('i    = %.9f deg\n', rad2deg(elements(3)));
fprintf('RAAN = %.9f deg\n', rad2deg(elements(4)));
fprintf('omega= %.9f deg\n', rad2deg(elements(5)));
fprintf('nu   = %.9f deg\n', rad2deg(elements(6)));

fprintf('\nInitial Cartesian state\n');
fprintf('-----------------------------------------------------\n');

fprintf('x  = %.12f km\n', Data.InitialState.y0(1));
fprintf('y  = %.12f km\n', Data.InitialState.y0(2));
fprintf('z  = %.12f km\n', Data.InitialState.y0(3));

fprintf('vx = %.12f km/s\n', Data.InitialState.y0(4));
fprintf('vy = %.12f km/s\n', Data.InitialState.y0(5));
fprintf('vz = %.12f km/s\n', Data.InitialState.y0(6));

fprintf('=====================================================\n');

end