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

fid = fopen("data/S202107080401");

j=1;
sfile = fopen('data/S202107080401','r');

% while 1==1

tLine = fgets(sfile); % each successive call gets next line in sfile

% get header values, minus leading magic header "W210"
[A, ~, errmsg, nextindex] = sscanf(tLine(6:end),'%d,%4d-%2d-%dT%2d:%2d:%2d,%d,%d,%f,%f,%f,%f,%d,%f,%d',16);
% get waveform samples
[y, count] = sscanf(tLine(nextindex+6:end),'%f,',inf);

time = datenum(A(2:7)');

rmsAmp = A(9);  % rms amplitude
dtoga = A(10);  % TOGA offset in seconds from start of waveform
c1=A(11);       % dispersion fit parameters
c2=A(12);       %
c3=A(13);       %
Fs=A(15);       % sampling frequency in Hz
N=A(16);        % number of samples

f1=6000;        % VLF TOGA frequency envelope: 6-18 kHz
f4=18000;
% TODO: figure out what exactly f1Idx, f4Idx represent!
% number of samples at 
f1Idx = floor(f1*N/Fs+0.5)+1; % low frequency * number of samples/sampling frequency == low frequency * time to take all samples == number of samples * fraction 
f4Idx = floor(f4*N/Fs+0.5)+1;
f=(0:N/2-1)*Fs/N;

s=y';
S=fft(s);

 %Option to measure phase relative to first sample
tOffset = 0;
    
%or measure phase relative to trigger point
%i.e. delayed by N/4 samples
wtN4=1i*2*pi*0.25*(0:N/2-1);
S=exp(wtN4).*S(1:N/2);
tOffset = 0.25*N/Fs;

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

pa
fittedPhase = pa(1).*w + pa(2) + pa(3)./w;
cfitph = c1.*w + c2 + c3./w;

%do the linear toga fit
ta=polyfit(w,phase,1);
t1=-ta(1) + tOffset;

%mLinPhaseFit = (180/pi)*(ta(1)*w+ta(2));

figure(1)

subplot(2,2,[1 3])

%plot the measured and fitted phase 
deltaPhase = (180/pi)*(phase - fittedPhase);
rmsPhaseError = sqrt(sum(deltaPhase.*deltaPhase)/length(phase));


kHzFreq=0.001*freq;
plot(kHzFreq,phase*180/pi,'k',kHzFreq,fittedPhase*180/pi,'b--',kHzFreq,cfitph*180/pi,'r*');
xlabel('Frequency (kHz)');
ylabel('Phase (degrees)');
legend('Measured phase','MATLAB fit','C++ fit')
title(sprintf('RMS phase error = %f',rmsPhaseError));

%group travel time = -dphi/dw
t0=-pa(1) + tOffset;
tg= t0 + pa(3)./(w.*w);
subplot(2,2,2)

plot([t1 t1],[kHzFreq(1) kHzFreq(end)],'b',dtoga*ones(size(kHzFreq(1:3:end))),kHzFreq(1:3:end),'r*', tg,kHzFreq,'k',[t0 t0],[kHzFreq(1) kHzFreq(end)],'k--');
xlabel('Time (s)');
ylabel('Frequency (kHz)');

legend('MATLAB TOGA','C++ TOGA')
title('Dispersion & TOGA (linear fit)');
v=axis;
v(1)=0e-3;
v(2)=1.2e-3;
axis(v);

subplot(2,2,4)

%compute RMS amp
mRMSAmp = sqrt(mean(s(N/4:end).^2))*32768;
timeBase = (1:length(s))/Fs;

%,[min(timeBase) max(timeBase)],[mRMSAmp mRMSAmp],'g--',[min(timeBase) max(timeBase)],[rmsAmp rmsAmp]/32768,'g*'
plot([t1 t1],[-1 1],'b',[dtoga dtoga dtoga dtoga dtoga dtoga],[-0.5 -0.3 -0.1 0.1 0.3 0.5 ],'r*',timeBase,s,'k',[-c1+0.25*N/Fs -c1+0.25*N/Fs],[-1 1],'k--');%,[t0 t0],[min(s) max(s)],'r--');
xlabel('Time (s)')
ylabel('Amplitude');
legend('MATLAB TOGA','C++ TOGA')
title(sprintf('Sferic waveform & TOGA. RMS Amp = %f, %d',mRMSAmp,rmsAmp));
v=axis;
v(1)=0e-3;
v(2)=1.2e-3;
v(3)=-0.8;
v(4)=0.8;
axis(v);

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
%     j=j+1;
% end

fclose(fid);
