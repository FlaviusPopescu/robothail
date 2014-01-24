function [res] = showPosition(x,y,t, colour)
	p_length = 0.02;
	p_size = 6;
	
  plot(x, y, [colour '.'], 'MarkerSize', p_size);
  dx = x + p_length * cos(t);
  dy = y + p_length * sin(t);
  plot([x dx]', [y dy]', [colour '-']);    
	
	
end