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
                str = strip(string(data), "right", char(13));
                if str == "home"
                    obj.nano.flush;
                    pause(5);
                    obj.nano.flush;
                    break;
                end
            end
            done = 1;
        end
        
        % move printhead to given destination X Y
        function moveToXY(obj, X, Y)
            initPosStr_Y = "G0 Y" + string(Y);
            initPosStr_X = "G0 X" + string(X);
            obj.printer.writeline(initPosStr_Y); % sending absolute start position to printer
            obj.printer.writeline(initPosStr_X);

            % waiting for drive to complete
            while 1
                data = obj.nano.readline; % getting coordinates from arduino
                new = split(data, ",");
                if data == new
                else
                    obj.currPosX = double(new(1,1));
                    obj.currPosY = double(new(2,1));
                end
                % checking postion
                if (obj.currPosY == Y) && (obj.currPosX == X)
                    break;
                end
            end
        end
        
        % move printhead to the given height
        function setHeight(obj, Z_height)
            obj.printer.writeline("G0 Z" + Z_height);
        end

        % bed scan
        function values = bedScan(obj, X_start_coordinate, Y_start_coordinate, X_range, Y_range)
            values = zeros(235, 235);
            right = 1;
            lock = 1;
            
            for i = Y_start_coordinate:1:(Y_start_coordinate + Y_range)
                if right
                    for j = X_start_coordinate:1:(X_start_coordinate + X_range)
                        posY = i;
                        posX = j;
                        strY = "G0 Y" + string(posY); % building position string
                        strX = "G0 X" + string(posX) + " F500";
                        obj.printer.writeline(strY); % sending absolute position to printer
                        obj.printer.writeline(strX);
                        disp("position: X " + posX + " Y" + posY);
            
                        while lock
                            data = obj.nano.readline;
                            new = split(data, ",");
                            obj.currPosX = double(new(1,1));
                            obj.currPosY = double(new(2,1));
                            if (obj.currPosY == posY) && (obj.currPosX == posX)
                                lock = 0;
                            end
                        end
                        obj.sensor.writeline("RM")
                        data = obj.sensor.readline;
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
                        obj.printer.writeline(strY); % sending absolute position to printer
                        obj.printer.writeline(strX);
                        disp("position: X " + posX + " Y" + posY);
                        while lock
                            data = obj.nano.readline;
                            new = split(data, ",");
                            obj.currPosX = double(new(1,1));
                            obj.currPosY = double(new(2,1));
                            if (obj.currPosY == posY) && (obj.currPosX == posX)
                                lock = 0;
                            end
                        end
                        obj.sensor.writeline("RM")
                        data = obj.sensor.readline;
                        strArr = split(data, " ");
                        values(posX + 1, posY + 1) = double(strip(strArr(2,1), 'right', char(13)));
                        lock = 1;
                    end
                     right = 1;
                     left = 0;
                end
            end
        end

    end
end
