clear sensor % close last serial connection
sensor = serialport("COM14", 115200, Timeout=2);

sensor.Terminator;
pause(2)
sensor.flush
sensor.writeline("HI");
sensor.readline

% first call is answered with confirmation ("Manual Read")
sensor.writeline("RM")
confirmation = sensor.readline;

for  i = 0:1:20
    sensor.writeline("RM")
    data = sensor.readline;
    strArr = split(data, " ");
    sensValue = double(strip(strArr(2,1), 'right', char(13)))
end