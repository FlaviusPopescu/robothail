function [res_particles, res_w] = resample_step(particles, w)
% importance sampling using the resampling wheel algorithm

particles2 = zeros(size(particles,1), 3);
idx = ceil(rand(1) * size(particles,1));
bta = 0.0;
mw = max(w);    
s = zeros(size(particles,1), 1) ; % new weights
for t=1:size(particles,1),
	bta = bta + rand(1) * 2 * mw;
	while bta > w(idx),
		bta = bta - w(idx);  idx = mod(idx + 1, size(particles,1));
		if idx == 0,
			idx = 1;
		end
	end
	s(t) = w(idx);
	particles2(t,:) = particles(idx,:); 
end
res_particles = particles2;
res_w = s;
res_w = res_w / sum(res_w);



