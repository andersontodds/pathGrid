% sferic_stats_plot.m
% Todd Anderson
% 30 April 2023
%
% Plot statisics of sferic path crossings, perpendicularity, and
% perp-weighted path crossings as a function of several variables.
%
%% 1. Load average day of path crossings, perpendicularity, and perp-weighted path crossings for month of November 2022

c = 299792458;

gc = importdata("data/sferic_gridcross_10m_202211.mat");
perp = importdata("data/sferic_perp_10m_202211.mat");
gcpw = importdata("data/sferic_gcpw_10m_202211.mat");
d_quiet = importdata("data/sferic_dispersion_10m_202211_quietavg.mat");
d_quiet_sm5 = importdata("data/sferic_dispersion_10m_202211_quietavg_sm5.mat");
load coastlines;
geoidrefvec = [1,90,-180];

% run days
run_start = datenum(2022, 11, 01);
run_end = datenum(2022, 11, 30);
run_days = run_start:run_end;
% run_days = datenum(2022, 11, [6, 10, 12, 14, 15, 16, 17, 19, 21, 22, 23, 24]);
run_days = run_days';
times = linspace(run_start, run_start+1, 145);
timestring = string(datestr(times, "HH:MM:SS"));
datestring = string(datestr(run_start, "mmmm yyyy"));

[lonmesh, latmesh] = meshgrid(-179.5:179.5,-89.5:89.5);
mlatmesh = importdata("mlatmesh.mat");
%% 2. plot sample time bin of sferic paths, perpendicularity, and perp-weighted paths

chooseplot = "iono_h";
% single-day options
% day = 3;
% datestring = string(datestr(datenum(2022,11,day), "mmmm dd yyyy"));
% dispersion_filename = sprintf("data/sferic_grouptimediff_gridcross_10m_202211%02d.mat", day);
% dispersion = importdata(dispersion_filename);

k = 100;

h = figure(1);
h.Position = [-1000 -200 980 600];
hold off
t = tiledlayout(1,1, "TileSpacing","compact", "Padding", "compact");
nexttile
worldmap("World")
cb = colorbar("eastoutside");
cb.Label.FontSize = 15;
cb.FontSize = 15;

