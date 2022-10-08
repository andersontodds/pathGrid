% great_circle_normals.m
% Todd Anderson
% 7 October 2022
%
% Define normal vectors to great circles, select subset of vectors that lie
% within certain range, and calculate circular statistics (e.g. variance, 
% perpendicularity) of this subset.

% start with set of latitudes and longitudes defining start and end points
% of paths, and location of interest
% tlat = deg2rad(50);
% tlon = deg2rad(10);
% rlat = deg2rad(45);
% rlon = deg2rad(-120);
tlat = deg2rad(rand(10,1)*180 - 90);
tlon = deg2rad(rand(10,1)*360 - 180);
rlat = deg2rad(rand(10,1)*180 - 90);
rlon = deg2rad(rand(10,1)*360 - 180);

mlat = deg2rad(70);
mlon = deg2rad(0);



% convert t, r latitude and longitude to 3D cartesian vectors
%  (R, theta, phi) -> (x, y, z)
%   R = 1;
%   theta = azimuth angle = longitude;
%   phi = elevation angle = latitude;
[tx, ty, tz] = sph2cart(tlon, tlat, 1);
[rx, ry, rz] = sph2cart(rlon, rlat, 1);
[mx, my, mz] = sph2cart(mlon, mlat, 1);

T = [tx, ty, tz];
R = [rx, ry, rz];
M = [mx, my, mz];
% find unit vector normal to t and r vectors
N_nonnorm = cross(T, R);
N = zeros(size(N_nonnorm));
L = zeros(size(N_nonnorm));
for i = 1:length(N)
    N(i,:) = N_nonnorm(i,:)/vecnorm(N_nonnorm(i,:),2,2); % say that ten times fast
    L(i,:) = cross(M,N(i,:));
end

% find normal vectors within band
% for a location on the sphere defined by a vector M, great circles that
% pass near M will have normal vectors N that are nearly perpendicular to
% M, and therefore the cross product of M and N will have a magnitude
% close to |M||N| [= 1 if M and N are unit vectors].  Since the cross
% product L = M x N has magnitude |M||N|sin(alpha), where alpha is the
% angle between M and N, paths passing within angle beta of M can be found 
% by checking whether norm(L) > cos(beta).

alpha = deg2rad([0.1, 0.5, 1, 5, 10]);
near_M = vecnorm(L,2,2) > abs(cos(alpha));

%% plot

% geoshow can only interpolate straight lines (i.e. relative to the figure
% axes), so need to get points on GC paths

load coastlines;

uif = uifigure;

g = geoglobe(uif);

% geoplot3 only seems to plot one object at a time; consider going to plot3
% or worldmap
for j = 1:length(tlat)
    %[tracklat, tracklon] = track2(rad2deg(tlat(j)), rad2deg(tlon(j)), rad2deg(rlat(j)), rad2deg(rlon(j));
    [tracklat, tracklon] = interpm([rad2deg(tlat(j)), rad2deg(rlat(j))], [rad2deg(tlon(j)), rad2deg(rlon(j))],0.1, 'gc');
    geoplot3(g, tracklat, tracklon, [], 'y', 'LineWidth', 2);
end