function [D] = get_aerodynamic_drag(stateArray, iStage, Parameter)
%Computes the drag force acting on the rocket for a given state.
%   Uses the height of the rocket 


    [~,~,~,rho]= atmosisa(stateArray(1));
    
    velocity = (stateArray(3).^2 + (stateArray(4) * (Parameter.Constant.earthRadius + stateArray(1))).^2).^0.5;

    D = 50;
end

