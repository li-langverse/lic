#include "li_rt.h"

void li_panic(const char* msg) {
  fprintf(stderr, "li panic: %s\n", msg);
  abort();
}

void li_bounds_fail(void) { li_panic("array index out of bounds"); }

void li_rt_print_int(int32_t value) { printf("%d\n", value); }

void li_rt_print_str(const char* s) { puts(s); }
