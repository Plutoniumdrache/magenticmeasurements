% Serial config file for magnetic measurement system 
% Author: Julius Preuschoff
% Date: 23.02.2022
%% configure printer
printer = serialport(COM_Printer, 115200, Timeout=2); % starting serial connection
printer.Terminator; 
readline(printer);
configureTerminator(printer,"CR");
printer.writeline("M107"); % turn fan off
printer.writeline("M104 S0"); % turn hot end heating off 
printer.writeline("M140 S0"); % turn bed headting off
pause(0.5);
%% config arduino
nano = serialport(COM_ArduinoNano, 19200, Timeout=1);
nano.Terminator;
%% configure sensor
sensor = serialport(COM_Sensor, 115200, Timeout=2);
sensor.Terminator;
pause(2);
sensor.flush;
% getting response from sensor
sensor.writeline("HI");
disp(sensor.readline);
% setting sensor up for one-shot trigger mode
sensor.writeline("RM");
% first call is answered with confirmation ("Manual Read")
disp(sensor.readline);