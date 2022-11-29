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
% average each lat, lon element across 1 day
run_start = datenum(2022, 11, 24);
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
% average each lat, lon, UT element across 1 month
% requires grid_crossings_10 files for entire time range; either download
% these from flashlight or prepend "/gridstats" to gcfile below and run
% this part on flashlight
run_start = datenum(2022, 11, 01);
run_end = datenum(2022, 11, 24);
run_days = run_start:run_end;
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
gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(1));
gtd = importdata(gtdfile);
gtd_cavg = gtd;


% load subsequent days and calculate cumulative average
for j = 2:length(daystr)
    gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr(j));
    gtd = importdata(gtdfile);

    % NaN handling: 
    % (1) set all NaNs in gc to current gc_cavg values for those
    % array elements.
    %gtd_nans = find(isnan(gtd));
    %gtd(gtd_nans) = gtd_cavg(gtd_nans);
    %gtd_cavg  = (gtd_cavg.*(j-1) + gtd)./j;

    % find zeros and set these values to NaN
%     gtd_zeros = gtd == 0;
%     gtd(gtd_zeros) = NaN;
    gtd_big = cat(4, gtd_cavg, gtd);
    gtd_cavg = mean(gtd_big, 4, "omitnan");

end


%% plot
% whole day average: plot day_avg
% month average: plot gc_cavg(:,:,k); manually input desired frame k or
% loop over k

times = linspace(run_start, run_start+1, 145);
timestring = string(datestr(times, "HH:MM:SS"));
datestring = string(datestr(run_start, "mmmm dd yyyy"));

[lonmesh, latmesh] = meshgrid(-179.5:179.5,-89.5:89.5);
lsi = importdata("../landseaice/LSI_mask.mat");
lsimask = interp2(lsi.lon_mesh, lsi.lat_mesh, lsi.LSI, lonmesh, latmesh, "nearest");

coastlines = importdata('coastlines.mat');
coastlat = coastlines.coastlat;
coastlon = coastlines.coastlon;
geoidrefvec = [1,90,-180];


daymean = zeros(size(gtd, 3),1);
nightmean = zeros(size(gtd, 3),1);
landmean = zeros(size(gtd, 3),1);
seamean = zeros(size(gtd, 3),1);
icemean = zeros(size(gtd, 3),1);

% for k = 1:size(gtd_cavg,3)
for k = 1:size(gtd, 3)    
% for k = 144
%     c3plot = mean(c3pl_cavg, 3,'omitnan');
%     c3plot = gtd_cavg(:,:,k);
%     pplot = pg_cavg(:,:,k);
%     c3plot = gtd_avg;
    c3plot = gtd(:,:,k);
    
    % terminator test
    [sslat, sslon] = subsolar(times(k));
    night = distance(sslat, sslon, latmesh, lonmesh, 'degrees') > 90;
    %c3plot(night) = 10;
    
    daymean(k) = mean(c3plot(~night), "all", "omitnan");
    nightmean(k) = mean(c3plot(night), "all", "omitnan");
    landmean(k) = mean(c3plot(lsimask == 1), "all", "omitnan");
    seamean(k) = mean(c3plot(lsimask == -1), "all", "omitnan");
    icemean(k) = mean(c3plot(lsimask == 0), "all", "omitnan");

    figure(1)
    hold off
    t = tiledlayout(2,2, "TileSpacing","compact", "Padding", "compact");
    
    nexttile([1,2])
    worldmap("World")
    geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
%     set(gca,'ColorScale','log');
    crameri('-hawaii');
%     caxis([0 1]);
%     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
    caxis([0 0.2]);
    
    nexttile
    %worldmap("World");
    worldmap([60 90],[-180 180])
    geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    xlabel("Latitude");
    ylabel("Longitude");
    title("");
%     set(gca,'ColorScale','log');
    crameri('-hawaii');
%     caxis([0 1]);
%     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
    caxis([0 0.2]);
    
    nexttile
    worldmap([-90 -60],[-180 180])
    geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    xlabel("Latitude");
    ylabel("Longitude");
    title("");
%     set(gca,'ColorScale','log');
    crameri('-hawaii');
%     caxis([0 1]);
%     crameri('tokyo'); % requires "crameri" colormap toolbox
    caxis([0 0.2]);
    cb = colorbar;
    cb.Layout.Tile = 'east';
    cb.Label.String = "rad^2 s^{-1} m^{-1}";
    cb.Label.FontSize = 12;
    
    
    
    titlestr = sprintf("Average sferic c3/path length \n %s %s-%s", ...
        datestring, timestring(k), timestring(k+1));
%     titlestr = sprintf("Average sferic c3/path length \n November 1-16 %s-%s", ...
%        timestring(k), timestring(k+1));
    title(t, titlestr);

    gifname = sprintf('animations/sferic_gtd_%s.gif', daystr);
%     gifname = 'animations/sferic_gtd_mean_20221101-16.gif';
    if k == 1
        gif(gifname);
    else
        gif;
    end

end

figure(2)
hold off
plot(datetime(times(2:end), "ConvertFrom", "datenum"), nightmean, '-o')
hold on
plot(datetime(times(2:end), "ConvertFrom", "datenum"), daymean, '-o')
plot(datetime(times(2:end), "ConvertFrom", "datenum"), landmean, '-^', "Color", [0.5 0.5 0.2])
plot(datetime(times(2:end), "ConvertFrom", "datenum"), seamean, '-^', "Color", [0.1 0.1 0.8])
plot(datetime(times(2:end), "ConvertFrom", "datenum"), icemean, '-^', "Color", [0.2 0.2 0.2])
legend("night", "day", "land", "sea", "ice")
ylabel("c3/d (rad^2 s^{-1} m^{-1})")    
title("Mean c3/d for night and day hemispheres and land/sea/ice")


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

    gifname = sprintf('average_paths_perp_weighted_202203.gif');
    if k == 1
        gif(gifname);
    else
        gif;
    end

end
