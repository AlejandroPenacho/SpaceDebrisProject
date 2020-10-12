function [] = plot_results(Results, Objective, gammaArray, propellantArray)
%PLOT_RESULTS Summary of this function goes here
%   Detailed explanation goes here

    nRockets = length(Results);

    figure
    subplot(2,3,1)
    title("Trajectory")
    hold on
    for iRocket = 1:nRockets
        plot(Results(iRocket).stateArray(:,3)/1000, Results(iRocket).stateArray(:,4)/1000)
        for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
            index = Results(iRocket).stageChange(i);
            if index ~= 0
                scatter(Results(iRocket).stateArray(index,3)/1000, Results(iRocket).stateArray(index,4)/1000)
            end
        end
    end
    hold off
    xlabel("X (km)")
    ylabel("Y (km)")
    grid minor
    % daspect([1 1 1])

    subplot(2,3,2)
    title("Velocity profile")
    hold on
    for iRocket = 1:nRockets
        plot(Results(iRocket).timeArray, Results(iRocket).stateArray(:,1))
        for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
            index = Results(iRocket).stageChange(i);
            if index ~= 0
                scatter(Results(iRocket).timeArray(index), Results(iRocket).stateArray(index,1))
            end
        end
    end
    hold off
    xlabel("Time(s)")
    ylabel("Speed (m/s)")
    grid minor  

    subplot(2,3,3)
    title("Velocity-altitude profile")
    hold on
    for iRocket = 1:nRockets
        plot(Results(iRocket).stateArray(:,1), Results(iRocket).stateArray(:,4)/1000)
        for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
            index = Results(iRocket).stageChange(i);
            if index ~= 0
                scatter(Results(iRocket).stateArray(index,1), Results(iRocket).stateArray(index,4)/1000)
            end
        end
    end
    hold off
    xlabel("Speed (m/s)")
    ylabel("Altitude (km)")
    grid minor  
    ylim([0 300])
    %         if stageStateArray(end,2) <= 0
    %             break
    %         end

    subplot(2,3,4)
    title("Altitude profile")
    hold on
    for iRocket = 1:nRockets
        plot(Results(iRocket).timeArray(:), Results(iRocket).stateArray(:,4)/1000)
        for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
            index = Results(iRocket).stageChange(i);
            if index ~= 0
                scatter(Results(iRocket).timeArray(index,1), Results(iRocket).stateArray(index,4)/1000)
            end
        end
    end
    hold off
    xlabel("Time (s)")
    ylabel("Altitude (km)")
    grid minor  
    ylim([0 300])


    subplot(2,3,5)
    title("Energy profile")
    hold on
    for iRocket = 1:nRockets
        energyArray = (Results(iRocket).stateArray(:,1).^2)/2 - ...
                      Objective.mu./(Results(iRocket).stateArray(:,4) + Objective.earthRadius) + ...
                      Objective.mu./Objective.earthRadius;
        plot(Results(iRocket).timeArray(:), energyArray/Objective.energy)
        for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
            index = Results(iRocket).stageChange(i);
            if index ~= 0
                scatter(Results(iRocket).timeArray(index,1), energyArray(index)/Objective.energy)
            end
        end
    end
    hold off
    xlabel("Time (s)")
    ylabel("Energy")
    grid minor  


    subplot(2,3,6)
    title("Angular momentum profile")
    hold on
    for iRocket = 1:nRockets
        hArray = Results(iRocket).stateArray(:,1) .* ...
                 cos(Results(iRocket).stateArray(:,2)) .* ...
                 (Results(iRocket).stateArray(:,4) + Objective.earthRadius);
        plot(Results(iRocket).timeArray(:), hArray/Objective.h)
        for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
            index = Results(iRocket).stageChange(i);
            if index ~= 0
                scatter(Results(iRocket).timeArray(index,1), hArray(index)/Objective.h)
            end
        end
    end
    hold off
    xlabel("Time (s)")
    ylabel("Angular momentum")
    grid minor  

    IDarray = cell(nRockets,1);

    %% Plot in the perigee-apogee region

    [perigeeArray, minApArray, maxApArray] = get_deploy_region_perap(Objective);

    figure
    title("Phase space diagram")
    ylabel("Apogee (km)")
    xlabel("Perigee (km)")
    hold on

    plot_rocket_map_perap("Gamma (rad)", gammaArray, "Propellant", propellantArray, Results, Objective);

    plot(perigeeArray/1000 - Objective.earthRadius/1000, ...
         minApArray/1000 - Objective.earthRadius/1000, "m")
    plot([perigeeArray(1),perigeeArray, perigeeArray(2)]/1000 - Objective.earthRadius/1000, ...
         [minApArray(1), maxApArray, minApArray(1)]/1000 - Objective.earthRadius/1000, "m")

    hold off
    
    
    %% USEFUL PLOTS
    
    colorArray = {  [1, 0, 0], ...
                    [0.8500, 0.3250, 0.0980], ...
                    [0.4660, 0.6740, 0.1880], ...
                    [0.9290, 0.6940, 0.1250]};
                
    figure
    title("Rocket trajectory")
    xlabel("X (km)")
    ylabel("Altitude (km)")
    hold on
    for i=1:4
        if i==1
            initialIndex = 1;
            finalIndex = Results.stageChange(1);
        elseif i==4
            initialIndex = Results.stageChange(3);
            finalIndex = length(Results.timeArray);
        else
            initialIndex = Results.stageChange(i-1);
            finalIndex = Results.stageChange(i);            
        end
        plot(Results.stateArray(initialIndex:finalIndex,3)/1000, ...
             Results.stateArray(initialIndex:finalIndex,4)/1000, ...
             "color", colorArray{i}, ...
             "LineWidth", 5)
    end
    hold off
    grid minor
    legend("First stage", "Second stage", "No thrust", "Third stage", ...
           "location", "southeast")
    set(gca, "fontsize", 12)
    
    
        figure
    title("Velocity-altitude")
    xlabel("Velocity (km/s)")
    ylabel("Altitude (km)")
    hold on
    for i=1:4
        if i==1
            initialIndex = 1;
            finalIndex = Results.stageChange(1);
        elseif i==4
            initialIndex = Results.stageChange(3);
            finalIndex = length(Results.timeArray);
        else
            initialIndex = Results.stageChange(i-1);
            finalIndex = Results.stageChange(i);            
        end
        plot(Results.stateArray(initialIndex:finalIndex,1)/1000, ...
             Results.stateArray(initialIndex:finalIndex,4)/1000, ...
             "color", colorArray{i}, ...
             "LineWidth", 5)
    end
    hold off
    grid minor
    legend("First stage", "Second stage", "No thrust", "Third stage", ...
           "location", "northwest")
    set(gca, "fontsize", 12)
