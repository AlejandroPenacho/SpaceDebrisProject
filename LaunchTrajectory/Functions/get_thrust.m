function [T] = get_thrust(t, stateArray, iStage, Parameter)
    %For a given time, state and parameters of the problem, provides the thrust
    %of the rocket

    T = Parameter.Rocket.Stage(iStage).maxThrust;
end

