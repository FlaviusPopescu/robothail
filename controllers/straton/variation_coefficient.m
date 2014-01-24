function [res] = variation_coefficient(ws)
	% given the weights of the particles, calculate the coefficient of variation

	M = length(ws); % number of particles
	res = 1 / M * sum(  (M * ws - 1).^2);