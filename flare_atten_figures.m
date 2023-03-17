% flare_atten_figures.m
% Todd Anderson
% March 16 2023
%
% Reproduce/remake figures from Anderson et al 2020 paper
%
% Figures:
% 1. sample path distribution
%       mark WWLLN stations!
% 2. sample trailing mean of path distribution
% 3. flare attenuation

%% load data

f906 = importdata("20170906_attenplotvars.mat");
f910 = importdata("20170910_attenplotvars.mat");

f906.gc = importdata("grid_crossings_10m_20170906.mat");
f910.gc = importdata("grid_crossings_10m_20170910.mat");

coastlines = importdata('coastlines.mat');
coastlat = coastlines.coastlat;
coastlon = coastlines.coastlon;
geoidrefvec = [1,90,-180];

stations = importdata("stations.mat");

%% 1. sample path distribution

k = 73;
pathdist = f906.gc(:,:,k);
datestring = string(datestr(f906.time_10m, "mmm dd yyyy"));
timestring = string(datestr(f906.time_10m, "hh:MM"));

h = figure(1);
h.Position = [-1000 -200 980 600];
hold off
t = tiledlayout(1,1, "TileSpacing","compact", "Padding", "compact");
nexttile;
% worldmap("World")
h1 = axesm("pcarree");
h1.FontSize = 12;
framem;
gridm;
mlabel("south");
plabel("west");
tightmap;
geoshow(pathdist, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color","black");
% geoshow([stations{:,1}], [stations{:,2}], "DisplayType", "multipoint", "Marker", "square", "MarkerFaceColor", "blue", "MarkerEdgeColor","black", "MarkerSize", 8, "DisplayName", "WWLLN stations");

% legend(h1, ["","","","WWLLN Stations","",""], "Location","southoutside", "FontSize", 15)

set(gca,'ColorScale','log');
crameri('-hawaii');
caxis([0.1 1000]);
cb = colorbar;
%     cb.Layout.Tile = 'east';
cb.Label.String = "number of paths";
cb.Label.FontSize = 15;
cb.FontSize = 15;
%     


titlestr = sprintf("WWLLN propagation paths\n%s %s-%s", ...
   datestring(k), timestring(k-1), timestring(k));
title(titlestr, "FontSize", 20);

% save
% exportgraphics(h, "figures/lanl/flare906_examplepaths2_nostations.jpg")

%% 2. sample trailing mean of path distribution

k = 73;
pathmedian = median(f906.gc(:,:,k-6:k-1), 3, "omitnan");
datestring = string(datestr(f906.time_10m, "mmm dd yyyy"));
timestring = string(datestr(f906.time_10m, "hh:MM"));

h = figure(1);
h.Position = [-1000 -200 980 600];
hold off
t = tiledlayout(1,1, "TileSpacing","compact", "Padding", "compact");
nexttile;
% worldmap("World")
h1 = axesm("pcarree");
h1.FontSize = 12;
framem;
gridm;
mlabel("south");
plabel("west");
tightmap;
geoshow(pathmedian, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color","black");
% geoshow([stations{:,1}], [stations{:,2}], "DisplayType", "multipoint", "Marker", "square", "MarkerFaceColor", "blue", "MarkerEdgeColor","black", "MarkerSize", 8, "DisplayName", "WWLLN stations");

% legend(h1, ["","","","WWLLN Stations","",""], "Location","southoutside", "FontSize", 15)

set(gca,'ColorScale','log');
crameri('-hawaii');
caxis([0.1 1000]);
cb = colorbar;
%     cb.Layout.Tile = 'east';
cb.Label.String = "number of paths";
cb.Label.FontSize = 15;
cb.FontSize = 15;
%     


titlestr = sprintf("median WWLLN propagation paths\n%s %s-%s", ...
   datestring(k), timestring(k-7), timestring(k-1));
title(titlestr, "FontSize", 20);

% save
% exportgraphics(h, "figures/lanl/flare906_examplepathmedian2_nostations.jpg")

%% 3. flare attenuation
% uncomment contour and subsolar point plotting as needed

d = 6;

if d == 6
    % September 6 2017, 12:00-12:10
    k = 73;
    flareatten = f906.dB_gridcross_sm12(:,:,k);
    datestring = string(datestr(f906.time_10m, "mmm dd yyyy"));
    timestring = string(datestr(f906.time_10m, "hh:MM"));
    clat = f906.latc(:,4,k);
    clon = f906.lonc(:,4,k);
    sslat = f906.ss_lat(k);
    sslon = f906.ss_lon(k);
    figname = "figures/lanl/flare906_atten.jpg";
elseif d == 10
    % September 10 2017, 16:40-16:50
    k = 97;
    flareatten = f910.dB_gridcross_sm12(:,:,k);
    datestring = string(datestr(f910.time_10m, "mmm dd yyyy"));
    timestring = string(datestr(f910.time_10m, "hh:MM"));
    clat = f910.latc(:,4,k);
    clon = f910.lonc(:,4,k);
    sslat = f910.ss_lat(k);
    sslon = f910.ss_lon(k);
    figname = "figures/lanl/flare910_atten.jpg";

else
    error("try d == 6 or d == 10 !")
end

flareatten(abs(flareatten) == Inf) = NaN;

h = figure(1);
h.Position = [-1000 -200 980 600];
hold off
t = tiledlayout(1,1, "TileSpacing","compact", "Padding", "compact");
nexttile;
% worldmap("World")
h1 = axesm("pcarree");
h1.FontSize = 12;
framem;
gridm;
mlabel("south");
plabel("west");
tightmap;
geoshow(flareatten, geoidrefvec, "DisplayType","texturemap");
hold on
geoshow(coastlat, coastlon, "Color","black");
% geoshow(sslat, sslon, DisplayType="point", Marker="square", MarkerFaceColor="yellow", MarkerSize=8);
% geoshow(clat, clon, Color="yellow", LineWidth=2)
% geoshow([stations{:,1}], [stations{:,2}], "DisplayType", "multipoint", "Marker", "square", "MarkerFaceColor", "blue", "MarkerEdgeColor","black", "MarkerSize", 8, "DisplayName", "WWLLN stations");

% legend(h1, ["","","","WWLLN Stations","",""], "Location","southoutside", "FontSize", 15)

% set(gca,'ColorScale','log');
ncolors = 64;
g = [1 1 1]*0.8;
cmap = crameri('vik', ncolors);
cmap = [g; cmap; g];

cextents = [-10 10];
offset = range(cextents)*(size(cmap,1)/ncolors - 1)/2;
caxis(cextents + [-offset offset]);

colormap(cmap);
cb = colorbar;
%     cb.Layout.Tile = 'east';
cb.Label.String = "10 log_{10}ss/ss_b";
cb.Label.FontSize = 15;
cb.FontSize = 15;
%     


titlestr = sprintf("attenuation of WWLLN propagation paths\n%s %s-%s", ...
   datestring(k), timestring(k-1), timestring(k));
title(titlestr, "FontSize", 20);

% save
% exportgraphics(h, figname)

%% contour comparison with xray flux

d = 6;

if d == 6
    dt_crad = datetime(f906.time_10m, "ConvertFrom","datenum");
    crad = f906.maxrad(:,4);
    dt_xrs = datetime(f906.time_num_20, "ConvertFrom", "datenum");
    xrs_A = f906.xrs_AFLUX_20;
    figname = "figures/lanl/flare906_crad_xrs.jpg";
elseif d == 10
    dt_crad = datetime(f910.time_10m, "ConvertFrom","datenum");
    crad = f910.maxrad(:,4);
    dt_xrs = datetime(f910.time_num_10, "ConvertFrom", "datenum");
    xrs_A = f910.xrs_AFLUX_10;
    figname = "figures/lanl/flare910_crad_xrs.jpg";
else
    error("try d == 6 or d == 10 !")
end

datestring = string(datestr(dt_crad(1), "mmm dd yyyy"));
purple = [0.6 0.2 0.6];
yellow = [0.5 0.3 0.0];

h = figure(2);
h.Position = [-1000 -200 980 600];
yyaxis left
semilogy(dt_xrs,xrs_A, '-', LineWidth=1, Color=purple);
ylim([1E-8 1E-3])
ylabel("X-ray irradiance (W m^{-2})", FontSize=15);
ax = gca;
ax.YColor = purple;
colororder(purple);
yyaxis right
plot(dt_crad,crad, '-', LineWidth=1, color=yellow)
ylim([0 90])
ylabel("Attenuation region radius (\circ)", FontSize=15);
ax = gca;
ax.YColor = yellow;
set(gca, "FontSize", 15)
titlestr = sprintf("GOES-13 0.05-0.4 nm X-ray irradiance and WWLLN -6 dB contour radius\n%s", datestring);
title(titlestr, FontSize=20);

% save
exportgraphics(h, figname, Resolution=300)
