function res = sense(x, y, theta, range, map)
  % given a map and the sensor range, get beam-model ranges using raycasting on the map. 
	
	ang = theta * 180 / pi;
	
	angles = [ang-90:1:ang + 90 - 1]
	
	res = [];
	for i=1:length(angles),
		res(i) = raycast(x,y,angles(i) * pi / 180, range,map);
	end
	

end