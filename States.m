% enum class for FSM states
% Author: Julius Preuschoff
% Date: 23.02.2022
classdef States
    properties (Constant)
        INIT = 1;
        HOME = 2;
        LOADING = 3;
        PARAMETER_SETUP = 4;
        INITIAL_HEIGHT = 5;
        INITIAL_XY_POSITION = 6;
        MEASURING = 7;
        SHOW = 8;
    end
end