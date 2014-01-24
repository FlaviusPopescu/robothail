% MATLAB controller for Webots
% File:          straton.m
% Date:          
% Description:   An agent that bids on open auctions and carries out awarded tasks.
%									It uses particle filtering for location estimation.
% Author:        Flavius Popescu
% Modifications: 

format long;
TIME_STEP = 64;
NUM_PARTICLES=40;  
     
%% ---------------- World setup
% load '../map.mat' % loads the map into variable 'map'
world_size = 1;


%% ---------------- Robot characteristics
robot_name = wb_robot_get_name();

% DEBUGGING
%if strcmp(robot_name, 'epuck1') == 0 & strcmp(robot_name, 'epuck2') == 0 & strcmp(robot_name, 'epuck3') == 0
%	exit
%end

L = 0.052; % axle length
R = 0.0205; % wheel radius 
speed_unit = 0.00628; % speed unit (rads/sec) 
turn_speed = 100;
cruise_speed = 300;
load '~/webots/mpp2/controllers/straton/ps_coord.mat' % loads proximity sensor coordinates into variable 'ps_coord'
load '~/webots/mpp2/controllers/map.mat' % loads the map matrix representation into variable 'map'
load '~/webots/mpp2/controllers/planetmap.mat' % loads the map matrix representation into variable 'map'
sensing_noise = 4000; % was 2000

max_range_ps = 1; % proximity sensor range 1 meter

N=8;
braitenberg_matrix = [150 -35; 100 -15; 80 -10; -10 -10; -10 -10; -10 80; -30 100; -20 150 ];
conv_matrix = [ -1 -1 -1; -1  8 -1; -1 -1 -1 ];

proximity_threshold = 1000;

% enable sensors and comm devices
for i=1:N
  ps(i) = wb_robot_get_device(['ps' int2str(i-1)]);
  wb_distance_sensor_enable(ps(i),TIME_STEP);
end
camera = wb_robot_get_device('camera');
wb_camera_enable(camera,TIME_STEP);
emitter = wb_robot_get_device('emitter');
receiver = wb_robot_get_device('receiver');
wb_emitter_set_channel(emitter, 1);
wb_receiver_enable(receiver,TIME_STEP);
wb_receiver_set_channel(receiver,1);

gps = wb_robot_get_device('gps');
wb_gps_enable(gps, TIME_STEP);
wb_differential_wheels_enable_encoders(TIME_STEP);
display = wb_robot_get_device('display');
wb_display_set_color(display, [0 0 0]);
display = wb_robot_get_device('display');
wb_display_set_color(display, [0 0 0]);

%% get initial position
wb_robot_step(TIME_STEP);
gps_pos = wb_gps_get_values(gps);
x = gps_pos(1); z = gps_pos(3); theta = 3 * pi /2;

% initiliaze particles for position estimation
particles = zeros(NUM_PARTICLES, 3);
for j=1:NUM_PARTICLES,
	particles(j, :) = [ x + 0.04 * randn(1), z + 0.04 * randn(1), theta]; % Gaussian around starting location
	%% EXPERIMENT
	% particles(j,:) = [rand(1) * world_size, rand(1) * world_size, rand(1) * 2 * pi];  % unknown initial location
	% particles(j,:) = [x,y,theta]; % exact location via GPS
end  

%% initialize weights vector, used in particle filter steps
ws = ones(NUM_PARTICLES, 1) / NUM_PARTICLES;

% plot particles in initial place; use figure 1
f = figure(1);
showMap(map);
showParticles(particles, 'r');
plot(x,z, 'y.', 'MarkerSize', 10);          

curr_step = 0;
speed_left = 0;
speed_right = 0;
last_speed_left = 0;
last_speed_right = 0;

% DEBUGGING
% goals = [0.75, 0.15; 0.65, 0.65; 0.05, 0.95; 0.95, 0.05];

skip_mechanism = 0;
goals = [];
have_goals = false;

