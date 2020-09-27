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

    mechanicalPower = thrust * 9.81 * Parameter.Rocket.Stage(iStage).Isp;

    derivativeStateArray = [derivativeVelocity; ...
                            derivativeGamma; ...
                            derivativeX; ...
                            derivativeH; ...
                            derivativeMass; ...
                            % mechanicalPower; ...
                            propulsionAcceleration; ...
                            dragAcceleration; ...
                            gravitationalAcceleration];

end



%% Compute thrust and fuel consumption


function [T] = get_thrust(t, stateArray, iStage, Parameter)
    %For a given time, state and parameters of the problem, provides the thrust
    %of the rocket
    
    if stateArray(2) < Parameter.Control.maxGammaThrust(iStage)
        T = Parameter.Rocket.Stage(iStage).maxThrust;
    else
        T = 0;
    end
end


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



%% Get gravity

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



%% Get aerodynamic drag


function [D] = get_aerodynamic_drag(stateArray, iStage, Parameter)
%Computes the drag force acting on the rocket for a given state.
%   Uses the height of the rocket
    gamma=1.4;
    speedOfSound= sqrt(gamma*get_R(stateArray(4))*get_temperature(stateArray(4)));
    
    rho = get_density(stateArray(4));

    velocity = stateArray(1);
    mach = velocity/speedOfSound;
    
    if Parameter.Rocket.Stage(iStage).C_D.type == "constant"
        C_D = Parameter.Rocket.Stage(iStage).C_D.value;
    else
        C_D = interp1(Parameter.Rocket.Stage(iStage).C_D.mach, ...
                      Parameter.Rocket.Stage(iStage).C_D.value, ...
                      mach, ...
                      "linear", ...
                      "extrap");
    end

    D = 0.5*C_D*Parameter.Rocket.Stage(iStage).surface*rho*velocity^2;
end

function R=get_R(h)
    k=10^3;
    Rm=8314.5;
    if 0<=h && h<=150*k
        M=29;
    elseif 150*k<h && h<=200*k
        M=24.1;
    elseif 200*k<h && h<=250*k
        M=21.3;
    elseif 250*k<h && h<=300*k
        M=19.2;
    elseif 300*k<h && h<=350*k
        M=17.7;
    elseif 350*k<h && h<=400*k
        M=16;
    elseif 400*k<h && h<=450*k
        M=15.3;
    elseif 450*k<h && h<=500*k
        M=14.3;
    elseif 500*k<h && h<=550*k
        M=13.1;
    elseif 550*k<h && h<=600*k
        M=11.5;
    elseif 600*k<h && h<=650*k
        M=9.72;
    elseif 650*k<h && h<=700*k
        M=8;
    elseif 700*k<h && h<=750*k
        M=6.58;
    elseif 750*k<h && h<=800*k
        M=5.54;
    elseif 800*k<h && h<=850*k
        M=4.85;
    elseif 850*k<h && h<=900*k
        M=4.4;
    elseif 950*k<h && h<=1000*k
        M=4.12;
    else 
        M=3.94;
    end 
    R=Rm/M;
end 


function rho=get_density(h)
    if 0<=h && h<=150*10^3
        h0=8.4345*10^3;
        rho0=1.225;
        rho=rho0*exp(-h/h0);
    elseif 150*10^3<h && h<=200*10^3
        h0=23.380*10^3;
        rho0=2.076*10^-9;
        rho=rho0*exp(-h/h0);
    elseif 200*10^3<h && h<=250*10^3
        h0=36.183*10^3;
        rho0=2.541*10^-10;
        rho=rho0*exp(-h/h0);
    elseif 250*10^3<h && h<=300*10^3
        h0=44.924*10^3;
        rho0=6.073*10^-11;
        rho=rho0*exp(-h/h0);
    elseif 300*10^3<h && h<=350*10^3
        h0=51.193*10^3;
        rho0=1.916*10^-11;
        rho=rho0*exp(-h/h0);
    elseif 350*10^3<h && h<=400*10^3
        h0=55.832*10^3;
        rho0=7.014*10^-12;
        rho=rho0*exp(-h/h0);
    elseif 400*10^3<h && h<=450*10^3
        h0=59.678*10^3;
        rho0=2.803*10^-12;
        rho=rho0*exp(-h/h0);
    elseif 450*10^3<h && h<=500*10^3
        h0=63.644*10^3;
        rho0=1.184*10^-12;
        rho=rho0*exp(-h/h0);
    elseif 500*10^3<h && h<=550*10^3
        h0=68.785*10^3;
        rho0=5.215*10^-13;
        rho=rho0*exp(-h/h0); 
    elseif 550*10^3<h && h<=600*10^3
        h0=76.427*10^3;
        rho0=2.384*10^-13;
        rho=rho0*exp(-h/h0);
    elseif 600*10^3<h && h<=650*10^3
        h0=88.244*10^3;
        rho0=1.137*10^-13;
        rho=rho0*exp(-h/h0);
    elseif 650*10^3<h && h<=700*10^3
        h0=105.992*10^3;
        rho0=5.7212*10^-14;
        rho=rho0*exp(-h/h0);
    elseif 700*10^3<h && h<=750*10^3
        h0=130.630*10^3;
        rho0=3.070*10^-14;
        rho=rho0*exp(-h/h0);
    elseif 750*10^3<h && h<=800*10^3
        h0=161.074*10^3;
        rho0=1.788*10^-14;
        rho=rho0*exp(-h/h0);
    elseif 800*10^3<h && h<=850*10^3
        h0=193.862*10^3;
        rho0=1.136*10^-14;
        rho=rho0*exp(-h/h0);
    elseif 850*10^3<h && h<=900*10^3
        h0=224.737*10^3;
        rho0=7.824*10^-15;
        rho=rho0*exp(-h/h0);
    elseif 900*10^3<h && h<=950*10^3
        h0=250.894*10^3;
        rho0=5.579*10^-15;
        rho=rho0*exp(-h/h0);
    elseif 950*10^3<h && h<=1000*10^3
        h0=271.754*10^3;
        rho0=4.453*10^-15;
        rho=rho0*exp(-h/h0);
    else 
        h0=288.203*10^3;
        rho0=3.561*10^-15;
        rho=rho0*exp(-h/h0);

    end 
end 


function T=get_temperature(x)

    k=10^3;
    m=10^-3;
    if x>=0 && x<=(11*k)
        a1=-6.5*m;
        T=a1.*(x)+288.16;
    elseif x>11*k && x<=25*k
        T=216.66;
    elseif 25*k<x && x<=47*k
        a2=3*m;
        T=a2.*(x-25*k)+216.66;
    elseif 47*k<x && x<=53*k
        T=282.66;
    elseif 53*k<x && x<=79*k
        a3=-4.5*m;
        T=a3.*(x-53*k)+282.66;
    elseif 79*k<x &&x <=90*k
        T=165.66;
    elseif 90*k<x && x<=100*k
        a4=4*m;
        T=a4.*(x-90*k)+165.66;
    elseif 100*k<x && x<=130*k
        a5=0.03;
        T=a5*(x-100*k)+205.7;
    else 
        T=(1500+273.15);

    end 
end 
