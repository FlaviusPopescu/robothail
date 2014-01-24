function [] = showParticlesWeights(particles, ws, colour) 
    p_size = 60;
    p_length = 0.02;
    hold on;
				
		for i=1:size(particles,1)
			msize = p_size * ws(i);
			msize = max(1, msize);		

	    plot(particles(i,1), particles(i,2), [colour '.'], 'MarkerSize', msize);
	    dx = particles(i,1) + p_length * cos(particles(i,3));
	    dy = particles(i,2) + p_length * sin(particles(i,3));
	    plot([particles(i,1) dx]', [particles(i,2) dy]', [colour '-']);    

			
		end
end
