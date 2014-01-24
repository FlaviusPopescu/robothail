function [m] = rotation(theta)
% given an angle, returns the 2-D rotation matrix associated with it

m = [ cos(theta) , -sin(theta);  sin(theta), cos(theta)];

end