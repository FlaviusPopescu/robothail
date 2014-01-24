function [res, wp, d] = astar(xinit, yinit, xfin, yfin, map)
% Compute a path from [xinit, yinit] to [xfin ,yfin] on the map using A* search.
% This uses a Euclidean distance heuristic in 
% order to establish the next node that needs to be expanded.

s_xinit = xinit;
s_yinit = yinit;
s_xfin = xfin;
s_yfin = yfin;

% convert pose coordinates to matrix indices
xinit = xinit * 10;
yinit = yinit * 10;
xfin = xfin * 10;
yfin = yfin * 10;

actual_init = [xinit, yinit];
actual_fin = [xfin, yfin];

offset = -0.5; % define an offset to add to the final waypoints that will effectively center the resulting path

xinit = ceil(xinit); yinit = ceil(yinit);
xfin = ceil(xfin); yfin = ceil(yfin);

closed = zeros(size(map,2), size(map,1)); % expanded nodes
bp = zeros(size(map,2) ,size(map,1), 2); % back pointers, how the search reached a node ( - delta_change)

%% change matrix  [ delta_x, delta_y, cost_of_action ]
delta = [0, -1, 1 ;  % up 
         -1, 0, 1; % left
         0, 1, 1 ; % down
          1, 0, 1; % right 
          1, -1, 1.5;   % up-right           
          -1, -1, 1.5; % up-left
          -1, 1, 1.5;   % down-left
          1, 1, 1.5 ];  % down-right


moves = delta(:,[1,2]);
costs = delta(:,3);

% initialise open list
f = heuristic_distance([xinit, yinit], [xfin, yfin]); g = 0;
o = [f,g,xinit,yinit];

while size(o,1) > 0, 
	
	% pick best node
	fmin = min(o(:,1)); % min on first column
	pos = find(o(:,1) == fmin);
	pos = pos(1); % first result only;
	curr_node = o(pos,:); % current node indicated by pos in open list
	x = curr_node(3); y = curr_node(4); f = curr_node(1); g = curr_node(2);

  % goal reached?
	if x == xfin & y == yfin,
		break;
	end

	% remove from open and add to closed
	o(pos,:) = [];
	closed(y,x) = 1;    
	
	
	% generate neighbor-nodes, by adding the change (delta move) matrix to current x and y
	new_node = repmat([x,y], size(delta,1), 1) + moves; % motion 

	% generate costs for each new node
	new_g = repmat([g], size(new_node,1), 1) + costs;
	
	% iterate through neighbor nodes
	for i=1:size(new_node,1),

		% coordinates of current node 
	  x2 = new_node(i,1); y2 = new_node(i,2);    
		
		% check for out of bounds
		if x2 <= size(map,2) & y2 <= size(map,1) & x2 > 0 & y2 > 0, 
			
			if (closed(y2,x2) == 0 & map(y2, x2) == 0), % not already expanded and not an obstacle				
				
				%% diagonal motions can only be executed if, for resulting diagonally-adjacent node, its edge-adjacent cells are free
				%%   from obstacles
				ok_diagonal = true; % assume motion can be executed, or non-diagonal motion
				if i > 4,  % for diagonal motions
					
					%% get deltas that were used to obtain the current diagonally adjacent node
					delta_x = moves(i,1);
					delta_y = moves(i,2);

					%% obtain the 2 horizontally and vertically adjacent cells (e.g. like in 4-point connectivity) which surround the diagonally-adjacent cell
					if map(y + delta_y , x + 0) == 1 | map(y + 0, x + delta_x) == 1
						ok_diagonal = false; %% diagonal motion not possible, obstacles are adjacent
					end
					
				end % if diagonal motion
			
				if ok_diagonal,  %% possible diagonal motion, or non-diagonal motion
				
					g2 = g + costs(i);
										
					f2 = g2 + heuristic_distance([x2,y2], [xfin, yfin]);
				
					% search in open if present
					found = 0;
					for j=1:size(o,1),
						if o(j,3)== x2 & o(j,4) == y2, % check if g is better, and update backpointer(bp)
							found = 1;
							if o(j,2) > g2,
								o(j,2) = g2;
								bp(y2, x2, 1) = -moves(i,1);
								bp(y2, x2, 2) = -moves(i,2);
							end
						end
					end
				
					if ~ found,
						o(size(o,1) +1, :) = [f2, g2, x2, y2];
						bp(y2,x2,1) = -moves(i, 1);  % store change in x
						bp(y2,x2,2) = -moves(i, 2);  % store change in y
					end
				end % if ok diagonal
			end % if not an obstacle
		end
		
	end % for all neighbours
end  % while ok                

                                    
% trace back to get path
res = zeros(size(map,2), size(map,1));
waypoints = [];   
total_distance = 0;
x = xfin; y = yfin;
while x ~= xinit | y ~= yinit,
	waypoints = [waypoints; [( x + offset) / 10  , (y + offset) / 10]];
	x2 = x + bp(y,x,1);
	y2 = y + bp(y,x,2);
	total_distance = total_distance + close_by( waypoints(end,1), waypoints(end,2), (x2 + offset) / 10, (y2 + offset ) / 10);
	res(y2,x2) = 1;
	x = x2; y = y2;
end  

if size(waypoints,1) > 1
	wp = waypoints(end:-1:1, :);
else
	wp = waypoints(end:-1:1, :);
end
% if size(wp,1) > 1,
% 	wp = wp(2:end, :);
% end
% wp = [actual_init / 10 ; wp; actual_fin / 10];
% wp = [wp; actual_fin / 10];

d = total_distance;