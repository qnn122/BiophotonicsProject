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
%h_plot1 = plot(1:timepoints, zeros(1,timepoints));
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
xlabel('Time','FontWeight','bold','FontSize',14);

% Create ylabel
%ylabel('Voltage','FontWeight','bold','FontSize',14);

% Create title
title('Result','FontSize',15);


%% Start button
startButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.75 .52 .15 .12],...
            'Style', 'pushbutton',...
            'String', 'START',...
            'FontSize', 18);
        
%% Stop button
stopButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.75 .36 .15 .12],...
            'Style', 'pushbutton',...
            'String', 'STOP',...
            'FontSize', 18);
        
%% Analyzing button
analyzeButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.75 .2 .15 .12],...
            'Style', 'pushbutton',...
            'String', 'ANALYZE',...
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
            'Position', [.75 .05 .15 .08],...
            'Style', 'text',...
            'String', 'Ready',...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [1 1 1]);     
        
%
        
%% Update handles
handles.h_axes.axes1 = h_axes1;
handles.h_axes.axes2 = h_axes2;

%handles.h_plots.plot1 = h_plot1;
%handles.h_plots.plot2 = h_plot2;
% handles.h_plots.line = h_line;

handles.h_text = h_text;
handles.h_text3 = h_text3;
handles.h_plots.sec = sec;          % for axes1 (time)
handles.h_plots.freqLim = freqLim;  % for axes2 (frequency)

handles.Fs = Fs;
handles.Comm = answer{3};           % Communication type

set(startButton, 'Callback', {@startButton_Callback, handles});
set(stopButton, 'Callback', {@stopButton_Callback, handles});
set(analyzeButton, 'Callback', {@analyzeButton_Callback, handles});
    
%% Creat timer   
%  t = timer('TimerFcn', {@timer_Callback, serialPort}, ...
%     'ExecutionMode', 'fixedRate',...
%     'Period', 0.5);

end

function startButton_Callback(hObj, event, handles)
    global t;
    
    % clear all previous plot
    cla(handles.h_axes.axes1)
    
    % create t0 for begining
    assignin('base', 't0', 0); % t0 = 0 -> new data
    
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
  % global variables in that persistent variables are known only to the
 % function in which they are declared.
    persistent  nPts;
    persistent  xTime;
    persistent  yDataCH1;
    persistent  nDataCH1Save;
    
    % Handles
    h_axes1 = handles.h_axes.axes1;
    h_text3 = handles.h_text3;
    s = handles.serialPort;
    
    %disp(['Bytes Available: ' num2str(s.BytesAvailable)]);

    if (s.BytesAvailable>100)

    %fwrite(s, 'E');
    data = fread(s,s.BytesAvailable);
    %assignin('base', 'mydata', data);
    %===============================================

    % Detect NaN value
    fNaN=find(isnan(data)==1); 
    if (~isempty(fNaN))
        for i=1:length(fNaN)%lenLaser %length(fNaN)
            data(fNaN(i))=0;
        end
    end 

    %------------------------------------------------------------------
    % t0 for reset
    t0 = evalin('base', 't0'); % read from workspace
    
    
    % Initial variable
    if  (t0==0) 
        nPts = 1000;       % number of points to display on stripchart
        xTime = ones(1,nPts)*NaN;
        yDataCH1 = ones(1,nPts)*NaN;
        nDataCH1Save=[];    
    end

    lenFrameData=length(data);
    
    if (t0 < nPts)
        set(h_text3, 'String', 'Calibrating....');
    else
        set(h_text3, 'String', 'Ready for Analyzing');
    end

    %-------------------------------------------------------------------------
    % Initializing output data
    nDataCH1 = [];

    synIndex = 1; % data index

    %  uint8_t UART_Header[5] = {0xFF,0x00}; 
    while (synIndex < (lenFrameData - 3))
     if ((data(synIndex)==255)&&(data(synIndex+1)==0))  % Condition for detecting UART frame

        nDataCH1 = [nDataCH1 (data(synIndex+3)*256+data(synIndex+2))];

        synIndex = synIndex + 4;   % 
     else
         synIndex = synIndex + 1;  
     end

    end
    %-------------------------------------------------------------------------

    % save Data
    try
        nDataCH1Save=[nDataCH1Save nDataCH1];
    catch err
        err
    end
    %assignin('base', 'nDataCH1', nDataCH1); % tao trong workspace
    assignin('base', 'nDataCH1Save', nDataCH1Save); % tao trong workspace

    %-------------------------------------------------------------------------
    lenData = length(nDataCH1); % du lieu that data

    % Update the plot, initial t0=0 in workspace
    % t1=length(TimeSecond);
    time = t0:1:t0+lenData-1;
    t0 = t0+lenData; % update thoi diem luc sau
    assignin('base', 't0', t0); % tao trong workspace


    % fix up data to change plot
    xTime(1:end-lenData) = xTime(lenData+1:end);  % shift old data left
    xTime(end-lenData+1:end) = time;        % new data goes on right

    % channel 1
    yDataCH1(1:end-lenData) = yDataCH1(lenData+1:end);  % shift old data left
    yDataCH1(end-lenData+1:end) = 0 + 1*nDataCH1*5/1023;


    % theo doi trong matlab
    assignin('base', 'yDataCH1', yDataCH1); % tao trong workspace
    assignin('base', 'xTime', xTime); % tao trong workspace


    %-------------------------------------------------------------------------
    xmax=max(xTime);

    %-------------------------------------------------------------------------
    % plot in MATLAB
    set(h_axes1,'NextPlot','add'); % lenh hold on trong GUI
    grid(h_axes1, 'on');
    %set(handles.axes1,'NextPlot','new'); % lenh new

    plot(h_axes1,xTime,yDataCH1,'r-','LineWidth',2) ;

    
    % Update Y axes
    window = yDataCH1((end-500):end);
    set(h_axes1, 'Xlim', [xmax-1000 xmax], ...
                'Ylim', [(min(window)-0.5) (max(window)+0.5)]);
    
    %axis(h_axes1,[xmax-500 xmax 0 6]);

    save('handles.mat', 'handles');
    %===============================================
end % if BytesAvailable > 100

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

function analyzeButton_Callback(hObj, event, handles)
    %% Stop recording first
     s = handles.serialPort;
    
    % Close port
    if strcmp(get(s, 'Status'), 'closed')
        disp('Port is already closed. Please open the port first');
    else
        fclose(s);
        disp('Port is closed');
    end
    
    %% Then calculation
    % handles for output
    h_text = handles.h_text;    % heart rate
    h_axes2 = handles.h_axes.axes2;
    
    % Read data from workspace
    sig = evalin('base', 'yDataCH1');
    time = evalin('base', 'xTime');
    
    % Calc heart rate and perform other analyzing
    [y, HR] = calcHR(sig);
    
    % Display result
    cla(h_axes2)
    plot(h_axes2, time, y);
    axis tight
    set(h_text, 'String', num2str(HR));
    
end


function deleteFigure_Callback(hObj, event, handles)
    s = handles.serialPort;
    
    if strcmp(get(s, 'Status'), 'open')
        disp('Port is still open. Now closing the port');
        fclose(s);
    end
    delete(s)
end


