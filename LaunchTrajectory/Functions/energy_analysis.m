function [outputArg1,outputArg2] = energy_analysis(Results, Objective)
%ENERGY_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

    nStages = Results.Parameter.Rocket.nStages;
    nStatePoints = length(Results.timeArray);
    stateArray = Results.stateArray;
    
    usefulEnergyArray = zeros(nStages,1);
    
    for iStage=1:nStages
        
        if iStage == nStages
            structuralMass = stateArray(nStatePoints,5) - ...
                             Results.Parameter.Rocket.payloadMass;
            specificEnergy = get_specific_delta_energy(Results, Objective, nStatePoints);
        else
            stateIndex = Results.stageChange(iStage);
            structuralMass = stateArray(stateIndex,5) - ...
                             stateArray(stateIndex+1,5);
            specificEnergy = get_specific_delta_energy(Results, Objective, stateIndex);
        end
        usefulEnergyArray(iStage) = structuralMass * specificEnergy;
    end

    payloadUsefulEnergy = get_specific_delta_energy(Results, Objective, stateIndex) * ...
                          Results.Parameter.Rocket.payloadMass;
                      
    %% Total energy for the rocket
    
    totalEnergyArray = zeros(nStages, 1);
    
    for iState = 2:nStatePoints
        currentSpecificEnergy = ((Results.stateArray(iState,1).^2)/2 - ...
               Objective.mu/(Results.stateArray(iState,4)+Objective.earthRadius));
           
        previousSpecificEnergy = ((Results.stateArray(iState-1,1).^2)/2 - ...
               Objective.mu/(Results.stateArray(iState-1,4)+Objective.earthRadius));
        
        deltaEnergy = (currentSpecificEnergy - previousSpecificEnergy) * ...
                     (Results.stateArray(iState-1,5) + Results.stateArray(iState,5))/2;
                 
        totalEnergyArray(stateArray(iState,11)) = totalEnergyArray(stateArray(iState,11)) + ...
                                                  deltaEnergy;
    end
                
	%% Propulsive energy
    
    
end


function energy = get_specific_delta_energy(Results, Objective, index)

    energy = ((Results.stateArray(index,1).^2)/2 - ...
               Objective.mu/(Results.stateArray(index,4)+Objective.earthRadius)) -...
               Objective.mu/Objective.earthRadius;

end