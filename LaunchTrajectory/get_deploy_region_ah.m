function [energyArray, minHarray, maxHarray] = get_deploy_region(Objective)
% From the objective file given, extracts the region of the phase space
% (altitude and velocity) at which the rocket should be when gamma = 0 to
% consider the mission succesful
    
    minRadius = Objective.minRadius;
    maxRadius = Objective.maxRadius;
    
    minEnergy = Objective.minEnergy;
    maxEnergy = Objective.maxEnergy;
    meanEnergy = Objective.meanEnergy;
    meanH = Objective.meanH;
    
    mu = Objective.mu;
    earthEnergy = Objective.earthEnergy;

    energyArray = linspace(minEnergy, maxEnergy, 1000);
    
    minHarray = zeros(1000,1);
    maxHarray = zeros(1000,1);
    
    for i=1:1000
        realEnergy = energyArray(i) + earthEnergy;
        a_0 = -mu/(2*realEnergy);
        circularH = sqrt(mu * a_0);
        
        e_1 = 1 - minRadius/a_0;
        e_2 = maxRadius/a_0 - 1;
        
        max_e = min(e_1, e_2);
        
        % min_e = 0;
        
        maxHarray(i) = 0;
        minHarray(i) = (sqrt(mu * a_0 * (1 - max_e^2)) - circularH) / meanH;
        
    end
    
    energyArray = energyArray/meanEnergy;

end

