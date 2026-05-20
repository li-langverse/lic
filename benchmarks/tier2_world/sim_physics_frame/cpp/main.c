#include <stdio.h>

extern void li_sim_physics_frame_kernel(void);
extern double li_sim_physics_frame_checksum(void);

int main(int argc, char** argv) {
  if (argc > 1 && argv[1][0] == '-' && argv[1][1] == '-') {
    li_sim_physics_frame_kernel();
    printf("%.17g\n", li_sim_physics_frame_checksum());
    return 0;
  }
  li_sim_physics_frame_kernel();
  return 0;
}
