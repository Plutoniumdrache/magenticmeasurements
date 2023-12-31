% Class representing the Hardware of the measurement system
% Author: Julius Preuschoff
% Date: 23.02.2022
classdef System
    properties
        printer;
        sensor;
        nano;
        currPosX = 0;
        currPosY = 0;
    end
    methods
        function obj = System(printer, sensor, arduninoNano) % constructor
            obj.printer = printer;
            obj.sensor = sensor;
            obj.nano = arduninoNano;
        end
        
        % auto home printer and wait until home position is reached
        function done = autohome(obj)
            obj.printer.writeline("G28");
            
            while 1 % waiting for auto home to complete
                data = obj.nano.readline();
                if isstring(data)
                    str = strip(string(data), "right", char(13));
                    if str == "home"
                        obj.nano.flush;
                        pause(5);
                        obj.nano.flush;
                        break;
                    end
                end
            end
            done = 1;
        end
        
        % move printhead to given X Y destination  with given speed
        function moveToXY(obj, X, Y, speed)
            % building the G-Code command
            initPosStr_Y = "G0 Y" + string(Y) + " F" + speed;
            initPosStr_X = "G0 X" + string(X) + " F" + speed;
            % sending absolute position to printer
            obj.printer.writeline(initPosStr_Y);
            obj.printer.writeline(initPosStr_X);

            % waiting for drive to complete
            while 1
                data = obj.nano.readline; % getting coordinates from arduino
                if isstring(data)
                    new = split(data, ","); % splitting the incoming coordinates
                    if data == new % check for empty messages
                    else
                        obj.currPosX = double(new(1,1)); % converting to numbers
                        obj.currPosY = double(new(2,1));
                    end
                    % checking position
                    if (obj.currPosY == Y) && (obj.currPosX == X)
                        break;
                    end
                end
            end
        end
        
        % move printhead to the given height
        function setHeight(obj, Z_height)
            Z_height = Z_height + 4; % Offset correction
            obj.printer.writeline("G0 Z" + Z_height);
        end

        % getting sensor value
        function value = getSensorValue(obj)
            obj.sensor.writeline("RM");
            data = obj.sensor.readline;
            strArr = split(data, " "); % splitting given sensor string
            value = double(strip(strArr(2,1), 'right', char(13))); % extracting value from string
            % The String is in the format "RD 7.77029\r". The command
            % char(13) represents the \r character and is removed from the
            % string by the code line above.
        end

        % bed scan
        function values = bedScan(obj, X_start_coordinate, Y_start_coordinate, X_range, Y_range)
            values = zeros(235, 235);
            right = 1;
            
            for i = Y_start_coordinate:1:(Y_start_coordinate + Y_range)
                if right % check last moving direction
                    for j = X_start_coordinate:1:(X_start_coordinate + X_range)
                        posY = i;
                        posX = j;
                        disp("position: X " + posX + " Y" + posY); % show current position
                        obj.moveToXY(posX, posY, 500); % move to position
                        values(posY + 1, posX + 1) = obj.getSensorValue(); % get sensor value
                    end
                        right = 0;
                        left = 1;
                elseif left % check last moving direction
                    for j = (X_start_coordinate + X_range):-1:X_start_coordinate
                        posY = i;
                        posX = j;
                        disp("position: X " + posX + " Y" + posY); % show current position
                        obj.moveToXY(posX, posY, 500); % move to position
                        values(posY + 1, posX + 1) = obj.getSensorValue(); % get sensor value
                    end
                     right = 1;
                     left = 0;
                end
            end
        end
        
        % method for checking init parameter for errors
        function result = checkParameter(obj, Ysc, Xsc, Yr, Xr, Zh)
            result_sc = 0;
            result_scr = 0;
            result_z = 0;
            if (Ysc >= 0) && (Ysc <= 235) && (Xsc >= 0) && (Xsc <= 235)
                result_sc = 1;
            end
            Yscr = Ysc + Yr;
            Xscr = Xsc + Xr;
            if (Yscr >= 0) && (Yscr <= 235) && (Xscr >= 0) && (Xscr <= 235)
                result_scr = 1;
            end
            if (Zh >= 5) && (Zh <= 250)
                result_z = 1;
            end
            if result_z && result_scr && result_sc
                result = 1;
            else
                result = 0;
                disp("Fehler in den angebeben Parametern. Beachte die Regeln in der init.m Datei.");
            end
        end
    end
end
