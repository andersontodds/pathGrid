function [lat,lon] = subsolar(Y,M,D,h,m,s)
% subsolar.m
% 13 May 2022
%
% Calculates subsolar point in lat/lon coordinates from universal time
% input.  Subsolar point latitude = solar declination; subsolar point 
% longitude calculated from time of day.
% 
% Supported input formats: Nx1 datenum, Nx6 [yy mm dd HH MM SS], or 6
% separate vectors of yy mm dd HH MM SS.

switch nargin
    case 1
        if size(Y,2) == 1
            timein = datetime(Y,'ConvertFrom','datenum');
        elseif size(Y,2) == 6
            timein = datetime(Y);
        else
            error("Numeric data must be an Nx1 array of datenums, or an Nx6 array with columns [yyyy mm dd HH MM SS]");
        end
    case 6
        timein = datetime(Y,M,D,h,m,s);
end

days = day(timein,'dayofyear');
hour_frac = rem(datenum(timein),1);

lon = 180 - hour_frac*360;

lat = asind(sind(23.45)*sind(360*(days - 81)/365));

end