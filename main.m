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
    fsm.eval
end

% % auto home printer
% s.autohome;
% 
% % setting height
% s.setHeight(Z_height);
% 
% % driving to initial coordinates
% s.moveToXY(X_start_coordinate, Y_start_coordinate);

%% begin bed scan
% values = s.bedScan(X_start_coordinate, Y_start_coordinate, X_range, Y_range);
% 
% writeline(printer, "M84") % disable steppers

%% disp matrix
% [X,Y] = meshgrid(1:200, 1:200);
% surf(values);