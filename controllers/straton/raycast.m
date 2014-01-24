function [dist] = raycast(x,y,theta,range,map)
% cast rays and calculate distances given a map of the environment

% conversion factor from grid cell to meters (meters / grid cell)
conversion_factor = 0.1;

% convert from map position to grid location
x = x * 10;
y = y * 10;


theta = mod(theta, 2 * pi);

mapx = floor(x) + 1;
mapy = floor(y) + 1;

deltay = abs(1./sin(theta));
deltax = abs(1./cos(theta));
                             
fractx = x - floor(x);
fracty = y - floor(y);

stepx = 0; stepy = 0; sx = 0; sy = 0;
  
% compute distance to first boundary
sx = zeros(size(theta));
sy = zeros(size(theta));
stepx = zeros(size(theta));
stepy = zeros(size(theta));

% quadrant settings c1-c4
c1 = theta >= 0 & theta < pi/2;
sx(c1) = (1 - fractx(c1)) ./ cos(theta(c1));
sy(c1) = (1 - fracty(c1)) ./ sin(theta(c1));
stepx(c1) = 1;
stepy(c1) = 1;  

c2 = ~c1 & theta < pi;
sx(c2) = fractx(c2) ./ cos(pi - theta(c2));
sy(c2) = (1 - fracty(c2))  ./ sin(pi - theta(c2));
stepx(c2) = -1;
stepy(c2) = 1;  

c3 = ~c1 & ~c2 & theta < 3/2*pi;
sx(c3) = fractx(c3) ./ cos(theta(c3) - pi);
sy(c3) = fracty(c3) ./ sin(theta(c3) - pi);
stepx(c3) = -1;
stepy(c3) = -1;

c4 = ~c1 & ~c2 & ~c3 & theta <= 2*pi;
sx(c4) = (1 - fractx(c4)) ./ sin(theta(c4) - 3 * pi / 2);
sy(c4) = fracty(c4) ./ cos(theta(c4) - 3 * pi / 2);
stepx(c4) = 1;
stepy(c4) = -1;
deltax(c4) = abs(1./sin(theta(c4) - 3 * pi / 2));
deltay(c4) = abs(1./cos(theta(c4) - 3 * pi / 2)); 

% reset sx, sy to 0 when it's exactly on grid
sx(x == mapx) = 0;
sy(y == mapy) = 0;       

% start DDA-like sequence
hit = zeros(size(x));
side = zeros(size(x));
last = [sx; sy];	

while(sum(hit) ~= length(hit))         
  last(:,~hit) = [sx(~hit); sy(~hit)];
	last(last == NaN) = Inf;

  c1 = (sx < sy);
  c2 = ~c1;
  c1 = c1 & (~hit);
  sx(c1) = sx(c1) + deltax(c1);
  mapx(c1) = mapx(c1) + stepx(c1);
  side(c1) = 0;          
        
  c2 = (c2) & (~hit);
  sy(c2) = sy(c2) + deltay(c2);
  mapy(c2) = mapy(c2) + stepy(c2);
  side(c2) = 1; 
       
  c3 = mapx > size(map,2) | mapx < 1 | mapy > size(map,1) | mapy < 1;
  hit(c3) = 1;
  c4 = ~c3;

	% adjunct mapy, mapx matrix
	mapy_a = [ mapy ; 1:size(mapy,2)];
	mapx_a = [ mapx ; 1:size(mapx,2)];
	
	% remove columns corresponding to elements that were already 'hit'
	mapy_f = mapy_a(:, logical(c4));
	mapx_f = mapx_a(:, logical(c4));
	
	% get mask of elements that should now be 'hit'
  c5 = diag(map(mapy_f(1, :), mapx_f(1, :))) == 1 ;
	% get indices of those elements
	all_y = mapy_f(2, :);
	idx_y = all_y(c5);
	
	% update hit
	hit(idx_y) = 1;

end 

side = side + 1;
dist = abs(diag(last(side, :)));
dist = dist * conversion_factor;

% don't exceed max range
dist = min(dist,range);

end