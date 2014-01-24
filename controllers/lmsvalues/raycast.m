% cast rays and calculate distances given a map of the environment
function [dist] = raycast(x,y,theta,range,map)

 	mapx = ceil(x);
	mapy = ceil(y);

	deltay = abs(1/sin(theta));
	deltax = abs(1/cos(theta));
	                               
	fractx = x - floor(x);
	fracty = y - floor(y);
	
	stepx = 0; stepy = 0; sx = 0; sy = 0;
	
  
	theta = mod(theta, 2 * pi); % necessary??
	if theta >= 0 & theta < pi/2, % first quadrant 
    sx = (1 - fractx) / cos(theta);
		sy = (1 - fracty) / sin(theta);
    stepx = 1;
		stepy = 1;
	elseif theta >= pi/2 & theta < pi, % second quadrant
		sx = fractx / cos(pi - theta);
		sy = 1 - fracty / sin(pi - theta);
		stepx = -1;
		stepy = 1;
	elseif theta >= pi & theta < 3/2*pi, % third quadrant
		sx = fractx / cos(theta - pi);
		sy = fracty / sin(theta - pi);
		stepx = -1;
		stepy = -1;
	elseif theta >= 3/2 * pi & theta < 2*pi, % fourth quadrant
		sx = (1 - fractx) / cos(theta - 3 * pi / 2);
		sy = fracty / sin(theta - 3 * pi / 2);
		stepx = 1;
		stepy = -1;
		deltay = abs(1/sin(theta - 3 * pi / 2));
		deltax = abs(1/cos(theta - 3 * pi / 2));
	end
	
	hit = 0; 
	side = 0; %  0 -> X-side ;  1 -> Y-side
	last = []; 
	while hit == 0,
		last = [sx, sy];
		if sx < sy,
			sx = sx + deltax;
			mapx = mapx + stepx;
			side = 0;
		else,
			sy = sy + deltay;
			mapy = mapy + stepy;
			side = 1;
		end

		if mapx > size(map,1) | mapx < 1 | mapy > size(map,1) | mapy < 1,
			hit = 2;   % wall, out of bounds
		elseif map(mapx, mapy) == 1,
			hit = 1;
		end 
		      
	end     
	
	dist = last(side+1);


end