function [res] = forward_kinematics(x, y, theta, dt, speed_left, speed_right, R, L, map)
	% forward kinematics for a differential steering robot written in matrix form for fast computation
	
	if speed_left == -1 * speed_right,
		res = [x, y,  theta + 2 * speed_left * dt / L];
	else

		res = [];                
 
		% intermediate calculations
		dr = speed_right * R * dt;
		dl = speed_left * R * dt;
		dm = (dr + dl) / 2;             

		% matrix operation
		aux = theta + (dr - dl) / (2 * L);                            

		res = [x, y, theta] + [ dm  .* cos(aux), dm  .* sin(aux), (dl-dr) / L];
	end
                                  
end