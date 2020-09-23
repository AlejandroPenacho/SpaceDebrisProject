% This script has the task of testing whether the function for obtaining
% the information of the rocket works. And testing the integration.
clc; clear

RocketData = extract_rocket_data("rocket2.txt");
ControlStruct = struct("initialConditions", 0);
ConstantStruct = struct("earthRadius", 6371000, ...
                        "earthSLGravity", 9.81, ...
                        "mu", 3.986004418*10^14);
                    

nValuesGamma = 3;
nValuesPayload = 3;

gammaMeanValue = pi/2 - 0.048;
gammaDispersion = 0.003;

gammaArray = linspace(gammaMeanValue - gammaDispersion, gammaMeanValue + gammaDispersion, nValuesGamma);
payloadArray = linspace(0.1133, 0.14, nValuesPayload);                    

nRockets = nValuesGamma * nValuesPayload;

Parameter(1:nRockets) = struct("Rocket", RocketData, "Control", ControlStruct, "Constant", ConstantStruct);

Objective = extract_objective("rocketObjective.txt", Parameter(1));

for iRocket = 1:nRockets
    
    gammaIndex = mod(iRocket-1, nValuesGamma)+1;
    payloadIndex = ceil(iRocket/nValuesGamma);
    
    Parameter(iRocket).Control.initialConditions = [0, ...
                                                    gammaArray(gammaIndex), ...
                                                    0, ...
                                                    0, ...
                                                    RocketData.initialMass, ...
                                                    0, ...
                                                    0, ...
                                                    0];
    Parameter(iRocket).Rocket.Stage(2).payloadRatio = payloadArray(payloadIndex);
end


for iRocket = 1:nRockets
    Results(iRocket) = integrate_trajectory(Parameter(iRocket));
end


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
    plot(Results(iRocket).timeArray(:), energyArray/Objective.meanEnergy)
    for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
        index = Results(iRocket).stageChange(i);
        if index ~= 0
            scatter(Results(iRocket).timeArray(index,1), energyArray(index)/Objective.meanEnergy)
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
    plot(Results(iRocket).timeArray(:), hArray/Objective.meanH)
    for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
        index = Results(iRocket).stageChange(i);
        if index ~= 0
            scatter(Results(iRocket).timeArray(index,1), hArray(index)/Objective.meanH)
        end
    end
end
hold off
xlabel("Time (s)")
ylabel("Angular momentum")
grid minor  


[energyArray, minHarray, maxHarray] = get_deploy_region(Objective);
IDarray = cell(nRockets,1);

figure
title("Phase space diagram")
ylabel("Energy")
xlabel("\DeltaH")
hold on

plot_rocket_map("Gamma (rad)", gammaArray, "Payload", payloadArray, Results, Objective);

plot(minHarray, energyArray, "m")
plot(maxHarray, energyArray, "m")

hold off

grid on