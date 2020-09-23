function [altitudeArray, minVarray, maxVarray] = get_deploy_region()
% From the objective file given, extracts the region of the phase space
% (altitude and velocity) at which the rocket should be when gamma = 0 to
% consider the mission succesful
    mu = 3.986004418*10^14;
    rEarth = 6371000;
    minAltitude = 650000;
    maxAltitude = 850000;
    
    minRadius = minAltitude + rEarth;
    maxRadius = maxAltitude + rEarth;

    altitudeArray = linspace(minAltitude, maxAltitude, 1000);
    
    minVarray = zeros(1000,1);
    maxVarray = zeros(1000,1);
    
    for i=1:1000
        r_p = altitudeArray(i);
        r_a_min = minRadius;
        r_a_max = maxRadius;
        minVarray(i) = fsolve( @(v_p) ((v_p^2)/2 - mu/r_p - ((v_p^2)*(r_p^2))/(2*r_a_min^2) + mu/r_a_min), 3000);
        maxVarray(i) = fsolve( @(v_p) ((v_p^2)/2 - mu/r_p - ((v_p^2)*(r_p^2))/(2*r_a_max^2) + mu/r_a_max), 3000);

    end
    


end

