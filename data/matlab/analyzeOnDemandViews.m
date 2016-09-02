simulation = import_ondemandvidviews('on_demand_vid_views.csv', 2, 49);
simulation.Time=datetime(simulation.Time,'InputFormat','MM/dd/yy HH:mm');
simulation=sortrows(simulation,'Time');
x=simulation.Time;

t=datetime(15,10,1);
dt=x-t;
hour=hours(dt);
views=simulation.Views

[xData, yData] = prepareCurveData( hour, views );
% Set up fittype and options.
ft = fittype( 'smoothingspline' );
opts = fitoptions( 'Method', 'SmoothingSpline' );
opts.SmoothingParam = 0.979724658925069;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'On-Demand Views per minute distribution' );
h = plot( fitresult, xData, yData);
set(h,'color','b');
set(h,'LineWidth',1.75);
xlabel('Time 1-hour increments')
ylabel('On-Demand Views per minute K')

%figure
%plot(x,views);
%datetick('x','HH:MM');
%xlabel('Time');
%ylabel('Observed On-Demand Users Views');
