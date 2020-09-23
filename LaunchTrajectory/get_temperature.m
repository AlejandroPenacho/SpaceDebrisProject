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
    T=a5*(x-100*k)+205.7
else 
    T=(1500+273.15);
    
end 
end 
