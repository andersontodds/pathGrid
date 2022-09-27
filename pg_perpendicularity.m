function [gc_perp] = pg_perpendicularity(grid_cell)
% pg_variance.m
% 17 December 2018
% 
% Finds perpendicularity of of grid_cell input azimuths.  Applies 
% circ_var.m from CircStat2012a library.
%
% Perpendicularity (P) is related to the circular variance (V) of the 
% distribution of azimuths:
%   V = 1 - R(Theta)
%   P = 1 - R(2*Theta)
% where Theta is the distribution of azimuths, and R(Theta) is the mean
% length of the resultant vector of Theta.  P can be thought of as V
% mapped to the variance of the azimuthal distribution on the interval 
% [0, pi) radians, rather than on [0, 2pi).

% INPUTS:
%       grid_cell
%           180 x 360 cell array of stroke-station great circle path
%           crossings.  Each cell is a n x 3 array of format
%           stroke index | time | azimuth to stroke (Theta)
% 
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of pg_gridcell.  pg_gridcell should be run once per input
%           file, and the grid_cell variable should be saved to a file with
%           format grid_cell_*.mat.
%
% OUTPUTS:
%       gc_perp
%           180 x 360 array of perpendicularity of azimuths of stroke-
%           station great circle path crossings. Each element refers to all
%           paths crossing that lat/lon grid location in the input
%           grid_cell; i.e. each element is the size n of the corresponding
%           n x 3 cell in grid_cell.
%
%           gc_perp: P = 1-R(2*Theta)
%
%           gc_perp matrices are small in memory relative to
%           grid_cell cell arrays -- a whole day grid_cell can be 2-4 GB,
%           while the corresponding grid_crossings with 1-10 minute
%           resolution (i.e. a 3-D matrix with dimension 180 x 360 x (time
%           res)) could be tens of MB.  Therefore, grid statistics should
%           be calculated in the same script as grid_cell, so grid_cell
%           does not need to be saved to an output file.
%

gc_perp = zeros(180,360);

for lat = 1:180
    for lon = 1:360
         
        if size(grid_cell{lat,lon},1) == 0
            gc_perp(lat,lon) = NaN;
        else
            [gc_perp(lat,lon), ~] = circ_var(2*deg2rad(grid_cell{lat,lon}(:,3)),[],[],1);
        end
        
        
    end
    
end

end