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
            structuralMass = stateArray(stateIndex-1,5) - ...
                             stateArray(stateIndex,5);
            specificEnergy = get_specific_delta_energy(Results, Objective, stateIndex);
        end
        usefulEnergyArray(iStage) = structuralMass * specificEnergy;
    end

    payloadUsefulEnergy = get_specific_delta_energy(Results, Objective, nStatePoints) * ...
                          Results.Parameter.Rocket.payloadMass;
                      
    %% Total energy for the rocket
    
    totalEnergyArray = zeros(nStages, 1);
    
%     for iState = 2:nStatePoints
%         currentSpecificEnergy = ((Results.stateArray(iState,1).^2)/2 - ...
%                Objective.mu/(Results.stateArray(iState,4)+Objective.earthRadius));
%            
%         previousSpecificEnergy = ((Results.stateArray(iState-1,1).^2)/2 - ...
%                Objective.mu/(Results.stateArray(iState-1,4)+Objective.earthRadius));
%         
%         deltaEnergy = (currentSpecificEnergy - previousSpecificEnergy) * ...
%                      (Results.stateArray(iState-1,5) + Results.stateArray(iState,5))/2;
%                  
%         totalEnergyArray(stateArray(iState,13)) = totalEnergyArray(stateArray(iState,13)) + ...
%                                                   deltaEnergy;
%     end
               
    
    fprintf("\n\nEnergy after each decoupling:\n\n")
    fprintf("First stage\t%.3f\tGJ\n", usefulEnergyArray(1)/10^9)
    fprintf("Second stage\t%.3f\tGJ\n", usefulEnergyArray(2)/10^9)
    fprintf("Third stage\t%.3f\tGJ\n", usefulEnergyArray(3)/10^9)
    fprintf("Payload\t\t%.3f\tGJ\n", payloadUsefulEnergy/10^9)
    fprintf("----------------------\n")
    fprintf("Total\t\t%.3f\tGJ\n", (payloadUsefulEnergy + sum(usefulEnergyArray))/10^9)
	%% Propulsive energy
    
    mechanicalEnergyArray = zeros(3,1);
    
    mechanicalEnergyArray(1) = Results.stateArray(Results.stageChange(1),10);
    mechanicalEnergyArray(2) = Results.stateArray(Results.stageChange(2),10) - ...
                          mechanicalEnergyArray(1);
    mechanicalEnergyArray(3) = Results.stateArray(end,10) - ...
                          Results.stateArray(Results.stageChange(2),10);
    totalMechanicalEnergy = Results.stateArray(end,10);
    
    fprintf("\n\nMechanical energy generation:\n\n")
    fprintf("First stage:\t%.3f\tGJ\n", mechanicalEnergyArray(1)/10^9);
    fprintf("Second stage:\t%.3f\tGJ\n", mechanicalEnergyArray(2)/10^9);
    fprintf("Third stage:\t%.3f\tGJ\n", mechanicalEnergyArray(3)/10^9);
    fprintf("------------------------\n")
    fprintf("Total:\t\t%.3f\tGJ\n", totalMechanicalEnergy/10^9);
    
    
    %% Thermal energy
    
    specificEnergy = 40 * 10^6;
    
    thermalEnergyArray = zeros(3,1);
    
    for i=1:3
        StageData = Results.Parameter.Rocket.Stage(i);
        thermalEnergyArray(i) = StageData.initialMass * ...
                           (1-StageData.payloadRatio) * ...
                           (1-StageData.structuralRatio) * ...
                           specificEnergy;
                          
    end
    
    fprintf("\n\nThermal energy generation:\n\n")
    fprintf("First stage:\t%.3f\tGJ\n", thermalEnergyArray(1)/10^9);
    fprintf("Second stage:\t%.3f\t\tGJ\n", thermalEnergyArray(2)/10^9);
    fprintf("Third stage:\t%.3f\t\tGJ\n", thermalEnergyArray(3)/10^9);
    fprintf("------------------------\n")
    fprintf("Total:\t\t%.3f\tGJ\n", (sum(thermalEnergyArray))/10^9);
    
    
    %% Delta V
    
    deltaVArray = zeros(3,1);
    
    deltaVArray(1) = Results.stateArray(Results.stageChange(1),6);
    deltaVArray(2) = Results.stateArray(Results.stageChange(2),6) - ...
                          deltaVArray(1);
    deltaVArray(3) = Results.stateArray(end,6) - ...
                          Results.stateArray(Results.stageChange(3),6);
    deltaVTotal = Results.stateArray(end,6);
    
    fprintf("\n\nDeltaV generation:\n\n")
    fprintf("First stage:\t%.3f\tm/s\n", deltaVArray(1));
    fprintf("Second stage:\t%.3f\tm/s\n", deltaVArray(2));
    fprintf("Third stage:\t%.3f\tm/s\n", deltaVArray(3));
    fprintf("------------------------\n")
    fprintf("Total:\t\t%.3f\tm/s\n", deltaVTotal);    
    
    fprintf("Drag loss:\t%.3f\tm/s\n", Results.stateArray(end,7));
    fprintf("Gravity loss:\t%.3f\tm/s\n", Results.stateArray(end,8));
    fprintf("--------------------------\n")
    fprintf("Final:\t\t%.3f\tm/s\n\n", deltaVTotal+...
                                    Results.stateArray(end,7) + ...
                                    Results.stateArray(end,8));
end


function energy = get_specific_delta_energy(Results, Objective, index)

    energy = ((Results.stateArray(index,1).^2)/2 - ...
               Objective.mu/(Results.stateArray(index,4)+Objective.earthRadius)) +...
               Objective.mu/Objective.earthRadius;

end