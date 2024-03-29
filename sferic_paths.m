% sferic_paths.m
% Todd Anderson
% November 16 2022
%
% Daily and UT-averaged WWLLN stroke-to-station sferic information.
%
% 0. Animate day of s-s paths
%
% 1. Average whole day of s-s paths
%
% 2. Average month(s) of s-s paths
%   - try averaging in UT: average UT 00:00-00:10, 00:10-00:20, ...,
%   23:50-24:00; can then plot "average day" time series
%   - pay attention to timing here: is averaging a month of data easy to do
%   on a laptop? how easy will it be to do a year?
%       - single day grid_crossings file is about 75 MB
%       - month: 2-3 GB
%       - year: 25-30 GB (too big for laptop to hold in memory!)
%       - can get around this by doing cumulative average.  For each grid
%       location, cumavg(i) = (cumavg(i-1)*(i-1) + gc(i))/i
%       In place: cumavg = (cumavg*(i-1) + gc(i))/i
%
% 3. Average year of s-s paths
%   - will take some time to run getpaths, pathgrid for an entire year
%   - make sure to record # strokes detected by each station for each day
%   of year (in getpaths) --> can use this to decide which high-latitude
%   stations are good representations for simulating new stations
% - try averaging in UT, as above
% - average individual months in UT, to get an idea of seasonal differences

%% 1. day
% constants
c = 299792458;

% average each lat, lon element across 1 day
run_start = datenum(2022, 11, 25);
daystr = string(datestr(run_start, "yyyymmdd"));
% c3file = sprintf("data/sferic_c3_gridcross_10m_%s.mat", daystr);
% plfile = sprintf("data/sferic_pathlength_gridcross_10m_%s.mat", daystr);
gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr);
% s_c3 = importdata(c3file);
% pl = importdata(plfile);
gtd = importdata(gtdfile);

% c3_avg = mean(s_c3, 3, "omitnan");
% pl_avg = mean(pl, 3, "omitnan");
gtd_avg = mean(gtd, 3, "omitnan");

%% 2. month
% constants
c = 299792458;

% average each lat, lon, UT element across 1 month
% requires grid_crossings_10 files for entire time range; either download
% these from flashlight or prepend "/gridstats" to gcfile below and run
% this part on flashlight
run_start = datenum(2022, 1, 01);
run_end = datenum(2022, 1, 31);
run_days = run_start:run_end;
% run_days = datenum(2022, 11, [6, 10, 12, 14, 15, 16, 17, 19, 21, 22, 23, 24]);
run_days = run_days';
%run_days = run_days(run_days ~= datenum(2022, 01, 15));

daystr = string(datestr(run_days, "yyyymmdd"));

% % WWLLN stations
% stationID = 122; % 51:Fairbanks, 52:Sodankyla, 122:Churchill
% stationLat = stations{stationID, 1};
% stationLon = stations{stationID, 2};
% stationName = stations{stationID,3};

% % simulated stations: Toolik, Utqiagvik, Iqaluit, PondInlet, Longyearbyen
% stationLat = 78.2321;
% stationLon = 15.5145;
% stationName = "Longyearbyen";

% cumulative average method: avoid loading entire month of grid_crossings
% at once
% WARNING: any NaNs in first day will be propagated throughout whole
% average!
% load first day, initialize gc_avg

gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr(1));
gc = importdata(gcfile);
gc_cavg = gc;

% gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(1));
% gtd = importdata(gtdfile);
% gtd_cavg = gtd;

% gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr(1));
% gc = importdata(gcfile);
% gc_cavg = gc;
% 
% perpfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr(1));
% perp = importdata(perpfile);
% perp_cavg = perp;

% load subsequent days and calculate cumulative average
for j = 2:length(daystr)
%     gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(j));
%     gtd = importdata(gtdfile);

    gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr(j));
    gc = importdata(gcfile);

%     gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr(j));
%     gc = importdata(gcfile);

%     perpfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr(j));
%     perp = importdata(perpfile);

%     gtd_big = cat(4, gtd_cavg, gtd);
%     gtd_cavg = mean(gtd_big, 4, "omitnan");

    gc_big = cat(4, gc_cavg, gc);
    gc_cavg = mean(gc_big, 4, "omitnan");

