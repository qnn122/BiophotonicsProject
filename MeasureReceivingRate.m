% scipt file: MeasureReceivingRate.m
% Purpose:
%   Mearsure how many data points is imported in a unit of time
%

% Initializing
close all
clear all

%% Create input dialog, enter port name and sampling frequency
% Open port
 s= serial('COM7', 'BaudRate', 9600);
 fopen(s);

% Initialize ouput
numpoints = 3000;
rate = zeros(1, numpoints);
timevec = zeros(1, numpoints);
time = 10;
ind = 1;
indTime = 1;
indWeird = 0;

% Start recording
tStart = tic;
while toc(tStart) < 20
    a = fscanf(s, '%s');
    % Check weird data string and skip when necessary
    if isempty(str2num(a))
        disp(['Weird point at ' num2str(ind) ': ' a]);
        indWeird = indWeird + 1;
        continue;
    end
   
    timevec(ind) = toc(tStart);
    rate(ind) = ind/timevec(ind);
    ind = ind + 1;
end

%% Plot result
% plot(1:(ind-indWeird), data(1:(ind-indWeird)))
plot(timevec(1:(ind-indWeird)), rate(1:(ind-indWeird)))
xlabel('Time (msec)');
ylabel('Rate (samples/sec)');

%% When done, close and delete serial port
fclose(s)
delete(s)