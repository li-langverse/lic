#include "li_dpar.h"

#include <string.h>

#if !defined(_WIN32)
#include <sys/socket.h>
#include <unistd.h>
#else
#include <winsock2.h>
#endif

static int li_dpar_send_all(int fd, const void* buf, size_t len) {
  const char* p = (const char*)buf;
  size_t sent = 0;
  while (sent < len) {
#if defined(_WIN32)
    int n = send(fd, p + sent, (int)(len - sent), 0);
#else
    ssize_t n = send(fd, p + sent, len - sent, 0);
#endif
    if (n <= 0) {
      return -1;
    }
    sent += (size_t)n;
  }
  return 0;
}

static int li_dpar_recv_all(int fd, void* buf, size_t len) {
  char* p = (char*)buf;
  size_t got = 0;
  while (got < len) {
#if defined(_WIN32)
    int n = recv(fd, p + got, (int)(len - got), 0);
#else
    ssize_t n = recv(fd, p + got, len - got, 0);
#endif
    if (n <= 0) {
      return -1;
    }
    got += (size_t)n;
  }
  return 0;
}

void li_dpar_bcast_f64(double* buf, long long count, int root) {
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  if (world <= 1 || buf == NULL || count <= 0) {
    return;
  }
  if (root < 0 || root >= world) {
    root = 0;
  }
  const size_t bytes = (size_t)count * sizeof(double);
  if (rank == root) {
    for (int peer = 0; peer < world; ++peer) {
      if (peer == root) {
        continue;
      }
      const int fd = li_dpar_peer_fd(peer);
      if (fd >= 0) {
        li_dpar_send_all(fd, buf, bytes);
      }
    }
  } else {
    const int fd = li_dpar_peer_fd(root);
    if (fd >= 0) {
      li_dpar_recv_all(fd, buf, bytes);
    }
  }
}

double li_dpar_allreduce_sum_f64(double local, int root) {
  (void)root;
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  if (world <= 1) {
    return local;
  }
  double acc = local;
  for (int peer = 0; peer < world; ++peer) {
    if (peer == rank) {
      continue;
    }
    const int fd = li_dpar_peer_fd(peer);
    if (fd < 0) {
      continue;
    }
    if (peer < rank) {
      double remote = 0.0;
      li_dpar_recv_all(fd, &remote, sizeof(remote));
      acc += remote;
      li_dpar_send_all(fd, &acc, sizeof(acc));
    } else {
      li_dpar_send_all(fd, &acc, sizeof(acc));
      li_dpar_recv_all(fd, &acc, sizeof(acc));
    }
  }
  return acc;
}

long long li_dpar_allreduce_sum_i64(long long local, int root) {
  (void)root;
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  if (world <= 1) {
    return local;
  }
  long long acc = local;
  for (int peer = 0; peer < world; ++peer) {
    if (peer == rank) {
      continue;
    }
    const int fd = li_dpar_peer_fd(peer);
    if (fd < 0) {
      continue;
    }
    if (peer < rank) {
      long long remote = 0;
      li_dpar_recv_all(fd, &remote, sizeof(remote));
      acc += remote;
      li_dpar_send_all(fd, &acc, sizeof(acc));
    } else {
      li_dpar_send_all(fd, &acc, sizeof(acc));
      li_dpar_recv_all(fd, &acc, sizeof(acc));
    }
  }
  return acc;
}
