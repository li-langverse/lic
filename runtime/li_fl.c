#include "li_fl.h"

#include "li_dpar.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32)
#include <poll.h>
#include <sys/socket.h>
#include <unistd.h>
#else
#include <winsock2.h>
#endif

static uint64_t g_fl_active_mask = 0;
static li_fl_device_kind g_fl_device = LI_FL_DEVICE_CPU;

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

#if !defined(_WIN32)
static int li_dpar_recv_all_timeout(int fd, void* buf, size_t len, int timeout_ms) {
  char* p = (char*)buf;
  size_t got = 0;
  while (got < len) {
    struct pollfd pf = {.fd = fd, .events = POLLIN};
    const int pr = poll(&pf, 1, timeout_ms);
    if (pr <= 0) {
      return -1;
    }
    ssize_t n = recv(fd, p + got, len - got, 0);
    if (n <= 0) {
      return -1;
    }
    got += (size_t)n;
  }
  return 0;
}
#else
static int li_dpar_recv_all_timeout(int fd, void* buf, size_t len, int timeout_ms) {
  (void)timeout_ms;
  return li_dpar_recv_all(fd, buf, len);
}
#endif

static int li_fl_popcount64(uint64_t mask, int world) {
  int count = 0;
  for (int i = 0; i < world && i < 64; ++i) {
    if ((mask >> i) & 1ULL) {
      count++;
    }
  }
  return count;
}

static li_fl_device_kind li_fl_parse_device_env(void) {
  const char* v = getenv("LI_FL_DEVICE");
  if (v == NULL || v[0] == '\0') {
    return LI_FL_DEVICE_CPU;
  }
  if (strcmp(v, "gpu") == 0) {
    return LI_FL_DEVICE_GPU;
  }
  if (strcmp(v, "tpu") == 0) {
    return LI_FL_DEVICE_TPU;
  }
  if (strcmp(v, "asic") == 0) {
    return LI_FL_DEVICE_ASIC;
  }
  return LI_FL_DEVICE_CPU;
}

void li_fl_set_active_mask(uint64_t mask) {
  g_fl_active_mask = mask;
}

uint64_t li_fl_active_mask(void) {
  return g_fl_active_mask;
}

int li_fl_is_active(int rank) {
  if (rank < 0 || rank >= 64) {
    return 0;
  }
  return (int)((g_fl_active_mask >> rank) & 1ULL);
}

int li_fl_active_count(uint64_t mask) {
  const int world = li_dpar_world_size();
  return li_fl_popcount64(mask, world);
}

void li_fl_set_device_kind(li_fl_device_kind kind) {
  g_fl_device = kind;
}

li_fl_device_kind li_fl_get_device_kind(void) {
  return g_fl_device;
}

void li_fl_gather_device_kinds(li_fl_device_kind* out, int world) {
  if (out == NULL || world <= 0) {
    return;
  }
  const int rank = li_dpar_rank();
  const int kind_i = (int)g_fl_device;
  if (world <= 1) {
    out[0] = g_fl_device;
    return;
  }
  int gathered[64];
  memset(gathered, 0, sizeof(gathered));
  if (rank == 0) {
    gathered[0] = kind_i;
    for (int peer = 1; peer < world; ++peer) {
      const int fd = li_dpar_peer_fd(peer);
      if (fd >= 0) {
        int remote = 0;
        li_dpar_recv_all(fd, &remote, sizeof(remote));
        gathered[peer] = remote;
      }
    }
    for (int i = 0; i < world && i < 64; ++i) {
      out[i] = (li_fl_device_kind)gathered[i];
    }
    for (int peer = 1; peer < world; ++peer) {
      const int fd = li_dpar_peer_fd(peer);
      if (fd >= 0) {
        li_dpar_send_all(fd, out, (size_t)world * sizeof(*out));
      }
    }
  } else {
    const int fd = li_dpar_peer_fd(0);
    if (fd >= 0) {
      li_dpar_send_all(fd, &kind_i, sizeof(kind_i));
      li_dpar_recv_all(fd, out, (size_t)world * sizeof(*out));
    }
  }
}

void li_fl_compress_f32(const float* src, int n, li_fl_compressed_payload* out) {
  if (src == NULL || out == NULL || n <= 0) {
    return;
  }
  if (n > 64) {
    n = 64;
  }
  float min_v = src[0];
  float max_v = src[0];
  for (int i = 1; i < n; ++i) {
    if (src[i] < min_v) {
      min_v = src[i];
    }
    if (src[i] > max_v) {
      max_v = src[i];
    }
  }
  out->offset = min_v;
  out->scale = (max_v - min_v) / 255.0f;
  if (out->scale <= 0.0f) {
    out->scale = 1.0f;
  }
  out->count = n;
  for (int i = 0; i < n; ++i) {
    const float norm = (src[i] - out->offset) / out->scale;
    int q = (int)lroundf(norm);
    if (q < 0) {
      q = 0;
    }
    if (q > 255) {
      q = 255;
    }
    out->data[i] = (uint8_t)q;
  }
}

void li_fl_decompress_f32(const li_fl_compressed_payload* in, float* dst) {
  if (in == NULL || dst == NULL || in->count <= 0) {
    return;
  }
  for (int i = 0; i < in->count; ++i) {
    dst[i] = in->offset + in->scale * (float)in->data[i];
  }
}

