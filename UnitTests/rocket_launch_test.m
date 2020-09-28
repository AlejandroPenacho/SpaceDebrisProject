% This script has the task of testing whether the function for obtaining
% the information of the rocket works. And testing the integration.
clc; clear

RocketData = create_rocket("Epsilon.txt", 450, [-1, -1, 1050], true);




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


% gammaArray = linspace(gammaMeanValue - gammaDispersion, gammaMeanValue + gammaDispersion, nValuesGamma);

[bestGamma] = get_gamma_for_altitude(Parameter, 650000);

gammaArray = bestGamma;

propellantArray = 1;

nRockets = nValuesGamma * nValuesPropellant;


Objective = extract_objective("rocketObjective.txt", Parameter(1));

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
                                                    0];
end


for iRocket = 1:nRockets
    Results(iRocket) = integrate_trajectory(Parameter(iRocket));
end

plot_results(Results, Objective, gammaArray, propellantArray)

