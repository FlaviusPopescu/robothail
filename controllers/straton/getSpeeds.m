function [speed_left, speed_right] = getSpeeds(x, z, theta, goal_x, goal_z)
	speed_left = 0;
	speed_right = 0;
	
	% get error angle and decide what to do based on single pose variable
	error_angle = getErrorAngle( x, z, theta, goal_x, goal_z );
	distance_to = close_by(x, z, goal_x, goal_z);
	turn_gain = 1702; % 1700
	cruise_gain = 4799;
	
	speed_left = distance_to * cruise_gain;
	speed_right = distance_to * cruise_gain;
	
	turn_speed = error_angle / pi * turn_gain;	
	speed_left = speed_left + turn_speed;
	speed_right = speed_right - turn_speed;
	
	speed_left = bound(speed_left, -1000, 1000);
	speed_right = bound(speed_right, -1000, 1000);
		
end