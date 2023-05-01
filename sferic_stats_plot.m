% sferic_stats_plot.m
% Todd Anderson
% 30 April 2023
%
% Plot statisics of sferic path crossings, perpendicularity, and
% perp-weighted path crossings as a function of several variables.
%
%% 1. Load average day of path crossings, perpendicularity, and perp-weighted path crossings for month of November 2022

gc = importdata("data/sferic_gridcross_10m_202211.mat");
perp = importdata("data/sferic_perp_10m_202211.mat");
gcpw = importdata("data/sferic_gcpw_10m_202211.mat");
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

%% 2. plot sample time bin of sferic paths, perpendicularity, and perp-weighted paths

k = 1;
plotvar = "perp";

h = figure(1);
h.Position = [-1000 -200 980 600];
hold off
t = tiledlayout(1,1, "TileSpacing","compact", "Padding", "compact");
nexttile
worldmap("World")
cb = colorbar("eastoutside");
cb.Label.FontSize = 15;
cb.FontSize = 15;

switch plotvar
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
end

geoshow(plotslice, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color",coastcolor);
%     contourm(latmesh, lonmesh, mlatmesh, 50:5:70, "g", "LineWidth", 1); % mlat contours
%     contourm(latmesh, lonmesh, nightmesh, 0.5, "Color", [0.8 0.8 0.8], "LineWidth", 1.5); % terminator

% % gc plot options:
% set(gca,'ColorScale','log');
% crameri('-hawaii');
% caxis([0.01 1E3]);
% cb.Label.String = "number of paths";
% titlestr = sprintf("average number of WWLLN propagation path traversals\n %s %s-%s", ...
%     datestring, timestring(k), timestring(k+1));
% 
% % perp plot options:
% crameri('tokyo');
% caxis([0 1]);
% cb.Label.String = "perpendicularity";
% titlestr = sprintf("average WWLLN path perpendicularity\n %s %s-%s", ...
%     datestring, timestring(k), timestring(k+1));




%     cmap = crameri('-batlow', 256+64);
%     cmap = magma(256);
%     set(gca, 'Colormap', cmap)
%     caxis([0 1]);
%     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
%     caxis([-0.1 0.1]);


%     nexttile
%     %worldmap("World");
%     worldmap([60 90],[-180 180])
%     geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
% %     caxis([0 1]);
% %     crameri('tokyo');%,'pivot',1); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
% %     caxis([0 0.05]);
% 
%     
%     nexttile
%     worldmap([-90 -60],[-180 180])
%     geoshow(c3plot, geoidrefvec, "DisplayType","texturemap");
%     hold on
%     geoshow(coastlat, coastlon, "Color","black");
%     
%     title("");
% %     set(gca,'ColorScale','log');
%     crameri('-hawaii');
% %     caxis([0 1]);
% %     crameri('tokyo'); % requires "crameri" colormap toolbox
%     caxis([0 0.2]);
% %     caxis([0 0.05]);

%     cb.Layout.Tile = 'east';
%     cb.Label.String = "\omega_0^{ 2}/2c (rad^2 s^{-1} m^{-1})";

%     



title(titlestr, "FontSize", 20);

set(gcf,'color','w');

% save
exportgraphics(h, savestr, "Resolution", 300)

