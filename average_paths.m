% average_paths.m
% Todd Anderson
% June 24 2022
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
daystr = "20220330";
gcfile = sprintf("grid_crossings_10m_%s.mat", daystr);
gc = importdata(gcfile);

day_avg = mean(gc, 3, "omitnan");

%% 2. month
% average each lat, lon, UT element across 1 month
% requires grid_crossings_10 files for entire time range; either download
% these from flashlight or prepend "/gridstats" to gcfile below and run
% this part on flashlight
run_start = datenum(2022, 03, 01);
run_end = datenum(2022, 03, 31);
run_days = run_start:run_end;
run_days = run_days';

daystr = string(datestr(run_days, "yyyymmdd"));

% cumulative average method: avoid loading entire month of grid_crossings
% at once
% WARNING: any NaNs in first day will be propagated throughout whole
% average!
% load first day, initialize gc_avg
gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr(1));
gc = importdata(gcfile);
gc_cavg = gc;

% load subsequent days and calculate cumulative average
for j = 2:length(daystr)
    gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr(j));
    gc = importdata(gcfile);

    % NaN handling: set all NaNs in gc to current gc_cavg values for those
    % array elements.
    gc_nans = find(isnan(gc));
    gc(gc_nans) = gc_cavg(gc_nans);

    gc_cavg  = (gc_cavg.*(j-1) + gc)./j;

end


%% plot
% whole day average: plot day_avg
% month average: plot gc_cavg(:,:,k); manually input desired frame k or
% loop over k
for k = 1:size(gc_cavg,3)
    gplot = gc_cavg(:,:,k);
    
    times = linspace(run_start, run_start+1, 145);
    timestring = string(datestr(times, "HH:MM:SS"));
    
    
    coastlines = importdata('coastlines.mat');
    coastlat = coastlines.coastlat;
    coastlon = coastlines.coastlon;
    geoidrefvec = [1,90,-180];
    
    figure(1)
    hold off
    t = tiledlayout(2,2, "TileSpacing","compact");
    
    nexttile([1,2])
    worldmap("World")
    geoshow(gplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    set(gca,'ColorScale','log');
    crameri('-hawaii');%,'pivot',1); % requires "crameri" colormap toolbox
    
    nexttile
    %worldmap("World");
    worldmap([60 90],[-180 180])
    geoshow(gplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    xlabel("Latitude");
    ylabel("Longitude");
    title("");
    
    set(gca,'ColorScale','log');
    crameri('-hawaii');%,'pivot',1); % requires "crameri" colormap toolbox
    
    
    nexttile
    worldmap([-90 -60],[-180 180])
    geoshow(gplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    
    xlabel("Latitude");
    ylabel("Longitude");
    title("");
    
    set(gca,'ColorScale','log');
    crameri('-hawaii');%,'pivot',1); % requires "crameri" colormap toolbox
    cb = colorbar;
    cb.Layout.Tile = 'east';
    caxis([0.01 1000]);
    
    
    titlestr = sprintf("Average number of WWLLN stroke-to-station path crossings \n March 2022 %s-%s", timestring(k), timestring(k+1));
    title(t, titlestr);
    %title(t, "Average number of WWLLN stroke-to-station path crossings in a 10 minute period, March 30, 2022");

    if k == 1
        gif('average_paths_202203.gif');
    else
        gif;
    end

end
