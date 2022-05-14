%function compare_attencontour(data_gridcross,times)
% compare_attencontour.m
% 
% outline:
%   * calculate attenuation contours using pg_attencontour.m,
%   * compare to GOES X-ray data --> plot both of these

time_10m = datenum(2022, 03, 30, 00, 10:10:1440, 00);
time_10m = time_10m';

[ss_lat, ss_lon] = subsolar(time_10m);
cspec = [6 4 2];
[latc, lonc, maxrad] = pg_attencontour(dB_gridcross,ss_lat,ss_lon,cspec);

filename = 'sci_xrsf-l2-flsum_g16_s20170209_e20220331_v2-1-0.nc';
%filename = 'sci_xrsf-l2-flsum_g17_s20180601_e20220331_v2-1-0.nc';

%ncdisp(filename);

% read variables from file

xrsb_flux = ncread(filename, 'xrsb_flux');
xrsb_time = ncread(filename, 'time');
xrsb_time_dn = xrsb_time/86400 + datenum(2000, 01, 01, 12, 00, 00);

xrsb_pg_ind = find(xrsb_time_dn >= time_10m(1) & xrsb_time_dn <= time_10m(end));
xrsb_time_pg = xrsb_time_dn(xrsb_pg_ind);
xrsb_flux_pg = xrsb_flux(xrsb_pg_ind);

figure(1)
hold off
yyaxis left
plot(time_10m, maxrad(:,1));
hold on
plot(time_10m, maxrad(:,2));
plot(time_10m, maxrad(:,3));
yyaxis right
semilogy(xrsb_time_pg, xrsb_flux_pg);


coastlines = importdata('coastlines.mat');
coastlat = coastlines.coastlat;
coastlon = coastlines.coastlon;
geoidrefvec = [1,90,-180];

t = 107;

figure(2)
hold off
colormap(redblue);
hold off;
geoshow(dB_gridcross(:,:,t), geoidrefvec, 'DisplayType','texturemap');
hold on;
geoshow(coastlat, coastlon, 'Color', 'black');
%geoshow(stll(:,1),stll(:,2),'DisplayType','Point');
geoshow(ss_lat(t), ss_lon(t), 'DisplayType', 'Point');

cb = colorbar('southoutside');
label = cb.Label;
label.String = ['Attenuation of stroke-station path crossings (dB) ',datestr(time_10m(t))];
label.FontSize = 10;
caxis([-10 10]);