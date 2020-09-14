% This script has the task of testing whether the function for obtaining
% the information of the rocket works. And testing the integration.


RocketData = extract_rocket_data("rocket1.txt");

Parameter = struct("Rocket", RocketData);

Parameter.Control.initialConditions = [0, 0, 0, 0, RocketData.initialMass];

Parameter.Constant.earthRadius = 6371000;
Parameter.Constant.earthSLGravity = 9.81;

Results = integrate_trajectory(Parameter);

