% pg_Figures.m
% Todd Anderson
% 12 Nov 2019
%
% This script makes figures for the VLF Attenuation Detection paper.
% 
%% Load figure variables

%load('20170906_attenplotvars.mat');
load('20170910_attenplotvars.mat');

% load('stations.mat');
% stnum = stations(1:122,1:2);
% stnum = cell2mat(stnum);
% stlat = stnum(:,1);
% stlon = stnum(:,2);

%% Figure 1: Sample stroke-station path distribution

% 2017 09 06
%t = 71;

% 2017 09 10
t = 95;

figure(1);
colormap(parula);
hold off;
geoshow(log10(grid_crossings(:,:,t)), geoidrefvec, 'DisplayType','texturemap');
hold on;
geoshow(coastlat, coastlon, 'Color', 'black');
geoshow(stlat,stlon,'Color','red','DisplayType','point','Marker','^','MarkerSize',5);
cb = colorbar('southoutside');
label = cb.Label;
label.String = ['Number of stroke-station path crossings, ',datestr(time_10m(t))];
label.FontSize = 16;
caxis([0 3]);
cb.Ticks = [0 1 2 3];
cb.TickLabels = {'10^0', '10^1', '10^2', '10^3'};

xlim([-180 180]);
ylim([-90 90]);

xlabel(['Latitude (' char(176) ')']);
ylabel(['Longitude (' char(176) ')']);

%% Figure 2: Comparison between D-RAP HF attenuation regions and WWLLN VLF atten regions

% 2017 09 06
t = 73; % 12:10 UT

% 2017 09 10
%t = 97; % 16:10 UT

% atten contour
% cspec: [-1,-3,-5,-6,-7,-9]
latplot = latc(:,4,t);
lonplot = lonc(:,4,t);

% % caribbean region
% [latplot,lonplot] = scircle1(17.85,-73.15,km2deg(1000));

figure(2);
colormap(jet);
hold off;
geoshow(dB_gridcross_sm12(:,:,t), geoidrefvec, 'DisplayType','surface');
hold on;
geoshow(coastlat, coastlon, 'Color', 'black');
geoshow(ss_lat(t),ss_lon(t),'DisplayType','Point');
geoshow(latplot,lonplot,'Color','red','LineWidth',2);
cb = colorbar('southoutside');
label = cb.Label;
label.String = ['Attenuation of stroke-station path crossings (dB) ',datestr(time_10m(t))];
label.FontSize = 16;
caxis([-10 10]);
xlim([-180 180]);
ylim([-90 90]);

xlabel(['Latitude (' char(176) ')']);
ylabel(['Longitude (' char(176) ')']);

%% Figure 3: VLF attenuation region radius v. GOES-13 X-ray irradiance

figure(4);
hold off;
yyaxis left;
plot(time_10m,maxrad(:,4),'LineWidth',1);
ylabel(['Attenuation region radius (' char(176) ')']);

yyaxis right;
semilogy(time_num_20,xrs_AFLUX_20,'LineWidth',1);
ylabel('X-ray irradiance (W/m^2)');

title('6 dB Attenuation region radius v. GOES-13 X-ray irradiance, 2017 09 06');

day_start = datenum(2017,09,06,0,0,0);
day_end = datenum(2017,09,07,0,0,0);

xlim([day_start day_end]);

ax = gca;
set(ax,'Xtick',linspace(day_start,day_end,25));
ax.XMinorTick = 'off';
datetick('x', 'hh', 'keepticks');

xlabel('UT hour, 2017 09 06');


%% Figure 4: WWLLN stroke rate for Caribbean region v. GOES X-ray irradiance
% see haiti1000_relative_atten.m, %%xrays (figure 12)
