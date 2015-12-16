function SigView_timer()
%% SIGVIEW() display signal other devices given port name and sampling
% frequency. Heart rate calculating and data writing included.
% 
% Warning!, this version is for Bluetooth only
%

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
    s.InputBufferSize = 20000;
    s.BytesAvailableFcnCount = 1000;
    s.BytesAvailableFcnMode = 'terminator';
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
sec = 10;           % time range display
timepoints = sec*Fs;

% re-scale x axes
set(h_axes1, 'xtick', [0:Fs:timepoints], 'xticklabel', [0:sec]);

% Initial plot
hold on;
h_plot1 = plot(1:timepoints, zeros(1,timepoints));
% h_line = line([0 0], [0 6], 'Color', [1 0.5 0.5], 'LineWidth', 2);


% Vertical limit
ylim(h_axes1, [0 1]);

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
        
%
        
%% Update handles
handles.h_axes.axes1 = h_axes1;
handles.h_axes.axes2 = h_axes2;

handles.h_plots.plot1 = h_plot1;
handles.h_plots.plot2 = h_plot2;
% handles.h_plots.line = h_line;

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
    global t;
    
    s = handles.serialPort;
    
    % =========================================================
    try 
        disp('Opening port...');
        fopen(s);
        fwrite(s, 'E');
        disp('Done')
        pause(0.2);
        
        %
        delete(timerfindall);
        TMR_PERIOD  = 0.5;
        
        %
        t = timer('TimerFcn', {@timer_Callback, handles}, 'Period', TMR_PERIOD);
        set(t, 'ExecutionMode', 'fixedRate');
        start(t);
    catch e 
        if(strcmp(s.Status,'open')) %handles.s.status == 'open'
           fclose(handles.s);
       end
       errordlg(e.message); 
    end
            
    drawnow;       % flush event, used to stop program         
  
end % stopButton function

function timer_Callback(hObject, event, handles)
%     persistent count time volt lastvolt     % Count is used for automatically adjust horizontall axes
%     persistent timeShift
%     
%     % For storing data
    persistent buffer  buffsize     % Buffer to store incoming data
    persistent bufferInd  isBuffFull      % Index of buffer, update new data to buffer
%     persistent firstTime    % Flag that labels whether the first round of buffer has been filled or not
%     persistent wind         % window to calculate power spectrum
%     persistent indx         % Index of power spectrum calculation
% 
%     persistent sp f t       % for power spectrum calculation
%     persistent tStart tElapsed      % For timing
%     
%     % Initializing variables
%     if isempty(lastvolt), lastvolt = nan; end  
%     if isempty(point), point = 1; end 
%     if isempty(indx), indx = 2; end
%     if isempty(firstTime), firstTime = 0; end   % 0 means the first time has not been reached, no calculation takes place
%     
%     %
%     s = handles.serialPort;
%     name = get(s, 'Name');
%     disp(['Port name ' name]);
%     
%     % return handles
    h_axes1 = handles.h_axes.axes1;
    h_plot1 = handles.h_plots.plot1;
%     h_plot2 = handles.h_plots.plot2;
%     h_line = handles.h_plots.line;
%     h_text = handles.h_text;
%     h_text3 = handles.h_text3;
%     
%     sec = handles.h_plots.sec;
%     freqLim = handles.h_plots.freqLim;
%     Fs = handles.Fs
    disp('reach 1');
    persistent lenData
    persistent timepoints
    if isempty(timepoints)
        timepoints = length(get(h_plot1, 'XData'));
    end
    
    % Initialize buffer-related variables
    disp('reach 2');
    if isempty(buffer)|isempty(bufferInd)|isempty(isBuffFull);
        buffer = zeros(1,timepoints);
        bufferInd = 1;
        isBuffFull = 0;
    end

    % =============
    disp('reach 3');
    s = handles.serialPort;

    disp(['BytesAvailable: ' num2str(s.BytesAvailable)]);

    try
        data = fread(s,s.BytesAvailable);
    catch err
        disp('Program has stopped');
    end

    lenData = length(data);
    
    if lenData > timepoints
        return;
    end
    disp(['Number of values: ' num2str(lenData)]);
    disp('************');
    assignin('base', 'mydata', data);
    % =================
    
    
    %% Update buffer
    disp('reach 3');  
%     if isBuffFull   % only update tail part
%         buffer(1:(end-lenData)) = buffer((lenData + 1):end);
%         buffer((end - lenData + 1):end) = data*5/1023;
%     else            % update until it's full
%         disp('reach 3b');
%         buffer(bufferInd:lenData) = data;
%         bufferInd = bufferInd + lenData;
%         if bufferInd >= timepoints
%             isBuffFull = 1;
%         end
%     end
    buffer(1:(end-lenData)) = buffer((lenData + 1):end);
    buffer((end - lenData + 1):end) = data*5/1023;
    
    assignin('base', 'myBuffer', buffer);
    
    disp('reach 4');
    set(h_plot1, 'XData', [1:timepoints], 'YData', buffer);
        
end

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


