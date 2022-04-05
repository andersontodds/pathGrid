# pathGrid
pathGrid is a set of scripts and functions that calculates and plots statistics of great circle paths on a geodetic grid.

The purpose of this project is to detect regions of attenuation of very-low-frequency (VLF) radio waves in the Earth-ionosphere waveguide, caused by
extreme solar flares, using VLF waves launched by lightning strokes and detected by the [World Wide Lightning Location Network (WWLLN)](wwlln.net).  Results of this
technique, applied to the solar storm of September 2017, were presented at the February 2019 AGU Chapman Conference on "Challenges Related to Space Weather Forecasting Including Extremes", and published in the accompanying special issue of *Space Weather*:

**Anderson, T. S.**, McCarthy, M. P., & Holzworth, R. H. (2020). Detection of VLF attenuation in the Earth-ionosphere waveguide caused by X-class solar flares using a global lightning location network. *Space Weather*, 18, e2019SW002408. [doi:10.1029/2019SW002408](https://doi.org/10.1029/2019SW002408)

March 30, 2022: The next updates to this project will be:

1. running analysis for recent X- and M-class flares,
2. automatically running the analysis in real time on a WWLLN server,
3. incorporating and analyzing sferic dispersion, and
4. cleaning up documentation and packaging a release.

Ideally these updates will be ready by the end of November.  If you want to try this out with your own data, send me a message and I'll help you get started!

## Current pathGrid workflow
1. ensure working directory contains daily APfiles for flare days, as well as all scripts mentioned in this procedure.
2. edit ```getPathsFromAP.m``` to point to day or days relevant to analysis: ```startnum```, ```stopnum```, ```starttime```, and ```stoptime``` need to be edited.
3. run ```getPathsFromAP.m``` to generate stroke-station path files
4. run ```pathGrid_fullstats_10m.m``` to generate statistics on grid crossings
5. run ```pathgGrid_video.m``` to generate .mp4 video of grid crossings statistics over time range

Desired workflow:
1. ensure working directory contains all relevant files
2. specify input parameters: date range, ...
3. check for existence of stroke-station path files; if they exist for time range, skip to next step; else, generate with ```getPathsFromAP.m```
4. check for existence of ```grid_cell*.mat``` and/or ```grid_crossings*.mat``` files in time range; if detected, ask user to confirm they should be used
5. run ```pathGrid_fullstats_10m.m``` or similar to generate statistics on grid crossings
6. run ```pathGrid_figures.m``` or similar to generate figures and animations
