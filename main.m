% Magnetic Field Scanner with 3D-Printer Ender 3
% Author: Julius Preuschoff
% Date: 23.02.2022
%% Init System
clear printer; % closing last serial connection
clear nano;
clear sensor;
clear s;
clear fsm;

run("init.m");
run("configSerial.m");
%% running system
s = System(printer, sensor, nano);
fsm = printerFSM(s, States);

while 1
    exit = fsm.eval;
    if exit
        break;
    end
end
disp("Schrittmotoren deaktiviert.")
writeline(printer, "M84") % disable steppers
disp("Anwendung beendet.")
