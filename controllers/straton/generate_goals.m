function res = generate_goals(N, map)
	%% given a map, generate random goal locations that are reachable by robots
	%%   reachable goals are in the middle of the 
	
	count = 0;
	
	res = zeros(N,2);
	
	while count < N
		
		g = ceil(rand(1,2) * size(map,1));
		if map(g(2), g(1)) == 1 | sum( ismember(res, g, 'rows')) > 0
			continue;
		end
		
		count = count + 1;
		res(count, :) =  g / 10 - 0.05;
	end
	
end