function [res] = effective_sample_size(ws)
	% given particles weights, use coefficient of variation to calculate ESS
	
	res = length(ws) / (1 + variation_coefficient(ws));