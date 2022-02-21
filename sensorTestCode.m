clear sensor % close last serial connection
sensor = serialport("COM14", 115200, Timeout=2);

sensor.Terminator;
pause(2)
sensor.flush
sensor.writeline("HI");
sensor.readline

sensor.writeline("RC")
while 1
    sensor.readline
end 