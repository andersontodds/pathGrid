% perp_paths.m
% Todd Anderson
% September 27 2022
%
% Average WWLLN stroke-to-station path crossings for increasingly large
% time period in order to get nominal s-s path distributions.
%
% 1. Average whole day of s-s paths
%   - this is probably fast enough to do on a laptop
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
run_start = datenum(2022, 11, 01);
daystr = string(datestr(run_start, "yyyymmdd"));
pgfile = sprintf("data/sferic_perp_gridcross_10m_%s.mat", daystr);
pg = importdata(pgfile);

gtdfile = sprintf("data/sferic_grouptimediff_gridcross_10m_%s.mat", daystr);
gtd = importdata(gtdfile);

gtd_pg = gtd.*pg;

%pg_avg = mean(pg, 3, "omitnan");

%% 2. month
% average each lat, lon, UT element across 1 month
% requires grid_crossings_10 files for entire time range; either download
% these from flashlight or prepend "/gridstats" to gcfile below and run
% this part on flashlight
run_start = datenum(2022, 1, 01);
run_end = datenum(2022, 1, 31);
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
gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr(1));
% pgfile = sprintf("data/perp_gridcross_10m_%s.mat", daystr(1));

gc = importdata(gcfile);
gc_cavg = gc;

% pg = importdata(pgfile);
% pg_cavg = pg;

% gcp = gc.*pg;
% gcp_cavg = gcp;

% load subsequent days and calculate cumulative average
for j = 2:length(daystr)
    gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr(j));
%     pgfile = sprintf("data/perp_gridcross_10m_%s.mat", daystr(j));
    
    gc = importdata(gcfile);
%     pg = importdata(pgfile);

%     gcp = gc.*pg;

    % NaN handling: set all NaNs in gc to current gc_cavg values for those
    % array elements.
%     gcp_nans = find(isnan(gcp));
%     gcp(gcp_nans) = gcp_cavg(gcp_nans);
%     gcp_cavg  = (gcp_cavg.*(j-1) + gcp)./j;
% 
%     pg_nans = find(isnan(pg));
%     pg(pg_nans) = pg_cavg(pg_nans);
%     pg_cavg  = (pg_cavg.*(j-1) + pg)./j;

    gc_nans = find(isnan(gc));
    gc(gc_nans) = gc_cavg(gc_nans);
    gc_cavg  = (gc_cavg.*(j-1) + gc)./j;

end


%% plot
% whole day average: plot day_avg
% month average: plot gc_cavg(:,:,k); manually input desired frame k or
% loop over k
% for k = 1:size(pg_cavg,3)
for k = 1:size(gc_cavg, 3)    
% for k = 1
%     pplot = gcp_cavg(:,:,k);
%     pplot = pg_cavg(:,:,k);
    pplot = gc_cavg(:,:,k);

    times = linspace(run_start, run_start+1, 145);
    timestring = string(datestr(times, "HH:MM:SS"));
    daystring = string(datestr(times, "mmmm dd"));
    
    coastlines = importdata('coastlines.mat');
    coastlat = coastlines.coastlat;
    coastlon = coastlines.coastlon;
    geoidrefvec = [1,90,-180];
    
    h = figure(1);
    h.Position = [-1000 -200 980 600];
    hold off
%     t = tiledlayout(2,2, "TileSpacing","compact", "Padding", "compact");
    
