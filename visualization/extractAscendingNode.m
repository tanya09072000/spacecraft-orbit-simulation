function AscendingHistory = extractAscendingNode(Trajectory, C, Data)
%EXTRACTASCENDINGNODE Extract orbital elements at ascending node crossings.
%
% The ascending node is determined by the spacecraft crossing
% the equatorial plane from south to north (z < 0 -> z >= 0).
%
% The spacecraft state is linearly interpolated to the exact
% zero-crossing of z. Orbital elements are then calculated
% from the interpolated state.
%
% Input:
%   Trajectory - Propagated spacecraft trajectory
%   C          - Physical constants
%   Data       - Simulation input data
%
% Output:
%   AscendingHistory - Orbital elements at ascending node crossings

%% Initialize output

AscendingHistory.time = [];

% Absolute UTC epoch of each ascending node
AscendingHistory.epoch = NaT(0,1);

AscendingHistory.a = [];
AscendingHistory.height = [];
AscendingHistory.e = [];
AscendingHistory.i = [];
AscendingHistory.raan = [];
AscendingHistory.argPerigee = [];
AscendingHistory.trueAnomaly = [];

%% Z-coordinate

z = Trajectory.state(:,3);

n = length(z);

%% Find ascending node crossings

for k = 1:n-1

    % Ascending node:
    % spacecraft crosses equatorial plane from south to north

    if z(k) < 0 && z(k+1) >= 0

        %% Interpolation factor

        alpha = -z(k) / ...
            (z(k+1) - z(k));

        %% Interpolate time
        %
        % Time since beginning of propagation [s]

        tNode = Trajectory.time(k) + ...
            alpha * ...
            (Trajectory.time(k+1) - ...
             Trajectory.time(k));

        %% Interpolate spacecraft state
        %
        % State at exact z = 0 crossing

        stateNode = Trajectory.state(k,:) + ...
            alpha * ...
            (Trajectory.state(k+1,:) - ...
             Trajectory.state(k,:));

        %% Calculate orbital elements at ascending node

        elements = stateVectorToOrbitalElements( ...
            stateNode, C);

        %% Save time since separation

        AscendingHistory.time(end+1,1) = ...
            tNode;

        %% Save absolute UTC epoch

        AscendingHistory.epoch(end+1,1) = ...
            Data.Scenario.separationTime + ...
            seconds(tNode);

        %% Save orbital elements

        AscendingHistory.a(end+1,1) = ...
            elements(1);

        AscendingHistory.height(end+1,1) = ...
            norm(stateNode(1:3)) - C.Re;

        AscendingHistory.e(end+1,1) = ...
            elements(2);

        AscendingHistory.i(end+1,1) = ...
            rad2deg(elements(3));

        AscendingHistory.raan(end+1,1) = ...
            rad2deg(elements(4));

        AscendingHistory.argPerigee(end+1,1) = ...
            rad2deg(elements(5));

        AscendingHistory.trueAnomaly(end+1,1) = ...
            rad2deg(elements(6));

    end

end

%% Calculate LTAN

nNodes = length(AscendingHistory.time);

AscendingHistory.ltan = zeros(nNodes,1);

for k = 1:nNodes

    AscendingHistory.ltan(k) = calculateLTAN( ...
        AscendingHistory.time(k), ...
        AscendingHistory.raan(k), ...
        Data);

end

end