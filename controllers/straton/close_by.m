function [res] = close_by(x,y, wx, wy,  tester)
	% distance to goal used in a "close enough?" situation
	tester = 2;
	% res = ( sqrt((x - wx)^2 + (y - wy)^2) ) < 0.05;
	res = ( sqrt((x - wx)^2 + (y - wy)^2) );