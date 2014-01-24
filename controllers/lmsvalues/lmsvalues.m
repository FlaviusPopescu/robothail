% MATLAB controller for Webots
% File:          lmsvalues.m
% Date:          
% Description:  simple controller that displays values from the SICK LMS291 laser range finder.
% Author:        
% Modifications: 

% uncomment the next two lines if you want to use
% MATLABs desktop to interact with the controller
%desktop;
%keyboard;

format long;

TIME_STEP = 64;  
max_speed = 10;  
arrow_length = 1;

% world map
world_size = 10;
%landmarks = [5.5 5.5; 10.5 3.5; 16.5 16.5; 2.5 14.5];             
landmarks = [5.5 5.5; 0.5 9.5; 3.5 9.5; 8.5 1.5; 1.5 1.5]; 
       
load '~/webots/mpp2/controllers/bidder/map.mat' % loads the map into variable 'map'

% robot characteristics
L = 0.381; % length between centres of wheels
R = 0.1; % wheel radius  
bearing_noise = 0.5;
speed_noise = 0.1;

% get and enable devices, e.g.:
%  camera = wb_robot_get_device('camera');
%  wb_camera_enable(camera, TIME_STEP);
wheel_left = wb_robot_get_device('leftWheel');
wheel_right = wb_robot_get_device('rightWheel');

wb_servo_set_position(wheel_left, inf);
wb_servo_set_position(wheel_right, inf);

wb_servo_set_velocity(wheel_left, 0);
wb_servo_set_velocity(wheel_right, 0);

gps = wb_robot_get_device('gps');
wb_gps_enable(gps, TIME_STEP);

lms = wb_robot_get_device('lms291');
wb_camera_enable(lms, TIME_STEP);

lms_width = wb_camera_get_width(lms);
max_range = wb_camera_get_max_range(lms);
range_threshold = 2;
        
% main loop:
% perform simulation steps of TIME_STEP milliseconds
% and leave the loop when Webots signals the termination
%      
figure(1);
hold on;
print_once = 1;
while wb_robot_step(TIME_STEP) ~= -1
      
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % read the sensors, e.g.:
  %  rgb = wb_camera_get_image(camera);
  lms_values = wb_camera_get_range_image(lms); 
	if print_once == 1,
		fprintf('Read %d values\n', size(lms_values,2));
		print_once = 0;
	end
	
	% real position from gps
 	pos = wb_gps_get_values(gps);
	%fprintf('\n------\n');
	%fprintf('Real position [x,z] = [%f , %f]', pos(1), pos(3) );
	
	x = pos(1); y = pos(3);
	theta = 0;

  plot([1:180],lms_values,'b-');  

	vals_model = sense(x, y, theta + pi/2, 10, map);
	plot([1:180], vals_model, 'r-');

	fprintf('Average: %d\n', sum(lms_values)/length(lms_values) );

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Process here sensor data, images, etc.
		

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ACTUATOR %%%%%%%%%%%%%%%%%
  % send actuator commands, e.g.:
  %  wb_differential_wheels_set_speed(500, -500);
	
	speed_left = 0;
	speed_right = 0;
	                        
  wb_servo_set_velocity(wheel_left, speed_left);
  wb_servo_set_velocity(wheel_right, speed_right);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%
	% if your code plots some graphics, it needs to flushed like this:
	
  drawnow;

  cla;
end

% cleanup code goes here: write data to files, etc.
