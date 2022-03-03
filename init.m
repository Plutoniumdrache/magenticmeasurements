

% parameters for bed scan:
Y_start_coordinate = 60; % enter value from 0 - 235
X_start_coordinate = 20; % enter value from 0 - 235

% Attention: The sum of the start coordinate value and the range value have
% to be less or equal than 235!

Y_range = 10; % enter value from 0 - 235
X_range = 10; % enter value from 0 - 235

Z_height = 20; % enter value from 0 - 250


% COM Ports
% With the <serialportlist> command you can list all connected serial
% devices.
COM_Printer = "COM16";
COM_Sensor = "COM14";
COM_ArduinoNano = "COM13";