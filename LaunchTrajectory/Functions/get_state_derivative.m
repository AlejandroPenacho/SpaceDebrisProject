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
    %                > Altitude of the rocket above SL
    %                > Angle between the vector pointing from the center of
    %                   the Earth to the launch site, and from the center
    %                   of the Earth to the rocket, in radians
    %                > Derivative of altitude with time, that is, vetical
    %                   speed, in meters per second
    %                > Derivative of the angle of the seconda element with
    %                   respect to time, in radians per second
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
    
    h = state(1);
    theta = state(2);
    hDot = state(3);
    thetaDot = state(4);
    mass = state(5);

    % Thrust and drag are obtained from other functions, and the angle
    % gamma is computed based on the trajectory of the rocket, as it is the
    % angle between the local horizon and the trajectory of the rocket.
    
    thrust = get_thrust(t, state, iStage, Parameter);
    drag = compute_drag(state, iStage, Parameter);
    gamma = atan2(hDot, (rEarth + h)*thetaDot);
    
    % At first, the speed of the rocket is zero, but it is pointing
    % upwards, so this angle must be specified.
    
    if hDot == 0 && thetaDot==0
        gamma = pi/2;
    end

    % The local gravity is computed in a separated function
    localGravityAcceleration = get_local_gravity(h, Parameter);

    % The derivative of the altitude and theta are in the same state
    % vector, so calculation is straight-forward.
    derivativeH = hDot;
    derivativeTheta = thetaDot;
    
    % The radial and anglar accelerations come from dynamics. A better
    % explanation is pending.
    derivativeHDot = ((thrust - drag)*sin(gamma))/mass + ...
                     (rEarth + h) * thetaDot^2 - localGravityAcceleration;
    derivativeThetaDot = ((thrust - drag)*cos(gamma)/mass - 2*hDot*thetaDot) / (rEarth + h);
    
    % The derivative of the mass is obtained with an external function
    derivativeMass = get_fuel_consumption(thrust, Parameter, iStage);


    derivativeStateArray = [derivativeH; derivativeTheta; derivativeHDot; derivativeThetaDot; derivativeMass];

end

