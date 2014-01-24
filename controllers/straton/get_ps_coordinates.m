function [points] = get_ps_coordinates(x,y,theta, ps_coord)
	% given pose of robot, calculate position of distance (proximity) sensors (ps) based on robot position and orientation
	% return the result as an Nx3 matrix, where N is the number of sensors, third column is sensor (map) angle
	
	angles = mod( theta + [0.3008, 0.8008, pi/2, 2.6440, -2.6392, -pi/2, -0.7992, -0.2992]'  , 2 * pi) ;
	
	points = repmat([x,y], size(ps_coord,1), 1) + ps_coord(:,[1,2]) * rotation(-pi/2 - theta);
	points = [points, angles];