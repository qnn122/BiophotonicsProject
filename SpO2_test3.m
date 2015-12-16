function [RR2]=SPO2_test(x)
%close all,clear all,clc
%load('D:\2015-2016\Semester I\BME Capstone Design Course\LAB\PROJECT\DATA\Subject3\x1')
data=x;
L=length(data); 
fs=L/50;
n=L;x=x-mean(x);

%% Pre-processing
fNorm = [1 40] / (fs/2);         %normalized cutoff frequency
type='bandpass';N=2;
[b,a] = butter(N, fNorm, type);  % 10th order filter
y = filtfilt(b, a, x);Y=y;
y=y';
y=y/max(y);


%% R peaks enhancing
% y_slope1=diff(x);y_slope1=[0,y_slope1.^2]';

h_d = [-1 -2 0 2 1]*(1/8); %1/8*fs
y_slope2 = conv (y ,h_d);
y_slope2= y_slope2/max(y_slope2);y_slope2=y_slope2.^2;

% y_savitzky = sgolayfilt(y,0,41);
% y_slope3=y-y_savitzky; y_slope3=y_slope3.^2;

y_slope=y_slope2; % choose slope2


%%  Find peaks
[pks,locs] = findpeaks(y_slope,'MINPEAKDISTANCE',round(0.2*fs));
Thres1_R=mean(pks);
R1=find(pks>=Thres1_R);
R2=locs(R1(:));

%%%heartbeat Threshold
RR=diff(R2);
RRavg=mean(RR)
RRmin=round(0.92*RRavg);RRmax=round(1.16*RRavg);RRmissed=round(1.66*RRavg);

range=[RRmin RRmax];

Rmissed=find(RR>=RRmissed); 
if size(Rmissed,1)~=0
    for i=1:length(Rmissed)
        SearchBack=y_slope(R2(Rmissed(i))+round(0.200*fs):R2(Rmissed(i)+1)-round(0.200*fs));
        [pks2,locs2] = findpeaks(SearchBack,'MINPEAKDISTANCE',round(0.2*fs));
        xR1back=find(pks2>=mean(pks2));
        xRback=R2(Rmissed(i))+round(0.200*fs)+locs2(xR1back(:));
        xRadd=find(xRback<R2);
        R_search=[R2(1:xRadd(1)-1);xRback;R2(xRadd(1):end)];
    end
else
    R_search=R2;
end

%%%%R peak correction
[yMax,LocMax] = findpeaks(y); %find max
A=find(yMax>mean(y));
LocMax=LocMax(A(:));
k=1;R=[];
for i=1:size(R_search,1)
    
    for j=1:length(LocMax)
        if LocMax(j)>=R_search(i,1)
           
            if LocMax(j)==R_search(i,1)
                R=[R LocMax(j)];
            else  
                %%%%%%%%%%%%%%%%%%%%%%%
                if y(LocMax(j-1))>=y(LocMax(j));
                    R=[R LocMax(j-1)];
                else
                    R=[R LocMax(j)];
                end
                %%%%%%%%%%%%%%%%%%%%%%%
            end
            
            break
        end
    end
    
    
end

RR2=diff(R);RRavg2=mean(RR2);
RRmin2=round(0.92*RRavg2);RRmax2=round(1.16*RRavg2);
range2=[RRmin2 RRmax2];
RR2


R=[R' y(R(:))];

% figure
% plot(y_slope,'k');hold all; plot([0 length(y)],[Thres1_R Thres1_R],'r')
% plot(locs,pks,'ro');
% figure

%y=smooth(y,5);
 A=[];
for i=length(y):-1:1
    A=[A,y(i)];
end
y=A;%x=A1*-1;
y=smooth(y);
plot(y,'k');hold all,% plot(locs(yR1(:)),y(locs(yR1(:))),'ro')
%h=plot(R(:,1),R(:,2),'rx');set(h,'LineWidth',2); %plot([0 length(y)],[mean(yMax) mean(yMax)])
%% Power Spectrum
[PS,f] = pwelch(data, triang(64),[ ],64,100);
figure(2)
plot(f,PS,'k');
title('Power Spectrum (Welch Method)');
xlabel('Frequency (Hz)');
ylabel('Power Spectrum');
% Calculate BPM
duration_in_seconds=L/fs;
time=mean(RR2)*duration_in_seconds/L;
freq=1/time;
BPM=freq*60;
%% Display result
sprintf('Heart Rate is %.2f BPM',  BPM)
end
