% This script has the task of testing whether the function for obtaining
% the information of the rocket works. And testing the integration.


RocketData = extract_rocket_data("rocket1.txt");
ControlStruct = struct("initialConditions", 0);
ConstantStruct = struct("earthRadius", 6371000, ...
                        "earthSLGravity", 9.81);

Parameter(1:10) = struct("Rocket", RocketData, "Control", ControlStruct, "Constant", ConstantStruct);

for iRocket = 1:10
    Parameter(iRocket).Control.initialConditions = [0, pi/2 - 0.05 + 0.05* iRocket/10, 0, 0, RocketData.initialMass];
end


for iRocket = 1:10
    Results(iRocket) = integrate_trajectory(Parameter(iRocket));
end


figure
hold on
for iRocket = 1:10
    plot(Results(iRocket).stateArray(:,3), Results(iRocket).stateArray(:,4))
end
hold off
% daspect([1 1 1])
grid minor