
clear printer % close last serial connection
clear nano

% configure printer
printer = serialport("COM7", 115200, Timeout=2);
printer.Terminator
readline(printer)
configureTerminator(printer,"CR")
%writeline(printer, "G28")
writeline(printer, "G0 Z20")


% config arduino
nano = serialport("COM13", 19200, Timeout=1);
nano.Terminator

% begin bed scan
currPosX = 0;
currPosY = 0;

for i = 0:1:50
    if mod(i, 2) == 0
        posY = i;
        posX = 200;
    else
        posY = i;
        posX = 0;
    end
    strY = "G0 Y" + string(posY);
    strX = "G0 X" + string(posX);
    writeline(printer, strY);
    writeline(printer, strX);

    if posX == 200
        while currPosX < 200
            data = nano.readline;
            new = split(data, ",")
            currPosX = double(new(1,1));
            curPosY = double(new(2,1));
        end
    elseif posX == 0
        while currPosX > 0
            data = nano.readline;
            new = split(data, ",")
            currPosX = double(new(1,1));
            curPosY = double(new(2,1));
        end
    end
    currPosX = 1;
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
