function [] = showResult(goalx, goalz, pucks)
%% plot result nicely

fileprefix = ['goal',num2str(goalx),'-',num2str(goalz)];
colors = ['g', 'b', 'm', 'c'];
symbols = ['o', 's', 'd', '*'];
addpath '../straton';
load '../map.mat';
showMap(map);

filename = [fileprefix, 'auctioneer.mat'] % winning_robot, winning_value
load(filename); % loads winning_robot and winning value

plot(goalx, goalz, 'kp', 'MarkerSize', 20);

fileData = dir();
fileNames = {fileData.name};
index = regexp(fileNames, [fileprefix, 'epuck[0-9]+\.mat']);
inFiles = fileNames(~cellfun(@isempty, index));

nFiles = numel(inFiles);

for iFile=1:nFiles
	inFile = inFiles{iFile};
	
	load(inFile);
	
	if robot_name == winning_robot,
		winner_x = gps_x;
		winner_z = gps_z;
	end
	
	robot_index = str2double(robot_name(end)) ; % epuck2 -> 2
	showParticlesSymWs(particles, ws, ['r', symbols(robot_index) ]);
	
	plot(gps_x, gps_z, [colors(robot_index), symbols(robot_index)], 'MarkerSize', 10 );
end

[a,b,c] = astar(winner_x, winner_z, goalx, goalz, map);
b = [winner_x winner_z; b];
plot(b(:,1), b(:,2), [colors(str2double(winning_robot(end))), '--']);


rmpath '../straton';


end
