/* One-time Winsock 2.2 init for MSYS2 UCRT / native Windows builds. */
#include "li_rt_posix_compat.h"

#if defined(_WIN32)
static int g_winsock_ready;

void li_rt_winsock_ensure(void) {
  if (g_winsock_ready) {
    return;
  }
  WSADATA wsa;
  if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
    return;
  }
  g_winsock_ready = 1;
}
#else
void li_rt_winsock_ensure(void) {}
#endif
