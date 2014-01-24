function res = bound(x,a,b)
% bounds a value to an interval [a,b]:
if x < a,
	res = a;
elseif x > b,
	res = b;
else
	res = x;
end