function plotVisibility(Visibility)
%PLOTVISIBILITY Plot elevation history for all ground stations.
%
% Input:
%   Visibility - Output of calculateVisibility

for s = 1:length(Visibility.stationData)

    station = Visibility.stationData(s);

    figure;
    plot( ...
        station.time, ...
        station.elevation, ...
        'LineWidth', 1.0);

    hold on;

    yline( ...
        station.minElevation, ...
        '--', ...
        'Minimum elevation');

    grid on;

    xlabel('Time');
    ylabel('Elevation angle [deg]');

    title(['Ground station visibility — ', station.name]);

    legend( ...
        'Elevation', ...
        'Minimum elevation', ...
        'Location', 'best');

    hold off;

end

end