function [aArray, minEarray, maxEarray] = get_deploy_region()
% From the objective file given, extracts the region of the phase space
% (altitude and velocity) at which the rocket should be when gamma = 0 to
% consider the mission succesful
    mu = 3.986004418*10^14;
    rEarth = 6371000;
    minAltitude = 650000;
    maxAltitude = 850000;
    
    minRadius = minAltitude + rEarth;
    maxRadius = maxAltitude + rEarth;

    aArray = linspace(minRadius, maxRadius, 1000);
    
    minEarray = zeros(1000,1);
    maxEarray = zeros(1000,1);
    
    for i=1:1000
        a_0 = aArray(i);
        
        e_1 = 1 - minRadius/a_0;
        e_2 = maxRadius/a_0 - 1;
        
        max_e = min(e_1, e_2);
        
        % min_e = 0;
        
        maxEarray(i) = max_e;
        minEarray(i) = 0;
        
    end
    


end

