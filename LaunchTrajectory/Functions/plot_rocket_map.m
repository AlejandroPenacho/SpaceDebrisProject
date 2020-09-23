function [outputArg1,outputArg2] = plot_rocket_map(xName, xArray, yName, yArray, Results)
%PLOT_ROCKET_MAP Summary of this function goes here
%   Detailed explanation goes here
    nXValues = size(xArray);
    nXValues = nXValues(2);
    
    nYValues = size(yArray);
    nYValues = nYValues(2);
    
    xMesh = ones(nXValues, nYValues);
    xMesh = xMesh .* xArray';
 
    yMesh = ones(nXValues, nYValues);
    yMesh = yMesh .* yArray;
    
    altitudeMesh = zeros(nXValues, nYValues);
    speedMesh = zeros(nXValues, nYValues);
    
    for iRocket = 1:(nXValues*nYValues)
        xIndex = mod(iRocket-1, nXValues)+1;
        yIndex = ceil(iRocket/nXValues);
        
        altitudeMesh(xIndex, yIndex) = Results(iRocket).stateArray(end,4)/1000;
        speedMesh(xIndex, yIndex) = Results(iRocket).stateArray(end,1)/1000;
    end
    
    for xIndex=1:nXValues
        for yIndex=1:nYValues
            scatter(speedMesh(xIndex, yIndex), altitudeMesh(xIndex,yIndex), 7, "filled")
            
            if xIndex ~= nXValues
                plot( [speedMesh(xIndex, yIndex), speedMesh(xIndex+1, yIndex)], ...
                      [altitudeMesh(xIndex,yIndex), altitudeMesh(xIndex+1,yIndex)], "k");
            end
            if yIndex ~= nYValues
                plot( [speedMesh(xIndex, yIndex), speedMesh(xIndex, yIndex+1)], ...
                      [altitudeMesh(xIndex,yIndex), altitudeMesh(xIndex,yIndex+1)], "k");
            end            
        end
    end
    
    
    
    
    
    for xIndex = 1:nXValues
        text(speedMesh(xIndex, end)-0.12, altitudeMesh(xIndex,end), num2str(xArray(xIndex)))
    end
    text(mean(speedMesh(:,end))-0.3, mean(altitudeMesh(:,end)), xName);
    
    for yIndex = 1:nYValues
        text(speedMesh(1,yIndex), altitudeMesh(1,yIndex)-17, num2str(yArray(yIndex)))
    end   
    text(mean(speedMesh(1,:)), mean(altitudeMesh(1,:)-35), yName);
    
end

