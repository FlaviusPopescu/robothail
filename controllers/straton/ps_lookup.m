function [res] = ps_lookup(ds)
	% given a distance reading (or more) (computed through raycasting), 
	%    interpolate using the calibrated E-Puck promixity sensor look-up table
	
	lookup = [ 0 4095 0.005;
      0.005 3474 0.037;
      0.01 2211 0.071;
      0.02 676 0.105;
      0.03 306 0.125;
      0.04 164 0.206;
      0.05 90 0.269;
      0.06 56 0.438;
      0.07 34 0.704];

	for t=1:size(ds,1)
		d = ds(t);
		found = false;
		for i=1:(size(lookup,1) - 1)
			x0 = lookup(i,1);
			x1 = lookup(i+1, 1);
			y0 = lookup(i,2);
			y1 = lookup(i+1,2);
			noise0 = lookup(i,3);
			noise1 = lookup(i+1,3);
		
			if x0 <= d & d < x1
				found = true;
				break;
			end
		end
		if ~found % given value is over max_range
			err = 34 * 0.704;
			a = err - err/2;
			b = -a;

			r = 34 + a + (b-a) .* rand(1);
		else
			r = interp1([x0 x1], [y0 y1], d); % find y, the unknown in interpolation equation
			noise = interp1([x0 x1], [noise0 noise1], d); % interpolate noise as well
			err = r * noise;
			a = err - err/2;
			b = -a;
			r = r + a + (b-a) .* rand(1);
		end
	
		res(t) = round(r);
	end