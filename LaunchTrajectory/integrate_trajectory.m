function [Results] = integrate_trajectory(Parameter)
    % The set of differential equations that define the dynamics of the
    % rocket are integrated for each stage, according to the information
    % provided in the structure "Parameter".

    % The "Results" structure, which contains all the output information of
    % the function, is defined. It includes a copy of the "Parameter"
    % structure for reference.

    global thrustSwitch
    
    Results = struct("Parameter", Parameter, "timeArray", [], "stateArray", []);

    % The options of the ode45 are defined


    % Each value of "iStage" corresponds to each stage of the rocket. For
    % each one, the function ode45 is used to perform the integration until
    % the fuel of the given stage runs out.

    Rocket = Parameter.Rocket;

    for iStage = 1:Rocket.nStages

        if iStage == 1
            IC = Parameter.Control.initialConditions;
            tSpan = [0, 1000];
        else
            IC = Results.stateArray(end, 1:10);
            IC(5) = Rocket.Stage(iStage).initialMass;
            tSpan = Results.timeArray(end) + [0, 10000];
        end
        

        if Rocket.Stage(iStage).maxThrust ~= 0
            options = odeset('Events',@(t, state) odeFuelStopEvent(t, state, {Parameter, iStage}));
        else
            options = odeset('Events',@(t, state) odeMaxHStopEvent(t, state, {Parameter, iStage}));
        end
        
        [stageTimeArray, stageStateArray] = ...
            ode15s(@(t,x) get_state_derivative(t,x,{Parameter, iStage}), tSpan, IC, options);


        % The time array of the stage is appended to the time array of the
        % whole rocket trajectory

        Results.timeArray = [Results.timeArray; stageTimeArray];

        % The stage state array is extended in order to include more
        % information, and then appended to the total stage array.

        stageStateArray = extend_state_info(stageStateArray, Parameter, iStage);
        Results.stateArray = [Results.stateArray; stageStateArray];
        
        nChanges = Parameter.Rocket.nStages;
        stageChangeIndex = zeros(nChanges-1,1);
        changeNumber = 0;
        
        for iStep = 2:length(Results.stateArray)
            if Results.stateArray(iStep,end) ~= Results.stateArray(iStep-1,end)
                changeNumber = changeNumber + 1;
                stageChangeIndex(changeNumber) = iStep;
            end
            Results.stageChange = stageChangeIndex;
        end
        
        if stageStateArray(end,2) <= 0
            break
        end
        
    end
end


function [remainingFuel, isterminal, direction] = odeFuelStopEvent(t,state, Data)
    % The function tracks the remaing fuel in the current rocket stage.
    % When it reaches zero, the integration is stopped so next stage is
    % started.
    isterminal = 1;
    direction = -1;

    Parameter = Data{1};
    iStage = Data{2};
    StageData = Parameter.Rocket.Stage(iStage);
    remainingFuel = state(5) - StageData.initialMass * ...
                   (StageData.payloadRatio + (1-StageData.payloadRatio)*StageData.structuralRatio);

end

function [Vvertical, isterminal, direction] = odeMaxHStopEvent(t,state, Data)
    % The function tracks the remaing fuel in the current rocket stage.
    % When it reaches zero, the integration is stopped so next stage is
    % started.
    isterminal = 1;
    direction = -1;

    Parameter = Data{1};
    iStage = Data{2};
    StageData = Parameter.Rocket.Stage(iStage);
    Vvertical = state(1) * sin(state(2));

end