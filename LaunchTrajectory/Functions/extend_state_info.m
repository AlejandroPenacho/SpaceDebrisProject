function stageStateArray = extend_state_info(stageStateArray, Parameter, iStage)
% This function takes the state array obtained from the integration of the
% rocket trajectory for the last stage, and adds three additional columns.
% These columns are:
%       - Horizontal speed, in m/s, obtained as the product of the angular
%       speed times the distance between Earth center and the rocket. Note
%       this speed is with respect to ground, that is, the system of
%       reference considers the Earth as non-rotating
%
%       - Gamma angle, that is the angle between the rocket trajectory and
%       the local horizon, in radians
%
%       - Current stage of the rocket
%
% INPUT:
%       -stageStateArray: state array obtained from ode45
%       -Parameter: the Parameter structure
%       -iStage: the current stage of the rocket
%
% OUTPUT:
%
%       -stageStateArray: same as the input, but with the additional
%       columns
%

    [nPoints,~] = size(stageStateArray);

    stageStateArray(:,6) = (stageStateArray(1)+Parameter.Constant.earthRadius) ...
                          * stageStateArray(4);

    stageStateArray(:,7) = atan2(stageStateArray(:,3), stageStateArray(:,3));
    stageStateArray(:,8) = ones(nPoints, 1) * iStage;
end

