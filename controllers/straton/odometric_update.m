function [xp,yp,thetap] = odometric_update(x,y,theta, L, R, encoder_left, encoder_right)


% calculate travel distances based on tick count
d_left = 2 * pi * R * encoder_left / 1000;
d_right = 2 * pi * R * encoder_right / 1000;
d_mid = (d_left + d_right) / 2;
               
aux = [x; y; theta] + [d_mid * cos(theta); d_mid * sin(theta); ( - d_right + d_left) / L];
                                     
xp = aux(1);
yp = aux(2);
thetap = aux(3);                                         
                                     

end