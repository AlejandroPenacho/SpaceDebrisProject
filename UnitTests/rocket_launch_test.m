% This script has the task of testing whether the function for obtaining
% the information of the rocket works. And testing the integration.
clc; clear

RocketData = create_rocket("Epsilon.txt", 605.116, [3000, -1, 2225], true);




nRockets = 1;


ControlStruct = struct("initialConditions", 0, ...
                       "maxGammaThrust", [10, 10, 0]);
ConstantStruct = struct("earthRadius", 6371000, ...
                        "earthSLGravity", 9.81, ...
                        "mu", 3.986004418*10^14);
                   

nValuesGamma = 1;
nValuesPropellant = 1;

% gammaMeanValue = pi/2 - 0.495;
% gammaDispersion = 0.003;

Parameter(1:nRockets) = struct("Rocket", RocketData, "Control", ControlStruct, "Constant", ConstantStruct);
Objective = extract_objective("rocketObjective.txt", Parameter(1));

% gammaArray = linspace(gammaMeanValue - gammaDispersion, gammaMeanValue + gammaDispersion, nValuesGamma);

[bestGamma] = get_gamma_for_altitude(Parameter, Objective.perigee-Objective.earthRadius);
% bestGamma = 1.368819004524887;


gammaArray = bestGamma;


propellantArray = 1;

nRockets = nValuesGamma * nValuesPropellant;




for iRocket = 1:nRockets
    
    gammaIndex = mod(iRocket-1, nValuesGamma)+1;
    propellantIndex = ceil(iRocket/nValuesGamma);
    
    Parameter(iRocket).Control.initialConditions = [0, ...
                                                    gammaArray(gammaIndex), ...
                                                    0, ...
                                                    0, ...
                                                    RocketData.initialMass, ...
                                                    0, ...
                                                    0, ...
                                                    0, ...
                                                    0, ...
                                                    0];
end


for iRocket = 1:nRockets
    Results(iRocket) = integrate_trajectory(Parameter(iRocket));
end


for i=1:length(Results.timeArray)
    if Results.stateArray(i,13) == 3 && ...
       Results.stateArray(i,10) ~= Results.stateArray(i-1,10)
            Results.stageChange = [Results.stageChange; i];
            break
    end
end


plot_results(Results, Objective, gammaArray, propellantArray)

finalPerigee = Results.stateArray(end,4) + Objective.earthRadius;
finalSpeed = Results.stateArray(end,1);
requiredApogee = Objective.apogee;

requiredFinalSpeed = sqrt(2*Objective.mu) * ...
                     sqrt(1/finalPerigee - 1/(finalPerigee+requiredApogee));

fprintf("Change deltaV by %.3f m/s\n", requiredFinalSpeed - finalSpeed);

energy_analysis(Results, Objective)
