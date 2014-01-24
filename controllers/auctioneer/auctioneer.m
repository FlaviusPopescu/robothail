% MATLAB controller for Webots
% File:          auctioneer.m
% Date:          
% Description:   An agent that publishes goals and runs iterated auctions to assign
%									them to robots.
% Author:        Flavius Popescu
% Modifications: 

% uncomment the next two lines if you want to use
% MATLAB's desktop to interact with the controller:
%desktop;
%keyboard;

TIME_STEP = 64;
AUCTION_LENGTH = 3000; % miliseconds

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
robot_name = wb_robot_get_name();

load '~/webots/mpp2/controllers/map.mat';
remaining_goals = generate_goals(25, map);

wb_emitter_set_channel(emitter, 1);
wb_receiver_set_channel(receiver, 1);

%% attempt to allocate all goals
while wb_robot_step(TIME_STEP) ~= -1

	%% finish if no more goals
	if size(remaining_goals, 1) == 0
		disp(['no more goals']);
		break;
	end

	%% send first goal.
	% formulate string message
	msg = ['auction_open' ',' num2str(remaining_goals(1,1)) ',' num2str(remaining_goals(1,2)) ];
	wb_emitter_send(emitter, double(msg));
	disp([robot_name, ' sends: ', msg ]);
		
	% wait for bids
	bids = containers.Map;
	goals = containers.Map;
	winner_assigned = false;
	countdown = AUCTION_LENGTH;
	
	while wb_robot_step(TIME_STEP) ~= -1 & countdown > 0
		countdown = countdown - TIME_STEP;
					
		%% receive any messages and add any bids to the bid list
		queue_length = wb_receiver_get_queue_length(receiver);
		if queue_length > 0 % message detected
			
			%% get the next message
			msg = wb_receiver_get_data(receiver, 'double');
			msg = char(msg)'; % convert message back to string
			wb_receiver_next_packet(receiver);

			disp([robot_name, ' receives: ', msg]);
				
			%% parse message
			msg = regexp(msg, ',', 'split');
			
			if strcmp(msg{1}, 'bid') % message received was an auction bid
				
				bidding_robot = msg{2};
				bidding_value = str2double(msg(3));
				bidding_goal_x = str2double(msg(4));
				bidding_goal_z = str2double(msg(5));
				
				disp(['received bid: ', num2str(bidding_value), ' from ', bidding_robot ] );
								
				bids(bidding_robot) = bidding_value;
				goals(bidding_robot) = [bidding_goal_x , bidding_goal_z];
			else
				disp(['auctioneer: unknown message type: ', msg{1}]);
			end

		end % if
			
		%% check if auction time expired, take highest bid, if any
		if countdown < 0

			if bids.Count > 0 %% got bids, find max
				ks_bid = keys(bids);
				ks_goal = keys(goals);
					
				winning_robot = ks_bid{1};
				winning_value = bids(winning_robot);
				for i=2:double(bids.Count)
					current_robot = ks_bid{i};
					current_value = bids(current_robot);
					if current_value < winning_value % find the closest robot
						winning_value = current_value;
						winning_robot = current_robot;
					end
				end % for all bids
				
				disp(['decided ', winning_robot]);
					
				%% send name of winning robot
				awarded_goal = goals(winning_robot);
				msg = ['auction_close',',',winning_robot,',',num2str(awarded_goal(1)),',',num2str(awarded_goal(2))];
				wb_emitter_send(emitter, double(msg));
				
				% log goal assignment
				save(['../data/goal', num2str(awarded_goal(1)),'-', num2str(awarded_goal(2)),robot_name,'.mat'], 'winning_robot', 'winning_value' );
					
				disp([robot_name, ' sends: ', msg]);
					
				winner_assigned = true;
				
				remaining_goals(1,:) = [];
				disp([robot_name, ' allocated goal ', num2str(awarded_goal)]);

			end %% if got bids
					
		end %% if countdown expired
			
	end % while waiting for bids
	

end % while main

% cleanup code goes here: write data to files, etc.
