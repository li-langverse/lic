#include <stdio.h>

extern void li_render_frame_present_kernel(void);
extern double li_render_frame_present_checksum(void);

int main(int argc, char** argv) {
  if (argc > 1 && argv[1][0] == '-' && argv[1][1] == '-') {
    li_render_frame_present_kernel();
    printf("%.17g\n", li_render_frame_present_checksum());
    return 0;
  }
  li_render_frame_present_kernel();
  return 0;
}
