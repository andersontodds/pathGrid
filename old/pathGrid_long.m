% pathGrid_long.m
% 4 October 2018
%
% Lightweight version of pathToGridLoc.m section 2 to run for longer times
% with parallelization.  Imports lightning data (APfiles), extracts
% stroke-station pairs, and matches stroke-station great circle paths with
% grid locations they traverse.
%
% _long signifies use with full-day APfile/strokelist


%% 1b. Use AP data

load('strokelist_lite.mat');

lat1 = strokelist_lite(:,2);
lon1 = strokelist_lite(:,3);
lat2 = strokelist_lite(:,4);
lon2 = strokelist_lite(:,5);

time = strokelist_lite(:,1);

%parameters
nTracks = length(time);

%% Make and grid tracks

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

%% 2a. Non-parallelizable method

tic;

for j = 1:nTracks
    
   grid_loc = grid_tracks{j};
   grid_lat = grid_loc(:,1) - 91;
   grid_lon = grid_loc(:,2) - 181;
   
   az_to_stroke = azimuth(grid_lat,grid_lon,grid_lat(1),grid_lon(1));
    
   for k = 1:size(grid_loc,1)
       grid_cell{grid_loc(k,1),grid_loc(k,2)} = [grid_cell{grid_loc(k,1),grid_loc(k,2)}; ...
           j, time(j), az_to_stroke(k)];
   end   
   
end

save('grid_cell.mat','grid_cell','-v7.3');

nonp_time = toc;

%% Operate on grid_cell

% find number of grid crossings
grid_crossings = zeros(180,360);
mean_crossing_az = zeros(180,360);
std_crossing_az = zeros(180,360);
var_crossing_az = zeros(180,360);
for n = 1:180
   for p = 1:360
       grid_crossings(n,p) = size(grid_cell{n,p},1);
       if size(grid_cell{n,p},1) == 0
           mean_crossing_az(n,p) = NaN;
           std_crossing_az(n,p) = NaN;
       else
           grid_az = grid_cell{n,p}(:,3);
           grid_az_rad = deg2rad(grid_az);
           
           mean_az_rad = circ_mean(grid_az_rad,[],1);
           mean_crossing_az(n,p) = rad2deg(mean_az_rad);
           
           varx = 1-sqrt(mean(sin(grid_az_rad)).^2 + mean(cos(grid_az_rad)).^2);
           var_crossing_az(n,p) = varx;
           std_crossing_az(n,p) = sqrt(2*varx);
           
       end
   end
    
end

% grid_cell is pretty large (>2 GB) so need to use the -v7.3 flag (uses
% compression...maybe)

save('grid_crossings.mat','grid_crossings');
save('mean_crossing_az.mat','mean_crossing_az');
save('std_crossing_az.mat','std_crossing_az');
save('var_crossing_az.mat','var_crossing_az');

%% 3. Plot GC Path crossings

load coastlines;
load geoid;

%reference resolution, north max and western longitude limit (west max)
geoidrefvec = [1,90,-180];

figure(1);
hold off;
geoshow(grid_crossings, geoidrefvec, 'DisplayType','texturemap');
hold on;
geoshow(coastlat, coastlon, 'Color', 'white');
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');

cb = colorbar('southoutside');
label = cb.Label;
label.String = 'Number of sferic crossings at grid location';
label.FontSize = 11;

