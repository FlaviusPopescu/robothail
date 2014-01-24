function [] = showParticles(particles, colour) 
    p_size = 6;
    p_length = 0.02;
    hold on;
    plot(particles(:,1), particles(:,2), [colour '.'], 'MarkerSize', p_size);
    dx = particles(:,1) + p_length * cos(particles(:,3));
    dy = particles(:,2) + p_length * sin(particles(:,3));
    plot([particles(:,1) dx]', [particles(:,2) dy]', [colour '-']);    
end