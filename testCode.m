
clear printer % closing last serial connections
clear nano
clear sensor % close last serial connection

% configure printer
printer = serialport("COM7", 115200, Timeout=2); % starting serial connection
printer.Terminator
readline(printer)
configureTerminator(printer,"CR")
%writeline(printer, "G28")
writeline(printer, "G0 Z20")


% config arduino
nano = serialport("COM13", 19200, Timeout=1);
nano.Terminator

% % configure sensor
% sensor = serialport("COM14", 115200, Timeout=2);
% sensor.Terminator;
% pause(2)
% sensor.flush
% sensor.writeline("HI");
% sensor.readline

% parameters for bed scan:
Y_start_coordinate = 100;
X_start_coordinate = 100;
Y_range = 10;
X_range = 30;
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
    new = split(data, ",")
    currPosX = double(new(1,1));
    curPosY = double(new(2,1));
    if (curPosY == Y_start_coordinate) && (currPosX == X_start_coordinate)
        postion_reached = 0;
    end
end

disp("exit pso loop")
% begin bed scan
for i = Y_start_coordinate:1:(Y_start_coordinate + Y_range)
    disp(i)
    % scanning the bed and change coordinates if drive direction changes
    if mod(i, 2) == 0 %  
        posY = i;
        posX = X_start_coordinate + X_range;
    else
        posY = i;
        posX = X_start_coordinate;
    end
    strY = "G0 Y" + string(posY); % building position string
    strX = "G0 X" + string(posX);
    writeline(printer, strY); % sending absolute position to printer
    writeline(printer, strX);

    % controlling the movement with the arduino
    if posX == X_start_coordinate + X_range
        while currPosX < X_start_coordinate + X_range
            data = nano.readline;
            new = split(data, ",")
            currPosX = double(new(1,1));
            curPosY = double(new(2,1));
        end
    elseif posX == X_start_coordinate
        while currPosX > X_start_coordinate
            data = nano.readline;
            new = split(data, ",")
            currPosX = double(new(1,1));
            curPosY = double(new(2,1));
        end
    end
    currPosX = X_start_coordinate + 1;
    currPosY = 0;
end

% writeline(printer, "G0 X20");


% while 1
%     data = nano.readline;
%     new = split(data, ",");
%     currPosX = double(new(1,1));
%     curPosY = double(new(2,1));
% end

writeline(printer, "M84")
