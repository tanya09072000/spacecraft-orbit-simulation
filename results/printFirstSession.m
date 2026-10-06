function printFirstSession(Visibility)
%PRINTFIRSTSESSION Display the first communication session.

fprintf('\n============================================\n');
fprintf('       FIRST COMMUNICATION SESSION\n');
fprintf('============================================\n');

if ~isempty(Visibility.firstSession)

    session = Visibility.firstSession;

    fprintf('Station: %s\n', ...
        Visibility.firstStationName);

    fprintf('Start UTC: %s\n', ...
        datestr(session.startTime, ...
        'dd-mmm-yyyy HH:MM:SS.FFF'));

    fprintf('End UTC:   %s\n', ...
        datestr(session.endTime, ...
        'dd-mmm-yyyy HH:MM:SS.FFF'));

    fprintf('Duration:  %.3f s\n', ...
        session.duration);

    fprintf('Max elevation: %.3f deg\n', ...
        session.maxElevation);

    fprintf('Max elevation UTC: %s\n', ...
        datestr(session.maxElevationTime, ...
        'dd-mmm-yyyy HH:MM:SS.FFF'));

else

    fprintf('No communication sessions found.\n');

end

fprintf('============================================\n');

end