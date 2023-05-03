% sferic_stats_gif.m
% Todd Anderson
% 2 May 2023
%
% Plot statisics of sferic path crossings, perpendicularity, and
% perp-weighted path crossings as a function of several variables.  Same as
% sferic_stats_plot.m, but generates gif animations.
%
%% 1. Load average day of path crossings, perpendicularity, and perp-weighted path crossings for month of November 2022

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

chooseplot = "d_quiet_sm5";

for k = 1:size(gc,3)%;

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
        savestr = 'animations/average_paths_10m_202211.gif';

    case "perp"
        plotslice = perp(:,:,k);
        % perp plot options:
        coastcolor = "white";
        crameri('tokyo');
        caxis([0 1]);
        cb.Label.String = "perpendicularity";
        titlestr = sprintf("average WWLLN path perpendicularity\n %s %s-%s", ...
            datestring, timestring(k), timestring(k+1));
        savestr = 'animations/average_perp_10m_202211.gif';

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
        savestr = 'animations/average_perp_weighted_paths_10m_202211.gif';

    case {"d_quiet", "d_quiet_sm5"}

        
        % terminator test
        [sslat, sslon] = subsolar(times(k));
        night = distance(sslat, sslon, latmesh, lonmesh, 'degrees') > 90;
        nightmesh = zeros(size(latmesh));
        nightmesh(night) = 1;
        contourm(latmesh, lonmesh, mlatmesh, 50:5:70, "g", "LineWidth", 1); % mlat contours
        contourm(latmesh, lonmesh, nightmesh, 0.5, "Color", [0.8 0.8 0.8], "LineWidth", 1.5); % terminator

        if chooseplot == "d_quiet"
            plotslice = d_quiet(:,:,k);
            titlestr = sprintf("average quiet-day sferic dispersion\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'animations/dispersion_quietavg_10m_202211.gif';
        elseif chooseplot == "d_quiet_sm5"
            plotslice = d_quiet_sm5(:,:,k);
            titlestr = sprintf("average quiet-day sferic dispersion with 5 degree smoothing\n %s %s-%s", ...
                datestring, timestring(k), timestring(k+1));
            savestr = 'animations/dispersion_quietavg_sm5_10m_202211.gif';
        else
            error("Could not determine variable to plot!");
        end
        % perp plot options:
        coastcolor = "white";
        colormap('magma');
        caxis([0 0.2]);
        cb.Label.String = "a_3/r";

end

geoshow(plotslice, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color",coastcolor);

% terminator and mlat contours
if chooseplot == "d_quiet" || chooseplot == "d_quiet_sm5"
    [sslat, sslon] = subsolar(times(k));
    night = distance(sslat, sslon, latmesh, lonmesh, 'degrees') > 90;
    nightmesh = zeros(size(latmesh));
    nightmesh(night) = 1;
    contourm(latmesh, lonmesh, mlatmesh, 50:5:70, "g", "LineWidth", 1); % mlat contours
    contourm(latmesh, lonmesh, nightmesh, 0.5, "Color", [0.8 0.8 0.8], "LineWidth", 1.5); % terminator
end

title(titlestr, "FontSize", 20);

set(gcf,'color','w');

if k == 1
    gif(savestr);
else
    gif;
end

end
