% pathGrid_test.m
% 4 October 2018
%
% Lightweight version of pathToGridLoc.m section 2 to run for longer times
% with parallelization.  Imports lightning data (APfiles), extracts
% stroke-station pairs, and matches stroke-station great circle paths with
% grid locations they traverse.
%
% _test:  Contains more sections than necessary, some of which do the same
% thing.  Some sections may be broken.  Run section-by-section, not all at
% once.

%% 1a. Define sample great circle paths

% sample GC path with greater resolution than grid

%parameters
nTracks = 3;
timeStart = 1;
timeEnd = 100;

time = timeStart + (timeEnd-timeStart).*rand(nTracks,1);

lat1 = -90 + (89+90).*rand(nTracks,1);
lon1 = -180 + (179+180).*rand(nTracks,1);

lat2 = -90 + (89+90).*rand(nTracks,1);
lon2 = -180 + (179+180).*rand(nTracks,1);

%% 1b. Use AP data

load('strokelist_10000.mat');

lat1 = strokelist_10000(:,2);
lon1 = strokelist_10000(:,3);
lat2 = strokelist_10000(:,4);
lon2 = strokelist_10000(:,5);

time = strokelist_10000(:,1);

%% 1c. Truncate AP data for specific time range

start_time = datenum(2017,09,10,16,00,00);
stop_time = datenum(2017,09,10,16,10,00);
strokelist_short = strokelist_lite((strokelist_lite(:,1) >= start_time & strokelist_lite(:,1) <= stop_time),:);


%% Make and grid tracks: new version

grid_tracks = cell(nTracks,1);

for i = 1:nTracks

    [lattrkgc, lontrkgc] = track2(lat1(i),lon1(i),lat2(i),lon2(i),[],'degrees',400);
    
    % place all GC path points on grid locations
    % NOTE: grid points are transformed from lat-lon coordinates to indices for
    % grid_cell.  These are transformed back to lat-lon coordinates in the
    % plotting function using geoidrefvec.
    lattrkgc_grid = floor(lattrkgc) + 91;
    lontrkgc_grid = floor(lontrkgc) + 181;
    
    % remove duplicate points
   
    grid_tracks{i} = unique([lattrkgc_grid, lontrkgc_grid],'rows','stable');

end

% create and initialize grid cell array
grid_cell = cell(180,360);



%% Make and grid tracks

grid_tracks = cell(nTracks,1);

% define oblate sphereoid

for i = 1:nTracks

    [lattrkgc, lontrkgc] = track2(lat1(i),lon1(i),lat2(i),lon2(i),[],'degrees',400);
    
    % place all GC path points on grid locations
    % NOTE: grid points are transformed from lat-lon coordinates to indices for
    % grid_cell.  These are transformed back to lat-lon coordinates in the
    % plotting function using geoidrefvec.
    lattrkgc_grid = floor(lattrkgc) + 91;
    lontrkgc_grid = floor(lontrkgc) + 181;
    
    % remove duplicate points
   
    grid_tracks{i} = unique([lattrkgc_grid, lontrkgc_grid],'rows','stable');

end

% create and initialize grid cell array
grid_cell = cell(180,360);

%% 2a. Non-parallelizable method

tic;

for j = 1:nTracks
   for k = 1:size(grid_tracks{j},1)
       m = grid_tracks{j}(k,:);
       grid_cell{m(1),m(2)} = [grid_cell{m(1),m(2)}; ...
           j, time(j), azimuth(m(1) - 91,m(2) - 181, grid_tracks{j}(1,1) - 91, grid_tracks{j}(1,2) - 181)];
   end   
end

nonp_time = toc;

%% Operate on grid_cell

tic;

% find number of grid crossings
grid_crossings = zeros(180,360);
% mean_crossing_az = zeros(180,360);
% std_crossing_az = zeros(180,360);
% var_crossing_az = zeros(180,360);
% kurt_crossing_az = zeros(180,360);


frames = 24;
G(frames) = struct('cdata',[],'colormap',[]);

starttime = datenum(2017,09,28,00,00,00);
stoptime = datenum(2017,09,29,00,00,00);
hour_bin_edges = linspace(starttime,stoptime,25);

for t = 1:frames
    for n = 1:180
        for p = 1:360
            
            
            if size(grid_cell{n,p},1) == 0
                grid_crossings(n,p) = 0;
            else
                grid_crossings(n,p) = size(grid_cell{n,p}(grid_cell{n,p}(:,2) >= hour_bin_edges(t) & grid_cell{n,p}(:,2) < hour_bin_edges(t+1)),1);
            end
            
%             if size(grid_cell{n,p},1) == 0
%                 mean_crossing_az(n,p) = NaN;
%                 std_crossing_az(n,p) = NaN;
%             else
%                 grid_az = grid_cell{n,p}(:,3);
%                 grid_az_rad = deg2rad(grid_az);
%                 
%                 mean_az_rad = circ_mean(grid_az_rad,[],1);
%                 mean_crossing_az(n,p) = rad2deg(mean_az_rad);
%                 
%                 % circular variance, st. dev are both unitless!
%                 varx = 1-sqrt(mean(sin(grid_az_rad)).^2 + mean(cos(grid_az_rad)).^2);
%                 var_crossing_az(n,p) = varx;
%                 std_crossing_az(n,p) = sqrt(2*varx);
%                 
%                 kurt_crossing_az(n,p) = circ_kurtosis(grid_az_rad,[],1);
%                 
%             end
        end
        
    end
    
    figure(4)
    
    colormap('jet');
    cmap = colormap;
    cmap(1,:) = [1,1,1];
    colormap(figure(4),cmap);
    
    geoshow(grid_crossings,[1,90,-180],'DisplayType','texturemap');
    hold on;
    geoshow(coastlat,coastlon,'Color','black');
    
    cb = colorbar('southoutside');
    label = cb.Label;
    label.String = ['Number of sferic crossings at grid location UTC h = ',num2str(t-1)];
    label.FontSize = 11;
    
    
    drawnow
    
    G(t) = getframe(gcf);
    
    
end

stats_time = toc;


%% 2b. Parallel method

tic;

% grid_cell{:,:} = NaN(nTracks,3);

for n = 1:180
   for p = 1:360
       grid_cell{n,p} = zeros(nTracks,3);
   end
end

parfor j = 1:nTracks
   for k = 1:length(grid_tracks{j})
       m1 = grid_tracks{j}(k,1);
       m2 = grid_tracks{j}(k,2);
       %grid_cell_loc = grid_cell{m1,m2};
       grid_cell{m1,m2}(k,:) = [j, time(j), azimuth(m2,m1, lattrkgc(1,j), lontrkgc(1,j))];
       
   end   
end

p_time = toc;


%% 3. Plot GC Path crossings

load coastlines;
load geoid;

%reference resolution, north max and longitude center
geoidrefvec = [1,90,-180];

figure(1);
hold off;
geoshow(grid_crossings, geoidrefvec, 'DisplayType','texturemap');
hold on;
geoshow(coastlat, coastlon,'Color','white');
geoshow(lat1,lon1,'Color','green','DisplayType','Point');
geoshow(lat2,lon2,'Color','red','DisplayType','Point');

cb = colorbar('southoutside');
label = cb.Label;
label.String = 'Number of sferic crossings at grid location';
label.FontSize = 11;