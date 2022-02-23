
% Magnetic Field Scanner with 3D-Printer Ender 3
% Author: Julius Preuschoff
% Date: 23.02.2022
%% Init System
clear printer; % closing last serial connection
clear nano;
clear sensor;
clear s;

run("init.m");
run("configSerial.m");
%% pre-measure movements
s = System(printer, sensor, nano);

% auto home printer
s.autohome;

% setting height
s.setHeight(height);

% driving to initial coordinates
s.moveToXY(X_start_coordinate, Y_start_coordinate);

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
            disp("position: X " + posX + " Y" + posY)

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
            disp("position: X " + posX + " Y" + posY)
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

writeline(printer, "M84") % disable steppers

%% disp matrix
[X,Y] = meshgrid(1:200, 1:200);
surf(values);