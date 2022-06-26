function [d_gridcross,gridcross_mm] = pg_diffcross(grid_crossings,meanlength)
% pg_diffcross.m
% 7 January 2019
% 
% Calculates difference in 10-minute grid_crossigns from 1-hour moving mean
% of same.
%
% INPUTS:
%       grid_crossings
%           180 x 360 x N matrix of stroke-station path crossings.  Each
%           180 x 360 frame is those crossings of a whole-earth lat/lon
%           grid in some time bin.  For N = 144 and a whole-day input
%           file, this time bin is 10 minutes.
%
% OUTPUTS:
%       d_gridcross
%           180 x 360 x N matrix of time difference statistics in
%           grid_crossings.  Each element (l,m,n) is the difference between
%           that element in grid_crossings and the moving mean of the
%           previous 5-10 elements in grid_crossings (i.e. elements
%           (l,m,{n-10,n-9,...,n-1})).  The size of the moving mean is
%           tuned with the parameter "meanlength", below.
%
% PARAMETERS:
%       meanlength
%           size of moving mean for calculating d_gridcross.  E.g. if
%           meanlength == 10, d_gridcross elements are the difference
%           between element (l,m,n) and the mean of elements
%           [(l,m,n-10),(l,m,n-9),...,(l,m,n-1)], in grid_crossings.
%

%meanlength = 6;

d_gridcross = zeros(size(grid_crossings));

gridcross_mm = movmean(grid_crossings,[meanlength 0],3, "omitnan");

for m = 1:size(d_gridcross,3)
    if m == 1
        d_gridcross(:,:,m) = grid_crossings(:,:,m);
    else
        d_gridcross(:,:,m) = grid_crossings(:,:,m) - gridcross_mm(:,:,m-1);
    end
end


end
