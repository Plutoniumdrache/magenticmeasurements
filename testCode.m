
clear printer % closing last serial connections
clear nano
clear sensor % close last serial connection

% configure printer
printer = serialport("COM15", 115200, Timeout=2); % starting serial connection
printer.Terminator
readline(printer)
configureTerminator(printer,"CR")
%writeline(printer, "G28")
writeline(printer, "G0 Z20")


% config arduino
nano = serialport("COM13", 19200, Timeout=1);
nano.Terminator

% configure sensor
sensor = serialport("COM14", 115200, Timeout=2);
sensor.Terminator;
pause(2);
sensor.flush;
sensor.writeline("HI");
sensor.readline
% setting up for one-shot trigger mode
sensor.writeline("RM");
% first call is answered with confirmation ("Manual Read")
sensor.readline

% parameters for bed scan:
Y_start_coordinate = 50;
X_start_coordinate = 100;
Y_range = 10;
X_range = 10;
currPosX = 0;
currPosY = 0;

% driving to initial coordinates
initPosStr_Y = "G0 Y" + string(Y_start_coordinate);
initPosStr_X = "G0 X" + string(X_start_coordinate);
writeline(printer, initPosStr_Y); % sending absolute start position to printer
writeline(printer, initPosStr_X);

% waiting for drive to complete
postion_reached = 1;
while(postion_reached)
    data = nano.readline;
    new = split(data, ",");
    currPosX = double(new(1,1));
    curPosY = double(new(2,1));
    if (curPosY == Y_start_coordinate) && (currPosX == X_start_coordinate)
        postion_reached = 0;
    end
end

%% begin bed scan
values = zeros(200, 200);
right = 1;
lock = 1;

for i = Y_start_coordinate:1:(Y_start_coordinate + Y_range)
    if right
        for j = X_start_coordinate:1:(X_start_coordinate + X_range)
            posY = i;
            posX = j;
            strY = "G0 Y" + string(posY); % building position string
            strX = "G0 X" + string(posX) + " F500";
            writeline(printer, strY); % sending absolute position to printer
            writeline(printer, strX);
            disp("sensor at postion: X " + posX + " Y" + posY)

            while lock
                data = nano.readline;
                new = split(data, ",");
                currPosX = double(new(1,1));
                curPosY = double(new(2,1));
                if (curPosY == posY) && (currPosX == posX)
                    lock = 0;
                end
            end
            sensor.writeline("RM")
            data = sensor.readline;
            strArr = split(data, " ");
            values(posX + 1, posY + 1) = double(strip(strArr(2,1), 'right', char(13)));
            lock = 1;
        end
            right = 0;
            left = 1;
    elseif left
        for j = (X_start_coordinate + X_range):-1:X_start_coordinate
            posY = i;
            posX = j;
            strY = "G0 Y" + string(posY); % building position string
            strX = "G0 X" + string(posX) + " F500";
            writeline(printer, strY); % sending absolute position to printer
            writeline(printer, strX);
            disp("sensor at postion: X " + posX + " Y" + posY)
            while lock
                data = nano.readline;
                new = split(data, ",");
                currPosX = double(new(1,1));
                curPosY = double(new(2,1));
                if (curPosY == posY) && (currPosX == posX)
                    lock = 0;
                end
            end
            sensor.writeline("RM")
            data = sensor.readline;
            strArr = split(data, " ");
            values(posX + 1, posY + 1) = double(strip(strArr(2,1), 'right', char(13)));
            lock = 1;
        end
         right = 1;
         left = 0;
    end
end

writeline(printer, "G28") % auto home printer
writeline(printer, "M84") % disable steppers

%% disp matrix
[X,Y] = meshgrid(1:200, 1:200);
surf(values);