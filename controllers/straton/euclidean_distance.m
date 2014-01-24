function [res] = euclidean_distance(predicted, actual)
	% get euclidean distance between the vectors of measurements
	
	res =   sqrt( sum( (predicted - actual).^2 ) );