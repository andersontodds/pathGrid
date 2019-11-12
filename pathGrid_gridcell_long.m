% pathGrid_gridcell_long.m
% 4 October 2018
%
% Lightweight version of pathToGridLoc.m section 2 to run for longer times
% with parallelization.  Imports lightning data (APfiles), extracts
% stroke-station pairs, and matches stroke-station great circle paths with
% grid locations they traverse.
%
% _long signifies use with full-day APfile/strokelist
% 
% _gridcell only saves grid_cell, does not perform whole-time-interval
% statistics (e.g. calculate grid_crossings, angular statistics, etc).
% This version takes strokelist*.mat as input, returns grid_cell*.mat.


%% 1b. Use AP data

load('strokelist_lite_20170928.mat');

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

save('grid_cell_20170928.mat','grid_cell','-v7.3');

nonp_time = toc;
