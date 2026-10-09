function validateInputData(Data)
%VALIDATEINPUTDATA Check simulation input data.

C = orbConstants();

%% Scenario

if seconds(Data.Scenario.duration) <= 0
    error('Simulation duration must be positive.');
end

if Data.Scenario.stopTime <= Data.Scenario.separationTime
    error('Stop time must be later than separation time.');
end

%% Spacecraft

if ~isfinite(Data.Spacecraft.mass) || Data.Spacecraft.mass <= 0
    error('Spacecraft mass must be positive.');
end

if ~isfinite(Data.Spacecraft.area) || Data.Spacecraft.area <= 0
    error('Reference area must be positive.');
end

if ~isfinite(Data.Spacecraft.Cr) || Data.Spacecraft.Cr < 0
    error('Cr must be finite and non-negative.');
end

%% Initial state

if ~isfield(Data.InitialState, 'mode')
    error('Initial state mode is not specified.');
end

switch Data.InitialState.mode

    case "OrbitalElements"

        a = Data.Orbit.a;
        e = Data.Orbit.e;
        angles = [Data.Orbit.i, Data.Orbit.raan, ...
                  Data.Orbit.argPerigee, Data.Orbit.trueAnomaly];

        if any(~isfinite([a, e, angles])) || ...
                a <= C.Re || e < 0 || e >= 1
            error('Invalid orbital elements.');
        end

        if angles(1) < 0 || angles(1) > 180 || ...
                any(angles(2:4) < 0) || any(angles(2:4) >= 360)
            error('Invalid orbital angles.');
        end

        if a*(1-e) <= C.Re
            error('Orbital perigee is inside the Earth.');
        end

    case "StateVector"

        r = Data.InitialState.position(:);
        v = Data.InitialState.velocity(:);

        if numel(r) ~= 3 || numel(v) ~= 3 || ...
                any(~isfinite([r; v]))
            error('Position and velocity must contain 3 finite components each.');
        end

        if norm(r) <= C.Re || norm(v) <= 0
            error('Invalid initial position or velocity.');
        end

        elements = stateVectorToOrbitalElements([r; v], C);
        a = elements(1);
        e = elements(2);

        if ~isfinite(a) || ~isfinite(e) || e < 0 || e >= 1 || ...
                a*(1-e) <= C.Re
            error('State vector does not define a valid closed Earth orbit.');
        end

    otherwise

        error('Unknown initial state mode.');

end

end