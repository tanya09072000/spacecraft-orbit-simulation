function Visibility = calculateVisibility(Trajectory, Data, C)
%CALCULATEVISIBILITY Calculate all communication sessions
% with all available ground stations.
%
% Input:
%   Trajectory - Propagated spacecraft trajectory
%   Data       - Simulation input data
%   C          - Physical constants
%
% Output:
%   Visibility - Visibility data for all ground stations.

%% Ground stations

Stations = Data.Station;
nStations = length(Stations);

%% Absolute trajectory time

time = Data.Scenario.separationTime + ...
    seconds(Trajectory.time);

% All visibility times are stored in UTC

time.TimeZone = 'UTC';

nPoints = length(time);

%% Initialize output

Visibility.stationData = struct([]);

%% Calculate visibility for each station

for s = 1:nStations

    station = Stations(s);

    elevation = zeros(nPoints, 1);

    %% Calculate elevation history

    for k = 1:nPoints

        elevation(k) = calculateElevation( ...
            Trajectory.state(k,1:3)', ...
            time(k), ...
            station, ...
            C);

    end

    %% Visibility condition

    visible = elevation >= station.minElevation;

    %% Find visibility intervals

    dVisible = diff([false; visible; false]);

    starts = find(dVisible == 1);
    ends   = find(dVisible == -1) - 1;

    nSessions = length(starts);

    %% Initialize session data

    sessions = struct( ...
        'startTime', {}, ...
        'endTime', {}, ...
        'duration', {}, ...
        'maxElevation', {}, ...
        'maxElevationTime', {});

    %% Calculate all sessions

    for j = 1:nSessions

        startIndex = starts(j);
        endIndex   = ends(j);

        %% Initial interval boundaries

        startTime = time(startIndex);
        endTime = time(endIndex);

        %% Refine start boundary

        if startIndex > 1

            t1 = time(startIndex - 1);
            t2 = time(startIndex);

            e1 = elevation(startIndex - 1);
            e2 = elevation(startIndex);

            startTime = t1 + ...
                seconds((station.minElevation - e1) * ...
                seconds(t2 - t1) / ...
                (e2 - e1));

        end

        %% Refine end boundary

        if endIndex < nPoints

            t1 = time(endIndex);
            t2 = time(endIndex + 1);

            e1 = elevation(endIndex);
            e2 = elevation(endIndex + 1);

            endTime = t1 + ...
                seconds((station.minElevation - e1) * ...
                seconds(t2 - t1) / ...
                (e2 - e1));

        end

        %% Maximum elevation

        [maxElevation, localIndex] = ...
            max(elevation(startIndex:endIndex));

        maxIndex = startIndex + localIndex - 1;

        %% Save session

        sessions(j).startTime = startTime;

        sessions(j).endTime = endTime;

        sessions(j).duration = ...
            seconds(endTime - startTime);

        sessions(j).maxElevation = ...
            maxElevation;

        sessions(j).maxElevationTime = ...
            time(maxIndex);

    end

    %% Save station data

    Visibility.stationData(s).name = station.name;

    Visibility.stationData(s).time = time;

    Visibility.stationData(s).elevation = elevation;

    Visibility.stationData(s).visible = visible;

    Visibility.stationData(s).sessions = sessions;

    Visibility.stationData(s).minElevation = ...
        station.minElevation;

end

%% Find first communication session

firstStart = NaT;
firstStation = NaN;
firstSession = [];

for s = 1:nStations

    sessions = Visibility.stationData(s).sessions;

    if isempty(sessions)
        continue;
    end

    % First session for this station
    session = sessions(1);

    % Compare with the current first session
    if isnat(firstStart) || session.startTime < firstStart

        firstStart = session.startTime;
        firstStation = s;
        firstSession = session;

    end

end

%% Save first communication session

Visibility.firstSession = firstSession;
Visibility.firstStationIndex = firstStation;

if ~isnan(firstStation)

    Visibility.firstStationName = ...
        Visibility.stationData(firstStation).name;

else

    Visibility.firstStationName = "";

end

end