/*
 * File:         supervisor.c
 * Date:         27-Nov-2009
 * Description:  Simple Supervisor for matlab example
 * Author:       Yvan Bourquin - www.cyberbotics.com
 */

#include <webots/supervisor.h>
#include <webots/robot.h>
#include <webots/emitter.h>
#include <webots/receiver.h>

#define TIME_STEP 320

int main(int argc, const char *argv[]) {
  /* necessary to initialize webots stuff */
  wb_robot_init();
  
  WbDeviceTag emitter = wb_robot_get_device("emitter");
  WbDeviceTag receiver = wb_robot_get_device("receiver");
  wb_receiver_enable(receiver, TIME_STEP);
  
  WbNodeRef epuck = wb_supervisor_node_get_from_def("E_PUCK");
  WbFieldRef trans = wb_supervisor_node_get_field(epuck, "translation");
  
  /* main loop */
  while (wb_robot_step(TIME_STEP) != -1) {
    /* send 3 doubles to matlab */
    const double *pos = wb_supervisor_field_get_sf_vec3f(trans);
    wb_emitter_send(emitter, pos, 3 * sizeof(double));
    
    while (wb_receiver_get_queue_length(receiver) > 0) {
      // receive null-terminated 8 bit ascii string from matlab
      const char *string = wb_receiver_get_data(receiver);
      wb_supervisor_set_label(0, string, 0.01, 0.01, 0.1, 0x000000, 0.0);
      wb_receiver_next_packet(receiver);
    }
  } 

  /* Necessary to cleanup webots stuff */
  wb_robot_cleanup();
  
  return 0;
}
