% avid_paths.m
% Todd Anderson
% September 1 2022
%
% Plot Tx-Rx paths of proposed AVID network.  See Forrest Gasdia's
% dissertation for diagram network.

%% AVID network only

% Tx:                 Lat (deg N)      Lon (deg E)
Tx = {  "NLK",             48.2000 ,       -121.9167;
        "NML",             46.3660 ,        -98.3357;
        "NAA",             44.6500 ,        -67.2833};


% Rx:
Rx = {  "Poker Flat"    ,  65.1256 ,       -147.4919;
        "Whitehorse"    ,  60.7197 ,       -135.0523;
        "Prince George" ,  53.9171 ,       -122.7497;
        "Fort Nelson"   ,  58.8050 ,       -122.6972;
        "Yellowknife"   ,  62.4540 ,       -114.3718;
        "Rankin Inlet"  ,  62.8084 ,        -92.0853;
        "Iqaluit"       ,  63.7467 ,        -68.5170;
        "Kuujjuaq"      ,  58.1030 ,        -68.4188;
        "Labrador City" ,  52.9390 ,        -66.9142;
        "Rimouski"      ,  48.4390 ,        -68.5350};

Rx_proposal = {
        "Whitehorse"    ,  60.7197 ,       -135.0523;
        "Juneau"        ,  58.3005 ,       -134.4201;
        "Ketchikan"     ,  55.3422 ,       -131.6461;
        "Bella Bella"   ,  52.1605 ,       -128.1456;
        "Nahanni Butte" ,  61.0335 ,       -123.3834;
        "Fort Smith"    ,  60.0055 ,       -111.8849;
        "Stony Rapids"  ,  59.2588 ,       -105.8317;
        "Churchill"     ,  58.7679 ,        -94.1696;
        "Kuujjuaq"      ,  58.1030 ,        -68.4188;
        "Labrador City" ,  52.9390 ,        -66.9142;
        "Rimouski"      ,  48.4390 ,        -68.5350};


% plot network paths
load coastlines;
latlim = [40, 75];
lonlim = [-170, -40];

figure(1);
hold off
worldmap(latlim, lonlim);
setm(gca, 'MapProjection','giso');
geoshow(coastlat, coastlon, 'Color', 'black');
hold on

for r = 1:length(Rx)
    for t = 1:length(Tx)
        geoshow([Tx{t,2}, Rx{r,2}],[Tx{t,3}, Rx{r,3}], "DisplayType", "line");
    end
end

geoshow([Tx{:,2}], [Tx{:,3}], "DisplayType","point", "Marker","^","MarkerFaceColor",[0 0.75 0], "MarkerEdgeColor",[0 0.75 0]);
geoshow([Rx{:,2}], [Rx{:,3}], "DisplayType","point", "Marker","v","MarkerFaceColor",[0.75 0 0], "MarkerEdgeColor",[0.75 0 0]);

textm([Tx{:,2}], [Tx{:,3}] + 1, [Tx{:,1}]);
textm([Rx{:,2}], [Rx{:,3}] + 1, [Rx{:,1}]);

%% compare with WWLLN paths
% see average_paths.m for WWLLN path plotting

%% 1. day
% average each lat, lon element across 1 day
daystr = "20220330";
run_start = datenum(2022, 03, 30);
gcfile = sprintf("data/grid_crossings_10m_%s.mat", daystr);
gc = importdata(gcfile);

gc_avg = mean(gc, 3, "omitnan");

%% 2. month
% average each lat, lon, UT element across 1 month
% requires grid_crossings_10 files for entire time range; either download
% these from flashlight or prepend "/gridstats" to gcfile below and run
% this part on flashlight
run_start = datenum(2022, 03, 01);
run_end = datenum(2022, 03, 31);
run_days = run_start:run_end;
run_days = run_days';
%run_days = run_days(run_days ~= datenum(2022, 01, 15));

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
%for k = 1:size(gc, 3)    
%for k = 1
    gplot = gc_cavg(:,:,k);
    %gplot = gc(:,:,k);
    %gplot = gc_avg;

    times = linspace(run_start, run_start+1, 145);
    timestring = string(datestr(times, "HH:MM:SS"));
    
    
    coastlines = importdata('coastlines.mat');
    coastlat = coastlines.coastlat;
    coastlon = coastlines.coastlon;
    geoidrefvec = [1,90,-180];
    
    figure(1)
    hold off
    worldmap(latlim, lonlim)
%     setm(gca, 'MapProjection','giso');
    geoshow(gplot, geoidrefvec, "DisplayType","texturemap");
    hold on
    geoshow(coastlat, coastlon, "Color","black");
    

    for r = 1:length(Rx)
        for t = 1:length(Tx)
            geoshow([Tx{t,2}, Rx{r,2}],[Tx{t,3}, Rx{r,3}], "DisplayType", "line");
        end
    end

    geoshow([Tx{:,2}], [Tx{:,3}], "DisplayType","point", "Marker","^","MarkerFaceColor",[0 0.75 0], "MarkerEdgeColor",[0 0.75 0]);
    geoshow([Rx{:,2}], [Rx{:,3}], "DisplayType","point", "Marker","v","MarkerFaceColor",[0.75 0 0], "MarkerEdgeColor",[0.75 0 0]);
    
    textm([Tx{:,2}], [Tx{:,3}] + 1, [Tx{:,1}]);
    textm([Rx{:,2}], [Rx{:,3}] + 1, [Rx{:,1}]);

    set(gca,'ColorScale','log');
    crameri('buda');%,'pivot',1); % requires "crameri" colormap toolbox
    cb = colorbar;
    caxis([0.01 1000]);
    
    
%     titlestr = sprintf("Average stroke-to-station path crossings \n March 2022 %s-%s \n station: %s (%0.3f N, %0.3f E)", ...
%         timestring(k), timestring(k+1), stationName, stationLat, stationLon);
    titlestr = sprintf("WWLLN stroke-to-station path crossings \n March 30 2022 %s-%s", ...
        timestring(k), timestring(k+1));
    title(titlestr);
%     title("Average number of WWLLN stroke-to-station path crossings in a 10 minute period, March 30, 2022");

    gifname = sprintf('average_paths_202203_AVID.gif');
    if k == 1
        gif(gifname);
    else
        gif;
    end

end

