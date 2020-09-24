function RocketData = change_propellant_mass(RocketData, massRatio);
%CHANGE_PROPELLANT_MASS Summary of this function goes here
%   Detailed explanation goes here

    stage = RocketData.Stage(1);

    initialPropellant = stage.initialMass * ...
                        (1 - stage.payloadRatio) * ...
                        (1 - stage.structuralRatio);
    
    initialStructuralMass = stage.initialMass * ...
                           (1 - stage.payloadRatio) * ...  
                           stage.structuralRatio;
                       
    initialPayloadRatio = stage.initialMass * ...
                          stage.payloadRatio;
                    
    newInitialPropellant = initialPropellant * massRatio;
    
    newInitialMass = newInitialPropellant + ...
                     initialPayloadRatio + ...
                     initialStructuralMass;
    
    RocketData.Stage(1).initialMass = newInitialMass;
    RocketData.Stage(1).payloadRatio = initialPayloadRatio/newInitialMass;
    RocketData.Stage(1).structuralRatio = initialStructuralMass / ...
                                           (newInitialPropellant + initialStructuralMass);
    
    RocketData.initialMass = newInitialMass;
    
end

