% MATLAB controller for Webots
% File:          goalplacer.m
% Date:          
% Description:   
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

receiver = wb_robot_get_device('receiver');
wb_receiver_enable(receiver,TIME_STEP);

m1 = wb_supervisor_node_get_from_def('R1goal');
t1 = wb_supervisor_node_get_field(m1, 'translation');

m2 = wb_supervisor_node_get_from_def('R2goal');
t2 = wb_supervisor_node_get_field(m2, 'translation');

m3 = wb_supervisor_node_get_from_def('R3goal');
t3 = wb_supervisor_node_get_field(m3, 'translation');

m4 = wb_supervisor_node_get_from_def('R4goal');
t4 = wb_supervisor_node_get_field(m4, 'translation');



while wb_robot_step(TIME_STEP) ~= -1

  % read the sensors, e.g.:
  %  rgb = wb_camera_get_image(camera);
  
  % Process here sensor data, images, etc.

	queue_length = wb_receiver_get_queue_length(receiver);
	if queue_length > 0
		msg = wb_receiver_get_data(receiver, 'double');
		msg = char(msg)';
		wb_receiver_next_packet(receiver);
	
		% disp([robot_name, ' receives: ', msg]);
		msg = regexp(msg, ',', 'split');
		if strcmp(msg{1}, 'auction_close')

			winning_robot = msg{2};
			goal_x = str2double(msg(3));
			goal_z = str2double(msg(4));			

			if winning_robot == 'epuck1'
		      wb_supervisor_field_set_sf_vec3f(t1, [goal_x, 0.02, goal_z] );
		    elseif winning_robot == 'epuck2'
		      wb_supervisor_field_set_sf_vec3f(t2, [goal_x, 0.02, goal_z] );
		    elseif winning_robot == 'epuck3'
		      wb_supervisor_field_set_sf_vec3f(t3, [goal_x, 0.02, goal_z] );
		    elseif winning_robot == 'epuck4'
		      wb_supervisor_field_set_sf_vec3f(t4, [goal_x, 0.02, goal_z] );		    		   
			end


		end
	
	
	end % if message available


  % send actuator commands, e.g.:
  %  wb_differential_wheels_set_speed(500, -500);
  
  % if your code plots some graphics, it needs to flushed like this:
  drawnow;

end

% cleanup code goes here: write data to files, etc.
