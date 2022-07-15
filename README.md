# pathGrid
pathGrid is a set of scripts and functions that calculates and plots statistics of great circle paths on a geodetic grid.

The purpose of this project is to detect regions of attenuation of very-low-frequency (VLF) radio waves in the Earth-ionosphere waveguide, caused by
extreme solar flares, using VLF waves launched by lightning strokes and detected by the [World Wide Lightning Location Network (WWLLN)](wwlln.net).  Results of this
technique, applied to the solar storm of September 2017, were presented at the February 2019 AGU Chapman Conference on "Challenges Related to Space Weather Forecasting Including Extremes", and published in the accompanying special issue of *Space Weather*:

**Anderson, T. S.**, McCarthy, M. P., & Holzworth, R. H. (2020). Detection of VLF attenuation in the Earth-ionosphere waveguide caused by X-class solar flares using a global lightning location network. *Space Weather*, 18, e2019SW002408. [doi:10.1029/2019SW002408](https://doi.org/10.1029/2019SW002408)

June 24, 2022: The next updates to this project will be:

1. examining nominal path distributions over month and year averages; 
2. simulating additional stations, and investigating where additional stations might have outsized impacts on the nominal path distribution; 
3. ~~~running analysis for recent X- and M-class flares, including getting the subsolar attenuation area analysis working;~~~ switching focus to higher-latitude regions for now!
4. investigating spatial resolution in polar/auroral regions
5. incorporating and analyzing sferic dispersion, and estimating the electron density slope at the VLF reflection layer; and
6. cleaning up documentation and packaging a release.

All X-class flares between Jan 1, 2017, and March 30, 2022, have been processed, but need to be re-run with the subsolar attenuation region code.  If you want to try this out with your own data, send me a message and I'll help you get started!

This code is fast enough to run in "near-real-time"; that is, it takes less than an hour to run a full day of WWLLN data, and theoretically could run on 10-minute files with less than 10 minutes of runtime per file.  However, I'm not sure it's worth developing a real-time version of this analysis until there is a better science case for using this analysis on non-flare days, **and** I have reduced runtime enough to make analysis of many years of WWLLN data feasible.  If you disagree, and want to see a real-time version of this project, let me know!

Here's an example of the stroke-to-station path distribution detected by WWLLN.  This is a plot of the whole month of March 2022, with each 10-minute window of every day averaged.  Next, I'll try longer averages (seasonal, yearly), although at about 48 minutes per day, it takes about 24 hours to run the pathGrid code on a full month of WWLLN data!

![average stroke-to-station paths in 10-minute windows in March 2022](https://github.com/andersontodds/pathGrid/blob/master/average_paths_202203.gif?raw=true)

## Current full pathGrid workflow
1. ensure working directory contains daily APfiles for flare days, as well as all scripts mentioned in this procedure.
2. edit ```getPathsFromAP.m``` to point to day or days relevant to analysis: ```startnum```, ```stopnum```, ```starttime```, and ```stoptime``` need to be edited.
3. run ```getPathsFromAP.m``` to generate stroke-station path files
4. run ```pathGrid_fullstats_10m.m``` to generate statistics on grid crossings
5. run ```pathgGrid_video.m``` to generate .mp4 video of grid crossings statistics over time range

## Remote workflow (APfiles on flash5, processing on flashlight): 
Run ```run_pathgrid.m```, which does the following:

1. loads dates of interest generated by ```flare_import.m``` (e.g. X-class flare days)
2. for each date, 
   a. get pathlist files with ```getpaths.m```
   b. get ```grid_crossings```, ```mm_gridcross```, ```d_gridcross``` with ```pathgrid.m```
   c. create AVI video of grid_crossings./mm_gridcross (including smoothing) with ```animate_pg.m```

## TO DO (April 15, 2022):
1. Trim the fat! Functions in remote workflow include ugly comment blocks and are not memory-efficient; e.g., should not need to both pass entire ```pathlist_lite``` to ```pathgrid``` and load 10-minute pathlist files.
2. Add subsolar contour analysis back in to ```animate_pg```, and save contour radius time series.
3. Add option to save matrix of frames plotted with ```animate_pg```, so single frames can be plotted later.
4. Enable control of ```animate_pg``` statistics and plotting options with optional arguments.
5. Get proper benchmarks working: started running x_days only on April 15 at about 17:50 PDT.
