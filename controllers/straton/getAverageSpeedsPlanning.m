function [speed_left, speed_right] = getAverageSpeedsPlanning(particles, ws, goal_x, goal_z, map)
	% decide what to do (control) based on entire weighted particle set
	% Given goal is the location of a target objective. Perform A* search for each particle
	%  to determine next waypoint and action.
	
	speed_left = zeros(size(particles,1), 1);
	speed_right = zeros(size(particles,1), 1);
	
	for i=1:size(particles,1)
		
		x = particles(i,1);
		z = particles(i,2);
		t = particles(i,3);
		
		if (x > 0 & x < 1 & z > 0 & z < 1) % within map area and away from goal
			if false & close_by(x,z, goal_x, goal_z) < 0.05 % DISABLED
				speed_left(i) = 0;
				speed_right(i) = 0;
				ws(i) = 0; % particle shouldn't affect the resulting averaged speed value, it already reached the goal and doesn't matter
			else
				% path planning and speed computation
				[path_map, waypoints, goal_dist] = astar(x, z, goal_x, goal_z, map);
				
				% checks for null list of waypoints (particle is too close to generate any more waypoints?)
				if size(waypoints,1 ) == 0
					speed_left(i) = 0;
					speed_right(i) = 0;
				else % waypoints found
					current_waypoint = waypoints(1, :);
					[sl, sr] = getSpeeds(x, z, t, current_waypoint(1), current_waypoint(2));
					
					speed_left(i) = sl;
					speed_right(i) = sr;				
				end		
			end
			
		else % out of bounds or reached goal
			speed_left(i) = 0;
			speed_right(i) = 0;
			ws(i) = 0; % set it to 0 if it's not already 0 so it doesn't make a difference
									% resampling step would have taken out this particle anyway
									% NOTE: weights are not changed in the body of the main control loop
		end
	end
	
	speed_left = sum(speed_left .* ws) ;
	speed_right = sum(speed_right .* ws) ;
	
	speed_left = bound( speed_left * 200, -1000, 1000);
	speed_right = bound( speed_right * 200, -1000, 1000);
	
	if isnan(speed_left)
		speed_left = 200;
	end
	if isnan(speed_right)
		speed_right = 200;
	end
	
end