%     perp_big = cat(4, perp_cavg, perp);
%     perp_cavg = mean(perp_big, 4, "omitnan");

end

% % calculate quiet day compound standard deviation
% % initialize 4D matrices
% gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(1));
% gtd = importdata(gtdfile);
% gtd_big = gtd;
% gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr(1));
% gc = importdata(gcfile);
% gc_big = gc;
% stdfile = sprintf("data/sferic_std_grouptimediff_gridcross_10m_%s.mat", daystr(1));
% std = importdata(stdfile);
% std_big = std;
% 
% % build 4D matrices
% for m = 2:length(daystr)
%     gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(m));
%     gtd = importdata(gtdfile);
%     gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr(m));
%     gc = importdata(gcfile);
%     stdfile = sprintf("data/sferic_std_grouptimediff_gridcross_10m_%s.mat", daystr(m));
%     std = importdata(stdfile);
% 
%     gtd_big = cat(4, gtd_big, gtd);
%     gc_big = cat(4, gc_big, gc);
%     std_big = cat(4, std_big, std);
%     
% end
% 
% gc_quiet = zeros(size(gtd));
% gtdavg_quiet = zeros(size(gtd));
% std_quiet = zeros(size(gtd));
% 
% for i = 1:size(gtd, 1)
%     for j = 1:size(gtd, 2)
%         for k = 1:size(gtd, 3)
%             [gc_quiet(i,j,k), gtdavg_quiet(i,j,k), std_quiet(i,j,k)] = overallmeanstd(gc_big(i,j,k,:), gtd_big(i,j,k,:), std_big(i,j,k,:));
%         end
%     end
% end

% save("data/sferic_total_gridcrossings_10m_202211_quietavg.mat", "gc_quiet");
% save("data/sferic_grouptimediff_10m_202211_quietavg.mat", "gtd_quietavg");
% save("data/sferic_std_grouptimediff_10m_202211_quietavg.mat", "std_quiet");

% gtd_cavg_file = "data/sferic_grouptimediff_10m_202211_quietavg.mat";
% save(gtd_cavg_file, "gtd_cavg");
% 
% gc_cavg_file = "data/sferic_gridcrossings_10m_202211_quietavg.mat";
% save(gc_cavg_file, "gc_cavg");
% 
% gtd_quietavg = importdata("data/sferic_grouptimediff_10m_202211_quietavg.mat");
% gc_quietavg =  importdata("data/sferic_gridcrossings_10m_202211_quietavg.mat");
% gtd_quiet_sm5 = zeros(size(gtd_quietavg));
% gc_quiet_sm5 = zeros(size(gc_quietavg));
% for i = 1:size(gtd_quiet_sm5,3)
%     gtd_quiet_sm5(:,:,i) = smooth2(gtd_quietavg(:,:,i), 5);
%     gc_quiet_sm5(:,:,i) = smooth2(gc_quietavg(:,:,i), 5);
% end
% 
% save("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat", "gtd_quiet_sm5");
% save("data/sferic_gridcrossings_10m_202211_quietavg_sm5.mat", "gc_quiet_sm5");

%% 3. day - quiet mean
% 
run_start = datenum(2022, 11, 25);
daystr = string(datestr(run_start, "yyyymmdd"));
gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr);
perpfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr);
gcfile = sprintf("data/sferic_gridcrossings_10m_%s.mat", daystr);
gtd = importdata(gtdfile);
perp = importdata(perpfile);
gc = importdata(gcfile);
gtdavg_quiet = importdata("data/sferic_grouptimediff_10m_202211_quietavg.mat");
gtd_quietavg_sm5 = importdata("data/sferic_grouptimediff_10m_202211_quietavg_sm5.mat");

gcpw = gc.*perp;

mlatmesh = importdata("mlatmesh.mat");

%% plot
% whole day average: plot day_avg
% month average: plot gc_cavg(:,:,k); manually input desired frame k or
% loop over k

times = linspace(run_start, run_start+1, 145);
timestring = string(datestr(times, "HH:MM:SS"));
datestring = string(datestr(run_start, "mmmm yyyy"));

