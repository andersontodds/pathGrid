 % read_sfile.m
% Todd Anderson
% November 1 2022
%
% Read WWLLN Sfiles, get sferic properties, and associate sferics with
% strokes

% read Sfiles
% examples from Seattle station (togasea):
%   data/S202107072355
%   data/S202107080401
% Sfile format: each line has comma-separated values
%  1     magic header, 
%  2     station ID, 
%  3     UT time yyyy-mm-ddTHH:MM:SS, 
%  4     UTC toga offset in microseconds,
%  5     RMS amplitude of waveform,
%  6     TOGA offset in seconds from start of waveform,
%  7-9   The three dispersion fit parameters fit0 , fit1 , << fit2,
%  10    a dispersion fit ok flag (0 or 1),
%  11    sampling frequency in Hz (typically about 48 or 96 kHz),
%  12    number of waveforms samples (typically 64 or 128),
%  13-end  the waveform samples.
% E.g. the first line of data/S202107080401 is:
%   W210,10,2021-07-08T04:01:00,85788,2709,0.000389205,8.18806e-06,2.65566,380397,1,95991.63541,128,-0.00141068,-0.00173478, ... ,-0.0293896
%

fclose("all");
% sfile = "data/S-files/2021/S202107080401"; % seattle/togasea Sfile
sfile = "data/S-files/2022/S202211072302"; % fairbanks Sfile
fid = fopen(sfile,'r');

nlines = countLines(sfile);

%

rms = zeros(nlines, 2); % mRMSAmp, rmsAmp
cfit = zeros(nlines, 3); % c1, c2, c3
rmsPhaseError = zeros(nlines, 1);
kHzFreqs = zeros(nlines, 17); % frequencies in dispersion fit
tOffsets = zeros(nlines, 1); % time offset between start of sample and TOGA trigger point
mutoga = zeros(nlines, 1);
dtoga = zeros(nlines, 1);
secs = zeros(nlines, 1);


