% dispersion_fit_test.m
% Todd Anderson
% November 15 2022
%
% Scratch work for dispersion fits

% get sample pathgrid with sferic information
ps = importdata("data/pathlist_sferic_10m_20221108.mat");

% get stroke lat/lon, station lat/lon
stroke_lat_all = ps(:,2);
stroke_lon_all = ps(:,3);
station_lat_all = ps(:,4);
station_lon_all = ps(:,5);

c1_all = ps(:,8);
c2_all = ps(:,9);
c3_all = ps(:,10);

c1zero = c1_all == 0;
c2zero = c2_all == 0;
c3zero = c3_all == 0;

goodsferic = ~(c1zero & c2zero & c3zero);

% get lats, lons and dispersion coefficients with 
stroke_lat = stroke_lat_all(goodsferic);
stroke_lon = stroke_lon_all(goodsferic);
station_lat = station_lat_all(goodsferic);
station_lon = station_lon_all(goodsferic);

c1 = c1_all(goodsferic);
c2 = c2_all(goodsferic);
c3 = c3_all(goodsferic);

% calculate stroke_station distances
d_ss = distance(stroke_lat, stroke_lon, station_lat, station_lon, referenceEllipsoid('wgs84'));

% divide dispersion coefficients by distance
c1_dnorm = c1./d_ss;
c2_dnorm = c2./d_ss;
c3_dnorm = c3./d_ss;

c1_mean = mean(c1, 'omitnan');
c2_mean = mean(c2, 'omitnan');
c3_mean = mean(c3, 'omitnan');

c1_std = std(c1, 'omitnan');
c2_std = std(c2, 'omitnan');
c3_std = std(c3, 'omitnan');

freq = 6000:10:18000;
w = 2*pi*freq;

ph = c1_mean.*w + c2_mean + c3_mean./w;
ph_p1c1std = (c1_mean + c1_std).*w + c2_mean + c3_mean./w;
ph_n1c1std = (c1_mean - c1_std).*w + c2_mean + c3_mean./w;

%% plots

figure(2)
hold off
tiledlayout(3,1,"TileSpacing","compact");
nexttile
plot(1:length(c1_dnorm), c1_dnorm, 'r.');
title("c1")
nexttile
plot(1:length(c2_dnorm), c2_dnorm, 'g.');
title("c2")
nexttile
semilogy(1:length(c3_dnorm), c3_dnorm, 'b.');
title("c3")

figure(3)
tiledlayout(2,2)
nexttile
hold off
plot(d_ss, c1, '.');
ylabel("c1 (s)")
xlabel("distance (m)")

nexttile
hold off
plot(d_ss, c2, '.');
ylabel("c2 (rad)")
xlabel("distance (m)")

nexttile
hold off
plot(d_ss, c3, '.');
ylabel("c3 (rad^2 s^{-1})")
xlabel("distance (m)")


figure(4)
hold off
plot(freq/1000, ph*180/pi, '.');
hold on
plot(freq/1000, ph_p1c1std*180/pi, '.');
plot(freq/1000, ph_n1c1std*180/pi, '.');
xlabel("frequency (kHz)")
ylabel("phase (\circ)")