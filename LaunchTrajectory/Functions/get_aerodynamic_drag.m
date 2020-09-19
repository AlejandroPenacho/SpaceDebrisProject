function [D] = get_aerodynamic_drag(stateArray, iStage, Parameter)
%Computes the drag force acting on the rocket for a given state.
%   Uses the height of the rocket
    tropopauseLimit = 20000;

    [~,speedOfSound,~,rho]= atmosisa(stateArray(4));
    
    if stateArray(4) > tropopauseLimit
        rho = 1.225 * (1.225 / 0.088)^(-stateArray(4)/tropopauseLimit);
    end

    velocity = stateArray(1);
    mach = velocity/speedOfSound;
    
    if Parameter.Rocket.Stage(iStage).C_D.type == "constant"
        C_D = Parameter.Rocket.Stage(iStage).C_D.value;
    else
        C_D = interp1(Parameter.Rocket.Stage(iStage).C_D.mach, ...
                      Parameter.Rocket.Stage(iStage).C_D.value, ...
                      mach, ...
                      "linear", ...
                      "extrap");
    end

    D = 0.5*C_D*Parameter.Rocket.Stage(iStage).surface*rho*velocity^2;
end

