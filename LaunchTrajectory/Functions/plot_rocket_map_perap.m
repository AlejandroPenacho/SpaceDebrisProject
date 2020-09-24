function [] = plot_rocket_map(xName, xArray, yName, yArray, Results, Objective)
%PLOT_ROCKET_MAP Summary of this function goes here
%   Detailed explanation goes here
    rEarth = Objective.earthRadius;
    mu = Objective.mu;
    earthEnergy = Objective.earthEnergy;
    
    meanEnergy = Objective.meanEnergy;
    meanH = Objective.meanH;

    nXValues = size(xArray);
    nXValues = nXValues(2);
    
    nYValues = size(yArray);
    nYValues = nYValues(2);
    
    xMesh = ones(nXValues, nYValues);
    xMesh = xMesh .* xArray';
 
    yMesh = ones(nXValues, nYValues);
    yMesh = yMesh .* yArray;
    
    perMesh = zeros(nXValues, nYValues);
    apMesh = zeros(nXValues, nYValues);
    
    for iRocket = 1:(nXValues*nYValues)
        xIndex = mod(iRocket-1, nXValues)+1;
        yIndex = ceil(iRocket/nXValues);
        
        orbitalRadius = rEarth + Results(iRocket).stateArray(end,4);
        orbitalSpeed = Results(iRocket).stateArray(end, 1);
        gamma = Results(iRocket).stateArray(end, 2);
        
        energy = ((orbitalSpeed^2)/2 - mu/orbitalRadius);
        h = orbitalSpeed * cos(gamma) * orbitalRadius;
        
        a = -mu/(2*energy);
        e = sqrt(1 - h^2/(mu * a));
        
        perMesh(xIndex, yIndex) = (a * (1-e) - Objective.earthRadius) / 1000;
                                  
        apMesh(xIndex, yIndex) = (a * (1+e) - Objective.earthRadius)/ 1000;
    end
    
    for xIndex=1:nXValues
        for yIndex=1:nYValues
            scatter(perMesh(xIndex, yIndex), apMesh(xIndex,yIndex), 7, "filled")
            
            if xIndex ~= nXValues
                plot( [perMesh(xIndex, yIndex), perMesh(xIndex+1, yIndex)], ...
                      [apMesh(xIndex,yIndex), apMesh(xIndex+1,yIndex)], "k");
            end
            if yIndex ~= nYValues
                plot( [perMesh(xIndex, yIndex), perMesh(xIndex, yIndex+1)], ...
                      [apMesh(xIndex,yIndex), apMesh(xIndex,yIndex+1)], "k");
            end            
        end
    end
    
    
    
    
    
    for xIndex = 1:nXValues
        text(perMesh(xIndex, end)+0.0005, apMesh(xIndex,end)-0.001, num2str(xArray(xIndex)))
    end
    text(mean(perMesh(:,end)), mean(apMesh(:,end))-0.06, xName);
    
    for yIndex = 1:nYValues
        text(perMesh(1,yIndex)+0.001, apMesh(1,yIndex)+0.01, num2str(yArray(yIndex)))
    end   
    text(mean(perMesh(1,:))+0.0015, mean(apMesh(1,:)+0.05), yName);
    
end

