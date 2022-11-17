% dispersion_fit_test.m
% Todd Anderson
% November 15 2022
%
% Scratch work for dispersion fits

% get sample pathgrid with sferic information
ps = importdata("data/pathlist_sferic_20221108.mat");
stations = importdata("stations.mat");

% get dispersion coefficients and discard rows with bad sferic fits
c1_all = ps(:,8);
c2_all = ps(:,9);
c3_all = ps(:,10);

c1zero = c1_all == 0;
c2zero = c2_all == 0;
c3zero = c3_all == 0;

goodsferic = ~(c1zero & c2zero & c3zero);

% get lats, lons and dispersion coefficients for sferics
stroke_time = ps(goodsferic,1);
stroke_lat = ps(goodsferic,2);
stroke_lon = ps(goodsferic,3);
station_lat = ps(goodsferic,4);
station_lon = ps(goodsferic,5);
station_ID = ps(goodsferic,6);
stroke_ID = ps(goodsferic,7);

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

%% variation of sferic parameters for each lightning stroke
strokes = unique(stroke_ID);
for i = 1%:length(strokes)
    stroke_sferics = stroke_ID == strokes(i);
    stroke_c1 = c1(stroke_sferics);
    stroke_c2 = c2(stroke_sferics);
    stroke_c3 = c3(stroke_sferics);
    stroke_d_ss = d_ss(stroke_sferics);
    stroke_station_ID = station_ID(stroke_sferics);
    lat = stroke_lat(stroke_sferics);
    lon = stroke_lon(stroke_sferics);
    time = stroke_time(stroke_sferics);

    sf = [stroke_c1 stroke_c2 stroke_c3 stroke_d_ss stroke_station_ID];
    sf = sortrows(sf, 4);

    %close(figure(1))
    figure(1)
    t1 = tiledlayout(2,2, "TileSpacing","compact");
    h1 = nexttile;
    h2 = nexttile;
    h3 = nexttile([1 2]);
    % colormap
    colors = crameri('-lajolla', size(sf,1)+3);
    colors = colors(2:end, :);
    for j = 1:length(find(stroke_sferics))
        phase = sf(j,1).*w + sf(j,2) + sf(j,3)./w;
        t_g = -sf(j,1) + sf(j,3)./(w.*w);
        t_g_18kHz = -sf(j,1) + sf(j,3)./(2*pi*18E3)^2;
        t_g_6kHz = -sf(j,1) + sf(j,3)./(2*pi*6E3)^2;
        t_g_diff = t_g_6kHz - t_g_18kHz;
        dispname = sprintf("%s: %.0f km", stations{sf(j,5),3}, sf(j,4)/1000);
        
        axes(h1);
        plot(freq/1000, phase*180/pi, '.', "DisplayName",dispname);
        hold on

        axes(h2);
        plot((t_g - t_g(end))*1000, freq/1000, '.', "DisplayName",dispname)
        hold on

        axes(h3);
        scatter(sf(j,4)/1000, t_g_diff*1000, 15, "filled", "DisplayName",dispname);
        hold on
    end
    axes(h1);
    xlabel("frequency (kHz)");
    ylabel("phase (\circ)");
    legend;
    colororder(h1, colors);
    axes(h2);
    xlabel("time (ms)");
    ylabel("frequency (kHz)");
    legend;
    colororder(h2, colors);
    axes(h3);
    xlabel("distance (km)");
    ylabel("\Deltat_{18-6 kHz} (ms)");
    %legend;
    colororder(h3, colors);
    timestr = datestr(time(1), "yyyy-mm-dd HH:MM:SS");
    titlestr = sprintf("Sferics associated with stroke at %0.3fN, %0.3fE, %s UTC", lat(1), lon(1), timestr);
    title(t1,titlestr);


end

%% plots

ph = c1_mean.*w + c2_mean + c3_mean./w;
ph_p1c1std = (c1_mean + c1_std).*w + c2_mean + c3_mean./w;
ph_n1c1std = (c1_mean - c1_std).*w + c2_mean + c3_mean./w;

tg_16kHz = c3./(2*pi*16000)^2;% - c1;
tg_8kHz = c3./(2*pi*8000)^2;% - c1;
dt_16k_8k = tg_8kHz - tg_16kHz;

d_filter = d_ss < 5000E3 & d_ss > 4000E3; % only sferics near mode of propagation distance distribution

v_g = d_ss./tg_16kHz;

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
% hold on
% plot(d_ss(d_filter), c1(d_filter), '.');
ylabel("c1 (s)")
xlabel("distance (m)")

nexttile
hold off
plot(d_ss, c2, '.');
% hold on
% plot(d_ss(d_filter), c2(d_filter), '.');
ylabel("c2 (rad)")
xlabel("distance (m)")

nexttile
hold off
plot(d_ss, c3, '.');
% hold on
% plot(d_ss(d_filter), c3(d_filter), '.');
ylabel("c3 (rad^2 s^{-1})")
xlabel("distance (m)")

nexttile
hold off
plot(d_ss, dt_16k_8k, '.');
ylabel("16kHz-8kHz time delay (s)")
ylabel("group velocity (m s^{-1})")
xlabel("distance (m)")



% figure(4)
% hold off
% plot(freq/1000, ph*180/pi, '.');
% hold on
% plot(freq/1000, ph_p1c1std*180/pi, '.');
% plot(freq/1000, ph_n1c1std*180/pi, '.');
% xlabel("frequency (kHz)")
% ylabel("phase (\circ)")