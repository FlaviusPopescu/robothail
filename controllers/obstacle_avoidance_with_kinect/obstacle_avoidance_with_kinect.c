/*
 * File:         obstacle_avoidance_with_kinect.c
 * Date:         August 24th, 2011
 * Description:  A Braitenberg-like controller moving a Pioneer 3-DX equipped with a kinect.
 * Author:       Luc Guyot
 *
 * Copyright (c) 2011 Cyberbotics - www.cyberbotics.com
 */

#include <webots/robot.h>
#include <webots/servo.h> 
#include <webots/camera.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define MAX_SPEED 10.0
#define CRUISING_SPEED 7.5
#define TOLERANCE -0.1
#define OBSTACLE_THRESHOLD 0.5
#define SLOWDOWN_FACTOR 0.5

static WbDeviceTag leftWheel, rightWheel;
static WbDeviceTag kinect;
const float* kinectValues;
static int time_step = 0;

int main()
{
    //necessary to initialize Webots 
    wb_robot_init();
    // get time step and robot's devices
    time_step  = wb_robot_get_basic_time_step();
    leftWheel  = wb_robot_get_device("leftWheel");
    rightWheel = wb_robot_get_device("rightWheel");
    kinect     = wb_robot_get_device("kinect");
    wb_camera_enable(kinect, time_step);
    int kinectWidth = wb_camera_get_width(kinect);
    int kinectHeight = wb_camera_get_height(kinect);
    int halfWidth   = kinectWidth/2;
    int viewHeight  = kinectHeight/2 + 10;
    double maxRange = wb_camera_get_max_range(kinect);
    double rangeThreshold = 1.5;
    double invMaxRangeTimesWidth = 1.0 / (maxRange * kinectWidth);
  // set servos' positions
  wb_servo_set_position(leftWheel,INFINITY);
  wb_servo_set_position(rightWheel,INFINITY);
  // set speeds 
  wb_servo_set_velocity(leftWheel, 0.0);
  wb_servo_set_velocity(rightWheel, 0.0);
  //perform one control loop
  wb_robot_step(time_step);
  
  // init dynamic variables
  double leftObstacle = 0.0, rightObstacle = 0.0, obstacle = 0.0;
  double deltaObstacle = 0.0;
  double leftSpeed = CRUISING_SPEED, rightSpeed = CRUISING_SPEED;
  double speedFactor  = 1.0;
  float value = 0.0;
  int i = 0;
  while (1) {
    // get range-finder values
    kinectValues = (float*) wb_camera_get_range_image(kinect);
    
    for (i = 0; i < halfWidth; i++) {
    // record near obstacle sensed on the left side
      value = wb_camera_range_image_get_depth(kinectValues, kinectWidth, i, viewHeight);
      if(value < rangeThreshold) { // far obstacles are ignored
        leftObstacle += value;
      }
    // record near obstacle sensed on the right side
      value = wb_camera_range_image_get_depth(kinectValues, kinectWidth, kinectWidth - i, viewHeight);
      if(value < rangeThreshold) {
        rightObstacle += value;
      }
    }
    
    obstacle  =  leftObstacle + rightObstacle;
    
    // compute the speed according to the information on
    // possible left and right obstacles
    if(obstacle > 0.0){
      obstacle = 1.0 - obstacle * invMaxRangeTimesWidth;// compute the relevant overall quantity of obstacle
      speedFactor = (obstacle > OBSTACLE_THRESHOLD) ? 0.0 : SLOWDOWN_FACTOR;
      deltaObstacle = - (leftObstacle - rightObstacle) * invMaxRangeTimesWidth;
      if(deltaObstacle > TOLERANCE){
        leftSpeed    =               CRUISING_SPEED;
        rightSpeed   = speedFactor * CRUISING_SPEED;   
      }
      else {
        leftSpeed    = speedFactor *  CRUISING_SPEED;
        rightSpeed   =                CRUISING_SPEED;
      }
    }
    else {
       leftSpeed    = CRUISING_SPEED;
       rightSpeed   = CRUISING_SPEED;
    }

    // set speeds
    wb_servo_set_velocity(leftWheel,  leftSpeed);
    wb_servo_set_velocity(rightWheel, rightSpeed);
  
    // run simulation
    wb_robot_step(time_step);
    leftObstacle  = 0.0;
    rightObstacle = 0.0;
  }
}