[lonmesh, latmesh] = meshgrid(-179.5:179.5,-89.5:89.5);
lsi = importdata("../landseaice/LSI_mask.mat");
lsimask = interp2(lsi.lon_mesh, lsi.lat_mesh, lsi.LSI, lonmesh, latmesh, "nearest");

coastlines = importdata('coastlines.mat');
coastlat = coastlines.coastlat;
coastlon = coastlines.coastlon;
geoidrefvec = [1,90,-180];

% gcpw_threshold = 1;

% daymean = zeros(size(gtd, 3),1);
% nightmean = zeros(size(gtd, 3),1);
% landmean = zeros(size(gtd, 3),1);
% seamean = zeros(size(gtd, 3),1);
% icemean = zeros(size(gtd, 3),1);

for k = 1:size(gc_cavg,3)
% for k = 1:size(gtd, 3)    
% for k = 144
%     gtd_frame = gtd(:,:,k);
%     gtd_quietavg_sm5_frame = gtd_quietavg_sm5(:,:,k);
%     gcpw_frame = gcpw(:,:,k);
%     gcpw_above_threshold = gcpw_frame > gcpw_threshold; 
%     gtd_frame(~gcpw_above_threshold) = NaN;
%     gtd_quietavg_sm5_frame(~gcpw_above_threshold) = NaN;
%     c3plot = gtd_frame - gtd_quietavg_sm5_frame ;
%     c3plot = gtd_quietavg(:,:,k);
%     c3plot = gtd(:,:,k);
    c3plot = gc_cavg(:,:,k);
    
    % terminator test
    [sslat, sslon] = subsolar(times(k));
    night = distance(sslat, sslon, latmesh, lonmesh, 'degrees') > 90;
    nightmesh = zeros(size(latmesh));
    nightmesh(night) = 1;
    
%     daymean(k) = mean(c3plot(~night), "all", "omitnan");
%     nightmean(k) = mean(c3plot(night), "all", "omitnan");
%     landmean(k) = mean(c3plot(lsimask == 1), "all", "omitnan");
%     seamean(k) = mean(c3plot(lsimask == -1), "all", "omitnan");
%     icemean(k) = mean(c3plot(lsimask == 0), "all", "omitnan");



    h = figure(1);
    h.Position = [-1000 -200 980 600];
    hold off
    t = tiledlayout(1,1, "TileSpacing","compact", "Padding", "compact");
    nexttile
%     nexttile([1,2])
    worldmap("World")
    geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
%     contourm(latmesh, lonmesh, mlatmesh, 50:5:70, "g", "LineWidth", 1); % mlat contours
%     contourm(latmesh, lonmesh, nightmesh, 0.5, "Color", [0.8 0.8 0.8], "LineWidth", 1.5); % terminator
    
    
    set(gca,'ColorScale','log');
    crameri('-hawaii');
    caxis([0.01 1E3]);
%     cmap = crameri('-batlow', 256+64);
%     cmap = magma(256);
%     set(gca, 'Colormap', cmap)
%     caxis([0 1]);
%     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
%     caxis([-0.1 0.1]);


%     nexttile
%     %worldmap("World");
%     worldmap([60 90],[-180 180])
%     geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
% %     caxis([0 1]);
% %     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
% %     caxis([0 0.05]);
% 
%     
%     nexttile
%     worldmap([-90 -60],[-180 180])
%     geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
% %     caxis([0 1]);
% %     crameri('tokyo'); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
% %     caxis([0 0.05]);
    cb = colorbar("eastoutside");
%     cb.Layout.Tile = 'east';
%     cb.Label.String = "\omega_0^{ 2}/2c (rad^2 s^{-1} m^{-1})";
    cb.Label.String = "number of paths";
    cb.Label.FontSize = 15;
    cb.FontSize = 15;
%     
    
    
    titlestr = sprintf("average number of WWLLN propagation path traversals\n %s %s-%s", ...
        datestring, timestring(k), timestring(k+1));
%     titlestr = sprintf("average sferic dispersion\nNovember quiet days %s-%s", ...
%        timestring(k), timestring(k+1));
    title(titlestr, "FontSize", 20);

    set(gcf,'color','w');

%     gifname = sprintf('animations/sferic_mean_gtd_%s_magma.gif', daystr);
%     gifname = 'animations/average_paths_202201_lanl.gif';
%     if k == 1
%         gif(gifname);
%     else
%         gif;
%     end

