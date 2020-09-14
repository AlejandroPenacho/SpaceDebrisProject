function [localGravity] = get_local_gravity(altitude, Parameter)
% Computes the gravity at the altitude given.
%
% INPUT:
%       -altitude: altitude of the rocket with respect to sea level, in
%       meters
%       -Parameter: the Parameter structure
%
% OUTPUT:
%       - localGravity: local gravitational acceleration towards the Earth,
%                       in m/s^2
%

    localGravity = Parameter.Constant.earthSLGravity * ...
                   ((Parameter.Constant.earthRadius)/(Parameter.Constant.earthRadius + altitude))^2;
end

