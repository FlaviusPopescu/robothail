function [] = showMap(map) 
  hold on;
  imshow((1 - map),'InitialMagnification', 'fit', 'XData', [0.05 0.95], 'YData', [0.05 0.95]);
  plot(-0.05,-0.05,'k.');
  plot(1.05,1.05,'k.');     
end