function [a,h] = get_ah(data)
%GET_AH Summary of this function goes here
%   Detailed explanation goes here

    r = data(1);
    v = data(2);
    gamma = data(3);

    a = (mu * r)/((v^2)*r + 2*mu);
    h = v * r * cos(gamma);

end

