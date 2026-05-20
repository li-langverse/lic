#include <stdio.h>

extern void li_game_world_soa_kernel(void);
extern double li_game_world_soa_checksum(void);

int main(int argc, char** argv) {
  if (argc > 1 && argv[1][0] == '-' && argv[1][1] == '-') {
    li_game_world_soa_kernel();
    printf("%.17g\n", li_game_world_soa_checksum());
    return 0;
  }
  li_game_world_soa_kernel();
  return 0;
}
