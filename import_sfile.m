function sfile_values = import_sfile(sfilename)
% Todd Anderson
% November 9 2022
% 
% Reads Sfile information and returns matrix of sferic information.

fclose("all");
% sfilename = "data/S-files/2021/S202107080401"; % seattle/togasea Sfile
% sfilename = "data/S-files/2022/S202211072302"; % fairbanks Sfile

nlines = countLines(sfilename);

fid = fopen(sfilename,'r');
%

time = zeros(nlines, 1);
mutoga = zeros(nlines, 1);
rmsAmp = zeros(nlines, 1);
dtoga = zeros(nlines, 1);
c1 = zeros(nlines, 1);
c2 = zeros(nlines, 1);
c3 = zeros(nlines, 1);
Fs = zeros(nlines, 1);
N = zeros(nlines, 1);
% rmsPhaseError = zeros(nlines, 1);
% kHzFreqs = zeros(nlines, 17); % frequencies in dispersion fit
% tOffsets = zeros(nlines, 1); % time offset between start of sample and TOGA trigger point
% secs = zeros(nlines, 1);


j=1;
while j <= nlines

    tLine = fgets(fid); % each successive call gets next line in sfile
    
    % get header values, minus leading magic header "W210"
    [A, ~, errmsg, nextindex] = sscanf(tLine(6:end),'%d,%4d-%2d-%dT%2d:%2d:%2d,%d,%d,%f,%f,%f,%f,%d,%f,%d',16);
    % add check: if line in Sfile does not have enough elements, skip it

    % get waveform samples
    %[y, count] = sscanf(tLine(nextindex+6:end),'%f,',inf);
    
    time(j) = datenum(A(2:7)');
    %secs(j) = A(7);

    mutoga(j) = A(8);  % UTC toga offset in microseconds
    rmsAmp(j) = A(9);  % rms amplitude
    dtoga(j) = A(10);  % TOGA offset in seconds from start of waveform
    c1(j)=A(11);       % dispersion fit parameters
    c2(j)=A(12);       %
    c3(j)=A(13);       %
    Fs(j)=A(15);       % sampling frequency in Hz
    N(j)=A(16);        % number of samples

    j=j+1;
end

fclose(fid);

sfile_values = cat(2,time, mutoga, rmsAmp, dtoga, c1, c2, c3, Fs, N);

end