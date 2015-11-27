function test_Bluetooth()
% Purpose:
%   Test value received from bluetooth (which delivered by Arduino)

%% Create input dialog, enter port name and sampling frequency
disp('Connecting ...')
b = Bluetooth('Chau_HC-05',1);
disp('Done.')
if isempty(b)
    disp('Cannot find the bluetooth module. The program terminated!')
    return;
else
    disp('Found the desired bluetooth module')
end


% Open port
try
    fopen(b);
    disp('Port is opened');
catch
    disp('Something wrong. Can''t open the bluetooth serial port')
end

% Create handles
handles.serialPort = b;

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
% for i=1:10
%     b = handles.serialPort;
%     a = fgets(b);
%     a = str2double(a(1:4));
%     disp(a);
%     assignin('base', 'mya', a);
% end
    b = handles.serialPort;
    a = fgets(b);
    disp(a);
    assignin('base', 'mya', a);
end

function deleteFigure_Callback(hObj, event, handles)
    b = handles.serialPort;
    if strcmp(get(b, 'Status'), 'open')
        disp('Port is still open. Now closing the port');
        fclose(b);
    end
    delete(b)
end
