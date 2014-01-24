function [ws] = update_step(particles, sig, ps_values, ps_coord, max_range, map)
	%% Particle filter update step using a Gaussian noise model
	
	covariance_matrix = eye(length(ps_values) ) * sig;
	
	ws = zeros(size(particles,1), 1);
	
	for i=1:size(particles,1)
		
		x = particles(i,1);
		y = particles(i,2);
		

		if x < 0 | y < 0 | x > 1 | y > 1,
			ws(i) = 0;
		elseif map(  ceil(y * 10), ceil(x * 10) ) == 1,
			ws(i) = 0;
		else	
			predicted = sense_ps(x, y, particles(i, 3), ps_coord, max_range, map);
		
			ws(i) = phit(ps_values, predicted , covariance_matrix);				
		end
	end
	
	ws = ws / sum(ws);
	
