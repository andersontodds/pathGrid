function [gc_mean_grouptimediff] = pg_grouptimediff(grid_cell_sferic)
% pg_grouptime.m
% 14 November 2022
% 
% Finds mean time difference of frequency components of sferics propagating over a grid.
%
% Dispersion is quantified by the hyperbolic fit equation:
% (1)   phase = c1.*w + c2 + c3./w
% where w is the angular frequency, and phase is the phase of each
% frequency component in w.
% Group time tg as a function of frequency is given by:
% (2)   tg(w) = t0 - dphase/dw
% where t0 is the sample time.  Differentiating (1) w.r.t. w,
% (3)   tg(w) = t_offset - c1 + c3/w^2
% where t_offset is the difference between the sample time and trigger
% time, and is constant for all sferic measurements.
% The difference between the group time of a high frequency w_H and low
% frequency w_L is then:
%       dtg(wL-wH) = tg(w_L) - tg(w_H)
%       dtg(wL-wH) = [t_offset - c1 + c3/w_L^2] - [t_offset - c1 + c3/w_H^2]
%       dtg(wL-wH) = c3/w_L^2 - c3/w_H^2
% (4)   dtg(wL-wH) = (c3/2pi)*(w_L^-2 - w_H^-2)
% Because this time difference results from the w_H and w_L components
% propagating at different, but constant, velocities; the time difference
% should scale linearly with propagation distance:
% (5)   dtg(wL-wH)/distance = (c3/2pi*distance)*(w_L^-2 - w_H^-2)
% (assuming constant and 2D-homogenous waveguide conditions).
% w_L, w_H, and of course 2*pi are constants, so the quantity we need to
% calculate, then take the mean of, is:
% (6)   dtg(wL-wH) * 2pi/(w_L^-2 - w_H^-2) = c3/distance

% INPUTS:
%       grid_cell_sferic
%           180 x 360 cell array of stroke-station great circle path
%           crossings.  Each cell is a n x 3 array of format
%           stroke index | time | azimuth to stroke | c1 | c2 | c3 |
%           propagation distance
% 
%           grid_cell variables can be very large and computationally
%           expensive; they should not be recalculated with subsequent
%           runs of pg_gridcell.  pg_gridcell should be run once per input
%           file, and the grid_cell variable should be saved to a file with
%           format grid_cell_*.mat.
%
% OUTPUTS:
%       gc_mean_grouptime
%           180 x 360 array of mean of c3 dispersion parameter divided by
%           propagation distance.
%
%           gc_mean_c* matrices are small in memory relative to
%           grid_cell cell arrays -- a whole day grid_cell can be 2-4 GB,
%           while the corresponding grid_crossings with 1-10 minute
%           resolution (i.e. a 3-D matrix with dimension 180 x 360 x (time
%           res)) could be tens of MB.  Therefore, grid statistics should
%           be calculated in the same script as grid_cell, so grid_cell
%           does not need to be saved to an output file.
%

gc_mean_grouptimediff = zeros(180,360);

for lat = 1:180
    for lon = 1:360
         
        if size(grid_cell_sferic{lat,lon},1) == 0
            gc_mean_grouptimediff(lat,lon) = NaN;
            
        else
            % grid_cell_sferic{lat,lon}(:,6): c3
            % grid_cell_sferic{lat,lon}(:,7): propagation distance
            gc_mean_grouptimediff(lat,lon) = mean(grid_cell_sferic{lat,lon}(:,6)./grid_cell_sferic{lat,lon}(:,7), 'omitnan');
            
        end
        
        
    end
    
end


end