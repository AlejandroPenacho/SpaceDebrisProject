function stageStateArray = extend_state_info(stageStateArray, Parameter, iStage)
% This function takes the state array obtained from the integration of the
% rocket trajectory for the last stage, and adds three additional columns.
% These columns are:
%
%       - Vetical speed, in m/s, projection of the velocity of the rocket
%         in the vertical axis
%
%       - Horizontal speed, in m/s, obtained as the product of the angular
%         speed times the distance between Earth center and the rocket. Note
%         this speed is with respect to ground, that is, the system of
%         reference considers the Earth as non-rotating
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

    stageStateArray(:,9) = stageStateArray(:,1) .* sin(stageStateArray(:,2));

    stageStateArray(:,10) = stageStateArray(:,1) .* cos(stageStateArray(:,2));
    stageStateArray(:,11) = ones(nPoints, 1) * iStage;
end

