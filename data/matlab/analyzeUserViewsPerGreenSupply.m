simulation = import_greencdnusersimulation('green_cdn_user_simulation.csv', 2, 51);
simulation.Time=datetime(simulation.Time,'InputFormat','MM/dd/yy HH:mm');
simulation=sortrows(simulation,'Time');
x=simulation.Time;
demand_wst=simulation.usrUSWest;
demand_ctl=simulation.usrUSCentral;
demand_est=simulation.usrUSEast;

supply_wst=simulation.grnUSWest;
supply_ctl=simulation.grnUSCentral;
supply_est=simulation.grnUSEast;

figure
subplot(2,1,1);
[hAx,hAy1,hAy2]=plotyy(x,demand_wst,[x,x],[demand_ctl,demand_est]);
datetick('x','HH:MM')
xlabel('Date Time')
ylabel('Simulated User Demand KCPUs')
%hAy2(1).LineStyle = '-.';
hAy2(1).LineWidth = 1.75;
hAy2(1).Marker = '+';

%hAy2(2).LineStyle = '-.';
hAy2(2).LineWidth = 0.55;
hAy2(2).Marker = '*';

%hAy1.LineStyle = '-.';
hAy1.LineWidth = 1.75;
hAy1.Marker = 'o';
legend('US West','US Central','US East');

subplot(2,1,2);
[hAxx,hAw1,hAw2]=plotyy(x,supply_wst,[x,x],[supply_ctl,supply_est]);
datetick('x','HH:MM');
xlabel('Date Time')
ylabel('Simulated Green Power (MW)')
hAw2(1).LineWidth = 1.75;
hAw2(1).Marker = '+';
hAw2(2).LineWidth = 0.55;
hAw2(2).Marker = '*';
hAw1.LineWidth = 1.75;
hAw1.Marker = 'o';
legend('US West','US Central','US East');