end


function [] = plot_rocket_map_perap(xName, xArray, yName, yArray, Results, Objective)
%PLOT_ROCKET_MAP Summary of this function goes here
%   Detailed explanation goes here
    rEarth = Objective.earthRadius;
    mu = Objective.mu;

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
        
        orbitalRadius = Objective.earthRadius + Results(iRocket).stateArray(end,4);
        orbitalSpeed = Results(iRocket).stateArray(end, 1);
        gamma = Results(iRocket).stateArray(end, 2);
        
        gamma = 0;
        
        energy = ((orbitalSpeed^2)/2 - Objective.mu/orbitalRadius);
        h = orbitalSpeed * cos(gamma) * orbitalRadius;
        
        a = -Objective.mu/(2*energy);
        e = sqrt(1 - h^2/(Objective.mu * a));
        
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
    
    
    
    
    
%     for xIndex = 1:nXValues
%         text(perMesh(xIndex, end)+0.0005, apMesh(xIndex,end)-0.001, num2str(xArray(xIndex)))
%     end
%     text(mean(perMesh(:,end)), mean(apMesh(:,end))-0.06, xName);
%     
%     for yIndex = 1:nYValues
%         text(perMesh(1,yIndex)+0.001, apMesh(1,yIndex)+0.01, num2str(yArray(yIndex)))
%     end   
%     text(mean(perMesh(1,:))+0.0015, mean(apMesh(1,:)+0.05), yName);
    
end


function [perigeeArray, minApArray, maxApArray] = get_deploy_region_perap(Objective)
% From the objective file given, extracts the region of the phase space
% (altitude and velocity) at which the rocket should be when gamma = 0 to
% consider the mission succesful
    
    
    perigeeArray = Objective.perigee * (1 + Objective.error*[-1,1]);
    
    minApArray = Objective.apogee * (1 - Objective.error) * [1, 1];
    maxApArray = Objective.apogee * (1 + Objective.error) * [1, 1];

end

