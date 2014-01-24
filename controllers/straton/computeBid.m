function res = computeBid(particles, ws, goal_x, goal_z, map)
	%% for a given goal location, compute a bid valuation based on expected distance from every particle
	
	if sum(ws) ~= 1 % ensure weights are normalized!
		ws = ws / sum(ws);
	end
	
	ds = zeros(size(particles,1), 1);

	for i=1:size(particles,1)
		
		x = particles(i,1);
		z = particles(i,2);
		
		if x < 0 | z < 0 | x > 1 | z > 1 % out of bounds
			ds(i) = 0;
			ws(i) = 0; %% distance (of 0) will not affect average; particle is unimportant because it is out of bounds (resampling hasn't occurred yet)
		else % in bounds, valid place to start A* search from
			[path_map, waypoints, goal_dist] = astar(x, z, goal_x, goal_z, map);
			ds(i) = goal_dist;
		end
	end
	
	res = sum(ds .* ws);
end
