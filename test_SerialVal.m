function test_SerialVal()
% Purpose:
%   Test value received from serial port (which delivered by Arduino)

%% Create input dialog, enter port name and sampling frequency
prompt = {'Enter port name: '};
def = {'COM9'};
answer = inputdlg(prompt, 'Input', 1, def);

% Open port
s = serial(answer{1}, 'Baudrate', 9600);
set(s, 'Timeout', 2);
fopen(s);

% Create handles
handles.serialPort = s;

% Figure
h_fig = figure('name', 'SimpleGui', ....
    'Units', 'normalized', ...
    'Position', [0.4 0.4 0.15 0.15], ...
    'DeleteFcn', {@deleteFigure_Callback, handles});

% Read data from serial port, one value at a time
readButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.1 .1 .8 .8],...
            'Style', 'pushbutton',...
            'String', 'READ',...
            'FontSize', 18);
        
set(readButton, 'Callback', {@readButton_Callback, handles});

end

function readButton_Callback(hObj, event, handles)
    s = handles.serialPort;
%     a = fscanf(s, '%s')
    fwrite(s, 'E');
    pause(1);
    s.BytesAvailable
    a = fread(s, s.BytesAvailable);
    assignin('base', 'mya', a);
    
end

function deleteFigure_Callback(hObj, event, handles)
    s = handles.serialPort;
    
    if strcmp(get(s, 'Status'), 'open')
        disp('Port is still open. Now closing the port');
        fclose(s);
    end
    delete(s)
end