static double li_fl_fedavg_root_collect(double local, uint64_t active_mask, int timeout_ms,
                                        uint64_t* timed_out_mask, int use_timeout) {
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  if (timed_out_mask != NULL) {
    *timed_out_mask = 0;
  }
  if (world <= 1) {
    return local;
  }

  const int is_active = (int)((active_mask >> rank) & 1ULL);
  double sum = is_active ? local : 0.0;
  int count = is_active ? 1 : 0;

  if (rank == 0) {
    for (int peer = 1; peer < world; ++peer) {
      if (((active_mask >> peer) & 1ULL) == 0) {
        continue;
      }
      const int fd = li_dpar_peer_fd(peer);
      if (fd < 0) {
        if (timed_out_mask != NULL) {
          *timed_out_mask |= (1ULL << peer);
        }
        continue;
      }
      double remote = 0.0;
      int ok = 0;
      if (use_timeout && timeout_ms >= 0) {
        ok = li_dpar_recv_all_timeout(fd, &remote, sizeof(remote), timeout_ms) == 0;
      } else {
        ok = li_dpar_recv_all(fd, &remote, sizeof(remote)) == 0;
      }
      if (!ok) {
        if (timed_out_mask != NULL) {
          *timed_out_mask |= (1ULL << peer);
        }
        continue;
      }
      sum += remote;
      count++;
    }
    const double avg = count > 0 ? sum / (double)count : 0.0;
    for (int peer = 1; peer < world; ++peer) {
      if (((active_mask >> peer) & 1ULL) == 0) {
        continue;
      }
      const int fd = li_dpar_peer_fd(peer);
      if (fd >= 0) {
        li_dpar_send_all(fd, &avg, sizeof(avg));
      }
    }
    return avg;
  }

  if (!is_active) {
    return 0.0;
  }
  const int fd = li_dpar_peer_fd(0);
  if (fd < 0) {
    return local;
  }
  li_dpar_send_all(fd, &local, sizeof(local));
  double avg = 0.0;
  li_dpar_recv_all(fd, &avg, sizeof(avg));
  return avg;
}

double li_fl_fedavg_masked_f64(double local, uint64_t active_mask) {
  return li_fl_fedavg_root_collect(local, active_mask, -1, NULL, 0);
}

double li_fl_fedavg_straggler_f64(double local, uint64_t active_mask, int timeout_ms,
                                  uint64_t* timed_out_mask) {
  const int rank = li_dpar_rank();
  const char* slow = getenv("LI_FL_STRAGGLER_RANK");
  if (slow != NULL && atoi(slow) == rank && rank != 0) {
    return 0.0;
  }
  return li_fl_fedavg_root_collect(local, active_mask, timeout_ms, timed_out_mask, 1);
}

double li_fl_fedavg_overlap_f64(double local, uint64_t active_mask, li_fl_compute_fn compute,
                                void* ctx, int* overlap_ran) {
  if (overlap_ran != NULL) {
    *overlap_ran = 0;
  }
  const int rank = li_dpar_rank();
  const int world = li_dpar_world_size();
  const int is_active = (int)((active_mask >> rank) & 1ULL);

  if (world <= 1) {
    if (compute != NULL && is_active) {
      compute(ctx);
      if (overlap_ran != NULL) {
        *overlap_ran = 1;
      }
    }
    return local;
  }

  if (rank == 0) {
    double sum = is_active ? local : 0.0;
    int count = is_active ? 1 : 0;
    for (int peer = 1; peer < world; ++peer) {
      if (((active_mask >> peer) & 1ULL) == 0) {
        continue;
      }
      const int fd = li_dpar_peer_fd(peer);
      if (fd < 0) {
        continue;
      }
      if (compute != NULL) {
        compute(ctx);
        if (overlap_ran != NULL) {
          *overlap_ran = 1;
        }
      }
      double remote = 0.0;
      if (li_dpar_recv_all(fd, &remote, sizeof(remote)) != 0) {
        continue;
      }
      sum += remote;
      count++;
    }
    const double avg = count > 0 ? sum / (double)count : 0.0;
    for (int peer = 1; peer < world; ++peer) {
      if (((active_mask >> peer) & 1ULL) == 0) {
        continue;
      }
      const int fd = li_dpar_peer_fd(peer);
      if (fd >= 0) {
        li_dpar_send_all(fd, &avg, sizeof(avg));
      }
    }
    return avg;
  }

  if (compute != NULL && is_active) {
    compute(ctx);
    if (overlap_ran != NULL) {
      *overlap_ran = 1;
    }
  }
  if (!is_active) {
    return 0.0;
  }
  const int fd = li_dpar_peer_fd(0);
  if (fd < 0) {
    return local;
  }
  li_dpar_send_all(fd, &local, sizeof(local));
  double avg = 0.0;
  li_dpar_recv_all(fd, &avg, sizeof(avg));
  return avg;
}

uint64_t li_fl_shrink_mask(uint64_t active_mask, uint64_t failed_mask) {
  return active_mask & ~failed_mask;
}

void li_fl_init_from_env(void) {
  const int world = li_dpar_world_size();
  uint64_t mask = 0;
  const char* mask_env = getenv("LI_FL_ACTIVE_MASK");
  if (mask_env != NULL && mask_env[0] != '\0') {
    mask = strtoull(mask_env, NULL, 0);
  } else {
    for (int i = 0; i < world && i < 64; ++i) {
      mask |= (1ULL << i);
    }
  }
  g_fl_active_mask = mask;
  g_fl_device = li_fl_parse_device_env();
}
