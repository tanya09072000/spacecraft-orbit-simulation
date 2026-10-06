function printVisibilitySummary(Visibility)
%PRINTVISIBILITYSUMMARY Print all communication sessions.

fprintf('\n');
fprintf('=====================================================\n');
fprintf('          COMMUNICATION SESSIONS\n');
fprintf('=====================================================\n');

for s = 1:length(Visibility.stationData)

    station = Visibility.stationData(s);

    fprintf('\n');
    fprintf('Station : %s\n', station.name);
    fprintf('-----------------------------------------------------\n');

    sessions = station.sessions;

    if isempty(sessions)

        fprintf('No communication sessions.\n');
        continue;

    end

    for j = 1:length(sessions)

        fprintf('\n');
        fprintf('Session %d\n', j);

        fprintf('Start          : %s UTC\n', ...
            datestr(sessions(j).startTime, ...
            'dd-mmm-yyyy HH:MM:SS.FFF'));

        fprintf('End            : %s UTC\n', ...
            datestr(sessions(j).endTime, ...
            'dd-mmm-yyyy HH:MM:SS.FFF'));

        fprintf('Duration       : %.3f s\n', ...
            sessions(j).duration);

        fprintf('Max elevation  : %.3f deg\n', ...
            sessions(j).maxElevation);

        fprintf('Max elevation time : %s UTC\n', ...
            datestr(sessions(j).maxElevationTime, ...
            'dd-mmm-yyyy HH:MM:SS.FFF'));

    end

end

fprintf('\n');
fprintf('=====================================================\n');

end