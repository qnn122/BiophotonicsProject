function test_Bluetooth()
% Purpose:
%   Test value received from bluetooth (which delivered by Arduino)

%% Create input dialog, enter port name and sampling frequency
disp('Connecting ...')
b = Bluetooth('Chau_HC-05',1);
set(b, 'Timeout', 2);
disp('Done.')
if isempty(b)
    disp('Cannot find the bluetooth module. The program terminated!')
    return;
else
    disp('Found the desired bluetooth module')
end


% Open port
disp('Opening the port. Please wait ....');
try
    fopen(b);
    disp('Port is opened');
catch
    disp('Something wrong. Can''t open the bluetooth serial port')
end



% Figure
h_fig = figure('name', 'SimpleGui', ....
    'Units', 'normalized', ...
    'Position', [0.3 0.3 0.3 0.3]);
    

% Read data from serial port, one value at a time
readButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.1 .4 .8 .5],...
            'Style', 'pushbutton',...
            'String', 'READ',...
            'FontSize', 18);
        
commandEdit = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.1 .1 .6 .2],...
            'Style', 'edit', ...
            'BackgroundColor', [1 1 1]);

sendButton = uicontrol('Parent', h_fig,...
            'Units', 'normalized',...
            'Position', [.75 .1 .15 .2],...
            'Style', 'pushbutton',...
            'String', 'Send');

 
% Create handles
handles.serialPort = b;
handles.readButton = readButton;
handles.commandEdit = commandEdit;
handles.sendButton = sendButton;

% Set callback functions
set(h_fig, 'DeleteFcn', {@deleteFigure_Callback, handles});
set(readButton, 'Callback', {@readButton_Callback, handles});
set(sendButton, 'Callback', {@sendButton_Callback, handles});

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
    lastwarn('');
    
    try     % Timeout handling
        a = fgets(b);
        if(~isempty(lastwarn))
        error(lastwarn)
        end
    catch err
        err
    end
    
    disp(a);
    assignin('base', 'mya', a);
end

function sendButton_Callback(hObj, event, handles)
    commandEdit = handles.commandEdit;
    b = handles.serialPort;
    
    val = get(commandEdit, 'String'); % return char value
    disp([val ' command has been sent']);
    try
        fwrite(b, val);
    catch err
        err
    end
    
end

function deleteFigure_Callback(hObj, event, handles)
    b = handles.serialPort;
    if strcmp(get(b, 'Status'), 'open')
        disp('Port is still open. Now closing the port');
        fclose(b);
    end
    delete(b)
end