switch chooseplot
    case "gc"
        plotslice = gc(:,:,k);
        % gc plot options:
        coastcolor = "black";
        set(gca,'ColorScale','log');
        crameri('-hawaii');
        caxis([0.01 1E3]);
        cb.Label.String = "number of paths";
        titlestr = sprintf("average number of WWLLN propagation path traversals\n %s %s-%s", ...
            datestring, timestring(k), timestring(k+1));
        savestr = "figures/average_paths_example10m_202211.jpg";

    case "perp"
        plotslice = perp(:,:,k);
        % perp plot options:
        coastcolor = "white";
        crameri('tokyo');
        caxis([0 1]);
        cb.Label.String = "perpendicularity";
        titlestr = sprintf("average WWLLN path perpendicularity\n %s %s-%s", ...
            datestring, timestring(k), timestring(k+1));
        savestr = "figures/average_perp_example10m_202211.jpg";

    case "gcpw"
        plotslice = gcpw(:,:,k)./2;
        % gcpw plot options:
        coastcolor = "black";
        set(gca,'ColorScale','log');
        crameri('-roma');
        caxis([1E-2 1E3]);
        cb.Label.String = "number of perpendicular pairs";
        titlestr = sprintf("average equivalent perpendicular path pairs\n %s %s-%s", ...
            datestring, timestring(k), timestring(k+1));
        savestr = "figures/average_perp_weighted_paths_example10m_202211.jpg";

    case {"d_quiet", "d_quiet_sm5", "d_qadiff", "dispersion"}
        if chooseplot == "d_quiet"
            plotslice = d_quiet(:,:,k);
            titlestr = sprintf("average quiet-day sferic dispersion\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'figures/dispersion_quietavg_example10m_202211.jpg';
            caxis([0 0.2]);
        elseif chooseplot == "d_quiet_sm5"
            plotslice = d_quiet_sm5(:,:,k);
            titlestr = sprintf("average quiet-day sferic dispersion with 5 degree smoothing\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'figures/dispersion_quietavg_sm5_example10m_202211.jpg';
            caxis([0 0.2]);
        elseif chooseplot == "d_qadiff"
            % TODO: use diverging colormap!
            plotslice = dispersion(:,:,k) - d_quiet(:,:,k);
            plotslice(isnan(plotslice)) = 0;
            titlestr = sprintf("sferic dispersion: difference from quiet-day mean\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'figures/dispersion_qadiff_example10m_202211.jpg';
            caxis([-0.1 0.1]);
        elseif chooseplot == "dispersion"
            plotslice = dispersion(:,:,k);
            titlestr = sprintf("sferic dispersion\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'figures/dispersion_example10m_20221103.jpg';
            caxis([0 0.2]);
        else
            error("Could not determine variable to plot!");
        end
        % dispersion plot options:
        coastcolor = "white";
        colormap('magma');
%         cmocean('curl', 'negative', 'pivot', 0);
        cb.Label.String = "a_3/r";

    case {"iono_h", "cutoff_freq"}
        if chooseplot == "iono_h"
            plotslice = pi*c./sqrt(d_quiet(:,:,k)*2*2*c)./1E3;
            titlestr = sprintf("corrected ionosphere effective height\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'figures/ionoh_quietavg_example10m_corr_202211.jpg';
            caxis([60 120]);
            % iono_h plot options:
            coastcolor = "white";
            crameri('-oslo');
            cb.Label.String = "height (km)";
        elseif chooseplot == "cutoff_freq"
            plotslice = sqrt(d_quiet(:,:,k)*2*2*c)./(2*pi)./1E3;
            titlestr = sprintf("cutoff frequency\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'figures/cutoff_quietavg_example10m_202211.jpg';
            caxis([0.8 2]);
            % dispersion plot options:
            coastcolor = "white";
            crameri('hawaii');
            cb.Label.String = "frequency (kHz)";
        else
            error("Could not determine variable to plot!");
        end

end

geoshow(plotslice, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color",coastcolor);

% terminator and mlat contours
switch chooseplot
    case {"d_quiet", "d_quiet_sm5", "d_qadiff", "dispersion", "iono_h", "cutoff_freq"}
    [sslat, sslon] = subsolar(times(k));
    night = distance(sslat, sslon, latmesh, lonmesh, 'degrees') > 90;
    nightmesh = zeros(size(latmesh));
    nightmesh(night) = 1;
%     contourm(latmesh, lonmesh, mlatmesh, 50:5:70, "g", "LineWidth", 1); % mlat contours
    contourm(latmesh, lonmesh, nightmesh, 0.5, "Color", [0.8 0.8 0.8], "LineWidth", 1.5); % terminator
end

title(titlestr, "FontSize", 20);

set(gcf,'color','w');

% save
% exportgraphics(h, savestr, "Resolution", 300)

%% 3. calculate and plot statistics of gc, perp and gcpw
% want average gc, perp, gcpw in: time, localtime, lat, lon
% 1. time
% calculate average over entire time slice, for all slices

gc_mean = zeros(size(gc,3),1);
perp_mean = zeros(size(gc_mean));
for i = 1:size(gc,3)
    gc_mean(i) = mean(gc(:,:,i), "all", "omitnan");
    perp_mean(i) = mean(perp(:,:,i), "all", "omitnan");
end

h = figure(2);
hold off
t = tiledlayout(2,1,"TileSpacing","compact","Padding","compact");
nexttile
plot(datetime(times(2:end), "ConvertFrom", "datenum"), gc_mean);
nexttile
plot(datetime(times(2:end), "ConvertFrom", "datenum"), perp_mean);

% 2. local time
% see filtering techniques in mlat_sferic_stats.m
% use solar angle tools
