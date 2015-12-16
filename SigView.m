function SigView()
%% SIGVIEW() display signal other devices given port name and sampling
% frequency. Heart rate calculating and data writing included.
%
% Date of revision
%   Date        Author          Record
%  14/10/15     QuangNguyen     Initial Code: open and close port, single point exported
%  21/10/15     //              Add signal plot, resolve real-time problem, lagging remains
%  27/10/15     //              Add power spectrum plot and heart rate display

clear all
close all

%% Create input dialog, enter port name and sampling frequency
prompt = {'Enter port name: ', 'Enter sampling frequency: ', 'Communication type (Serial or Bluetooth): '};
def = {'Chau_HC-05', '100', 'Bluetooth'};
answer = inputdlg(prompt, 'Input', 1, def);

if isempty(answer)
    disp('No Port selected. Program terminated!');
    return;
end

%% Create Serial Port
PortName = answer{1};
if strcmp(answer{3}, 'Serial')
    disp('Connecting to serial port...');
    s = serial(PortName);
    disp('Done.')
elseif  strcmp(answer{3}, 'Bluetooth')
    disp('Connecting to Bluetooth port...');
    s = Bluetooth(PortName, 1);
    disp('Done.')
else
    disp('No appropriate communicate type is selected');
end
% set(s,'DataBits', 8);
% set(s,'StopBits', 1);
% s.ReadAsyncMode = 'continuous';

set(s, 'Timeout', 2);
    
handles.serialPort = s;

%%  --------  Create simple GUI ------------
% Figure
h_fig = figure('name', 'SimpleGui', ....
    'Units', 'normalized', ...
    'Position', [0.2 0.2 0.6 0.6], ...
    'DeleteFcn', {@deleteFigure_Callback, handles});

%% Axes to plot time series
h_axes1 = axes('Parent', h_fig, ...
            'Position', [0.1, 0.57, 0.6, 0.35], ...
            'YGrid', 'on', ...
            'XGrid', 'on');

Fs = str2double(answer{2});
sec = 3;           % time limit
timepoints = sec*Fs;

% re-scale x axes
set(h_axes1, 'xtick', [0:Fs:timepoints], 'xticklabel', [0:sec]);

% Initial plot
hold on;
h_plot1 = plot(1:timepoints, zeros(1,timepoints));
h_line = line([0 0], [0 6], 'Color', [1 0.5 0.5], 'LineWidth', 2);


% Vertical limit
ylim(h_axes1, [0 6]);

% Create xlabel
xlabel('Time','FontWeight','bold','FontSize',14);

% Create ylabel
ylabel('Voltage in V','FontWeight','bold','FontSize',14);

% Create title
title('Real Time Data','FontSize',15);


%% Axes to plot spectrum
h_axes2 = axes('Parent', h_fig, ...
            'Position', [0.1, 0.1, 0.6, 0.32], ...
            'YGrid', 'on', ...
            'XGrid', 'on');
        
% Intial plot
freqLim = 100;
hold on;
h_plot2 = plot(1:floor(freqLim/2-1), zeros(1, floor(freqLim/2-1)));

% Vertical lim
ylim(h_axes1, [0 7]);

% Create xlabel
xlabel('Frequency','FontWeight','bold','FontSize',14);

% Create ylabel
ylabel('Amplitude','FontWeight','bold','FontSize',14);

% Create title
title('Power Spectrum','FontSize',15);


%% Start button
startButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.75 .3 .15 .15],...
            'Style', 'pushbutton',...
            'String', 'START',...
            'FontSize', 18);
        
%% Stop button
stopButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.75 .5 .15 .15],...
            'Style', 'pushbutton',...
            'String', 'STOP',...
            'FontSize', 18);
        
%% Hear reate panel
h_text = uicontrol('Parent', h_fig, ...
            'Units', 'normalized',...
            'Position', [.75 .7 .15 .13],...
            'Style', 'text',...
            'String', '0',...
            'FontSize', 30, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [1 1 1]);
        
h_text2 = uicontrol('Parent', h_fig, ...
            'Units', 'normalized',...
            'Position', [.75 .85 .15 .05],...
            'Style', 'text',...
            'String', 'HEART RATE',...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [1 1 1]);   
        
h_text3 = uicontrol('Parent', h_fig, ...
            'Units', 'normalized',...
            'Position', [.75 .1 .15 .1],...
            'Style', 'text',...
            'String', 'Initializing... Please wait.',...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [1 1 1]);            
        
%% Update handles
handles.h_axes.axes1 = h_axes1;
handles.h_axes.axes2 = h_axes2;

handles.h_plots.plot1 = h_plot1;
handles.h_plots.plot2 = h_plot2;
handles.h_plots.line = h_line;

handles.h_text = h_text;
handles.h_text3 = h_text3;
handles.h_plots.sec = sec;          % for axes1 (time)
handles.h_plots.freqLim = freqLim;  % for axes2 (frequency)

handles.Fs = Fs;
handles.Comm = answer{3};           % Communication type

set(startButton, 'Callback', {@startButton_Callback, handles});
set(stopButton, 'Callback', {@stopButton_Callback, handles});
    
%% Creat timer   
%  t = timer('TimerFcn', {@timer_Callback, serialPort}, ...
%     'ExecutionMode', 'fixedRate',...
%     'Period', 0.5);

end

