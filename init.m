% parameter initial file for magnetig measurement system
% Author: Julius Preuschoff
% Date: 23.02.2022
%% parameters for bed scan:
Y_start_coordinate = 15; % enter value from 0 - 235
X_start_coordinate = 85; % enter value from 0 - 235

% Attention: The sum of the start coordinate value and the range value have
% to be less or equal than 235!

Y_range = 30; % enter value from 0 - 235
X_range = 50; % enter value from 0 - 235

Z_height = 8; % enter value from 5 - 250
%% parameter for filename:
filename = "data"; % enter only the filename NOT the extension

%% COM Port parameters list
% With the <serialportlist> command you can list all connected serial
% devices.
COM_Printer = "COM17";
COM_Sensor = "COM14";
COM_ArduinoNano = "COM13";