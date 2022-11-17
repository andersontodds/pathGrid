% SfilePlot.m
% Copied to pathGrid November 1 2022, original author unknown.  Most likely
% James Brundell, Bob Holzworth or Carl Cristofferson.
%Oct 2012. 
%matlab plotter for latest S-file format

%format is ASCII encoded lines with the following comma separated data
% Magic header: "W210"
% wwlln site id
% UTC time YYYY-MM-DDThh:mm:ss
% UTC toga offset in microseconds
% RMS amplitude of waveform
% TOGA offset in seconds from start of waveform
% The three dispersion fit parameters fit0 , fit1 , << fit2;
% a dispersion fit ok flag (0 or 1)
% sampling frequency
% number of waveforms samples
% the waveform samples.

%examples:
%W210,42,2012-10-28T23:46:00,64171,482,0.000423515,0.000122209,-22.342,995620,1,47999.46798,64,-0.00014624,0.000582488,-0.000494393,0.00140434,-0.00163871,-0.00123657,0.000718572,0.000621287,-0.0001625
%74,-0.00116322,0.00388718,-0.00666286,0.00216732,0.01378,-0.026122,0.000209468,0.0442478,-0.02622,-0.0446904,0.0351573,0.0394996,-0.0211124,-0.0351118,-0.00535202,0.0274045,0.0265337,-0.0149415,-0.029
%9324,-0.00224716,0.0185099,0.0126136,-0.00335984,-0.0101292,-0.00462183,0.0026746,-0.000943734,0.0031667,0.00555653,-0.00410046,0.00204483,2.68955e-05,-0.00972615,0.000853926,0.0104586,0.00383928,-0.0
%0881304,-0.00597818,0.00393418,0.00530903,0.00264597,-0.0041357,-0.00457889,-0.000137381,0.00449631,0.00456637,-0.00231624,-0.00294187,-0.00213906,0.000441485,0.00269525,0.000698999,0.00123525,-0.0014
%8989,-0.001246
%W210,42,2012-10-28T23:46:00,123917,332,0.000398143,0.00014805,-21.6917,979791,1,47999.46798,64,-0.000130322,-0.000310242,-0.00231567,0.000930541,-8.66156e-05,0.000615641,0.000720385,-0.00359491,0.0027
%8483,0.000539874,-0.0040015,0.00704413,-0.00451845,-0.0125554,0.0203505,0.0101424,-0.035849,-0.00413924,0.0397386,0.00396383,-0.0300246,-0.0123813,0.0129059,0.0182671,0.00502621,-0.0149814,-0.0179782,
%0.00368812,0.0163254,0.00944645,-0.00449458,-0.0140641,-0.00577213,0.00481855,0.00785777,0.00357204,-0.00263434,-0.00297747,-0.00291283,6.26107e-05,0.000662741,0.00127326,0.00258255,-0.00131182,-0.000
%751091,-0.00134917,-0.000896377,0.00170703,0.000251747,0.00042879,-0.000673938,0.000525141,0.000723948,-0.000571585,-0.00014077,-0.00212627,0.000942156,0.00148114,6.18015e-05,0.000990541,-0.000912377,
%-0.000321788,-0.000810857,0.000367789


fclose('all');
clear;
j=1;
mskPipe = fopen('data/S-files/2021/S202107080401','r');

while 1==1,

    tLine = fgets(mskPipe) % each successive call gets next line in file mskPipe
    %W210,42,2012-10-28T23:46:00,123917,332,0.000398143,0.00014805,-21.6917,979791,1,47999.46798,64
    
    [A,count, errmsg, nextindex]=sscanf(tLine(6:end),'%d,%4d-%2d-%dT%2d:%2d:%2d,%d,%d,%f,%f,%f,%f,%d,%f,%d',16)
    %[A,count, errmsg, nextindex]=sscanf(tLine(6:end),'%d %4d %2d %d %2d %2d %2d %d %d %f %f %f %f %d %f %d')
    [y,count]=sscanf(tLine(nextindex+6:end),'%f,',inf);
    
    rmsAmp = A(9)
    dtoga = A(10);
    c1=A(11);
    c2=A(12);
    c3=A(13);
    Fs=A(15);
    N=A(16);
    
 %   break
    
%     if strncmp(tLine,'SFERIX',5),
%         tLine = fgets(mskPipe, 256);
%         [dtoga,count] = sscanf(tLine, '%f');
%         
%         tLine = fgets(mskPipe, 256);
%         [c1,count] = sscanf(tLine, '%f');
%         tLine = fgets(mskPipe, 256);
%         [c2,count] = sscanf(tLine, '%f');
%         tLine = fgets(mskPipe, 256);
%         [c3,count] = sscanf(tLine, '%f');
%         tLine = fgets(mskPipe, 256);
%         [N,count] = sscanf(tLine, '%d');
%         tLine = fgets(mskPipe, 256);
%         [Fs,count] = sscanf(tLine, '%f');
%         tLine = fgets(mskPipe, 256);
%         [rmsAmp,count] = sscanf(tLine, '%d');
%         for idx=1:N,
%             tLine = fgets(mskPipe, 256);
%             [a,count] = sscanf(tLine, '%f');
%     
%             if count == 1,
%                 y(idx) = a;
%             end
%             
%         end
%         
%         tLine = fgets(mskPipe, 256);
%         [okSferic,count] = sscanf(tLine, '%d')
	N
	Fs
    f1=6000;
    f4=18000;
    f1Idx = floor(f1*N/Fs+0.5)+1;
    f4Idx = floor(f4*N/Fs+0.5)+1;
    f=(0:N/2-1)*Fs/N;

    s=y';
    S=fft(s);
    
    %Option to measure phase relative to first sample
    tOffset = 0;
    
    %or measure phase relative to trigger point
    %i.e. delayed by N/4 samples
    wtN4=i*2*pi*0.25*(0:N/2-1);
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
       pause
   % else
   %     pause(0.1)
   % end
    rms(j,:)=[mRMSAmp, rmsAmp];
    j=j+1;
end
