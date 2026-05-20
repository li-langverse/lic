#include <stdio.h>

extern void li_game_repl_kernel(void);
extern double li_game_repl_checksum(void);

int main(int argc, char** argv) {
  if (argc > 1 && argv[1][0] == '-' && argv[1][1] == '-') {
    li_game_repl_kernel();
    printf("%.17g\n", li_game_repl_checksum());
    return 0;
  }
  li_game_repl_kernel();
  return 0;
}