%     nexttile([1,2])
    worldmap("World")
    geoshow(pplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    set(gca,'ColorScale','log');
    crameri('-hawaii');
    caxis([1E-2 1E3]);
    cb = colorbar("eastoutside");
%     cb.Layout.Tile = 'east';
%     cb.Label.String = "\omega_0^{ 2}/2c (rad^2 s^{-1} m^{-1})";
    cb.Label.String = "number of paths";
    cb.Label.FontSize = 15;
    cb.FontSize = 15;
%     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
%     caxis([0 1]);
    
%     nexttile
%     %worldmap("World");
%     worldmap([60 90],[-180 180])
%     geoshow(pplot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     xlabel("Latitude");
%     ylabel("Longitude");
%     title("");
%     set(gca,'ColorScale','log');
%     crameri('-hawaii');
%     caxis([0 0.2]);
% %     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
% %     caxis([0 1]);
%     
%     nexttile
%     worldmap([-90 -60],[-180 180])
%     geoshow(pplot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     xlabel("Latitude");
%     ylabel("Longitude");
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
%     caxis([0 0.2]);
% %     crameri('tokyo'); % requires "crameri" colormap toolbox
% %     caxis([0 1]);
%     cb = colorbar;
%     cb.Layout.Tile = 'east';
    
    
    titlestr = sprintf("average number of WWLLN propagation path traversals\n %s %s-%s", ...
        datestring, timestring(k), timestring(k+1));
%     titlestr = sprintf("Average stroke-to-station paths weighted by perpendicularity \n November %s %s-%s", ...
%         daystring(k), timestring(k), timestring(k+1));
%     titlestr = sprintf("WWLLN stroke-to-station path perpendicularity \n March 01 2022 %s-%s", ...
%         timestring(k), timestring(k+1));
    title(titlestr, FontSize=20);
    set(gcf,'color','w');
    %title(t, "Average number of WWLLN stroke-to-station path crossings in a 10 minute period, March 30, 2022");

    gifname = 'animations/average_paths_202201_lanl.gif';
    if k == 1
        gif(gifname);
    else
        gif;
    end

end

%% plot average path crossings, perpendicularity, and path crossings weighted by perpendicularity

for k = 1:size(pg_cavg,3)
% for k = 1:size(pg, 3)    
% for k = 1
    gcplot = gc_cavg(:,:,k);
    pgplot = pg_cavg(:,:,k);
    pplot = gcp_cavg(:,:,k);
%     pplot = pg_cavg(:,:,k);
%     pplot = pg(:,:,k);

    times = linspace(run_start, run_start+1, 145);
    timestring = string(datestr(times, "HH:MM:SS"));
    
    
    coastlines = importdata('coastlines.mat');
    coastlat = coastlines.coastlat;
    coastlon = coastlines.coastlon;
    geoidrefvec = [1,90,-180];
    
    figure(1)
    set(gcf,'color','w');
    hold off
    t = tiledlayout(1,1, "Padding", "compact"); % add "TileSpacing", "compact" if subtitles are not needed
    
%     % path crossings
%     nexttile
%     worldmap("World")
%     geoshow(gcplot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     set(gca,'ColorScale','log');
%     crameri('-hawaii');
%     caxis([0.01 1000]);
%     cb = colorbar;
%     cb.Layout.Tile = 'east';
%     cb.FontSize = 20;
%     cb.Label.String = "number of paths";
%     cb.Label.FontSize = 20;
%     titlestr = sprintf("average number of stroke-to-station path crossings\nNovember 2022 %s-%s", ...
%         timestring(k), timestring(k+1));
%     title(titlestr, "FontSize", 20);
    
%     % perpendicularity
%     nexttile
%     worldmap("World");
%     geoshow(pgplot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","white");
% 
%     title("");
%     crameri('tokyo');
%     caxis([0 1]);
%     cb = colorbar;
%     cb.Layout.Tile = 'east';
%     cb.FontSize = 20;
%     cb.Label.String = "perpendicularity";
%     cb.Label.FontSize = 20;
% 
%     titlestr = sprintf("path perpendicularity\nNovember 2022 %s-%s", ...
%         timestring(k), timestring(k+1));
%     title(titlestr, "FontSize", 20);
%     
    % weighted path crossings
    nexttile
    worldmap('World')
    geoshow(pplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color", "black");
    
    title("");
    set(gca,'ColorScale','log');
    caxis([0.01 1000]);
    cmap = crameri('-roma', 256+2*64);
    set(gca, 'Colormap',cmap(65:256+64, :))
    cb = colorbar;
    cb.Layout.Tile = 'east';
    cb.FontSize = 15;
    cb.Label.String = "number of paths";
    cb.Label.FontSize = 15;
    
    titlestr = sprintf("equivalent average perpendicular paths\nMarch 2022 %s-%s", ...
        timestring(k), timestring(k+1));
    title(titlestr, "FontSize", 20);

%     supertitlestr = sprintf("WWLLN stroke-to-station path statistics \n November 2022 %s-%s", ...
%         timestring(k), timestring(k+1));
%     title(t, supertitlestr);

%     gifname = sprintf('perp_weighted_paths_202203_medium.gif');
%     if k == 1
%         gif(gifname);
%     else
%         gif;
%     end

end
