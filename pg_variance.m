function [gc_var, gc_angvar] = pg_variance(grid_cell)
% pg_variance.m
% 17 December 2018
% 
% Finds circular variance of grid_cell input azimuths.  Applies
% circ_var.m from CircStat2012a library.
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
%       gc_var, gc_angvar
%           180 x 360 array of skewness of azimuths of stroke-station great
%           circle path crossings. Each element refers to all
%           paths crossing that lat/lon grid location in the input
%           grid_cell; i.e. each element is the size n of the corresponding
%           n x 3 cell in grid_cell.
%
%           gc_var: variance = 1-R
%           gc_angvar: angular variance = 2*(1-R)
%
%           gc_var matrices are small in memory relative to
%           grid_cell cell arrays -- a whole day grid_cell can be 2-4 GB,
%           while the corresponding grid_crossings with 1-10 minute
%           resolution (i.e. a 3-D matrix with dimension 180 x 360 x (time
%           res)) could be tens of MB.  Therefore, whole-day statistics are
%           best calculated by running pg_gridcell and pg_gridcross for
%           10-minute input files, then concatenating pg_gridcross into a
%           whole-day 3-D matrix.
%

gc_var = zeros(180,360);
gc_angvar = zeros(180,360);

for n = 1:180
    for p = 1:360
         
        if size(grid_cell{n,p},1) == 0
            gc_var(n,p) = NaN;
            gc_angvar(n,p) = NaN;
        else
            [gc_var(n,p), gc_angvar(n,p)] = circ_var(deg2rad(grid_cell{n,p}(:,3)),[],[],1);
        end
        
        
    end
    
end

end