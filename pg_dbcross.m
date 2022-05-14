function dB_gridcross = pg_dbcross(grid_crossings, gridcross_mm)
% dB_gridcross.m
% 13 May 2022
%
% Calculates the change in stroke-station path crossings of a geodetic grid
% from previous moving mean, in decibels. 
%
% INPUTS:
%   grid_crossings: 180x360xN double
%       matrix of stroke-station path crossings of 180x360 grid, in N time
%       bins.  Typically, N = 144, for each of the 144 10-minute time bins
%       in a 24-hour period.
%  
%   gridcross_mm:   180x360xN double
%       the moving mean of grid_crossings.  Typically, the trailing mean
%       over the previous hour; so in the case where N = 144, for 144
%       10-minute time bins over a 24-hour period, gridcross_mm is the mean
%       over the previous 6 bins.
%
% OUTPUTS:
%   dB_gridcross: 180x360xN double
%       the change in grid_crossings, from gridcross_mm, in dB.

grid_crossings_add001 = grid_crossings + 0.001;
dB_gridcross = 10*log10(grid_crossings_add001./gridcross_mm); % can use gridcross_mmed as well if available

dB_gc_inf = (dB_gridcross(:,:,73) == -Inf | dB_gridcross(:,:,73) == Inf);
dB_gridcross(dB_gc_inf) = NaN;

end