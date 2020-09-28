function [optimalGamma] = get_gamma_for_altitude(Parameter, desiredAltitude)
%GET_GAMMA_FOR_ALTITUDE Summary of this function goes here
%   Detailed explanation goes here

    options = optimset('Display','off');
                                                
    [optimalGamma,deltaH,exitflag] = fsolve(@(gamma) get_perigee(Parameter, gamma) - desiredAltitude, ...
                                   pi/2-0.1, options);
                              
    if exitflag ~=1
        fprintf("Activating automatic root finder...\n")
        
        newOptimalGamma = optimalGamma - (0.08)/...
                          (get_perigee(Parameter, optimalGamma + 0.04) - ...
                           get_perigee(Parameter, optimalGamma - 0.04)) * ...
                           deltaH;
        error = abs(1 - get_perigee(Parameter, newOptimalGamma)/desiredAltitude) * 100;
                       
        if error < 0.1
            optimalGamma = newOptimalGamma;
            fprintf("Succesful in linear estimation of gamma (error = %.2f %%)\n", error)
        else
            fprintf("MATLAB unable of finding the root. Please click on intersection\n")
            done = false;
            delta = 0.05;
            while done == false
                [gammaArray, altitudeArray] = what_is_going_on(Parameter, optimalGamma, delta);
                figure
                hold on
                plot(gammaArray, altitudeArray)
                yline(desiredAltitude)
                xline(optimalGamma)
                hold off
                [optimalGamma,~] = ginput(1);
                
                error = abs(1 - get_perigee(Parameter, optimalGamma)/desiredAltitude) * 100;
                if error < 0.1
                    done = true;
                    fprintf("Success (error = %.2f %%)\n", error)
                else
                    delta = delta/2;
                    fprintf("Please keep refining (error = %.2f %%)\n", error)
                end
            end
        end
    end
end


function perigeeAltitude = get_perigee(Parameter, gamma)

    RocketData = Parameter.Rocket;

    Parameter.Control.initialConditions = [0, ...
                                                    gamma, ...
                                                    0, ...
                                                    0, ...
                                                    RocketData.initialMass, ...
                                                    0, ...
                                                    0, ...
                                                    0];
	Results = integrate_trajectory(Parameter);
                                                    
    perigeeAltitude = max(Results.stateArray(:,4));

end

function [gamma, altitude] = what_is_going_on(Parameter, currentGamma, delta)
    gamma = linspace(currentGamma-delta, currentGamma+delta, 50);

    for i=1:50
        altitude(i) = get_perigee(Parameter, gamma(i));
    end
end
