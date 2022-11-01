% perpendicularity_test.m
% Todd Anderson
% September 23 2022
%
% Test characterstics of circular perpendicularity for different
% distributions.
%

% define angular distributions
a_uniform = deg2rad(0:10:350);  % evenly-spaced
a_uniform = a_uniform';
a_beamed = randn(size(a_uniform))*pi/16; % normal distribution with mean 0 and standard deviation of pi/16
% a_perp2 = [ones(length(a_uniform)/2, 1)*0; ones(length(a_uniform)/2, 1)*1]*pi/2; % bimodal perpendicular distribution
% a_perp4 = [ones(length(a_uniform)/4, 1)*0; ones(length(a_uniform)/4, 1)*1; ...
%     ones(length(a_uniform)/4, 1)*2; ones(length(a_uniform)/4, 1)*3]*pi/2; % quadrimodal perpendicular distribution

a_perp2 = [randn(length(a_uniform)/2, 1)*pi/16; randn(length(a_uniform)/2, 1)*pi/16 + pi/2]; % bimodal perpendicular distribution
a_perp4 = [randn(length(a_uniform)/4, 1)*pi/16; randn(length(a_uniform)/4, 1)*pi/16 + pi/2; ...
    randn(length(a_uniform)/4, 1)*pi/16 + pi; randn(length(a_uniform)/4, 1)*pi/16 + 3*pi/2]; % quadrimodal perpendicular distribution

v_uniform = circ_var(a_uniform);
v_beamed = circ_var(a_beamed);
v_perp2 = circ_var(a_perp2);
v_perp4 = circ_var(a_perp4);

p_uniform = circ_var(2*a_uniform);
p_beamed = circ_var(2*a_beamed);
p_perp2 = circ_var(2*a_perp2);
p_perp4 = circ_var(2*a_perp4);

figure(1)
tiledlayout(2,2, "TileSpacing","compact","Padding","compact")
nexttile
polarhistogram(a_uniform,36);
titlestr = sprintf("Uniform\nP = %0.2f, V = %0.2f", p_uniform, v_uniform);
title(titlestr);

nexttile
polarhistogram(a_beamed,36)
titlestr = sprintf("Beamed\nP = %0.2f, V = %0.2f", p_beamed, v_beamed);
title(titlestr);

nexttile
polarhistogram(a_perp2,36)
titlestr = sprintf("Bimodal perpendicular\nP = %0.2f, V = %0.2f", p_perp2, v_perp2);
title(titlestr);

nexttile
polarhistogram(a_perp4,36)
titlestr = sprintf("Quadrimodal perpendicular\nP = %0.2f, V = %0.2f", p_perp4, v_perp4);
title(titlestr);

