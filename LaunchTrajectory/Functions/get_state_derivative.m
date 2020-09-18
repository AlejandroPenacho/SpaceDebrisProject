function [derivativeStateArray] = get_state_derivative(t, state, Data)
    % For a given state of the rocket, the function computes the derivative
    % of each of the variables of the state. This functions is expected to
    % be used inside ODE45
    %
    % INPUTS:
    %   - t: current time of the integration since launch, in seconds. It
    %        is usually not necessary, unless some control parameter depends on
    %        time
    %   - state: current state of the rocker, given as a vector with the
    %            following composition-
    %                > Absolute velocity of the rocket with respect to gound
    %                > Flight path angle, angle between the velocity vector
    %                   of the rocket and the local horizon, in radians
    %                > Horizontal distance between the rocket and the
    %                   launch site, in meters
    %                > Altitude of the rocket above SL, in meters
    %                > Total mass of the rocket, in kg
    %
    %
    %   - Data: cell with two elements, in which the first is the Parameter
    %           structure (more information in LaunchTrajectory/readme.txt)
    %           and the second is the current stage of the rocket.
    %
    % OUTPUT:
    %   - derivativeStateArray: derivative with respect to time of each of
    %                           the elements of the state array, always
    %                           taking time in seconds.


    % First, the Parameter structure and the current stage of the rocket is
    % extracted from Data. The radius of the Earth, for convenience, is
    % written in a variable.

    Parameter = Data{1};
    iStage = Data{2};
    rEarth = Parameter.Constant.earthRadius;

    % Each of the elements in the state array is extracted, so it is more
    % convenient to work with them

    velocity = state(1);
    gamma = state(2);
    x = state(3);
    h = state(4);
    mass = state(5);

    % Thrust and drag are obtained from other functions, and the angle
    % gamma is computed based on the trajectory of the rocket, as it is the
    % angle between the local horizon and the trajectory of the rocket.

    thrust = get_thrust(t, state, iStage, Parameter);
    drag = get_aerodynamic_drag(state, iStage, Parameter);

    % The local gravity is computed in a separated function
    localGravityAcceleration = get_local_gravity(h, Parameter);

    % The derivatives of the altitude and horizontal position are in the same state
    % vector, so calculation is straight-forward.
    derivativeX = velocity * cos(gamma);
    derivativeH = velocity * sin(gamma);

    % The radial and anglar accelerations come from dynamics. A better
    % explanation is pending.
    propulsionAcceleration = thrust / mass;
    dragAcceleration = -drag/mass;
    gravitationalAcceleration = -localGravityAcceleration * sin(gamma);
    
    derivativeVelocity = propulsionAcceleration + ...
                         dragAcceleration + ...
                         gravitationalAcceleration;
                 
    if h < 100
        derivativeGamma = 0;
    else
        derivativeGamma = -(velocity^(-1)) * (localGravityAcceleration - (velocity^2)/(earthRadius + h))*cos(gamma);
    end
    
    % The derivative of the mass is obtained with an external function
    derivativeMass = get_fuel_consumption(thrust, Parameter, iStage);


    derivativeStateArray = [derivativeVelocity; ...
                            derivativeGamma; ...
                            derivativeX; ...
                            derivativeH; ...
                            derivativeMass; ...
                            propulsionAcceleration;
                            dragAcceleration;
                            gravitationalAcceleration];

end

