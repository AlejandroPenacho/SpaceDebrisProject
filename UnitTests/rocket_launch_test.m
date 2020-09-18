% This script has the task of testing whether the function for obtaining
% the information of the rocket works. And testing the integration.
clc; clear

RocketData = extract_rocket_data("rocket1.txt");
ControlStruct = struct("initialConditions", 0);
ConstantStruct = struct("earthRadius", 6371000, ...
                        "earthSLGravity", 9.81);

Parameter(1:10) = struct("Rocket", RocketData, "Control", ControlStruct, "Constant", ConstantStruct);

for iRocket = 1:10
    Parameter(iRocket).Control.initialConditions = [0, ...
                                                    pi/2 - 0.005 + 0.005* iRocket/10, ...
                                                    0, ...
                                                    0, ...
                                                    RocketData.initialMass, ...
                                                    0, ...
                                                    0, ...
                                                    0];
end


for iRocket = 1:10
    Results(iRocket) = integrate_trajectory(Parameter(iRocket));
end


figure
subplot(1,3,1)
title("Trajectory")
hold on
for iRocket = 1:10
    plot(Results(iRocket).stateArray(:,3), Results(iRocket).stateArray(:,4))
    for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
        index = Results(iRocket).stageChange(i);
        scatter(Results(iRocket).stateArray(index,3), Results(iRocket).stateArray(index,4))
    end
end
hold off
xlabel("X (m)")
ylabel("Y (m)")
grid minor
daspect([1 1 1])

subplot(1,3,2)
title("Velocity profile")
hold on
for iRocket = 1:10
    plot(Results(iRocket).timeArray, Results(iRocket).stateArray(:,1))
    for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
        index = Results(iRocket).stageChange(i);
        scatter(Results(iRocket).timeArray(index), Results(iRocket).stateArray(index,1))
    end
end
hold off
xlabel("Time(s)")
ylabel("Speed (m/s)")
grid minor  

subplot(1,3,3)
title("Velocity-altitude profile")
hold on
for iRocket = 1:10
    plot(Results(iRocket).stateArray(:,1), Results(iRocket).stateArray(:,4)/1000)
    for i = 1:(Results(iRocket).Parameter.Rocket.nStages-1)
        index = Results(iRocket).stageChange(i);
        scatter(Results(iRocket).stateArray(index,1), Results(iRocket).stateArray(index,4)/1000)
    end
end
hold off
xlabel("Speed (m/s)")
ylabel("Altitude (km)")
grid minor  
ylim([0 300])
