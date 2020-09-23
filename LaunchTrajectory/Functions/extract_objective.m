function [Objective] = extract_objective(file, Parameter)
%EXTRACT_OBJECTIVE Summary of this function goes here
%   Detailed explanation goes here
    fID = fopen(file);
    fgetl(fID);
    Objective.minRadius = str2double(fgetl(fID)) + Parameter.Constant.earthRadius;
    fgetl(fID);
    fgetl(fID);
    Objective.maxRadius = str2double(fgetl(fID)) + Parameter.Constant.earthRadius;
    
    Objective.meanRadius = (Objective.minRadius + Objective.maxRadius)/2;
    
    Objective.earthEnergy = -Parameter.Constant.mu/Parameter.Constant.earthRadius;
    
    Objective.mu = Parameter.Constant.mu;
    Objective.earthRadius = Parameter.Constant.earthRadius;
    
    Objective.minEnergy = -Parameter.Constant.mu/(2* Objective.minRadius) ...
                           - Objective.earthEnergy;
    Objective.maxEnergy = -Parameter.Constant.mu/(2* Objective.maxRadius) ...
                           - Objective.earthEnergy;
    Objective.meanEnergy = -Parameter.Constant.mu/(2* Objective.meanRadius) ...
                           - Objective.earthEnergy;
                       
    Objective.meanH = sqrt(Objective.mu * Objective.meanRadius);
    fclose(fID);
    
end

