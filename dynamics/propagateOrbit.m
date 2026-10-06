function Trajectory = propagateOrbit(Data, C)
%PROPAGATEORBIT Numerically propagate the spacecraft orbit.
%
% Input:
%   Data - Simulation input data
%   C    - Physical constants
%
% Output:
%   Trajectory - Propagated spacecraft trajectory

%% Initial state

y0 = Data.InitialState.y0;

%% Integrator settings

options = odeset('RelTol', 1e-12, 'AbsTol', 1e-14, 'MaxStep', 1);

Trajectory.time = [];
Trajectory.state = [];

currentTime = 0;
yCurrent = y0;
updateStep = seconds(Data.Environment.updateStep);
tEnd = seconds(Data.Scenario.duration);

%% Propagation

if Data.Model.drag
    
    % Atmosphere is updated according to Environment.updateStep

    nSteps = ceil(seconds(Data.Scenario.duration) / updateStep);

    for step = 1:nSteps

        currentDate = Data.Scenario.separationTime + seconds((step-1)*updateStep);

        Data.Atmosphere = buildAtmosphere( ...
            Data,...
            currentDate,...
            yCurrent(1:3),...
            C);

        tspan = [currentTime, min(currentTime + updateStep, tEnd)];
        
        [t,y] = ode113( ...
            @(t,y) orbitalDynamics(t,y,C,Data), ...
            tspan,...
            yCurrent,...
            options);

        %% Store results
        
        if step == 1
        
            Trajectory.time = t;
            Trajectory.state = y;
        
        else
        
            Trajectory.time = [Trajectory.time; t(2:end)];
            Trajectory.state = [Trajectory.state; y(2:end,:)];
        
        end
        
        
        yCurrent = y(end,:)';
        currentTime = t(end);

    end
    
    else

    %% Propagation without atmospheric drag

    tspan = [0, tEnd];

    [t,y] = ode113( ...
        @(t,y) orbitalDynamics(t,y,C,Data), ...
        tspan,...
        yCurrent,...
        options);

    Trajectory.time = t;
    Trajectory.state = y;

end

end
