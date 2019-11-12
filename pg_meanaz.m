function [meanaz] = pg_meanaz(grid_cell)
% pg_meanaz.m
% 29 January 2019
% 
% Finds mean azimuth of grid_cell input azimuths.  Applies circ_mean.m from
% CircStat2012a library.
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
%       mu
%           Mean azimuth in degrees
%
%       ul, ll
%           Upper and lower 95% confidence limits
%

meanaz = zeros(180,360);

for n = 1:180
    for p = 1:360
         
        if size(grid_cell{n,p},1) == 0
            meanaz(n,p) = NaN;
        else
            [meanaz(n,p)] = rad2deg(circ_mean(deg2rad(grid_cell{n,p}(:,3)),[],1));
        end
        
        
    end
    
end


end