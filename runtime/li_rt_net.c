#include "li_rt_net.h"

#include "li_rt.h"

#include <stdlib.h>
#include <string.h>

static int32_t g_next_listen_fd = 2;
static int32_t g_next_conn_fd = 3;

int32_t tcp_listen(int32_t port) {
  if (port <= 0 || port > 65535) {
    li_panic("tcp_listen: invalid port");
  }
  const int32_t fd = g_next_listen_fd;
  g_next_listen_fd += 2;
  return fd;
}

int32_t tcp_accept(int32_t listen_fd) {
  if (listen_fd < 0) {
    li_panic("tcp_accept: invalid listen fd");
  }
  const int32_t fd = g_next_conn_fd;
  g_next_conn_fd += 2;
  return fd;
}

int32_t tcp_send(int32_t conn_fd, const char* data) {
  if (conn_fd < 0) {
    li_panic("tcp_send: invalid fd");
  }
  if (data == NULL) {
    return 0;
  }
  return (int32_t)strlen(data);
}

const char* tcp_recv(int32_t conn_fd, int32_t max_bytes) {
  if (conn_fd < 0) {
    li_panic("tcp_recv: invalid fd");
  }
  if (max_bytes <= 0) {
    li_panic("tcp_recv: max_bytes must be positive");
  }
  static char empty[] = "";
  return empty;
}

void tcp_close(int32_t conn_fd) {
  if (conn_fd < 0) {
    li_panic("tcp_close: invalid fd");
  }
}
