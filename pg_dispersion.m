function [gc_mean_c1, gc_mean_c2, gc_mean_c3] = pg_dispersion(grid_cell_sferic)
% pg_dispersion.m
% 14 November 2022
% 
% Finds mean dispersion of sferics propagating over a grid.
%
% Dispersion is quantified by the hyperbolic fit equation:
%   phase = c1.*w + c2 + c3./w
% where w is the angular frequency, and phase is the phase of each
% frequency component in w.

% INPUTS:
%       grid_cell_sferic
%           180 x 360 cell array of stroke-station great circle path
%           crossings.  Each cell is a n x 3 array of format
%           stroke index | time | azimuth to stroke | c1 | c2 | c3
% 
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of pg_gridcell.  pg_gridcell should be run once per input
%           file, and the grid_cell variable should be saved to a file with
%           format grid_cell_*.mat.
%
% OUTPUTS:
%       gc_mean_c1, gc_mean_c2, gc_mean_c3
%           180 x 360 arrays of means of each dispersion parameter. Each 
%           element refers to the mean of all paths crossing that lat/lon 
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

gc_mean_c1 = zeros(180,360);
gc_mean_c2 = zeros(180,360);
gc_mean_c3 = zeros(180,360);

for lat = 1:180
    for lon = 1:360
         
        if size(grid_cell_sferic{lat,lon},1) == 0
            gc_mean_c1(lat,lon) = NaN;
            gc_mean_c2(lat,lon) = NaN;
            gc_mean_c3(lat,lon) = NaN;
        else
            gc_mean_c1(lat,lon) = mean(grid_cell_sferic{lat,lon}(:,4), 'omitnan');
            gc_mean_c2(lat,lon) = mean(grid_cell_sferic{lat,lon}(:,5), 'omitnan');
            gc_mean_c3(lat,lon) = mean(grid_cell_sferic{lat,lon}(:,6), 'omitnan');
        end
        
        
    end
    
end


end