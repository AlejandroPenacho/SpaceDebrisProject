function [T] = get_thrust(t, stateArray, iStage, Parameter)
    %For a given time, state and parameters of the problem, provides the thrust
    %of the rocket
    if stateArray(4) >= Parameter.Control.minAltitudeThrust(iStage)
        T = Parameter.Rocket.Stage(iStage).maxThrust;
    else 
        T = 0;
    end
end

