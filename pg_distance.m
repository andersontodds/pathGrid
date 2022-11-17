function [gc_mean_distance] = pg_distance(grid_cell_sferic)
% pg_distance.m
% 16 November 2022
% 
% Finds mean distance of sferics propagating over a grid.
%
% INPUTS:
%       grid_cell_sferic
%           180 x 360 cell array of stroke-station great circle path
%           crossings.  Each cell is a n x 3 array of format
%           stroke index | time | azimuth to stroke | c1 | c2 | c3 |
%           distance
% 
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of pg_gridcell.  pg_gridcell should be run once per input
%           file, and the grid_cell variable should be saved to a file with
%           format grid_cell_*.mat.
%
% OUTPUTS:
%       gc_mean_distance
%           180 x 360 array of mean distance. Each 
%           element refers to the mean of dispersion parameters of all paths crossing that lat/lon 
%           grid location in the input grid_cell; i.e. each element is the 
%           size n of the corresponding n x 3 cell in grid_cell.
%
%           gc_mean_c* matrices are small in memory relative to
%           grid_cell cell arrays -- a whole day grid_cell can be 2-4 GB,
%           while the corresponding grid_crossings with 1-10 minute
%           resolution (i.e. a 3-D matrix with dimension 180 x 360 x (time
%           res)) could be tens of MB.  Therefore, grid statistics should
%           be calculated in the same script as grid_cell, so grid_cell
%           does not need to be saved to an output file.
%

gc_mean_distance = zeros(180,360);

for lat = 1:180
    for lon = 1:360
         
        if size(grid_cell_sferic{lat,lon},1) == 0
            gc_mean_distance(lat,lon) = NaN;

        else
            gc_mean_distance(lat,lon) = mean(grid_cell_sferic{lat,lon}(:,7), 'omitnan');

        end
        
        
    end
    
end


end