j=1;
while j <= nlines

    tLine = fgets(fid); % each successive call gets next line in sfile
    
    % get header values, minus leading magic header "W210"
    [A, ~, errmsg, nextindex] = sscanf(tLine(6:end),'%d,%4d-%2d-%dT%2d:%2d:%2d,%d,%d,%f,%f,%f,%f,%d,%f,%d',16);
    % get waveform samples
    [y, count] = sscanf(tLine(nextindex+6:end),'%f,',inf);
    
    time = datenum(A(2:7)');
    secs(j) = second(datetime(time, "ConvertFrom", "datenum"));

    mutoga(j) = A(8);  % UTC toga offset in microseconds
    rmsAmp = A(9);  % rms amplitude
    dtoga(j) = A(10);  % TOGA offset in seconds from start of waveform
    c1=A(11);       % dispersion fit parameters
    c2=A(12);       %
    c3=A(13);       %
    Fs=A(15);       % sampling frequency in Hz
    N=A(16);        % number of samples
    
    cfit(j,:) = [c1, c2, c3];

    f1=6000;        % VLF TOGA frequency envelope: 6-18 kHz
    f4=18000;
    % TODO: figure out what exactly f1Idx, f4Idx represent!
    % 
    f1Idx = floor(f1*N/Fs+0.5)+1; % low frequency * number of samples/sampling frequency == low frequency * time to take all samples == number of samples * fraction 
    f4Idx = floor(f4*N/Fs+0.5)+1;
    f=(0:N/2-1)*Fs/N;
    
    s=y';
    S=fft(s);
    
    %Option to measure phase relative to first sample
    %tOffset = 0;
        
    %or measure phase relative to trigger point
    %i.e. delayed by N/4 samples
    wtN4=1i*2*pi*0.25*(0:N/2-1);
    S=exp(wtN4).*S(1:N/2);
    tOffset = 0.25*N/Fs;
    tOffsets(j) = tOffset;
    
    measuredPhase = unwrap(angle(S));
    
    %estimate range
    amp = abs(S(f1Idx:f4Idx));
    %amp = amp.^2;
    phase = measuredPhase(f1Idx:f4Idx);
    freq = f(f1Idx:f4Idx);
    w=2*pi*freq;
    
    ws=w/std(w);
    pa=togafit(ws,phase,amp);
    
    pa(1)=pa(1)/std(w);
    pa(3)=pa(3)*std(w);
    
%     pa
    fittedPhase = pa(1).*w + pa(2) + pa(3)./w;
    cfitph = c1.*w + c2 + c3./w;
    
    %do the linear toga fit
    ta=polyfit(w,phase,1);
    t1=-ta(1) + tOffset;
    
    %mLinPhaseFit = (180/pi)*(ta(1)*w+ta(2));
    
    % plots
%     figure(1)
    
%     subplot(2,2,[1 3])
    
    %plot the measured and fitted phase 
    deltaPhase = (180/pi)*(phase - fittedPhase);
    rmsPhaseError(j) = sqrt(sum(deltaPhase.*deltaPhase)/length(phase));
    
    
    kHzFreq=0.001*freq;
    kHzFreqs(j,:) = kHzFreq;
%     plot(kHzFreq,phase*180/pi,'k',kHzFreq,fittedPhase*180/pi,'b--',kHzFreq,cfitph*180/pi,'r*');
%     xlabel('Frequency (kHz)');
%     ylabel('Phase (degrees)');
%     legend('Measured phase','MATLAB fit','C++ fit')
%     title(sprintf('RMS phase error = %f',rmsPhaseError(j)));
    
    %group travel time = -dphi/dw
    t0=-pa(1) + tOffset;
    tg= t0 + pa(3)./(w.*w);
%     subplot(2,2,2)
    
%     plot([t1 t1],[kHzFreq(1) kHzFreq(end)],'b',dtoga*ones(size(kHzFreq(1:3:end))),kHzFreq(1:3:end),'r*', tg,kHzFreq,'k',[t0 t0],[kHzFreq(1) kHzFreq(end)],'k--');
%     xlabel('Time (s)');
%     ylabel('Frequency (kHz)');
    
%     legend('MATLAB TOGA','C++ TOGA')
%     title('Dispersion & TOGA (linear fit)');
%     v=axis;
%     v(1)=0e-3;
%     v(2)=1.2e-3;
%     axis(v);
    
%     subplot(2,2,4)
    
    %compute RMS amp
    mRMSAmp = sqrt(mean(s(N/4:end).^2))*32768;
    timeBase = (1:length(s))/Fs;
    
    %,[min(timeBase) max(timeBase)],[mRMSAmp mRMSAmp],'g--',[min(timeBase) max(timeBase)],[rmsAmp rmsAmp]/32768,'g*'
%     plot([t1 t1],[-1 1],'b',[dtoga dtoga dtoga dtoga dtoga dtoga],[-0.5 -0.3 -0.1 0.1 0.3 0.5 ],'r*',timeBase,s,'k',[-c1+0.25*N/Fs -c1+0.25*N/Fs],[-1 1],'k--');%,[t0 t0],[min(s) max(s)],'r--');
%     xlabel('Time (s)')
%     ylabel('Amplitude');
%     legend('MATLAB TOGA','C++ TOGA')
%     title(sprintf('Sferic waveform & TOGA. RMS Amp = %f, %d',mRMSAmp,rmsAmp));
%     v=axis;
%     v(1)=0e-3;
%     v(2)=1.2e-3;
%     v(3)=-0.8;
%     v(4)=0.8;
%     axis(v);
    
    %c=299792458;
    %h=87e3;
    %w1= 2*pi*c/(2*h);
    %r=c*2*pa(3)/(w1*w1);
    %tstr = sprintf('h = %d km, range = %6g km',h/1000,r/1000);
    %title(tstr);
    
    
        
    %  end
    %if okSferic==1,
    %        pause
    % else
    %     pause(0.1)
    % end
    rms(j,:)=[mRMSAmp, rmsAmp];
    j=j+1;
end

fclose(fid);

%% define functions

function count = countLines(fname)
% adapted from here: https://stackoverflow.com/a/12177413/10526646
fh = fopen(fname, 'rt');
assert(fh ~= -1, 'Could not read: %s', fname);
x = onCleanup(@() fclose(fh));
count = 0;
while ~feof(fh)
    count = count + sum( fread( fh, 16384, 'char' ) == char(10) );
end
end
