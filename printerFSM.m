% FSM Class

classdef printerFSM < handle
    properties
        system;
        currentState;
        States;
        currentHeight = 0;
        values;
    end
    methods
        function obj = printerFSM(system, States) % constructor
            obj.system = system;
            obj.States = States;
            obj.currentState = States.INIT;
        end

        % eval method
        function lock = eval(obj)
            nextstate = obj.currentState;
            switch obj.currentState
                case obj.States.INIT
                    str = input("Ist das Druckbett frei von jeglichen Hindernissen? (Y/N): ", 's');
                    if str == 'N'
                        disp("Druckbett bitte freiräumen.");
                        nextstate = obj.States.INIT;
                    elseif str == 'Y'
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
                    obj.system.moveToXY(0, 235); % Bett nach vorne zur Beladung
                    nextstate = obj.States.PARAMETER_SETUP;

                case obj.States.PARAMETER_SETUP
                    str = input("Bitte die Messungsparameter in der init.m bearbeiten (Höhe, Startpunkt, Messfeldgröße). Fertig? (Y): ", 's');
                    if str == 'Y'
                        clear init;
                        run("init.m");
                        disp("Drucker verfährt zur eingestellten Höhe Z" + Z_height);
                        nextstate = obj.States.INITIAL_HEIGHT;
                    else
                        disp("Eingabe nicht erkannt.")
                        nextstate = obj.States.PARAMETER_SETUP;
                    end
                case obj.States.INITIAL_HEIGHT
                    clear init;
                    run("init.m");
                    obj.currentHeight = Z_height;
                    obj.system.setHeight(obj.currentHeight); % Höhe Messobjekt + gewünschten Abstand

                    str = input("Eingestellte Höhe passt so? (Y/N): ", 's');
                    if str == 'Y'
                        disp("Verfahre zur Startposition");
                        nextstate = obj.States.INITIAL_XY_POSITION;
                    elseif str == 'N'
                        nextstate = obj.States.PARAMETER_SETUP;
                    else
                        disp("Eingabe nicht erkannt.")
                        nextstate = obj.States.INITIAL_HEIGHT;
                    end
                case obj.States.INITIAL_XY_POSITION
                    clear init;
                    run("init.m");
                    obj.system.moveToXY(X_start_coordinate, Y_start_coordinate);
                    
                    str = input("Eingestellter Startpunkt passt so? (Y/N): ", 's');
                    if str == 'Y'
                        disp("Beginne mit der Messung");
                        nextstate = obj.States.MEASURING;
                    elseif str == 'N'
                        nextstate = obj.States.PARAMETER_SETUP;
                    else
                        disp("Eingabe nicht erkannt.")
                        nextstate = obj.States.INITIAL_XY_POSITION;
                    end
                case obj.States.MEASURING
                    clear init;
                    run("init.m");
                    obj.values = obj.system.bedScan(X_start_coordinate, Y_start_coordinate, X_range, Y_range);
                    nextstate = obj.States.SHOW;
                case obj.States.SHOW
                    % disp matrix
                    [X,Y] = meshgrid(1:200, 1:200);
                    surf(obj.values);

                    obj.currentHeight  = obj.currentHeight + 5;
                    obj.system.setHeight(obj.currentHeight); % offset damit nicht gegen Bett gefahren wird
                    obj.system.moveToXY(0, 235); % Bett nach vorne zur Beladung
                    nextstate = obj.States.PARAMETER_SETUP;
                otherwise
            end
            obj.currentState = nextstate;
        end
    end
end