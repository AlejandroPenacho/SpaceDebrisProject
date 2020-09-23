function [outputArg1,outputArg2] = plot_rocket_map(xName, xArray, yName, yArray, Results)
%PLOT_ROCKET_MAP Summary of this function goes here
%   Detailed explanation goes here
    rEarth = 6371000;
    mu = 3.986004418*10^14;

    nXValues = size(xArray);
    nXValues = nXValues(2);
    
    nYValues = size(yArray);
    nYValues = nYValues(2);
    
    xMesh = ones(nXValues, nYValues);
    xMesh = xMesh .* xArray';
 
    yMesh = ones(nXValues, nYValues);
    yMesh = yMesh .* yArray;
    
    aMesh = zeros(nXValues, nYValues);
    hMesh = zeros(nXValues, nYValues);
    
    for iRocket = 1:(nXValues*nYValues)
        xIndex = mod(iRocket-1, nXValues)+1;
        yIndex = ceil(iRocket/nXValues);
        
        orbitalRadius = rEarth + Results(iRocket).stateArray(end,4);
        orbitalSpeed = Results(iRocket).stateArray(end, 1);
        gamma = Results(iRocket).stateArray(end, 2);
        
        aMesh(xIndex, yIndex) = (mu * orbitalRadius)/...
                                (orbitalSpeed^2 * orbitalRadius + 2*mu);
        hMesh(xIndex, yIndex) = orbitalSpeed * ...
                                cos(gamma) * ...
                                orbitalRadius;
    end
    
    for xIndex=1:nXValues
        for yIndex=1:nYValues
            scatter(hMesh(xIndex, yIndex), aMesh(xIndex,yIndex), 7, "filled")
            
            if xIndex ~= nXValues
                plot( [hMesh(xIndex, yIndex), hMesh(xIndex+1, yIndex)], ...
                      [aMesh(xIndex,yIndex), aMesh(xIndex+1,yIndex)], "k");
            end
            if yIndex ~= nYValues
                plot( [hMesh(xIndex, yIndex), hMesh(xIndex, yIndex+1)], ...
                      [aMesh(xIndex,yIndex), aMesh(xIndex,yIndex+1)], "k");
            end            
        end
    end
    
    
    
    
    
    for xIndex = 1:nXValues
        text(hMesh(xIndex, end)-0.12, aMesh(xIndex,end), num2str(xArray(xIndex)))
    end
    text(mean(hMesh(:,end))-0.3, mean(aMesh(:,end)), xName);
    
    for yIndex = 1:nYValues
        text(hMesh(1,yIndex), aMesh(1,yIndex)-17, num2str(yArray(yIndex)))
    end   
    text(mean(hMesh(1,:)), mean(aMesh(1,:)-35), yName);
    
end

