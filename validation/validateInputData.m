function validateInputData(Data)
%VALIDATEINPUTDATA Validate simulation input data.

%% Constants

C = orbConstants();

%% Scenario

if Data.Scenario.duration <= 0

    error('Simulation duration must be greater than zero.');

end

if Data.Scenario.stopTime <= Data.Scenario.separationTime

    error('Stop time must be later than separation time.');

end

%% Spacecraft

if ~isfinite(Data.Spacecraft.mass) || ...
        Data.Spacecraft.mass <= 0

    error('Spacecraft mass must be greater than zero.');

end

if ~isfinite(Data.Spacecraft.area) || ...
        Data.Spacecraft.area <= 0

    error('Reference area must be greater than zero.');

end

if ~isfinite(Data.Spacecraft.Cr) || ...
        Data.Spacecraft.Cr < 0

    error('Reflectivity coefficient Cr must be non-negative.');

end

%% Initial state mode

if ~isfield(Data.InitialState,'mode')

    error('Initial state mode is not specified.');

end

%% Initial state

switch Data.InitialState.mode

    %% Orbital elements

    case "OrbitalElements"

        a = Data.Orbit.a;
        e = Data.Orbit.e;
        i = Data.Orbit.i;
        raan = Data.Orbit.raan;
        argPerigee = Data.Orbit.argPerigee;
        trueAnomaly = Data.Orbit.trueAnomaly;

        %% Check numerical values

        elements = [
            a
            e
            i
            raan
            argPerigee
            trueAnomaly
        ];

        if any(~isfinite(elements))

            error('Orbital elements must contain only finite numeric values.');

        end

        %% Semi-major axis

        if a <= C.Re

            error(['Semi-major axis must be greater than Earth radius. ', ...
                   'Current value: %.3f km.'], a);

        end

        %% Eccentricity

        if e < 0 || e >= 1

            error(['Eccentricity must satisfy 0 <= e < 1 ', ...
                   'for a closed Earth orbit.']);

        end

        %% Inclination

        if i < 0 || i > 180

            error('Inclination must be between 0 and 180 deg.');

        end

        %% Angles

        if raan < 0 || raan >= 360

            error('RAAN must be between 0 and 360 deg.');

        end

        if argPerigee < 0 || argPerigee >= 360

            error('Argument of perigee must be between 0 and 360 deg.');

        end

        if trueAnomaly < 0 || trueAnomaly >= 360

            error('True anomaly must be between 0 and 360 deg.');

        end

        %% Perigee altitude

        perigeeRadius = a * (1 - e);

        perigeeHeight = perigeeRadius - C.Re;

        if perigeeHeight <= 0

            error(['Perigee is inside the Earth. ', ...
                   'Perigee altitude: %.3f km.'], ...
                   perigeeHeight);

        end


    %% State vector

    case "StateVector"

        r = Data.InitialState.position;
        v = Data.InitialState.velocity;

        %% Check dimensions

        if numel(r) ~= 3

            error('Position vector must contain exactly 3 components.');

        end

        if numel(v) ~= 3

            error('Velocity vector must contain exactly 3 components.');

        end

        %% Convert to column vectors

        r = r(:);
        v = v(:);

        %% Check numerical values

        if any(~isfinite(r)) || any(~isfinite(v))

            error('State vector must contain only finite numeric values.');

        end

        %% Position magnitude

        radius = norm(r);

        if radius <= C.Re

            error(['Spacecraft position is inside the Earth. ', ...
                   'Altitude: %.3f km.'], ...
                   radius - C.Re);

        end

        %% Velocity magnitude

        velocity = norm(v);

        if velocity <= 0

            error('Velocity magnitude must be greater than zero.');

        end

        %% Calculate orbital elements

        elements = stateVectorToOrbitalElements( ...
            [r; v], C);

        a = elements(1);
        e = elements(2);

        %% Check orbit type

        if ~isfinite(a) || ~isfinite(e)

            error('Unable to calculate valid orbital elements from the state vector.');

        end

        if e >= 1

            error(['The specified state vector does not define a closed ', ...
                   'Earth orbit (eccentricity = %.4f).'], e);

        end

        %% Perigee altitude

        perigeeRadius = a * (1 - e);

        perigeeHeight = perigeeRadius - C.Re;

        if perigeeHeight <= 0

            error(['State vector results in a trajectory with perigee ', ...
                   'inside the Earth. Perigee altitude: %.3f km.'], ...
                   perigeeHeight);

        end


    otherwise

        error('Unknown initial state mode.');

end

end