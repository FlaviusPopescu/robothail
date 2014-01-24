function res = generate_goals(N, map)
	%% given a map, generate N random goal locations that are reachable by robots
	
	% the number of reachable goals
	count = 0;
	
	RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
	
	while count < N
		g = ceil(rand(1,2) * size(map,1));
		
		% check for locations blocked by obstacles
		if map(g(2), g(1)) == 1 | g(1) == 1 | g(2) == 1 | g(1) == size(map,2) | g(2) == size(map,1)
			continue;
		end		
		candidate =  g / 10 - 0.05;
		
		for i=1:count
			if candidate(1) == res(i,1) & candidate(2) == res(i,2)
				continue;
			end
		end
		count = count + 1;
		res(count, :) = candidate;
	end
	
end
