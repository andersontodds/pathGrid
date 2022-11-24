function [grid_cell_sferic] = pg_gridcell_sferic(pathlist_sferic)
% pg_gridcell_sferic.m
% 14 December 2022
%
% Function version of pathGrid.m. Takes stroke-station pairs as input,
% calculates great circle paths between them, and outputs cell array of
% stroke-station path crossings on lat/lon grid.  This cell array can be
% used to calculate various global statistics, e.g. with
% pg_gridcrossings.m.
%
% This version requires the input pathlist to include sferic information.
% 
% TODO (11/23/2022):
%   Merge the two for loops that both iterate over 1:nTracks.  These are
%   holdovers from an earlier version that should not be necessary.
%
% INPUTS:
%       pathlist_sferic
%           n x 10 matrix of stroke-station pairs, with columns:
%           1. time (datenum format)
%           2-3. stroke_lat, stroke_lon: location of lightning stroke
%           4-5. station_lat, station_lon: location of WWLLN station
%           6. station_ID: station ID number in stations.mat (starting at 1 = Dunedin)
%           7. stroke_secs: seconds field of stroke time with 1 us precision
%           8-10: c1, c2, c3: sferic dispersion fit parameters, from the
%           equation:
%               phase = c1.*w + c2 + c3./w
%           where w = 2*pi*frequency
%
% OUTPUTS:
%       grid_cell_sferic
%           180 x 360 cell array of stroke-station path crossings on grid.
%           Each cell is n x 3 matrix with format
%           stroke index | time | azimuth to stroke | c1 | c2 | c3
%           
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of this function.  grid_cell should be optionally saved to
%           a file of format grid_cell_*.mat
%
% 

%% break out pathlist variables

lat1 = pathlist_sferic(:,2);
lon1 = pathlist_sferic(:,3);

lat2 = pathlist_sferic(:,4);
lon2 = pathlist_sferic(:,5);

dist = distance(lat1,lon1,lat2,lon2, referenceEllipsoid("wgs84")); % this will add significant computation time

time = pathlist_sferic(:,1);

c1 = pathlist_sferic(:,8);
c2 = pathlist_sferic(:,9);
c3 = pathlist_sferic(:,10);

nTracks = length(time);

%% Make and grid tracks
%tic;

% create and initialize grid cell array
grid_cell_sferic = cell(180,360);

for j = 1:nTracks
   
    [lattrkgc, lontrkgc] = track2(lat1(j),lon1(j),lat2(j),lon2(j),[],'degrees',400);
    
    % place all GC path points on grid locations
    % NOTE: grid points are transformed from lat-lon coordinates to indices for
    % grid_cell.  These are transformed back to lat-lon coordinates in the
    % plotting function using geoidrefvec.
    lattrkgc_grid = floor(lattrkgc) + 91;
    lontrkgc_grid = floor(lontrkgc) + 181;

    grid_loc = unique([lattrkgc_grid, lontrkgc_grid],'rows','stable');
    grid_lat = grid_loc(:,1) - 91;
    grid_lon = grid_loc(:,2) - 181;
   
    az_to_stroke = azimuth(grid_lat,grid_lon,grid_lat(1),grid_lon(1));
    
    for k = 1:size(grid_loc,1)
        grid_cell_sferic{grid_loc(k,1),grid_loc(k,2)} = [grid_cell_sferic{grid_loc(k,1),grid_loc(k,2)}; ...
           j, time(j), az_to_stroke(k), c1(j), c2(j), c3(j), dist(j)];
    end   
   
end

%nonp_time = toc;

end