function startButton_Callback(hObj, event, handles)
    persistent count time volt lastvolt     % Count is used for automatically adjust horizontall axes
    persistent timeShift
    
    % For storing data
    persistent buffer  buffsize     % Buffer to store incoming data
    persistent point        % Index of buffer, update new data to buffer
    persistent firstTime    % Flag that labels whether the first round of buffer has been filled or not
    persistent wind         % window to calculate power spectrum
    persistent indx         % Index of power spectrum calculation

    persistent sp f t       % for power spectrum calculation
    persistent tStart tElapsed      % For timing
    
    % Initializing variables
    if isempty(lastvolt), lastvolt = nan; end  
    if isempty(point), point = 1; end 
    if isempty(indx), indx = 2; end
    if isempty(firstTime), firstTime = 0; end   % 0 means the first time has not been reached, no calculation takes place
    
    %
    s = handles.serialPort;
    name = get(s, 'Name');
    disp(['Port name ' name]);
    
    % return handles
    h_axes1 = handles.h_axes.axes1;
    h_plot1 = handles.h_plots.plot1;
    h_plot2 = handles.h_plots.plot2;
    h_line = handles.h_plots.line;
    h_text = handles.h_text;
    h_text3 = handles.h_text3;
    
    sec = handles.h_plots.sec;
    freqLim = handles.h_plots.freqLim;
    Fs = handles.Fs;
    
    %  **** Changable variable
    timeCalcSpec = 1; % time duration after which the power spectrum takes place (second)
    pointCalcSpec = ceil(timeCalcSpec*Fs); % number of points after which the ps is calculated
    %  ****
    
    % Buffer window
    buffsize = 5*Fs;    % a*Fs, a is the number of seconds
    if isempty(buffer), buffer = zeros(1, buffsize); end
    if isempty(wind), wind = zeros(1, buffsize); end    % buffer and wind has same size but
                                                        % different
                                                        % functions

    % 
    if isempty(timeShift)
        timeShift = 0;
    end
    
    %
    count = 2;
    time = get(h_plot1, 'XData');
    volt = get(h_plot1, 'YData');
    
    % Open port
    if strcmp(get(s, 'Status'), 'open')
        disp('Port is already opened');
    else
        fopen(s);
        disp('Port is opened. Importing data');
        handles.stop = 0;
        
        while 1
            tStart = tic;
            % ---------- Automatically adjust horizontal axes -----
            if count == sec*Fs
                count = 1;
                timeShift = timeShift+ sec;
                set(h_axes1, 'xtick', [0:Fs:sec*Fs], 'xticklabel', [timeShift:(timeShift+sec)]);
            end
            
            % --------------- Import data -----------------------    
            try
                switch handles.Comm
                    case 'Serial'
                        a = fscanf(s,'%s');     % read from Arduino
                    case 'Bluetooth'
                        a = fgets(s);
                        if size(a, 2) < 6
                            continue;       % very crude, need improving
                        end
                end
                assignin('base', 'mya', a);  
            catch
                break;
            end
            
            % Detect weird string stored in a, ignore such value
%             if isempty(str2num(a))
%                     continue;
%             end
            
            try
%                 voltage = str2double(a(1:4))/1023*5;    % need improvement too
                voltage = str2double(a(1:4));
                buffer(point) = voltage;
                
                %  -------- Calculate power spectrum -----------------
                if (rem(abs(point-indx),pointCalcSpec)==0)&&(firstTime == 1)    % calculation is only performed when the time comes
                    wind = [buffer(indx:end) buffer(1:(indx-1))];
                    assignin('base', 'mywind', wind);
                    wind = wind - sign(mean(wind))*abs(mean(wind));             % Remove DC component
%                     assignin('base', mywind, wind);
                    [sp, f] = PowerSpect(wind, Fs);                             % Calc power spectrum   
                    
%                     assignin('base', 'mysp', sp);
                    set(h_plot2, 'XData',  f(1:floor(freqLim/2-1)), 'YData', sp(1:floor(freqLim/2-1)));
                    indx = point;   % Update index
                    
                    % --------- Calculate and display Heart Rate ---------------
                    heartRate = 60*f(find(sp == max(sp)));
                    set(h_text, 'String', num2str(heartRate), ...
                        'FontSize', 30, ...
                        'FontWeight', 'bold')                    
                end

                % Reset point pointer every time it finishes filling the buffer
                if (point ~= buffsize) 
                    point = point + 1;
                else    % point reaches buffsize
                    % SWITCH flag when the first round of buffer is filled
                    if (firstTime ~= 1)
                        set(h_text3, 'String', 'OK, importing data');
                        firstTime = 1;
                    end
                point = 1; % reset
                end
                
            catch e
                warning('warning: something is not working probably');
                pause(1.5);
                continue;
            end
               
            
            % --------------- Update plot -----------------------
            % First approach
            time(count) = count;
            volt(count) = voltage(1);
            set(h_plot1, 'XData', time, 'YData', volt);
            set(h_line, 'XData', [count, count]);
            
            % Update Y axes
            if count > 50
                window = volt(count-50:count);
                set(h_axes1, 'Ylim', [(min(window)-0.5) (max(window)+0.5)]);
            end
            
            
            % --------- Write data to file -----------------
            count = count + 1;
            
%             tElapsed = toc(tStart)*1000
%             disp(['Bytes Available: ' num2str(s.BytesAvailable)]);
%             disp(['Bytes To Output: ' num2str(s.BytesToOutput)]);
%             assignin('base', 'BytesToOutput', s.BytesToOutput);
            
                
            drawnow;    % update events (stop button)
        end   % while       
    end % if
end % stopButton function

function stopButton_Callback(hObj, event, handles)
     s = handles.serialPort;
    
    % Close port
    if strcmp(get(s, 'Status'), 'closed')
        disp('Port is already closed. Please open the port first');
    else
        fclose(s);
        disp('Port is closed');
    end
    
end

function deleteFigure_Callback(hObj, event, handles)
    s = handles.serialPort;
    
    if strcmp(get(s, 'Status'), 'open')
        disp('Port is still open. Now closing the port');
        fclose(s);
    end
    delete(s)
end


