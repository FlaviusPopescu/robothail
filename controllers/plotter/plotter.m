% MATLAB controller for Webots
% File:          listener.m
% Date:          
% Description:   An agent that assists with simulation vizualisation
% Author:        Flavius Popescu
% Modifications: 

% uncomment the next two lines if you want to use
% MATLAB's desktop to interact with the controller:
%desktop;
%keyboard;

TIME_STEP = 64;

% get and enable devices, e.g.:
%  camera = wb_robot_get_device('camera');
%  wb_camera_enable(camera, TIME_STEP);

% main loop:
% perform simulation steps of TIME_STEP milliseconds
% and leave the loop when Webots signals the termination
%

emitter = wb_robot_get_device('emitter');
receiver = wb_robot_get_device('receiver');
wb_receiver_enable(receiver,TIME_STEP);
wb_receiver_set_channel(receiver, 1);
wb_emitter_set_channel(emitter, 1);
robot_name = wb_robot_get_name();

fileId = fopen('data/result.txt','wt');

steps = 0;
alloc_no = 0;
while wb_robot_step(TIME_STEP) ~= -1
	steps = steps + TIME_STEP;
	
	queue_length = wb_receiver_get_queue_length(receiver);
	if queue_length > 0
		msg = wb_receiver_get_data(receiver, 'double');
		msg = char(msg)';
		wb_receiver_next_packet(receiver);
		
		% disp([robot_name, ' receives: ', msg]);
		msg = regexp(msg, ',', 'split');
		
		if strcmp(msg{1}, 'auction_open') % message received was an auction call
			new_goal_x = str2double(msg(2));
			new_goal_z = str2double(msg(3));
		
		else if strcmp(msg{1}, 'bid') % message received was a bid
			
			bidding_robot = msg{2};
			bidding_value = str2double(msg(3));
			bidding_goal_x = str2double(msg(4));
			bidding_goal_z = str2double(msg(5));
							
			bids(bidding_robot) = bidding_value;
			goals(bidding_robot) = [bidding_goal_x , bidding_goal_z];

		
		else if strcmp(msg{1}, 'goal_complete')

			completing_robot = msg{2};
			goal_x = str2double(msg(3));
			goal_z = str2double(msg(4));			

			
			fprintf(fileId, '%s %d %d  %d\n', completing_robot, steps, goal_x, goal_z );
			
			
		end
		
	end % if message available
	

  % read the sensors, e.g.:
  %  rgb = wb_camera_get_image(camera);
  
  % Process here sensor data, images, etc.

  % send actuator commands, e.g.:
  %  wb_differential_wheels_set_speed(500, -500);
  
  % if your code plots some graphics, it needs to flushed like this:
  drawnow;

end

fclose(fileId);

% cleanup code goes here: write data to files, etc.
