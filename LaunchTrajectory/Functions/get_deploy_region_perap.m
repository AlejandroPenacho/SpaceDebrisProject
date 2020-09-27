function [perigeeArray, minApArray, maxApArray] = get_deploy_region_perap(Objective)
% From the objective file given, extracts the region of the phase space
% (altitude and velocity) at which the rocket should be when gamma = 0 to
% consider the mission succesful
    
    minRadius = Objective.minRadius;
    maxRadius = Objective.maxRadius;
    
    perigeeArray = [minRadius, maxRadius];
    
    minApArray = [minRadius, minRadius];
    maxApArray = [maxRadius, maxRadius];

end

