function varargout = DATA_ACQUISITION_V1_0(varargin)
% DATA_ACQUISITION_V1_0 M-file for DATA_ACQUISITION_V1_0.fig
%      DATA_ACQUISITION_V1_0, by itself, creates a new DATA_ACQUISITION_V1_0 or raises the existing
%      singleton*.
%
%      H = DATA_ACQUISITION_V1_0 returns the handle to a new DATA_ACQUISITION_V1_0 or the handle to
%      the existing singleton*.
%
%      DATA_ACQUISITION_V1_0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_ACQUISITION_V1_0.M with the given input arguments.
%
%      DATA_ACQUISITION_V1_0('Property','Value',...) creates a new DATA_ACQUISITION_V1_0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DATA_ACQUISITION_V1_0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DATA_ACQUISITION_V1_0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DATA_ACQUISITION_V1_0

% Last Modified by GUIDE v2.5 17-Apr-2014 15:43:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DATA_ACQUISITION_V1_0_OpeningFcn, ...
                   'gui_OutputFcn',  @DATA_ACQUISITION_V1_0_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DATA_ACQUISITION_V1_0 is made visible.
function DATA_ACQUISITION_V1_0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DATA_ACQUISITION_V1_0 (see VARARGIN)

% Choose default command line output for DATA_ACQUISITION_V1_0
handles.output = hObject;

%-----------bien toan cuc
delete(instrfindall);   % Reset Com Port 

% Update handles structure
guidata(hObject, handles);

% save all data, a way which replace to global variable
save('handles.mat', 'handles');

% UIWAIT makes DATA_ACQUISITION_V1_0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DATA_ACQUISITION_V1_0_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PB_Connect.
function PB_Connect_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t;
global BT; 

BT = 0; % Initially, Bluetooth is OFF

if strcmp(get(hObject,'String'),'Connect') % currently disconnected
    
    % create t0 for begining
    assignin('base', 't0', 0); % tao trong workspace bien t0=0 de chuan bi lam 1 data moi
    
    chosenPort = get_stringPopup(handles.PU_ComPort);
    if strcmp(chosenPort, 'Chau_HC-05');
        BT = 1; % turn ON Bluetooth
    end
    
    if BT 
        s = Bluetooth(chosenPort, 1);
    else % if the object is serial
        s = serial(get_stringPopup(handles.PU_ComPort)); % Lay chuoi cong com
        s.BaudRate = 9600;      % Bluetooth unable
        s.DataBits = 8;
        s.Parity   = 'none';
        s.StopBit  = 1;
    end
    
    s.InputBufferSize=20000;
    s.BytesAvailableFcnCount = 1000;
    s.BytesAvailableFcnMode = 'terminator';
    %s.BytesAvailableFcnMode = 'byte'; %luc nay se don theo byte nhan duoc ma ngat
    
    %s.BytesAvailableFcn = @BytesAvailable_Callback; % khong can
    %======================================================================
    try
       handles.s = s; % s chinh la handles.s 
       fopen(handles.s);
       pause(0.2);
       %===================================================================
       delete(timerfindall);   % Delete Timers
       TMR_PERIOD = 0.5; % 1
       %==========================================================================
       t = timer('TimerFcn', @(x,y)getDataUART(s), 'Period', TMR_PERIOD);
       set(t,'ExecutionMode','fixedRate');
       start(t);
       % hien thi Disconnect
       set(hObject, 'String','Disconnect')
    catch e
       if(strcmp(s.Status,'open')) %handles.s.status == 'open'
           fclose(handles.s);
       end
       errordlg(e.message); % xu ly loi ngoai le, neu khong co ngoai le xay ra thi se thuc hien catch
    end
    
else
       
    set(hObject, 'String','Connect')
    fclose(handles.s);
    stop(t);
end

% Update handles structure
guidata(hObject, handles); % hObject la cai hien tai

% get Data
function getDataUART(s)

 load handles
 
 % global variables in that persistent variables are known only to the
 % function in which they are declared.
 persistent  nPts;
 persistent  xTime;
 persistent  yDataCH1;
 persistent  nDataCH1Save;
 
 
 
 if (s.BytesAvailable>100)
     
 data = fread(s,s.BytesAvailable);
 %===============================================
 
 % Data
 fNaN=find(isnan(data)==1); % mang chua vi tri phan tu NaN
 if (~isempty(fNaN))
    for i=1:length(fNaN)%lenLaser %length(fNaN)
        data(fNaN(i))=0;
    end
 end 
 
 %------------------------------------------------------------------
 % lay t0 de ve va lam dieu kien reset
 t0 = evalin('base', 't0'); % doc bien tu workspace
 
 % Initial variable
 if  (t0==0) 
    
    nPts = 5000;       % number of points to display on stripchart
    xTime = ones(1,nPts)*NaN;
    yDataCH1 = ones(1,nPts)*NaN;
    
    nDataCH1Save=[];    
 end
 
 % length
 lenFrameData=length(data);
 
 %-------------------------------------------------------------------------
 % khoi tao data
 nDataCH1 = [];
 
 synIndex = 1; % contro data
  
 % uint8_t UART_Header[5] = {0xFF,0x00}; // ky tu dac biet
 while (synIndex < (lenFrameData - 3))
     if ((data(synIndex)==255)&&(data(synIndex+1)==0))
         
        nDataCH1 = [nDataCH1 (data(synIndex+3)*256+data(synIndex+2))]; % IR truoc
         
        synIndex = synIndex + 4;   % bo qua khung vua roi
     else
         synIndex = synIndex + 1;  % do dong bo
     end
     
 end
 %-------------------------------------------------------------------------
 
 % save Data
 nDataCH1Save=[nDataCH1Save nDataCH1];
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
 set(handles.axes1,'NextPlot','add'); % lenh hold on trong GUI
 grid(handles.axes1, 'on');
 %set(handles.axes1,'NextPlot','new'); % lenh new
 
 plot(handles.axes1,xTime,yDataCH1,'r-','LineWidth',2) ;
 
 
 axis(handles.axes1,[xmax-200 xmax 3 6]);
   
 save('handles.mat', 'handles');
  %===============================================
 end

 
% Function to 
function doublePopup = get_doublePopup(hObject,handles)
    val = get(hObject,'Value');
    string_list = get(hObject,'String');
    selected_string = string_list{val}; % convert from cell array
                                        % to string
    doublePopup = str2double(selected_string);
% --- Executes on button press in button_ClearTX.


% Function to 
function stringPopup = get_stringPopup(hObject,handles)
    val = get(hObject,'Value');
    string_list = get(hObject,'String');
    stringPopup = string_list{val}; % convert from cell array
    

% --- Executes on selection change in PU_ComPort.
function PU_ComPort_Callback(hObject, eventdata, handles)
% hObject    handle to PU_ComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PU_ComPort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PU_ComPort


% --- Executes during object creation, after setting all properties.
function PU_ComPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PU_ComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on PB_Connect and none of its controls.
function PB_Connect_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to PB_Connect (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

       


% --- Executes on button press in PB_Exit.
function PB_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fclose(handles.s);

close(DATA_ACQUISITION_V1_0); % thoat

% --- Executes on key press with focus on PB_Exit and none of its controls.
function PB_Exit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to PB_Exit (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2