end

%% convert dispersion param to f_c: 
%   dp = (2*pi*f_c)^2/2c
%   f_c = sqrt(2c*dp)/2*pi
fc_daymean = sqrt(2*c*daymean)/(2*pi);
fc_nightmean = sqrt(2*c*nightmean)/(2*pi);
fc_landmean = sqrt(2*c*landmean)/(2*pi);
fc_seamean = sqrt(2*c*seamean)/(2*pi);
fc_icemean = sqrt(2*c*icemean)/(2*pi);

figure(2)
f2 = gca;
hold off
plot(datetime(times(2:end), "ConvertFrom", "datenum"), fc_nightmean./1E3, '-o')
hold on
plot(datetime(times(2:end), "ConvertFrom", "datenum"), fc_daymean./1E3, '-o')
plot(datetime(times(2:end), "ConvertFrom", "datenum"), fc_landmean./1E3, '-^', "Color", [0.5 0.5 0.2])
plot(datetime(times(2:end), "ConvertFrom", "datenum"), fc_seamean./1E3, '-^', "Color", [0.1 0.1 0.8])
plot(datetime(times(2:end), "ConvertFrom", "datenum"), fc_icemean./1E3, '-^', "Color", [0.2 0.2 0.2])
legend("night", "day", "land", "sea", "ice")
% ylabel("\omega_0^{ 2}/2c (rad^2 s^{-1} m^{-1})", "FontSize", 12);
ylabel("f_c (kHz)", "FontSize", 12);
f2.FontSize = 10;
% title("Mean \omega_0^{ 2}/2c for night and day hemispheres and land/sea/ice", "FontSize", 15);
title("Mean cutoff frequency for night and day hemispheres and land/sea/ice", "FontSize", 15);


%% plot average path crossings, perpendicularity, and path crossings weighted by perpendicularity

for k = 1:size(c3_cavg,3)
% for k = 1:size(pg, 3)    
% for k = 1
    gcplot = pl_cavg(:,:,k);
    pgplot = c3_cavg(:,:,k);
    c3plot = gtd_cavg(:,:,k);
%     pplot = pg_cavg(:,:,k);
%     pplot = pg(:,:,k);

    times = linspace(run_start, run_start+1, 145);
    timestring = string(datestr(times, "HH:MM:SS"));
    datestring = string(datestr(times, "mmmm dd yyyy"));
    
    coastlines = importdata('coastlines.mat');
    coastlat = coastlines.coastlat;
    coastlon = coastlines.coastlon;
    geoidrefvec = [1,90,-180];
    
    figure(1)
    hold off
    t = tiledlayout(3,1, "Padding", "compact"); % add "TileSpacing", "compact" if subtitles are not needed
    
    % path crossings
    nexttile
    worldmap("World")
    geoshow(gcplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    set(gca,'ColorScale','log');
    crameri('-hawaii');
    caxis([0.01 1000]);
    cb = colorbar;
    cb.Layout.Tile = 'east';
    titlestr = "average number of stroke-to-station path crossings";
    title(titlestr);
    
    % perpendicularity
    nexttile
    worldmap("World");
    geoshow(pgplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    xlabel("Latitude");
    ylabel("Longitude");
    title("");
    crameri('tokyo');
    caxis([0 1]);
    cb = colorbar;
    cb.Layout.Tile = 'east';

    titlestr = "perpendicularity";
    title(titlestr);
    
    % weighted path crossings
    nexttile
    worldmap('World')
    geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    xlabel("Latitude");
    ylabel("Longitude");
    title("");
    set(gca,'ColorScale','log');
    crameri('-hawaii');
    caxis([0.01 1000]);
    cb = colorbar;
    cb.Layout.Tile = 'east';
    
    titlestr = "path crossings weighted by perpendicularity";
    title(titlestr);

    supertitlestr = sprintf("WWLLN stroke-to-station path statistics \n March 2022 %s-%s", ...
        timestring(k), timestring(k+1));
    title(t, supertitlestr)     ;

%     gifname = sprintf('average_paths_perp_weighted_202203.gif');
%     if k == 1
%         gif(gifname);
%     else
%         gif;
%     end

end
