function [D] = get_aerodynamic_drag(stateArray, iStage, Parameter)
%Computes the drag force acting on the rocket for a given state.
%   Uses the height of the rocket
    gamma=1.4;
    speedOfSound= sqrt(gamma*get_R(stateArray(4))*get_temperature(stateArray(4)));
    
    rho = get_density(stateArray(4));

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

