function [res] = getAvg(a,b,c,d,e)
	
	maxlen = min([length(a), length(b), length(c), length(d), length(e)]);
	
	res = zeros(1, maxlen);
	
	for i=1:maxlen
		count = 0;
		if i <= length(a)
			res(i) = res(i) + a(i);
			count = count + 1;
		end

		if i <= length(b)
			res(i) = res(i) + b(i);
			count = count + 1;
		end

		if i <= length(c)
			res(i) = res(i) + c(i);
			count = count + 1;
		end

		if i <= length(d)
			res(i) = res(i) + d(i);
			count = count + 1;
		end

		if i <= length(e)
			res(i) = res(i) + e(i);
			count = count + 1;
		end
		res(i) = res(i) / count;
		
	end
	
	

end