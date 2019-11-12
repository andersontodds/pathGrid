% pg_flareContour.m
% 13 January 2018
%
% Quantifies attenuation effect of solar flares on the Earth-ionosphere
% waveguide using following assumptions:
%   1.  Attenuation region is small-circular, i.e. has no azimuthal
%       dependence
%   2.  Effect is centered on subsolar point
%
% Outline:
%   *   Compute difference of 10-minute stroke-station paths from 1-hour
%       trailing average with pg_diffcross; convert to percentage
%       difference
%   *   Guess attenuation region = [whole earth or dayside only]
%   *   Compute average diff_perc_gridcross in this region
%   *   Average <= -75%? [or -90%, or -50%, ...]
%       y   break
%       n   shrink region radius by 1 [2? 5?] degrees; repeat
%   *   Draw contours around regions of at least 75% [90%, 50%] attenuation
%           

%% Load/initialize

load('grid_crossings_10m_20170906.mat');
load('d_gridcross_10m_20170906.mat');   % difference from trailing mean
load('mmed_gridcross_10m_20170906.mat');  % 1-hour trailing median
load coastlines;
geoidrefvec = [1,90,-180];

starttime = datenum(2017,09,06,00,10,00);
stoptime = datenum(2017,09,07,00,00,00);
frames = 144;
time_10m = linspace(starttime,stoptime,frames);

% Get frame of d_gridcross
% 20170910 frame for time = 16:10:00; t = 97
f = 1:1:frames;
gridcross_frame = grid_crossings(:,:,f);
diffcross_frame = d_gridcross(:,:,f);
mmed_frame = gridcross_mmed(:,:,f);

dB_gridcross = 10*log10(grid_crossings./gridcross_mmed);

% grid_crossings_add001 = grid_crossings + 0.001;
% gridcross_mmed_add001 = gridcross_mmed + 0.001;
% dB_gridcross_add001 = 10*log10(grid_crossings_add001./gridcross_mmed_add001);

%f_gridcross = gridcross_frame./mm_frame;    % fraction grid_crossings compared to 1-hour trailing mean
%perc_diffcross = (diffcross_frame./mm_frame)*100;

% Subsolar points calculated from timeanddate.com/worldclock/sunearth.html
% 2017 09 06: 6* 15' N, -02* 56' E = 
% ss20170906 = dms2degrees([6 15 0; -2 56 0]);
% 2017 09 10: 4* 41' N, -63* 17' E = 
% ss20170910 = dms2degrees([4 41 0; -63 17 0]);
% 2017 09 28:

%[ss_lat,ss_lon] = subsolar(2017,09,10,15,10:10:120,0);
[ss_lat,ss_lon] = subsolar(2017,09,06,00,10:10:1440,0);

%% 2D smoothing

% diffcross_frame_sm1 = movmean(diffcross_frame,10,1);
% diffcross_frame_sm2 = movmean(diffcross_frame,10,2);
% diffcross_frame_sm12 = movmean(diffcross_frame_sm1,10,2);
% diffcross_frame_sm21 = movmean(diffcross_frame_sm2,10,1);


%% Loop

cspec = [-1,-3,-5];

[latc,lonc,maxrad] = pg_attencontour(dB_gridcross,ss_lat,ss_lon,cspec);

% lons = -180:1:179;
% lats = -90:1:89;
% [long,latg] = meshgrid(lons,lats);
% 
% diff_mean = 1;
% s = 0;
% 
% while diff_mean > .5
% 
%     [latc,lonc] = scircle1(ss_point(1),ss_point(2),90-s);
%     
%     in_l = inpolygon(long,latg,lonc,latc);
%     in = in_l.*1;
%     in(in == 0) = NaN;
%     
%     diff_in = f_gridcross.*in;
%     
%     diff_mean = mean(diff_in(:),'omitnan');
%     
%     s = s + 1;
% 
% end
% 
% while diff_mean > .4
% 
%     [latc2,lonc2] = scircle1(ss_point(1),ss_point(2),90-s);
%     
%     in_l = inpolygon(long,latg,lonc2,latc2);
%     in = in_l.*1;
%     in(in == 0) = NaN;
%     
%     diff_in = f_gridcross.*in;
%     
%     diff_mean = mean(diff_in(:),'omitnan');
%     
%     s = s + 1;
% 
% end
% 
% while diff_mean > .3
% 
%     [latc3,lonc3] = scircle1(ss_point(1),ss_point(2),90-s);
%     
%     in_l = inpolygon(long,latg,lonc3,latc3);
%     in = in_l.*1;
%     in(in == 0) = NaN;
%     
%     diff_in = f_gridcross.*in;
%     
%     diff_mean = mean(diff_in(:),'omitnan');
%     
%     s = s + 1;
% 
% end

%% Plot
% for nplot = 1:length(f)
%     
%     latplot = latc(:,:,nplot);
%     lonplot = lonc(:,:,nplot);
%     
%     figure(2);
%     hold off;
%     colormap(jet);
%     geoshow(diffcross_frame(:,:,nplot),geoidrefvec,'DisplayType','texturemap');
%     hold on;
%     geoshow(coastlat,coastlon,'Color','black');
%     geoshow(latplot(:),lonplot(:),'Color','white','LineWidth',2);
%     
%     
%     cb = colorbar('southoutside');
%     label = cb.Label;
%     label.String = ['Diff from hourly trailing mean: Number of sferic crossings at grid location ',datestr(time_10m(f(nplot)))];
%     label.FontSize = 11;
%     caxis([-50 50]);
%     
%     drawnow;
% 
% end

save('20170906_attencont_dB_lat.mat','latc');
save('20170906_attencont_dB_lon.mat','lonc');
save('20170906_attencont_dB_maxrad.mat','maxrad');
