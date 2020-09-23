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
else 1000*k<h
    M=3.94;
end 
R=Rm/M;
end 
    
    

    