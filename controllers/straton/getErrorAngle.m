function [res] = getErrorAngle(x,y, theta, wx, wy)
	% Calculate the error angle between the robot orientation and 
	%		desired direction determined by coordinates of next wapypoint 
	%   params:  x,y,theta - robot pose
	%							wx, wy - waypoint coordinates
	
	
	% d = repmat( [ wx, wy] , size(x,1), 1) - [x,y];
	d = [wx, wy] - [x, y];
	bearing = atan2(d(2), d(1));  % desired bearing
	
	res = bearing - theta;
	
	if abs(res) > pi % no point choosing the long turn
		res = 2 * pi - abs(res);
	end
