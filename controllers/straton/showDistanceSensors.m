function [] = showDistanceSensors(x,y, theta, ps_coord) 
    hold on;
	plot(x,y,'r.');
	plot(x + ps_coord(:,1), y + ps_coord(:,2), 'b.');
end