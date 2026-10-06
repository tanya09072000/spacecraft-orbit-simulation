function plotLTAN(AscendingHistory, targetLTAN)
%PLOTLTAN Plot the Local Time of Ascending Node.
%
% Input:
%   AscendingHistory - Orbital elements at ascending node crossings
%   targetLTAN       - Target local time of ascending node [hours]

%% Time [days]

time = AscendingHistory.time / 86400;

%% Figure

figure('Name','Local Time of Ascending Node', ...
       'NumberTitle','off');

plot(time, AscendingHistory.ltan, ...
    '-o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 4);

hold on

%% Target LTAN

yline(targetLTAN, '--', ...
    'Target LTAN', ...
    'LineWidth',1.5);

hold off

grid on

xlabel('Time [days]')

ylabel('LTAN [hours]')

title(sprintf('Local Time of Ascending Node (%.2f → %.2f h)', ...
    AscendingHistory.ltan(1), ...
    AscendingHistory.ltan(end)));

margin = 0.1;

ylim([min(AscendingHistory.ltan)-margin,...
      max(AscendingHistory.ltan)+margin]);

end