function [xp yp thetap] = getPosition(particles, ws)
% extract position from particle set using weighted average

res = sum(particles .* repmat(ws,1,3));
xp = res(1);
yp = res(2);
thetap = res(3);

