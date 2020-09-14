function [derivativeMass] = get_fuel_consumption(thrust, Parameter, iStage)
% Computes the consumption of propellant of the rocket for a given state,
% stage and thrust of the rocket.
%
% INPUT:
%       -thrust: force exerted by the rocket, in newtons
%       -Parameter: the Parameter structure
%       -iStage: current stage of the rocket
%
% OUTPUT:
%       - derivativeMass: derivative of the mass with respect to time, in
%                         kg/s
%

    derivativeMass = -thrust/(Parameter.Constant.earthSLGravity * Parameter.Rocket.Stage(iStage).Isp);
end

