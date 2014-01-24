function res = heuristic_distance(p, q)
% given two (sets of) points, compute the euclidean distance and return as a heuristic

res = (sqrt( sum( ((p - q).^2)')))';
end