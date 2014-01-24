function [vals] = sense_ps(x,y,t,ps_coord, max_range, map)
	% given robot pose and a map, cast rays and return predicted distance measurements interpolated on the lookup table
	ps = get_ps_coordinates(x,y,t, ps_coord);
	
	vals = raycast(ps(:,1)', ps(:,2)', ps(:,3)' , max_range, map);
	
	if sum(vals < 0) > 0 % any negative distances
		'Warning: negative distance value detected!'
	end
	
	% interpolate
	vals = ps_lookup(vals);