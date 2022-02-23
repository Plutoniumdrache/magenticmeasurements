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
        
        % move to given destination X Y
        function moveToXY(obj, X, Y)
            initPosStr_Y = "G0 Y" + string(Y);
            initPosStr_X = "G0 X" + string(X);
            obj.printer.writeline(initPosStr_Y); % sending absolute start position to printer
            obj.printer.writeline(initPosStr_X);

            % waiting for drive to complete
            while 1
                data = obj.nano.readline; % getting coordinates from arduino
                new = split(data, ",");
                obj.currPosX = double(new(1,1));
                obj.currPosY = double(new(2,1));
                % checking postion
                if (obj.currPosY == Y) && (obj.currPosX == X)
                    break;
                end
            end
        end

        function setHeight(obj, height)
            obj.printer.writeline("G0 Z" + height);
        end

    end
end
