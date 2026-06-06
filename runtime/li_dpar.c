#include "li_dpar.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32)
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#else
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")
#endif

static int g_dpar_rank = 0;
static int g_dpar_world = 1;
static int g_dpar_initialized = 0;
static int g_dpar_listen_fd = -1;
static int g_dpar_peer_fd[64];
static int g_dpar_peer_count = 0;

static int li_dpar_env_int(const char* name, int fallback) {
  const char* v = getenv(name);
  if (v == NULL || v[0] == '\0') {
    return fallback;
  }
  const int n = atoi(v);
  return n > 0 ? n : fallback;
}

static void li_dpar_parse_hosts(const char* hosts_raw, char out_hosts[][256], int* count) {
  *count = 0;
  if (hosts_raw == NULL || hosts_raw[0] == '\0') {
    return;
  }
  char buf[4096];
  strncpy(buf, hosts_raw, sizeof(buf) - 1);
  buf[sizeof(buf) - 1] = '\0';
#if defined(_WIN32)
  char* save = NULL;
  char* tok = strtok_s(buf, ",", &save);
#else
  char* save = NULL;
  char* tok = strtok_r(buf, ",", &save);
#endif
  while (tok != NULL && *count < 64) {
    while (*tok == ' ') {
      ++tok;
    }
    strncpy(out_hosts[*count], tok, 255);
    out_hosts[*count][255] = '\0';
    (*count)++;
#if defined(_WIN32)
    tok = strtok_s(NULL, ",", &save);
#else
    tok = strtok_r(NULL, ",", &save);
#endif
  }
}

int li_dpar_peer_fd(int peer) {
  if (peer < 0 || peer >= 64) {
    return -1;
  }
  return g_dpar_peer_fd[peer];
}

int li_dpar_init_from_env(void) {
  if (g_dpar_initialized) {
    return g_dpar_rank;
  }
  g_dpar_rank = li_dpar_env_int("LI_DPAR_RANK", 0);
  g_dpar_world = li_dpar_env_int("LI_DPAR_WORLD_SIZE", 1);
  if (g_dpar_world < 1) {
    g_dpar_world = 1;
  }
  if (g_dpar_rank < 0 || g_dpar_rank >= g_dpar_world) {
    g_dpar_rank = 0;
  }
  for (int i = 0; i < 64; ++i) {
    g_dpar_peer_fd[i] = -1;
  }

  const char* port_env = getenv("LI_DPAR_PORT");
  const int base_port = port_env ? atoi(port_env) : 29500;

  if (g_dpar_world > 1) {
    char hosts[64][256];
    int host_count = 0;
    li_dpar_parse_hosts(getenv("LI_DPAR_HOSTS"), hosts, &host_count);
    if (host_count < g_dpar_world) {
      for (int i = host_count; i < g_dpar_world; ++i) {
        strncpy(hosts[i], "127.0.0.1", 255);
      }
      host_count = g_dpar_world;
    }

#if defined(_WIN32)
    WSADATA wsa;
    WSAStartup(MAKEWORD(2, 2), &wsa);
#endif

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)(base_port + g_dpar_rank));

    g_dpar_listen_fd = (int)socket(AF_INET, SOCK_STREAM, 0);
    int opt = 1;
    setsockopt(g_dpar_listen_fd, SOL_SOCKET, SO_REUSEADDR, (const char*)&opt, sizeof(opt));
    bind(g_dpar_listen_fd, (struct sockaddr*)&addr, sizeof(addr));
    listen(g_dpar_listen_fd, g_dpar_world);

    for (int peer = 0; peer < g_dpar_world; ++peer) {
      if (peer == g_dpar_rank) {
        continue;
      }
      if (peer < g_dpar_rank) {
        struct sockaddr_in client;
        socklen_t clen = sizeof(client);
        int fd = (int)accept(g_dpar_listen_fd, (struct sockaddr*)&client, &clen);
        g_dpar_peer_fd[peer] = fd;
        g_dpar_peer_count++;
      } else {
        struct sockaddr_in remote;
        memset(&remote, 0, sizeof(remote));
        remote.sin_family = AF_INET;
        remote.sin_port = htons((uint16_t)(base_port + peer));
        inet_pton(AF_INET, hosts[peer], &remote.sin_addr);
        int fd = (int)socket(AF_INET, SOCK_STREAM, 0);
        for (int retry = 0; retry < 200; ++retry) {
          if (connect(fd, (struct sockaddr*)&remote, sizeof(remote)) == 0) {
            g_dpar_peer_fd[peer] = fd;
            g_dpar_peer_count++;
            break;
          }
#if defined(_WIN32)
          Sleep(10);
#else
          usleep(10000);
#endif
        }
      }
    }
  }

  g_dpar_initialized = 1;
  return g_dpar_rank;
}

void li_dpar_finalize(void) {
  for (int i = 0; i < 64; ++i) {
    if (g_dpar_peer_fd[i] >= 0) {
#if defined(_WIN32)
      closesocket(g_dpar_peer_fd[i]);
#else
      close(g_dpar_peer_fd[i]);
#endif
      g_dpar_peer_fd[i] = -1;
    }
  }
  if (g_dpar_listen_fd >= 0) {
#if defined(_WIN32)
    closesocket(g_dpar_listen_fd);
    WSACleanup();
#else
    close(g_dpar_listen_fd);
#endif
    g_dpar_listen_fd = -1;
  }
  g_dpar_peer_count = 0;
  g_dpar_initialized = 0;
}

int li_dpar_rank(void) {
  if (!g_dpar_initialized) {
    li_dpar_init_from_env();
  }
  return g_dpar_rank;
}

int li_dpar_world_size(void) {
  if (!g_dpar_initialized) {
    li_dpar_init_from_env();
  }
  return g_dpar_world;
}

void li_dpar_barrier(void) {
  if (li_dpar_world_size() <= 1) {
    return;
  }
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  char token = 1;
  for (int peer = 0; peer < world; ++peer) {
    if (peer == rank) {
      continue;
    }
    int fd = g_dpar_peer_fd[peer];
    if (fd < 0) {
      continue;
    }
    if (peer < rank) {
      recv(fd, &token, 1, 0);
      send(fd, &token, 1, 0);
    } else {
      send(fd, &token, 1, 0);
      recv(fd, &token, 1, 0);
    }
  }
}

long long li_dpar_block_partition_begin(long long global_n, int rank, int world) {
  if (world <= 0) {
    return 0;
  }
  if (rank < 0) {
    rank = 0;
  }
  if (rank >= world) {
    rank = world - 1;
  }
  return (global_n * rank) / world;
}

long long li_dpar_block_partition_end(long long global_n, int rank, int world) {
  if (world <= 0) {
    return global_n;
  }
  if (rank < 0) {
    rank = 0;
  }
  if (rank >= world) {
    rank = world - 1;
  }
  return (global_n * (rank + 1)) / world;
}

void li_distributed_for_i64(long long start, long long end, void (*body)(long long)) {
  if (body == NULL || end <= start) {
    return;
  }
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  const long long global_n = end - start;
  const long long local_begin = li_dpar_block_partition_begin(global_n, rank, world);
  const long long local_end = li_dpar_block_partition_end(global_n, rank, world);
  for (long long k = local_begin; k < local_end; ++k) {
    body(start + k);
  }
}
