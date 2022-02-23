
% configure printer
printer = serialport(COM_Printer, 115200, Timeout=2); % starting serial connection
printer.Terminator;
readline(printer);
configureTerminator(printer,"CR");


% config arduino
nano = serialport(COM_ArduinoNano, 19200, Timeout=1);
nano.Terminator;

% configure sensor
sensor = serialport(COM_Sensor, 115200, Timeout=2);
sensor.Terminator;
pause(2);
sensor.flush;
% getting response from sensor
sensor.writeline("HI");
sensor.readline
% setting sensor up for one-shot trigger mode
sensor.writeline("RM");
% first call is answered with confirmation ("Manual Read")
sensor.readline