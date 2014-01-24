function [] = showParticlesSymWs(particles, ws, pattern) 
    p_size = 6;
    p_length = 0.05;
    hold on;
    
    for i=1:size(particles,1)
    	
    	s = p_size * ws(i) / p_size + 5;
    	s = bound(s,5, 12);
    	
	    plot(particles(i,1), particles(i,2), pattern, 'MarkerSize', s);
    	dx = particles(i,1) + p_length * cos(particles(i,3));
    	dy = particles(i,2) + p_length * sin(particles(i,3));
    	plot([particles(i,1) dx]', [particles(i,2) dy]', [pattern(1) '-']);  % pattern(1)  - colour; pattern(2) - symbol
    	
    end
    
end
