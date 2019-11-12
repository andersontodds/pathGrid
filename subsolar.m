function [lat,lon] = subsolar(Y,M,D,h,m,s)
% subsolar.m
% 22 January 2019
%
% Calculates subsolar point in lat/lon coordinates from universal time
% input.  Subsolar point latitude = solar declination; subsolar point 
% longitude calculated from time of day.
% 
% Currently only supports 6-argument date format Y,M,D,h,m,s.

timein = datetime(Y,M,D,h,m,s);
days = day(timein,'dayofyear');
hour_frac = rem(datenum(timein),1);

lon = 180 - hour_frac*360;

lat = asind(sind(23.45)*sind(360*(days - 81)/365));

end