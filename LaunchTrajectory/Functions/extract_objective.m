function [Objective] = extract_objective(file, Parameter)
%EXTRACT_OBJECTIVE Summary of this function goes here
%   Detailed explanation goes here
    fID = fopen(file);
    fgetl(fID);
    Objective.perigee = str2double(fgetl(fID)) + Parameter.Constant.earthRadius;
    fgetl(fID);
    fgetl(fID);
    Objective.apogee = str2double(fgetl(fID)) + Parameter.Constant.earthRadius;
    fgetl(fID);
    fgetl(fID);
    Objective.error = str2double(fgetl(fID))/100;
    fclose(fID);
    
    Objective.energy = Parameter.Constant.mu * (1/Parameter.Constant.earthRadius - ...
                       1/(Objective.perigee+Objective.apogee));
                   
     
    a = Objective.apogee + Objective.perigee;
    e = (Objective.apogee + Objective.perigee)/(2*a);
    Objective.h = sqrt(Parameter.Constant.mu * a * (1-e^2));
    Objective.mu = Parameter.Constant.mu;
    Objective.earthRadius = Parameter.Constant.earthRadius;
    
end

