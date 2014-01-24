function [res] = prediction_step(particles, dt, speed_left, speed_right, R, L ,map)
	% updates particle set based on motion information 
	res = [];                
    
	trans_noise = 0.004; % good: 0.01
	drift_noise = 0.04;  % good: 0.04

	%trans_dist = (speed_right + speed_left) / 2 * R * dt; % translation distance
 
	% intermediate calculations
	dr = speed_right * R * dt;
	dl = speed_left * R * dt;
	dm = (dr + dl) / 2;             

	% add translational noise to mid-point distance and vectorize
	DM = dm + trans_noise * randn(size(particles,1), 1);

	% matrix operation for speed
	aux = particles(:,3) + (dr - dl) / (2 * L);                            

	% add drift noise to angle which is integrated into the translation for the current timestep
	%aux = aux + drift_noise * randn(size(particles,1), 1);

	theta_noise = drift_noise * randn(size(particles,1), 1);

	res = particles + [ DM  .* cos(aux), DM  .* sin(aux), repmat((dl-dr) / L, size(particles,1), 1) + theta_noise ];
                                  
end
