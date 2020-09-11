function [derivativeStateArray] = get_state_derivative(t, state, Parameter)
%
% State vector = [h,theta, hDot, thetaDot, mass]

h = state(1);
theta = state(2);
hDot = state(3);
thetaDot = state(4);
mass = state(5);

thrust = get_thrust(t, state, Parameter);
drag = compute_drag(state, Parameter);
gamma = atan2((R_earth + h)*thetaDot, hDot);

%gravity

derivativeH = hDot;
derivativeTheta = thetaDot;
DerivativeHDot = ((thrust - drag)*sin(gamma))/mass + (R_earth + h) * thetaDot^2 - g;
DerivativeThetaDot = ((thrust - drag)*cos(gamma)/m - 2*hDot*thetaDot) / (R+h);
derivativeMass = get_fuel_consumption(thrust, Parameter);


derivativeStateArray = [derivativeH; derivativeTheta; DerivativeHDot; DerivativeThetaDot; derivativeMass];

end

