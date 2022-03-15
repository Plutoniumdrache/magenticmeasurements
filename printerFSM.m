% FSM Class
% Author: Julius Preuschoff
% Date: 23.02.2022

classdef printerFSM < handle
    properties
        system;
        currentState;
        States;
        currentHeight = 0;
        values;
        travelspeed = 2000;
    end
    methods
        function obj = printerFSM(system, States) % constructor
            obj.system = system;
            obj.States = States;
            obj.currentState = States.INIT;
        end

        % eval method
        function exit = eval(obj)
            exit = 0;
            nextstate = obj.currentState;
            switch obj.currentState
                case obj.States.INIT
                    str = input("Ist das Druckbett frei von jeglichen Hindernissen? (y/n): ", 's');
                    if str == 'n'
                        disp("Druckbett bitte freiraeumen.");
                        nextstate = obj.States.INIT;
                    elseif str == 'y'
                        disp("Auto Home ...");
                        nextstate = obj.States.HOME;
                    else
                        disp("Eingabe nicht erkannt.")
                        nextstate = obj.States.INIT;
                    end

                case obj.States.HOME
                    obj.system.autohome;
                    nextstate = obj.States.LOADING;

                case obj.States.LOADING
                    obj.currentHeight = 20;
                    obj.system.setHeight(obj.currentHeight); % offset damit nicht gegen Bett gefahren wird
                    obj.system.moveToXY(0, 235, obj.travelspeed); % Bett nach vorne zur Beladung
                    nextstate = obj.States.PARAMETER_SETUP;

                case obj.States.PARAMETER_SETUP
                    str = input("Bitte die Messungsparameter in der init.m bearbeiten (Hoehe, Startpunkt, Messfeldgrosse) und Objekt platzieren. Fertig? (y) Exit? (e): ", 's');
                    if str == 'y'
                        clear init;
                        run("init.m");
                        if obj.system.checkParameter(Y_start_coordinate, X_start_coordinate, Y_range, X_range, Z_height)
                            disp("Drucker verfaehrt zur eingestellten Hoehe Z" + Z_height);
                            nextstate = obj.States.INITIAL_HEIGHT;
                        else
                            nextstate = obj.States.PARAMETER_SETUP;
                        end
                    elseif str == 'e'
                        exit = 1;
                    else
                        disp("Eingabe nicht erkannt.")
                        nextstate = obj.States.PARAMETER_SETUP;
                    end
                case obj.States.INITIAL_HEIGHT
                    clear init;
                    run("init.m");
                    if obj.system.checkParameter(Y_start_coordinate, X_start_coordinate, Y_range, X_range, Z_height)
                        obj.currentHeight = Z_height;
                        obj.system.setHeight(obj.currentHeight); 
                        
                        str = input("Eingestellte Hoehe passt so? (y/n): ", 's');
                        if str == 'y'
                            disp("Verfahre zur Startposition");
                            nextstate = obj.States.INITIAL_XY_POSITION;
                        elseif str == 'n'
                            nextstate = obj.States.PARAMETER_SETUP;
                        else
                            disp("Eingabe nicht erkannt.")
                            nextstate = obj.States.INITIAL_HEIGHT;
                        end
                    else
                        nextstate = obj.States.PARAMETER_SETUP;
                    end

                    
                case obj.States.INITIAL_XY_POSITION
                    clear init;
                    run("init.m");
                    if obj.system.checkParameter(Y_start_coordinate, X_start_coordinate, Y_range, X_range, Z_height)
                        obj.system.moveToXY(X_start_coordinate, Y_start_coordinate, 3000);
                    
                        str = input("Eingestellter Startpunkt passt so? (y/n): ", 's');
                        if str == 'y'
                            disp("Beginne mit der Messung");
                            nextstate = obj.States.MEASURING;
                        elseif str == 'n'
                            nextstate = obj.States.PARAMETER_SETUP;
                        else
                            disp("Eingabe nicht erkannt.")
                            nextstate = obj.States.INITIAL_XY_POSITION;
                        end
                    else
                        nextstate = obj.States.PARAMETER_SETUP;
                    end
                case obj.States.MEASURING
                    clear init;
                    run("init.m");
                    obj.values = obj.system.bedScan(X_start_coordinate, Y_start_coordinate, X_range, Y_range);
                    disp("Messung abgeschlossen.");
                    nextstate = obj.States.SHOW;
                case obj.States.SHOW
                    % convert values from Oe to T
                    my_0 = 1.256637061e-6;
                    my_r = 1; % air
                    B_values = my_0 * my_0 * (1000 / 4*pi) * obj.values;

                    % disp matrix as surf plot
                    disp("Zeige Messergergebnisse:")
                    [X,Y] = meshgrid(1:235, 1:235);

                    run("init.m"); % getting filename variable
                    figurename = "MesergebnisseDateiname_ " + filename;
                    figure('Name', figurename);
                    surf(B_values);
                    xlabel('X-Koordinaten in mm');
                    ylabel('Y-Koordinaten in mm');
                    zlabel('Magnetische Flussdichte in Tesla')
                    title(figurename);
                    grid on;

                    % write matrix to csv file
                    writematrix(B_values, filename + ".csv");

                    disp("Fahre Bett nach vorne.")
                    obj.currentHeight = obj.currentHeight + 5;
                    obj.system.setHeight(obj.currentHeight); % offset damit nicht gegen Bett gefahren wird
                    obj.system.moveToXY(0, 235, obj.travelspeed); % Bett nach vorne zur Beladung
                    nextstate = obj.States.PARAMETER_SETUP;
                    disp("Die Messung kann jetzt erneut gestartet werden.")
                otherwise
            end
            obj.currentState = nextstate;
        end
    end
end