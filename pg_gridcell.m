function [grid_cell] = pg_gridcell(strokefile)
% pg_gridcell.m
% 13 December 2018
%
% Function version of pathGrid.m. Takes stroke-station pairs as input,
% calculates great circle paths between them, and outputs cell array of
% stroke-station path crossings on lat/lon grid.  This cell array can be
% used to calculate various global statistics, e.g. with
% pg_gridcrossings.m.
% 
% INPUTS:
%       strokefile
%           File with name format strokelist_lite_*.mat
%           n x 5 matrix of stroke-station pairs, with format
%           time | stroke_lat | stroke_lon | station_lat | station_lon
%
% OUTPUTS:
%       grid_cell
%           180 x 360 cell array of stroke-station path crossings on grid.
%           Each cell is n x 3 matrix with format
%           stroke index | time | azimuth to stroke
%           
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of this function.  grid_cell should be optionally saved to
%           a file of format grid_cell_*.mat
%
% 

%% 1b. Use AP data

stroke_list = importdata(strokefile);

lat1 = stroke_list(:,2);
lon1 = stroke_list(:,3);

lat2 = stroke_list(:,4);
lon2 = stroke_list(:,5);

time = stroke_list(:,1);


%parameters
nTracks = length(time);

%% Make and grid tracks
tic;

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

grid_track_time = toc;
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

nonp_time = toc;

end
