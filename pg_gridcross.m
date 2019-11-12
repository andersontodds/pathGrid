function [grid_crossings] = pg_gridcross(grid_cell)
% pg_gridcross.m
% 17 December 2018
% 
% Function version of pathGrid.m, part 2.  Takes grid_cell as input,
% calculates grid_crossings.
%
% INPUTS:
%       grid_cell
%           180 x 360 cell array of stroke-station great circle path
%           crossings.  Each cell is a n x 3 array of format
%           stroke index | time | azimuth to stroke
% 
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of pg_gridcell.  pg_gridcell should be run once per input
%           file, and the grid_cell variable should be saved to a file with
%           format grid_cell_*.mat.
%
% OUTPUTS:
%       grid_crossings
%           180 x 360 array of stroke-station great circle path crossings.
%           Each element is the total number of paths crossing that lat/lon
%           grid location in the input grid_cell; i.e. each element is the
%           size n of the corresponding n x 3 cell in grid_cell.
%
%           grid_crossings matrices are small in memory relative to
%           grid_cell cell arrays -- a whole day grid_cell can be 2-4 GB,
%           while the corresponding grid_crossings with 1-10 minute
%           resolution (i.e. a 3-D matrix with dimension 180 x 360 x (time
%           res)) could be tens of MB.  Therefore, whole-day statistics are
%           best calculated by running pg_gridcell and pg_gridcross for
%           10-minute input files, then concatenating pg_gridcross into a
%           whole-day 3-D matrix.
%

grid_crossings = zeros(180,360);

for n = 1:180
    for p = 1:360
         
        if size(grid_cell{n,p},1) == 0
            grid_crossings(n,p) = 0;
        else
            grid_crossings(n,p) = size(grid_cell{n,p},1);
        end
        
        
    end
    
end

end