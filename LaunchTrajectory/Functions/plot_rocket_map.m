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
    
    energyMesh = zeros(nXValues, nYValues);
    hMesh = zeros(nXValues, nYValues);
    
    for iRocket = 1:(nXValues*nYValues)
        xIndex = mod(iRocket-1, nXValues)+1;
        yIndex = ceil(iRocket/nXValues);
        
        orbitalRadius = rEarth + Results(iRocket).stateArray(end,4);
        orbitalSpeed = Results(iRocket).stateArray(end, 1);
        gamma = Results(iRocket).stateArray(end, 2);
        
        energy = ((orbitalSpeed^2)/2 - mu/orbitalRadius);
        
        energyMesh(xIndex, yIndex) = (energy - earthEnergy)/meanEnergy;
        
                                  
        circularH = mu / sqrt(-2*energy);
                                  
        hMesh(xIndex, yIndex) = (orbitalSpeed * ...
                                cos(gamma) * ...
                                orbitalRadius - circularH)/meanH;
    end
    
    for xIndex=1:nXValues
        for yIndex=1:nYValues
            scatter(hMesh(xIndex, yIndex), energyMesh(xIndex,yIndex), 7, "filled")
            
            if xIndex ~= nXValues
                plot( [hMesh(xIndex, yIndex), hMesh(xIndex+1, yIndex)], ...
                      [energyMesh(xIndex,yIndex), energyMesh(xIndex+1,yIndex)], "k");
            end
            if yIndex ~= nYValues
                plot( [hMesh(xIndex, yIndex), hMesh(xIndex, yIndex+1)], ...
                      [energyMesh(xIndex,yIndex), energyMesh(xIndex,yIndex+1)], "k");
            end            
        end
    end
    
    
    
    
    
    for xIndex = 1:nXValues
        text(hMesh(xIndex, end)+0.0005, energyMesh(xIndex,end)-0.001, num2str(xArray(xIndex)))
    end
    text(mean(hMesh(:,end)), mean(energyMesh(:,end))-0.06, xName);
    
    for yIndex = 1:nYValues
        text(hMesh(1,yIndex)+0.001, energyMesh(1,yIndex)+0.01, num2str(yArray(yIndex)))
    end   
    text(mean(hMesh(1,:))+0.0015, mean(energyMesh(1,:)+0.05), yName);
    
end

