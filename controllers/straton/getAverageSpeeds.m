function [speed_left, speed_right] = getAverageSpeeds(particles, ws, goal_x, goal_z)
	% decide what to do (control) based on entire weighted particle set
	% Given goal is the next waypoint, no planning required.

	speed_left = 0;
	speed_right = 0;
	
	for i=1:size(particles,1)
		
		x = particles(i,1);
		z = particles(i,2);
		t = particles(i,3);
		
		[sl, sr] = getSpeeds(particles(i,1), particles(i,2), particles(i,3), goal_x, goal_z);
		speed_left = speed_left + sl * ws(i);
		speed_right = speed_right + sr * ws(i);
	end
	
	speed_left = speed_left / size(particles,1);
	speed_right = speed_right / size(particles,1);
	
	speed_left = bound( speed_left * 200, -1000, 1000);
	speed_right = bound( speed_right * 200, -1000, 1000);
	
	if isnan(speed_left)
		speed_left = 200;
	end
	if isnan(speed_right)
		speed_right = 200;
	end
	
end