disp([robot_name, ': initiating main control loop']);
while wb_robot_step(TIME_STEP) ~= -1  % master loop
	
	disp([robot_name, ': bidding for goals']);
	%% get goals
	while wb_robot_step(TIME_STEP) ~= -1 & size(goals,1) == 0  % no goals
		queue_length = wb_receiver_get_queue_length(receiver);
		
		if queue_length > 0  % message detected
			% [int2str(wb_receiver_get_queue_length(receiver)), ' packet(s) detected']			

			%% get data
			msg = wb_receiver_get_data(receiver, 'double');
			msg = char(msg)'; % convert message back to string
			wb_receiver_next_packet(receiver);
			
			% disp([robot_name, ' receives: ', msg]);
			
			%% parse message
			msg = regexp(msg, ',', 'split');
			
			if strcmp(msg{1}, 'auction_open') % message received was an auction call
				
				new_goal_x = str2double(msg(2));
				new_goal_z = str2double(msg(3));
				
				%% compute bid
				new_bid = computeBid(particles, ws, new_goal_x, new_goal_z, map);
				
				%% compose message and send bid
				msg = ['bid', ',', robot_name,',', num2str(new_bid), ',', num2str(new_goal_x), ',', num2str(new_goal_z)];
				wb_emitter_send(emitter, double(msg));
				
				gps_x = gps_pos(1);
				gps_z = gps_pos(3);

				% save to file
				save(['../data/goal', num2str(new_goal_x),'-', num2str(new_goal_z),robot_name,'.mat'], 'gps_x', 'gps_z', 'particles', 'ws', 'new_bid', 'robot_name' );
			
				
			% disp([robot_name ' sends: ', msg]);
							
			elseif strcmp(msg{1}, 'auction_close') % message received was an auction clearance

				%% auction_close, robot_name
				winner_name = msg{2}; 
				
				if strcmp(winner_name, robot_name)  % i am winner
					won_goal_x = str2double(msg(3));
					won_goal_z = str2double(msg(4));
					
					goals = [goals; [won_goal_x, won_goal_z] ];		
					
					wb_receiver_disable(receiver);			
				end
			else
				% disp([robot_name, ': ', 'unknown message type: ' msg{1}]);
			end
		end
	end
	
	disp([robot_name,': initiating execution phase for goal ', num2str(goals(1,:)) ]  );
	
	%% execute goals
	while wb_robot_step(TIME_STEP) ~= -1 & size(goals,1) > 0
	
		% maintenance 
    	curr_step = curr_step + 1;			
    
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% READ %%%%%%%%%%%%%%%%%%%%
		for i=1:N
		  ps_values(i) = wb_distance_sensor_get_value(ps(i));
		end 
		    
		encoder_left = wb_differential_wheels_get_left_encoder();
		encoder_right = wb_differential_wheels_get_right_encoder();

		gps_pos = wb_gps_get_values(gps);
		
		% rgb = wb_camera_get_image(camera);
			                          
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESS %%%%%%%%%%%%%%%%%%		
		
		%%% -- LOCALIZATION -- %%%
		
		%%% prediction step for particles
		particles = prediction_step(particles, TIME_STEP / 1024 , speed_left * speed_unit, speed_right * speed_unit, R, L, map);  
		
		%%% odometric position estimation
		[new_x, new_z, new_theta] = odometric_update(x,z, theta, L, R, encoder_left, encoder_right);
		
		%% using speeds
		% new_pos = forward_kinematics(x, z, theta, TIME_STEP / 1024, last_speed_left * speed_unit, last_speed_right * speed_unit, R, L, map);
				
		%%% update step for particles
		sig = sensing_noise;
		ws = update_step(particles, sig, ps_values, ps_coord, max_range_ps, map);
		
		%%% resample step for particles using ESS
		% ess = effective_sample_size(ws)
		% if ess / NUM_PARTICLES < 0.6
		% 	[particles, ws] = resample_step(particles, ws);	
		% end
		
		%% position extraction using particle filter
		[p_x, p_z, p_theta] = getPosition(particles, ws);
		
		%%% -- PLANNING -- %%%

		% next goal
		goal = goals(1,:);

		%% check if goal reached using supervisor true position
		if close_by(goal(1), goal(2), gps_pos(1), gps_pos(3) ) < 0.05
			
			disp([robot_name, ' reached goal ', num2str(goal(1)), ',', num2str(goal(2)) ]);
			goals = goals( (goals(:,1) ~= goal(1)) | ( goals(:,2) ~= goal(2)), : ); % remove goal from goals set
			wb_receiver_enable(receiver,TIME_STEP);			
			wb_receiver_set_channel(receiver,1);
			wb_differential_wheels_set_speed(0, 0);
			
			% confirm goal completion to listener
			wb_emitter_set_channel(emitter, 2);
			msg = ['goal_complete,',robot_name,',',num2str(goal(1)),',',num2str(goal(2))];
			wb_emitter_send(emitter, double(msg));
			wb_emitter_set_channel(emitter, 1);

			% % update location
			% x = gps_pos(1);
			% z = gps_pos(3);
			
			% re-generate particle set
			for j=1:NUM_PARTICLES,
				particles(j,:) = [ gps_pos(1) + 0.02 * randn(1), gps_pos(3) + 0.02 * randn(1), particles(j,3)];  % Gaussian around starting location
			end  
			ws = ones(NUM_PARTICLES, 1) / NUM_PARTICLES;
			
			clf;
			hold on;
			showMap(map);			
			[particles, ws] = resample_step(particles, ws);
						
			showParticles(particles,'r');

			continue;
			
		end
				      
		[speed_left, speed_right] = getAverageSpeedsPlanning(particles, ws, goal(1), goal(2), map);
		
		% override if fellow robot is in the way
		if ps_values(7) > 1300 | ps_values(8) > 600, % obstacle to the left
		    speed_right = -1000;
						speed_left = 1000;
		
						disp('obstacle to the left! turning right')
		elseif ps_values(2) > 1300 | ps_values(1) > 600, % obstacle to the right
						speed_right = 1000;
		    speed_left = -1000;
		
						disp('obstacle to the right! turning left')
		end
		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ACTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		% actuate wheels
		wb_differential_wheels_set_speed(speed_left, speed_right);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT/DEBUG %%%%%%%%%%%%%%%%%%%

		if mod(curr_step, 5) == 0
				clf;
				hold on;
				showMap(map);			
				[particles, ws] = resample_step(particles, ws);
									
				showParticles(particles,'r');
				plot(gps_pos(1), gps_pos(3),  'b*'); % gps
				showPosition(new_x, new_z, new_theta, 'y'); % odometry
				% showPosition(p_x, p_z, p_theta, 'g'); % particle filter
	 	
				%% log data
				saveas(f,['data/',robot_name,'_particles', num2str(curr_step),'.png']);
				save(['data/',robot_name,'_particles', num2str(curr_step), '.mat'], 'particles', 'ws');
	
		end

		% DEBUG
		% predicted_values = sense_ps(gps_pos(1),gps_pos(3),theta, ps_coord, max_range_ps, map);		
		% predicted_values_norm = predicted_values / sum(predicted_values)
		% ps_values_norm = ps_values / sum(ps_values)
		% bar(ws)
		% display ps readings and predicted readings using the map
		% subplot(131)
		% bar(ps_values)
		% subplot(132)
		% bar(predicted_values)
		% subplot(133)
		% likelihoods = phit(ps_values, predicted_values, 0.1 );
		% bar(likelihoods)
	
		% % flush graphics
		drawnow;
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ITERATION CLEAN-UP %%%%%%%%%%%%%%%%%
		wb_differential_wheels_set_encoders(0,0); 

		%% odometric update
		x = new_x;
		z = new_z;
		theta = new_theta;

		%% kinematics update
		% x = new_pos(1);
		% z = new_pos(2);
		% theta = new_pos(3);
		
		%% particle filter update
		% x = p_x;
		% z = p_z;
		% theta = p_theta;
				
	end % task execution loop
	
end % master loop

% cleanup code goes here: write data to files, etc.
