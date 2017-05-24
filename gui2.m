function varargout = gui2(varargin)
% GUI2 M-file for gui2.fig
%      GUI2, by itself, creates a new GUI2 or raises the existing
%      singleton*.
%
%      H = GUI2 returns the handle to a new GUI2 or the handle to
%      the existing singleton*.
%
%      GUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI2.M with the given input arguments.
%
%      GUI2('Property','Value',...) creates a new GUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui2

% Last Modified by GUIDE v2.5 14-May-2017 18:26:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui2_OpeningFcn, ...
                   'gui_OutputFcn',  @gui2_OutputFcn, ...
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

% --- Executes just before gui2 is made visible.
function gui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui2 (see VARARGIN)
global ID
filename = fullfile(pwd,'Data',num2str(ID),'images','edited','1.jpg');
% Choose default command line output for gui2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using gui2.
if strcmp(get(hObject,'Visible'),'off') 
    A = imread(filename);
    gray_image = rgb2gray(A);
    medfilt_image = medfilt2(gray_image,[3,3]);
    intentsity_image = uint8(medfilt_image);
    Im2 = (intentsity_image < hObject);
    subplot(1,2,1);
    imshow(A);
    subplot(1,2,2);
    imshow(Im2);
end

% UIWAIT makes gui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_Update.
function pushbutton_Update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ID
filename = fullfile(pwd,'Data',num2str(ID),'images','edited','1.jpg');
%%PLOT
cla;
A = imread(filename);
gray_image = rgb2gray(A);
medfilt_image = medfilt2(gray_image,[3,3]);
intentsity_image = uint8(medfilt_image);

temp_threshold = str2double(handles.threshold);

Im2 = (intentsity_image < temp_threshold);

subplot(1,2,1);
imshow(A);
subplot(1,2,2);
imshow(Im2);

prompt = 'Are you satisfied with this threshold?';
set(handles.text_prompt,'String',prompt);
%{
boolean isSatisfied = 0;
choice = questdlg(prompt, ...
	'hello', ...
	'Yes','No');
% Handle response
if strcmp( choice =='Yes')
    isSatisfied = 1;
end
%}
guidata(hObject, handles);


function edit_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold as a double
temp_threshold = get(hObject,'String');
handles.threshold = temp_threshold;

% Determine if the input is valid
valid = ~isnan(str2double(temp_threshold));
text = '';
if (~valid)
    text = 'The value you entered is not valid, please dont be a jerk'; 
    set(handles.pushbutton_yes,'visible','off');
    set(handles.pushbutton_no,'visible','off');
    set(handles.text_prompt,'visible','off');
else
    % if valid, enable and make yes, no and prompt visible
    set(handles.pushbutton_yes,'visible','on');
    set(handles.pushbutton_no,'visible','on');
    set(handles.text_prompt,'visible','on');

end
handles.valid = valid;
set(handles.text_valid,'String',text);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.threshold = 0;
guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function pushbutton_Update_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_yes.
function pushbutton_yes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Exit the program and pass the value 
assignin('base','threshold',handles.threshold);
close(gui2);


% --- Executes on button press in pushbutton_no.
function pushbutton_no_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
text = 'Please enter a threshold value and click on Update button';
set(handles.text_valid,'String',text);
set(handles.pushbutton_yes,'visible','off');
set(handles.pushbutton_no,'visible','off');
set(handles.text_prompt,'visible','off');


function text_prompt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
