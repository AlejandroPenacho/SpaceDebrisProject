function [altitudeArray, minVarray, maxVarray, circularVarray] = get_deploy_region()
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
    circularVarray = zeros(1000,1);
    
     options = optimset('Display','off');
    
    for i=1:1000
        r_0 = altitudeArray(i) + rEarth;
        r_f_min = minRadius;
        r_f_max = maxRadius;
        minVarray(i) = fsolve( @(v_0) ((v_0^2)/2 - mu/r_0 - ((v_0^2)*(r_0^2))/(2*r_f_min^2) + mu/r_f_min), 5000, options);
        maxVarray(i) = fsolve( @(v_0) ((v_0^2)/2 - mu/r_0 - ((v_0^2)*(r_0^2))/(2*r_f_max^2) + mu/r_f_max), 5000, options);
        circularVarray(i) = sqrt(mu/r_0);
        
        if i == 1
            minVarray(i) = circularVarray(i);
        elseif i == 1000
            maxVarray(i) = circularVarray(i);
        end
    end
    


end

