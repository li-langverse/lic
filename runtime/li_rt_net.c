/* Trusted Net seam — POSIX syscalls and I/O buffers only; HTTP lives in Li. */
#define _GNU_SOURCE
#include "li_rt.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>

#ifdef __linux__
#define HTTPD_EPOLL_CLIENT_TAG UINT64_C(0x8000000000000000)
#define HTTPD_EPOLL_UP_TAG UINT64_C(0xc000000000000000)
#define HTTPD_PROXY_SPLICE_MIN 512
#else
#define HTTPD_PROXY_SPLICE_MIN 4096
#define HTTPD_EPOLL_CLIENT_TAG UINT64_C(0)
#define HTTPD_EPOLL_UP_TAG UINT64_C(0)
#ifndef MSG_MORE
#define MSG_MORE 0
#endif
#ifndef EPOLLIN
#define EPOLLIN 0x001u
#define EPOLLOUT 0x004u
#define EPOLLET (1u << 30)
#define EPOLLERR 0x008u
#define EPOLLHUP 0x010u
#define EPOLL_CTL_ADD 1
#define EPOLL_CTL_MOD 2
#define EPOLL_CTL_DEL 3
struct epoll_event {
  uint32_t events;
  union {
    void* ptr;
    int fd;
    uint32_t u32;
    uint64_t u64;
  } data;
};
static int epoll_ctl(int epfd, int op, int fd, struct epoll_event* event) {
  (void)epfd;
  (void)op;
  (void)fd;
  (void)event;
  return 0;
}
static int epoll_create1(int flags) {
  (void)flags;
  return -1;
}
static int epoll_wait(int epfd, struct epoll_event* events, int maxevents, int timeout) {
  (void)epfd;
  (void)events;
  (void)maxevents;
  (void)timeout;
  return -1;
}
#endif
#endif

#ifdef __linux__
#include <sys/epoll.h>
#include <sys/sendfile.h>
#include <sys/uio.h>
#ifndef SPLICE_F_MOVE
#define SPLICE_F_MOVE 1
#endif
#ifndef SPLICE_F_NONBLOCK
#define SPLICE_F_NONBLOCK 2
#endif
#endif

#define HTTPD_MAX_CONN 512
#define HTTPD_IO_BUF 16384

#define HTTPD_PROXY_PHASE_IDLE 0
#define HTTPD_PROXY_PHASE_SEND_REQ 1
#define HTTPD_PROXY_PHASE_SEND_BODY 2
#define HTTPD_PROXY_PHASE_RELAY 3

#define HTTPD_MAX_HDR_RECV 16384
#define HTTPD_MAX_HEADER_LINES 128
#define HTTPD_MAX_BODY (1024 * 1024)
#define HTTPD_PROXY_RELAY_BUF 65536

typedef struct {
  char method[16];
  int method_len;
  char path[2048];
  int path_len;
  int body_mode; /* 0 none, 1 Content-Length, 2 chunked */
  int content_length;
} httpd_req_info_t;

typedef struct {
  int fd;
  char buf[HTTPD_IO_BUF];
  char hdr[512];
  int len;
  int proxy_active;
  int proxy_up_fd;
  int32_t proxy_peer_port;
  int proxy_keep;
  int proxy_hdr_end;
  int proxy_phase;
  size_t proxy_send_off;
  size_t proxy_send_total;
  int proxy_body_left;
  int proxy_body_slot_done;
  httpd_req_info_t proxy_req;
  char proxy_rbuf[HTTPD_PROXY_RELAY_BUF];
  int proxy_rbuf_len;
  size_t proxy_rbuf_sent;
  int proxy_up_reuse;
  int proxy_relay_got_data;
  /* Request chunked body (async) */
  int proxy_chunk_state;
  int proxy_chunk_remain;
  char proxy_chunk_line[32];
  int proxy_chunk_line_len;
  int proxy_slot_body_rem;
  int proxy_slot_body_off;
  char proxy_up_pending[4096];
  int proxy_up_pending_len;
  /* Upstream response */
  int proxy_resp_parsing;
  int proxy_resp_body_mode;
  int proxy_resp_body_left;
  int proxy_resp_chunk_state;
  int proxy_resp_chunk_remain;
  char proxy_resp_chunk_line[32];
  int proxy_resp_chunk_line_len;
  char proxy_resp_hdr_acc[4096];
  int proxy_resp_hdr_len;
  uint32_t proxy_client_epoll_events;
  uint32_t proxy_up_epoll_events;
} httpd_slot_t;

static httpd_slot_t g_slots[HTTPD_MAX_CONN];
static int g_slots_inited = 0;

static char g_cached_body[HTTPD_IO_BUF];
static int32_t g_cached_sz = 0;
static int g_cache_ready = 0;
static char g_cached_blob_ka[512 + HTTPD_IO_BUF];
static int32_t g_cached_blob_ka_len = 0;
static char g_cached_blob_close[512 + HTTPD_IO_BUF];
static int32_t g_cached_blob_close_len = 0;
static char g_doc_root[4096];
static size_t g_doc_root_len = 0;
static char g_proxy_host[64] = "127.0.0.1";
static int32_t g_proxy_port = 0;
static int g_proxy_all = 0;

#define HTTPD_MAX_ROUTES 16
typedef struct {
  char method[16];
  char path_prefix[512];
  int path_len;
  int is_prefix;
  int is_proxy;
  int rate_limit_rps;
  int rate_limit_burst;
  double rate_tokens;
  double rate_last_ts;
} httpd_route_t;

static httpd_route_t g_routes[HTTPD_MAX_ROUTES];
static int g_route_count = 0;

static int g_rate_limit_rps = 0;
static int g_rate_limit_burst = 0;
static double g_rate_tokens = 0.0;
static double g_rate_last_ts = 0.0;

static int g_health_max_fails = 1;
static int g_health_fail_timeout_sec = 10;

#define HTTPD_MAX_UPSTREAM_PEERS 8
#define HTTPD_POOL_PER_PEER 32

typedef struct {
  int32_t port;
  int fds[HTTPD_POOL_PER_PEER];
  int in_use[HTTPD_POOL_PER_PEER];
  int active;
  int down;
  int fail_count;
  double down_until;
} httpd_upstream_peer_t;

static httpd_upstream_peer_t g_up_peers[HTTPD_MAX_UPSTREAM_PEERS];
static int g_up_peer_count = 0;
static int g_lb_rr = 0;
static int g_lb_mode = 0; /* 0=round_robin, 1=least_conn */
static int32_t g_config_listen_port = 0;
static int g_httpd_epfd = -1;
static int g_li_proxy_mode = 0;
#ifdef __linux__
static int g_proxy_splice_pipe[2] = {-1, -1};
#endif

/* Nginx loopback backend response cache (proxy_loopback): skip re-parse when stable. */
static int g_proxy_resp_cl_cached = -1;
static int g_proxy_resp_hdr_bytes_cached = 0;
static char g_proxy_resp_hdr_copy[4096];
#define HTTPD_PROXY_RESP_PARSE_CACHED 2
#define HTTPD_PROXY_SNAP_MAX (128 * 1024)
static char g_proxy_snap[HTTPD_PROXY_SNAP_MAX];
static int g_proxy_snap_len = 0;
static int g_proxy_snap_ready = 0;
static int g_proxy_snap_recording = 0;
static int32_t g_li_scratch = 0;

/* Li-native proxy per-slot glue (logic in packages/li-net-httpd/src/lib.li). */
static int g_lp_up_fd[HTTPD_MAX_CONN];
static int g_lp_phase[HTTPD_MAX_CONN];
static int g_lp_hdr_end[HTTPD_MAX_CONN];
static int g_lp_body_left[HTTPD_MAX_CONN];
static int g_lp_keep[HTTPD_MAX_CONN];
static int g_lp_resp_parsing[HTTPD_MAX_CONN];

#define PROXY_CHUNK_HEX 0
#define PROXY_CHUNK_DATA 1
#define PROXY_CHUNK_CRLF 2

#define PROXY_RESP_BODY_NONE 0
#define PROXY_RESP_BODY_CL 1
#define PROXY_RESP_BODY_CHUNKED 2
#define PROXY_RESP_BODY_CLOSE 3

static void upstream_pool_prewarm_all(void);
static void httpd_proxy_snap_reset(void);
static void httpd_drain_upstream_fd(int fd);
static int httpd_fd_readable(int fd);

static void slots_init_once(void) {
  if (g_slots_inited) {
    return;
  }
  for (int i = 0; i < HTTPD_MAX_CONN; i++) {
    g_slots[i].fd = -1;
    g_slots[i].len = 0;
    g_slots[i].proxy_active = 0;
    g_slots[i].proxy_up_fd = -1;
    g_slots[i].proxy_phase = HTTPD_PROXY_PHASE_IDLE;
  }
  g_slots_inited = 1;
}

static void net_fail(const char* msg) {
  fprintf(stderr, "li net: %s: %s\n", msg, strerror(errno));
  li_panic("Net effect failed");
}

static const char* ptr_i(intptr_t p) { return (const char*)p; }
static intptr_t iptr(const char* p) { return (intptr_t)p; }

static char* li_rt_strdup_buf(const char* src, size_t n) {
  char* out = (char*)malloc(n + 1);
  if (!out) {
    li_panic("alloc failed");
  }
  if (n > 0 && src) {
    memcpy(out, src, n);
  }
  out[n] = '\0';
  return out;
}

static int set_nonblocking(int fd) {
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags < 0) {
    return -1;
  }
  return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}

static int wait_writable(int conn) {
  struct pollfd pfd;
  pfd.fd = conn;
  pfd.events = POLLOUT;
  pfd.revents = 0;
  for (;;) {
    int pr = poll(&pfd, 1, 30000);
    if (pr > 0) {
      return 0;
    }
    if (pr < 0 && errno == EINTR) {
      continue;
    }
    return -1;
  }
}

static ssize_t send_all_nb(int conn, const void* data, size_t len) {
  const char* p = (const char*)data;
  size_t off = 0;
  while (off < len) {
    ssize_t n = send(conn, p + off, len - off, MSG_NOSIGNAL);
    if (n < 0) {
      if (errno == EINTR) {
        continue;
      }
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        if (wait_writable(conn) < 0) {
          return -1;
        }
        continue;
      }
      return -1;
    }
    if (n == 0) {
      return -1;
    }
    off += (size_t)n;
  }
  return (ssize_t)off;
}

void tcp_tune_client(int32_t fd) {
  int one = 1;
  setsockopt((int)fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one));
#ifdef TCP_QUICKACK
  setsockopt((int)fd, IPPROTO_TCP, TCP_QUICKACK, &one, sizeof(one));
#endif
}

static void tcp_ack_now(int32_t fd) {
#ifdef TCP_QUICKACK
  int one = 1;
  setsockopt((int)fd, IPPROTO_TCP, TCP_QUICKACK, &one, sizeof(one));
#endif
  (void)fd;
}

int32_t tcp_listen(int32_t port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    net_fail("socket");
  }
  int one = 1;
  setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  addr.sin_port = htons((uint16_t)port);
  if (bind(fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
    close(fd);
    net_fail("bind");
  }
  if (listen(fd, 128) < 0) {
    close(fd);
    net_fail("listen");
  }
  return (int32_t)fd;
}

int32_t tcp_accept(int32_t listen_fd) {
  int c = accept((int)listen_fd, NULL, NULL);
  if (c < 0) {
    net_fail("accept");
  }
  return (int32_t)c;
}

void tcp_close(int32_t fd) {
  if (fd >= 0) {
    close((int)fd);
  }
}

int32_t tcp_send(int32_t conn_fd, const char* data) {
  if (!data) {
    return 0;
  }
  return tcp_send_n(conn_fd, data, (int32_t)strlen(data));
}

int32_t tcp_send_n(int32_t conn_fd, const char* data, int32_t len) {
  if (!data || len <= 0) {
    return 0;
  }
  ssize_t rc = send_all_nb((int)conn_fd, data, (size_t)len);
  return rc < 0 ? -1 : len;
}

const char* tcp_recv(int32_t conn_fd, int32_t max_bytes) {
  if (max_bytes <= 0) {
    max_bytes = 4096;
  }
  if (max_bytes > 65536) {
    max_bytes = 65536;
  }
  char* buf = (char*)malloc((size_t)max_bytes + 1);
  if (!buf) {
    li_panic("alloc failed");
  }
  ssize_t n = recv((int)conn_fd, buf, (size_t)max_bytes, 0);
  if (n < 0) {
    free(buf);
    net_fail("recv");
  }
  buf[n] = '\0';
  return buf;
}

int32_t bytes_len(const char* b) {
  if (!b) {
    return 0;
  }
  return (int32_t)strlen(b);
}

const char* bytes_slice(const char* b, int32_t off, int32_t n) {
  if (!b || off < 0 || n < 0) {
    return li_rt_strdup_buf("", 0);
  }
  int32_t total = bytes_len(b);
  if (off > total) {
    off = total;
  }
  if (off + n > total) {
    n = total - off;
  }
  if (n < 0) {
    n = 0;
  }
  return li_rt_strdup_buf(b + off, (size_t)n);
}

const char* bytes_append(const char* a, const char* b) {
  int32_t la = bytes_len(a);
  int32_t lb = bytes_len(b);
  char* out = (char*)malloc((size_t)la + (size_t)lb + 1);
  if (!out) {
    li_panic("alloc failed");
  }
  if (la > 0 && a) {
    memcpy(out, a, (size_t)la);
  }
  if (lb > 0 && b) {
    memcpy(out + la, b, (size_t)lb);
  }
  out[la + lb] = '\0';
  if (a && la > 0) {
    free((void*)a);
  }
  return out;
}

int32_t net_byte_at(const char* b, int32_t off) {
  if (!b || off < 0 || off >= bytes_len(b)) {
    return -1;
  }
  return (int32_t)(unsigned char)b[off];
}

int32_t net_atoi(const char* s) {
  if (!s) {
    return 0;
  }
  return (int32_t)atoi(s);
}

intptr_t tcp_recv_i(int32_t conn, int32_t max) { return iptr(tcp_recv(conn, max)); }

int32_t tcp_send_i(int32_t conn, intptr_t data) { return tcp_send(conn, ptr_i(data)); }

intptr_t li_rt_argv_i(int32_t index) { return iptr(li_rt_argv(index)); }

int32_t bytes_len_i(intptr_t b) { return bytes_len(ptr_i(b)); }

intptr_t bytes_slice_i(intptr_t b, int32_t off, int32_t n) {
  return iptr(bytes_slice(ptr_i(b), off, n));
}

intptr_t bytes_append_i(intptr_t a, intptr_t b) { return iptr(bytes_append(ptr_i(a), ptr_i(b))); }

int32_t net_byte_at_i(intptr_t b, int32_t off) { return net_byte_at(ptr_i(b), off); }

int32_t httpd_parse_port_i(intptr_t s) { return net_atoi(ptr_i(s)); }

static const char* str_cat2(const char* a, const char* b) {
  int32_t la = bytes_len(a);
  int32_t lb = bytes_len(b);
  char* out = (char*)malloc((size_t)la + (size_t)lb + 1);
  if (!out) {
    li_panic("alloc failed");
  }
  if (la > 0 && a) {
    memcpy(out, a, (size_t)la);
  }
  if (lb > 0 && b) {
    memcpy(out + la, b, (size_t)lb);
  }
  out[la + lb] = '\0';
  return out;
}

intptr_t str_cat2_i(intptr_t a, intptr_t b) { return iptr(str_cat2(ptr_i(a), ptr_i(b))); }

intptr_t net_lit_index_html_i(void) { return iptr("/index.html"); }

intptr_t net_lit_loopback_i(void) { return iptr("127.0.0.1"); }

static void httpd_proxy_snap_reset(void) {
  g_proxy_snap_ready = 0;
  g_proxy_snap_recording = 0;
  g_proxy_snap_len = 0;
}

int32_t httpd_set_proxy_upstream_port_i(int32_t port, int32_t proxy_all) {
  httpd_proxy_snap_reset();
  if (port <= 0 || port > 65535) {
    return -1;
  }
  strncpy(g_proxy_host, "127.0.0.1", sizeof(g_proxy_host) - 1);
  g_proxy_host[sizeof(g_proxy_host) - 1] = '\0';
  g_proxy_port = port;
  g_proxy_all = proxy_all ? 1 : 0;
  if (httpd_add_upstream_peer_i(port) < 0) {
    return -1;
  }
  upstream_pool_prewarm_all();
  return 0;
}

int32_t httpd_set_upstream_ports_csv_i(intptr_t csv, int32_t proxy_all) {
  const char* s = ptr_i(csv);
  if (!s) {
    return -1;
  }
  httpd_clear_upstream_peers_i();
  g_proxy_all = proxy_all ? 1 : 0;
  strncpy(g_proxy_host, "127.0.0.1", sizeof(g_proxy_host) - 1);
  g_proxy_host[sizeof(g_proxy_host) - 1] = '\0';
  int count = 0;
  while (*s) {
    while (*s == ' ' || *s == ',') {
      s++;
    }
    if (!*s) {
      break;
    }
    int port = 0;
    while (*s >= '0' && *s <= '9') {
      port = port * 10 + (*s - '0');
      s++;
    }
    if (port > 0 && port <= 65535) {
      if (httpd_add_upstream_peer_i(port) == 0) {
        count++;
        g_proxy_port = port;
      }
    }
    while (*s && *s != ',') {
      s++;
    }
  }
  if (count > 0) {
    httpd_proxy_snap_reset();
    upstream_pool_prewarm_all();
  }
  return count > 0 ? count : -1;
}

int32_t httpd_set_proxy_upstream_i(int32_t host, int32_t port, int32_t proxy_all) {
  const char* h = ptr_i(host);
  if (!h || port <= 0 || port > 65535) {
    return -1;
  }
  if (strcmp(h, "127.0.0.1") != 0 && strcmp(h, "::1") != 0) {
    return -1;
  }
  strncpy(g_proxy_host, h, sizeof(g_proxy_host) - 1);
  g_proxy_host[sizeof(g_proxy_host) - 1] = '\0';
  g_proxy_port = port;
  g_proxy_all = proxy_all ? 1 : 0;
  return 0;
}

int32_t net_set_nonblock(int32_t fd) { return set_nonblocking((int)fd); }

int32_t net_tcp_ack_now(int32_t fd) {
  tcp_ack_now(fd);
  return 0;
}

int32_t tcp_accept_nb(int32_t listen_fd) {
  int c = accept((int)listen_fd, NULL, NULL);
  if (c < 0) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return -1;
    }
    net_fail("accept");
  }
  return (int32_t)c;
}

int32_t tcp_recv_slot(int32_t conn, int32_t slot, int32_t max_bytes) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -2;
  }
  if (g_slots[slot].fd != conn) {
    return -2;
  }
  if (max_bytes <= 0) {
    max_bytes = HTTPD_IO_BUF;
  }
  if (g_slots[slot].len >= HTTPD_IO_BUF) {
    return -2;
  }
  tcp_ack_now(conn);
  ssize_t r = recv((int)conn, g_slots[slot].buf + g_slots[slot].len,
                   (size_t)(HTTPD_IO_BUF - g_slots[slot].len), 0);
  if (r < 0) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return -1;
    }
    return -2;
  }
  if (r == 0) {
    return 0;
  }
  g_slots[slot].len += (int)r;
  return (int32_t)r;
}

int32_t tcp_send_buf(int32_t conn, intptr_t data, int32_t off, int32_t n) {
  if (!data || n <= 0) {
    return 0;
  }
  ssize_t rc = send_all_nb((int)conn, ptr_i(data) + off, (size_t)n);
  return rc < 0 ? -1 : n;
}

int32_t tcp_send_coalesce_i(int32_t conn, intptr_t a, int32_t la, intptr_t b, int32_t lb) {
  if (la < 0) {
    la = 0;
  }
  if (lb < 0) {
    lb = 0;
  }
  if (la == 0 && lb == 0) {
    return 0;
  }
#ifdef __linux__
  struct iovec iov[2];
  int iovcnt = 0;
  if (la > 0 && a) {
    iov[iovcnt].iov_base = ptr_i(a);
    iov[iovcnt].iov_len = (size_t)la;
    iovcnt++;
  }
  if (lb > 0 && b) {
    iov[iovcnt].iov_base = ptr_i(b);
    iov[iovcnt].iov_len = (size_t)lb;
    iovcnt++;
  }
  if (iovcnt == 0) {
    return 0;
  }
  int idx = 0;
  while (idx < iovcnt) {
    ssize_t n = writev((int)conn, iov + idx, iovcnt - idx);
    if (n < 0) {
      if (errno == EINTR) {
        continue;
      }
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        if (wait_writable((int)conn) < 0) {
          return -1;
        }
        continue;
      }
      return -1;
    }
    if (n == 0) {
      return -1;
    }
    size_t rem = (size_t)n;
    while (rem > 0 && idx < iovcnt) {
      if (rem >= iov[idx].iov_len) {
        rem -= iov[idx].iov_len;
        idx++;
      } else {
        iov[idx].iov_base = (char*)iov[idx].iov_base + rem;
        iov[idx].iov_len -= rem;
        rem = 0;
      }
    }
  }
  return 0;
#else
  size_t total = (size_t)la + (size_t)lb;
  char* blob = (char*)malloc(total);
  if (!blob) {
    return -1;
  }
  if (la > 0 && a) {
    memcpy(blob, ptr_i(a), (size_t)la);
  }
  if (lb > 0 && b) {
    memcpy(blob + la, ptr_i(b), (size_t)lb);
  }
  ssize_t rc = send_all_nb((int)conn, blob, total);
  free(blob);
  return rc < 0 ? -1 : 0;
#endif
}

int32_t net_events_fd(intptr_t events, int32_t index) {
  return ((int32_t*)ptr_i(events))[index * 2];
}

int32_t net_events_revents(intptr_t events, int32_t index) {
  return ((int32_t*)ptr_i(events))[index * 2 + 1];
}

int32_t net_events_tagged_lo(intptr_t events, int32_t index) {
  return ((int32_t*)ptr_i(events))[index * 3];
}

int32_t net_events_tagged_hi(intptr_t events, int32_t index) {
  return ((int32_t*)ptr_i(events))[index * 3 + 1];
}

int32_t net_events_tagged_revents(intptr_t events, int32_t index) {
  return ((int32_t*)ptr_i(events))[index * 3 + 2];
}

static int32_t g_net_events_loaded[3];

void net_events_tagged_load_i(intptr_t events, int32_t index) {
  int32_t* e = (int32_t*)ptr_i(events);
  g_net_events_loaded[0] = e[index * 3];
  g_net_events_loaded[1] = e[index * 3 + 1];
  g_net_events_loaded[2] = e[index * 3 + 2];
}

int32_t net_events_loaded_lo_i(void) { return g_net_events_loaded[0]; }

int32_t net_events_loaded_hi_i(void) { return g_net_events_loaded[1]; }

int32_t net_events_loaded_revents_i(void) { return g_net_events_loaded[2]; }

int32_t net_epoll_readable(int32_t revents) {
#ifdef __linux__
  return (revents & EPOLLIN) != 0;
#else
  (void)revents;
  return 0;
#endif
}

int32_t net_epoll_hangup(int32_t revents) {
#ifdef __linux__
  return (revents & (EPOLLERR | EPOLLHUP)) != 0;
#else
  (void)revents;
  return 0;
#endif
}

int32_t net_fill_not_found_i(intptr_t p) {
  if (!p) {
    return 0;
  }
  memcpy(ptr_i(p), "not found", 9);
  return 9;
}

int32_t net_buf_len(int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return 0;
  }
  return g_slots[slot].len;
}

intptr_t net_slot_buf_ptr(int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return 0;
  }
  return iptr(g_slots[slot].buf);
}

intptr_t httpd_slot_hdr_i(int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return 0;
  }
  return iptr(g_slots[slot].hdr);
}

int32_t httpd_prepare_root_i(intptr_t root) {
  const char* r = ptr_i(root);
  if (!r) {
    return -1;
  }
  g_doc_root_len = strlen(r);
  if (g_doc_root_len == 0 || g_doc_root_len >= sizeof(g_doc_root)) {
    return -1;
  }
  memcpy(g_doc_root, r, g_doc_root_len + 1);
  char path[4096];
  int n = snprintf(path, sizeof(path), "%s/index.html", r);
  if (n < 0 || n >= (int)sizeof(path)) {
    return -1;
  }
  g_cache_ready = 0;
  g_cached_sz = 0;
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    return 0;
  }
  struct stat st;
  if (fstat(fd, &st) < 0 || !S_ISREG(st.st_mode) || st.st_size > HTTPD_IO_BUF) {
    close(fd);
    return 0;
  }
  ssize_t rd = read(fd, g_cached_body, (size_t)st.st_size);
  close(fd);
  if (rd < 0) {
    return 0;
  }
  g_cached_sz = (int32_t)rd;
  g_cached_blob_ka_len = snprintf(g_cached_blob_ka, sizeof(g_cached_blob_ka),
                                  "HTTP/1.1 200 OK\r\n"
                                  "Content-Type: text/html\r\n"
                                  "Content-Length: %d\r\n"
                                  "Connection: keep-alive\r\n"
                                  "\r\n",
                                  (int)g_cached_sz);
  if (g_cached_blob_ka_len < 0 || g_cached_blob_ka_len >= (int32_t)sizeof(g_cached_blob_ka) - g_cached_sz) {
    return -1;
  }
  memcpy(g_cached_blob_ka + g_cached_blob_ka_len, g_cached_body, (size_t)g_cached_sz);
  g_cached_blob_ka_len += g_cached_sz;

  g_cached_blob_close_len = snprintf(g_cached_blob_close, sizeof(g_cached_blob_close),
                                     "HTTP/1.1 200 OK\r\n"
                                     "Content-Type: text/html\r\n"
                                     "Content-Length: %d\r\n"
                                     "Connection: close\r\n"
                                     "\r\n",
                                     (int)g_cached_sz);
  if (g_cached_blob_close_len < 0 ||
      g_cached_blob_close_len >= (int32_t)sizeof(g_cached_blob_close) - g_cached_sz) {
    return -1;
  }
  memcpy(g_cached_blob_close + g_cached_blob_close_len, g_cached_body, (size_t)g_cached_sz);
  g_cached_blob_close_len += g_cached_sz;

  g_cache_ready = 1;
  return 0;
}

int32_t httpd_cache_ready_i(void) { return g_cache_ready; }

intptr_t httpd_cached_body_i(void) { return iptr(g_cached_body); }

int32_t httpd_cached_sz_i(void) { return g_cached_sz; }

int32_t httpd_reply_cached_index_i(int32_t conn, int32_t slot, int32_t keep_alive) {
  if (!g_cache_ready || g_cached_sz <= 0 || slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  (void)slot;
  tcp_ack_now(conn);
  if (keep_alive) {
    if (send_all_nb((int)conn, g_cached_blob_ka, (size_t)g_cached_blob_ka_len) < 0) {
      return -1;
    }
    return 0;
  }
  if (send_all_nb((int)conn, g_cached_blob_close, (size_t)g_cached_blob_close_len) < 0) {
    return -1;
  }
  return 0;
}

static int hdr_end_at_c(const char* buf, int len) {
  for (int i = 0; i + 3 < len; i++) {
    if (buf[i] == '\r' && buf[i + 1] == '\n' && buf[i + 2] == '\r' && buf[i + 3] == '\n') {
      return i + 4;
    }
  }
  return -1;
}

static int wants_connection_close(const char* buf, int hdr_end) {
  for (int i = 0; i + 10 < hdr_end; i++) {
    if (buf[i] == 'C' && buf[i + 10] == ':') {
      for (int j = i + 11; j < hdr_end; j++) {
        if (buf[j] == 'c' || buf[j] == 'C') {
          return 1;
        }
      }
    }
  }
  return 0;
}

static int is_index_get(const char* buf, int hdr_end) {
  if (hdr_end < 9 || memcmp(buf, "GET ", 4) != 0) {
    return 0;
  }
  if (memcmp(buf + 4, "/ ", 2) == 0) {
    return 1;
  }
  if (hdr_end >= 18 && memcmp(buf + 4, "/index.html ", 12) == 0) {
    return 1;
  }
  if (memcmp(buf + 4, "/ HTTP", 6) == 0) {
    return 1;
  }
  return 0;
}

static int parse_request_line_c(const char* buf, int hdr_end, httpd_req_info_t* info) {
  if (!info || hdr_end < 16) {
    return -1;
  }
  memset(info, 0, sizeof(*info));
  const char* line_end = buf + hdr_end;
  const char* sp1 = (const char*)memchr(buf, ' ', (size_t)(line_end - buf));
  if (!sp1) {
    return -1;
  }
  info->method_len = (int)(sp1 - buf);
  if (info->method_len <= 0 || info->method_len >= (int)sizeof(info->method)) {
    return -1;
  }
  memcpy(info->method, buf, (size_t)info->method_len);
  info->method[info->method_len] = '\0';
  const char* sp2 = (const char*)memchr(sp1 + 1, ' ', (size_t)(line_end - (sp1 + 1)));
  if (!sp2) {
    return -1;
  }
  const char* path_start = sp1 + 1;
  int plen = (int)(sp2 - path_start);
  if (plen <= 0 || plen >= (int)sizeof(info->path)) {
    return -1;
  }
  memcpy(info->path, path_start, (size_t)plen);
  info->path[plen] = '\0';
  info->path_len = plen;
  if (plen > 7 && memcmp(info->path, "http://", 7) == 0) {
    const char* slash = strchr(info->path + 7, '/');
    if (slash) {
      int new_len = (int)strlen(slash);
      if (new_len > 0 && new_len < (int)sizeof(info->path)) {
        memmove(info->path, slash, (size_t)new_len + 1);
        info->path_len = new_len;
      }
    }
  }
  return 0;
}

static int parse_get_path_c(const char* buf, int hdr_end, char* out, int out_cap) {
  httpd_req_info_t info;
  if (parse_request_line_c(buf, hdr_end, &info) != 0) {
    return -1;
  }
  if (info.method_len != 3 || memcmp(info.method, "GET", 3) != 0) {
    return -1;
  }
  if (info.path_len <= 0 || info.path_len >= out_cap) {
    return -1;
  }
  memcpy(out, info.path, (size_t)info.path_len);
  out[info.path_len] = '\0';
  return info.path_len;
}

static int hdr_has_token_c(const char* buf, int hdr_end, const char* token) {
  int tlen = (int)strlen(token);
  for (int i = 0; i + tlen <= hdr_end; i++) {
    if (memcmp(buf + i, token, (size_t)tlen) == 0) {
      return 1;
    }
  }
  return 0;
}

static int count_content_length_c(const char* buf, int hdr_end) {
  int count = 0;
  for (int i = 0; i + 15 < hdr_end; i++) {
    if (memcmp(buf + i, "Content-Length:", 15) == 0) {
      count++;
    }
  }
  return count;
}

/* Smuggling class only — duplicate CL and CL+TE conflict; chunked alone is allowed with limits. */
static int request_headers_unsafe_c(const char* buf, int hdr_end) {
  if (count_content_length_c(buf, hdr_end) > 1) {
    return 1;
  }
  if (count_content_length_c(buf, hdr_end) > 0 && hdr_has_token_c(buf, hdr_end, "Transfer-Encoding:") &&
      hdr_has_token_c(buf, hdr_end, "chunked")) {
    return 1;
  }
  int lines = 0;
  for (int i = 0; i < hdr_end; i++) {
    if (buf[i] == '\n') {
      lines++;
      if (lines > HTTPD_MAX_HEADER_LINES) {
        return 1;
      }
    }
  }
  return 0;
}

static void parse_request_body_meta_c(const char* buf, int hdr_end, httpd_req_info_t* info) {
  info->body_mode = 0;
  info->content_length = 0;
  if (hdr_has_token_c(buf, hdr_end, "Transfer-Encoding:") && hdr_has_token_c(buf, hdr_end, "chunked")) {
    info->body_mode = 2;
    return;
  }
  for (int i = 0; i + 15 < hdr_end; i++) {
    if (memcmp(buf + i, "Content-Length:", 15) == 0) {
      i += 15;
      while (i < hdr_end && (buf[i] == ' ' || buf[i] == '\t')) {
        i++;
      }
      int v = 0;
      while (i < hdr_end && buf[i] >= '0' && buf[i] <= '9') {
        v = v * 10 + (buf[i] - '0');
        if (v > HTTPD_MAX_BODY) {
          v = HTTPD_MAX_BODY + 1;
          break;
        }
        i++;
      }
      info->body_mode = 1;
      info->content_length = v;
      return;
    }
  }
}

static void parse_response_body_meta_c(const char* buf, int hdr_end, int* body_mode, int* content_length) {
  *body_mode = PROXY_RESP_BODY_CLOSE;
  *content_length = 0;
  if (hdr_has_token_c(buf, hdr_end, "Transfer-Encoding:") && hdr_has_token_c(buf, hdr_end, "chunked")) {
    *body_mode = PROXY_RESP_BODY_CHUNKED;
    return;
  }
  for (int i = 0; i + 15 < hdr_end; i++) {
    if (memcmp(buf + i, "Content-Length:", 15) == 0) {
      i += 15;
      while (i < hdr_end && (buf[i] == ' ' || buf[i] == '\t')) {
        i++;
      }
      int v = 0;
      while (i < hdr_end && buf[i] >= '0' && buf[i] <= '9') {
        v = v * 10 + (buf[i] - '0');
        if (v > HTTPD_MAX_BODY) {
          v = HTTPD_MAX_BODY + 1;
          break;
        }
        i++;
      }
      *body_mode = PROXY_RESP_BODY_CL;
      *content_length = v;
      return;
    }
  }
  if (hdr_has_token_c(buf, hdr_end, "Connection:")) {
    for (int i = 0; i + 12 < hdr_end; i++) {
      if (memcmp(buf + i, "Connection:", 11) == 0) {
        i += 11;
        while (i < hdr_end && (buf[i] == ' ' || buf[i] == '\t')) {
          i++;
        }
        if (i + 5 <= hdr_end && memcmp(buf + i, "close", 5) == 0) {
          *body_mode = PROXY_RESP_BODY_CLOSE;
        } else if (i + 10 <= hdr_end && memcmp(buf + i, "keep-alive", 10) == 0) {
          *body_mode = PROXY_RESP_BODY_NONE;
        }
        return;
      }
    }
  }
}

static int method_is(const httpd_req_info_t* info, const char* m) {
  int ml = (int)strlen(m);
  return info->method_len == ml && memcmp(info->method, m, (size_t)ml) == 0;
}

static int32_t httpd_send_status(int32_t conn, int status, const char* phrase, const char* extra, int keep) {
  char hdr[512];
  int hlen = snprintf(hdr, sizeof(hdr),
                      "HTTP/1.1 %d %s\r\n"
                      "%s"
                      "Content-Length: 0\r\n"
                      "Connection: %s\r\n"
                      "\r\n",
                      status, phrase, extra ? extra : "", keep ? "keep-alive" : "close");
  if (hlen < 0 || hlen >= (int)sizeof(hdr)) {
    return -1;
  }
  return send_all_nb((int)conn, hdr, (size_t)hlen) < 0 ? -1 : 0;
}

static int path_is_safe(const char* path, int plen) {
  if (plen <= 0 || plen > 2048 || path[0] != '/') {
    return 0;
  }
  if (plen >= 2 && path[0] == '/' && path[1] == '/') {
    return 0;
  }
  for (int i = 0; i < plen; i++) {
    if (path[i] == '%' || path[i] == '\\') {
      return 0;
    }
  }
  for (int i = 0; i < plen - 1; i++) {
    if (path[i] == '.' && path[i + 1] == '.' && (i == 0 || path[i - 1] == '/')) {
      return 0;
    }
  }
  return 1;
}

static int tcp_connect_loopback_port(int port) {
  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons((uint16_t)port);
  if (inet_pton(AF_INET, g_proxy_host, &addr.sin_addr) <= 0) {
    return -1;
  }
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    return -1;
  }
  if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
    close(fd);
    return -1;
  }
  tcp_tune_client((int32_t)fd);
  return fd;
}

static httpd_upstream_peer_t* upstream_peer_find(int32_t port) {
  for (int i = 0; i < g_up_peer_count; i++) {
    if (g_up_peers[i].port == port) {
      return &g_up_peers[i];
    }
  }
  return NULL;
}

static httpd_upstream_peer_t* upstream_peer_get_or_add(int32_t port) {
  httpd_upstream_peer_t* p = upstream_peer_find(port);
  if (p) {
    return p;
  }
  if (g_up_peer_count >= HTTPD_MAX_UPSTREAM_PEERS) {
    return NULL;
  }
  p = &g_up_peers[g_up_peer_count++];
  memset(p, 0, sizeof(*p));
  p->port = port;
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    p->fds[i] = -1;
    p->in_use[i] = 0;
  }
  return p;
}

int32_t httpd_add_upstream_peer_i(int32_t port) {
  if (port <= 0 || port > 65535) {
    return -1;
  }
  if (!upstream_peer_get_or_add(port)) {
    return -1;
  }
  g_proxy_port = port;
  return 0;
}

void httpd_clear_upstream_peers_i(void) {
  for (int i = 0; i < g_up_peer_count; i++) {
    for (int j = 0; j < HTTPD_POOL_PER_PEER; j++) {
      if (g_up_peers[i].fds[j] >= 0) {
        close(g_up_peers[i].fds[j]);
        g_up_peers[i].fds[j] = -1;
      }
      g_up_peers[i].in_use[j] = 0;
    }
  }
  g_up_peer_count = 0;
  g_lb_rr = 0;
}

int32_t httpd_set_lb_mode_i(int32_t mode) {
  g_lb_mode = mode ? 1 : 0;
  return 0;
}

int32_t httpd_lb_mode_from_arg_i(intptr_t s) {
  const char* p = ptr_i(s);
  if (!p) {
    return 0;
  }
  if (strcmp(p, "least_conn") == 0) {
    return 1;
  }
  return 0;
}

static double httpd_monotonic_now(void) {
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
    return 0.0;
  }
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

static void httpd_upstream_close_pool_fds(httpd_upstream_peer_t* p) {
  if (!p) {
    return;
  }
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] >= 0) {
      close(p->fds[i]);
      p->fds[i] = -1;
      p->in_use[i] = 0;
    }
  }
}

static void httpd_upstream_peer_maybe_recover(httpd_upstream_peer_t* p) {
  if (!p || !p->down) {
    return;
  }
  double now = httpd_monotonic_now();
  if (p->down_until > 0.0 && now >= p->down_until) {
    p->down = 0;
    p->fail_count = 0;
    p->down_until = 0.0;
  }
}

static void httpd_upstream_peer_mark_down(httpd_upstream_peer_t* p) {
  if (!p) {
    return;
  }
  p->down = 1;
  p->down_until = httpd_monotonic_now() + (double)g_health_fail_timeout_sec;
  httpd_upstream_close_pool_fds(p);
}

static void httpd_upstream_peer_note_failure(int32_t port) {
  httpd_upstream_peer_t* p = upstream_peer_find(port);
  if (!p) {
    return;
  }
  p->fail_count++;
  if (p->fail_count >= g_health_max_fails) {
    httpd_upstream_peer_mark_down(p);
  }
}

static void httpd_upstream_peer_note_success(int32_t port) {
  httpd_upstream_peer_t* p = upstream_peer_find(port);
  if (!p) {
    return;
  }
  p->fail_count = 0;
  if (p->down && p->down_until > 0.0) {
    httpd_upstream_peer_maybe_recover(p);
  }
}

int32_t httpd_mark_upstream_peer_down_i(int32_t port) {
  httpd_upstream_peer_t* p = upstream_peer_find(port);
  if (!p) {
    return -1;
  }
  httpd_upstream_peer_mark_down(p);
  return 0;
}

static int32_t httpd_lb_pick_port(void) {
  if (g_up_peer_count <= 0) {
    return g_proxy_port;
  }
  for (int i = 0; i < g_up_peer_count; i++) {
    httpd_upstream_peer_maybe_recover(&g_up_peers[i]);
  }
  if (g_lb_mode == 0) {
    for (int tries = 0; tries < g_up_peer_count; tries++) {
      int idx = g_lb_rr % g_up_peer_count;
      g_lb_rr++;
      if (!g_up_peers[idx].down) {
        return g_up_peers[idx].port;
      }
    }
    return g_proxy_port;
  }
  int best = -1;
  int min_act = 2147483647;
  for (int i = 0; i < g_up_peer_count; i++) {
    if (g_up_peers[i].down) {
      continue;
    }
    if (g_up_peers[i].active < min_act) {
      min_act = g_up_peers[i].active;
      best = i;
    }
  }
  if (best < 0) {
    return g_proxy_port;
  }
  return g_up_peers[best].port;
}

static int upstream_pool_acquire(int32_t port) {
  httpd_upstream_peer_t* p = upstream_peer_get_or_add(port);
  if (p) {
    httpd_upstream_peer_maybe_recover(p);
  }
  if (p && p->down) {
    return -1;
  }
  if (!p) {
    int fd = tcp_connect_loopback_port((int)port);
    p = upstream_peer_get_or_add(port);
    if (fd >= 0 && p) {
      set_nonblocking(fd);
      p->active++;
      httpd_upstream_peer_note_success(port);
    } else if (p) {
      httpd_upstream_peer_note_failure(port);
    }
    return fd;
  }
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] >= 0 && !p->in_use[i]) {
      p->in_use[i] = 1;
      p->active++;
      httpd_upstream_peer_note_success(port);
      return p->fds[i];
    }
  }
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] < 0) {
      int fd = tcp_connect_loopback_port((int)port);
      if (fd < 0) {
        httpd_upstream_peer_note_failure(port);
        return -1;
      }
      set_nonblocking(fd);
      p->fds[i] = fd;
      p->in_use[i] = 1;
      p->active++;
      httpd_upstream_peer_note_success(port);
      return fd;
    }
  }
  {
    int fd = tcp_connect_loopback_port((int)port);
    if (fd >= 0) {
      set_nonblocking(fd);
      p->active++;
      httpd_upstream_peer_note_success(port);
    } else {
      httpd_upstream_peer_note_failure(port);
    }
    return fd;
  }
}

static void upstream_pool_release(int32_t port, int fd, int reuse) {
  httpd_upstream_peer_t* p = upstream_peer_find(port);
  if (!p) {
    close(fd);
    return;
  }
  if (p->active > 0) {
    p->active--;
  }
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] == fd) {
      p->in_use[i] = 0;
      if (!reuse) {
        close(fd);
        p->fds[i] = -1;
        httpd_upstream_peer_note_failure(port);
      } else if (httpd_fd_readable(fd) > 0) {
        httpd_drain_upstream_fd(fd);
      }
      return;
    }
  }
  close(fd);
}

static int httpd_fd_readable(int fd) {
  if (fd < 0) {
    return 0;
  }
  int pending = 0;
  if (ioctl(fd, FIONREAD, &pending) < 0) {
    return 0;
  }
  return pending;
}

static void httpd_drain_upstream_fd(int fd) {
  if (fd < 0) {
    return;
  }
  set_nonblocking(fd);
  char junk[8192];
  for (;;) {
    ssize_t r = recv(fd, junk, sizeof(junk), 0);
    if (r > 0) {
      continue;
    }
    if (r == 0) {
      return;
    }
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return;
    }
    return;
  }
}

static void upstream_pool_prewarm_all(void) {
  for (int i = 0; i < g_up_peer_count; i++) {
    if (g_up_peers[i].down) {
      continue;
    }
    for (int j = 0; j < HTTPD_POOL_PER_PEER; j++) {
      if (g_up_peers[i].fds[j] < 0) {
        int fd = tcp_connect_loopback_port(g_up_peers[i].port);
        if (fd >= 0) {
          set_nonblocking(fd);
          tcp_tune_client(fd);
          g_up_peers[i].fds[j] = fd;
          g_up_peers[i].in_use[j] = 0;
        }
      }
    }
  }
}

static int parse_resp_content_length(const char* hdr, int hdr_len, int* out_keep) {
  *out_keep = 0;
  int cl = -1;
  for (int i = 0; i + 15 < hdr_len; i++) {
    if (hdr[i] == 'C' && memcmp(hdr + i, "Content-Length:", 15) == 0) {
      i += 15;
      while (i < hdr_len && (hdr[i] == ' ' || hdr[i] == '\t')) {
        i++;
      }
      cl = 0;
      while (i < hdr_len && hdr[i] >= '0' && hdr[i] <= '9') {
        cl = cl * 10 + (hdr[i] - '0');
        i++;
      }
    }
    if (hdr[i] == 'C' && i + 10 < hdr_len && memcmp(hdr + i, "Connection:", 11) == 0) {
      for (int j = i + 11; j < hdr_len; j++) {
        if (hdr[j] == 'k' || hdr[j] == 'K') {
          *out_keep = 1;
          break;
        }
      }
    }
  }
  return cl;
}

static ssize_t read_blocking(int fd, void* buf, size_t n) {
  char* p = (char*)buf;
  size_t off = 0;
  while (off < n) {
    ssize_t r = read(fd, p + off, n - off);
    if (r < 0) {
      if (errno == EINTR) {
        continue;
      }
      return -1;
    }
    if (r == 0) {
      return (ssize_t)off;
    }
    off += (size_t)r;
  }
  return (ssize_t)off;
}

/* Nginx proxy_set_header Connection "" — drop Connection / Proxy-Connection lines to upstream. */
static int httpd_proxy_compact_req_hdr(int32_t slot, int hdr_end) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || hdr_end <= 0) {
    return hdr_end;
  }
  char* buf = g_slots[slot].buf;
  int w = 0;
  int i = 0;
  while (i < hdr_end) {
    int line_start = i;
    while (i + 1 < hdr_end && !(buf[i] == '\r' && buf[i + 1] == '\n')) {
      i++;
    }
    if (i + 1 >= hdr_end) {
      break;
    }
    i += 2;
    int line_len = i - line_start;
    int skip = 0;
    if (line_len >= 12 && memcmp(buf + line_start, "Connection:", 11) == 0) {
      skip = 1;
    } else if (line_len >= 18 && memcmp(buf + line_start, "Proxy-Connection:", 17) == 0) {
      skip = 1;
    }
    if (!skip) {
      if (w != line_start) {
        memmove(buf + w, buf + line_start, (size_t)line_len);
      }
      w += line_len;
    }
  }
  int tail = g_slots[slot].len - hdr_end;
  if (tail > 0) {
    memmove(buf + w, buf + hdr_end, (size_t)tail);
  }
  g_slots[slot].len = w + tail;
  return w;
}

static int path_prefix_match(const char* path, int plen, const httpd_route_t* r) {
  if (plen < r->path_len) {
    return 0;
  }
  if (memcmp(path, r->path_prefix, (size_t)r->path_len) != 0) {
    return 0;
  }
  if (!r->is_prefix) {
    return plen == r->path_len;
  }
  if (plen == r->path_len) {
    return 1;
  }
  return path[r->path_len] == '/';
}

static int route_method_match(const httpd_route_t* r, const httpd_req_info_t* req) {
  if (r->method[0] == '*') {
    return 1;
  }
  int rl = (int)strlen(r->method);
  return req->method_len == rl && memcmp(req->method, r->method, (size_t)rl) == 0;
}

static int path_proxy_match_route(const char* path, int plen, const httpd_req_info_t* req) {
  for (int i = 0; i < g_route_count; i++) {
    const httpd_route_t* r = &g_routes[i];
    if (!r->is_proxy) {
      continue;
    }
    if (!route_method_match(r, req)) {
      continue;
    }
    if (path_prefix_match(path, plen, r)) {
      return 1;
    }
  }
  return 0;
}

static int httpd_rate_bucket_allow(int rps, int burst, double* tokens, double* last_ts) {
  if (rps <= 0) {
    return 1;
  }
  if (burst <= 0) {
    burst = rps;
  }
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
    return 1;
  }
  double now = (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
  if (*last_ts <= 0.0) {
    *last_ts = now;
    *tokens = (double)burst;
  }
  double elapsed = now - *last_ts;
  *last_ts = now;
  if (elapsed > 0.0) {
    *tokens += elapsed * (double)rps;
  }
  if (*tokens > (double)burst) {
    *tokens = (double)burst;
  }
  if (*tokens < 1.0) {
    return 0;
  }
  *tokens -= 1.0;
  return 1;
}

static int httpd_rate_limit_allow(void) {
  return httpd_rate_bucket_allow(g_rate_limit_rps, g_rate_limit_burst, &g_rate_tokens,
                                 &g_rate_last_ts);
}

static int httpd_match_route_index(const char* path, int plen, const httpd_req_info_t* req) {
  for (int i = 0; i < g_route_count; i++) {
    const httpd_route_t* r = &g_routes[i];
    if (!route_method_match(r, req)) {
      continue;
    }
    if (path_prefix_match(path, plen, r)) {
      return i;
    }
  }
  return -1;
}

static int httpd_rate_limit_allow_request(const char* path, int plen, const httpd_req_info_t* req) {
  int idx = httpd_match_route_index(path, plen, req);
  if (idx >= 0) {
    httpd_route_t* r = &g_routes[idx];
    if (r->rate_limit_rps > 0) {
      return httpd_rate_bucket_allow(r->rate_limit_rps, r->rate_limit_burst, &r->rate_tokens,
                                   &r->rate_last_ts);
    }
  }
  return httpd_rate_limit_allow();
}

static void httpd_access_log(const httpd_req_info_t* req, int status, int bytes_out) {
  struct timespec ts;
  if (clock_gettime(CLOCK_REALTIME, &ts) != 0) {
    return;
  }
  char tbuf[32];
  struct tm tm;
  if (gmtime_r(&ts.tv_sec, &tm) == NULL) {
    return;
  }
  strftime(tbuf, sizeof(tbuf), "%Y-%m-%dT%H:%M:%SZ", &tm);
  char pathbuf[256];
  int plen = req->path_len;
  if (plen <= 0 || plen >= (int)sizeof(pathbuf)) {
    snprintf(pathbuf, sizeof(pathbuf), "/");
  } else {
    memcpy(pathbuf, req->path, (size_t)plen);
    pathbuf[plen] = '\0';
  }
  char mbuf[16];
  int ml = req->method_len;
  if (ml <= 0 || ml >= (int)sizeof(mbuf)) {
    snprintf(mbuf, sizeof(mbuf), "GET");
  } else {
    memcpy(mbuf, req->method, (size_t)ml);
    mbuf[ml] = '\0';
  }
  li_rt_log_access_line(tbuf, mbuf, pathbuf, status, bytes_out);
}

static int path_proxy_match(const char* path, int plen, const httpd_req_info_t* req) {
  if (g_proxy_port <= 0) {
    return 0;
  }
  if (path_proxy_match_route(path, plen, req)) {
    return 1;
  }
  if (g_proxy_all) {
    return 1;
  }
  if (plen >= 4 && memcmp(path, "/v1", 3) == 0) {
    return 1;
  }
  return 0;
}

static int httpd_read_more_client(int conn, char* dst, int want) {
  int got = 0;
  while (got < want) {
    ssize_t r = recv(conn, dst + got, (size_t)(want - got), 0);
    if (r < 0) {
      if (errno == EINTR) {
        continue;
      }
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        struct pollfd pfd = {.fd = conn, .events = POLLIN};
        if (poll(&pfd, 1, 5000) <= 0) {
          return -1;
        }
        continue;
      }
      return -1;
    }
    if (r == 0) {
      return -1;
    }
    got += (int)r;
  }
  return got;
}

static int httpd_forward_body_cl(int conn, int up, int32_t slot, int hdr_end, int body_left) {
  if (body_left <= 0) {
    return 0;
  }
  if (body_left > HTTPD_MAX_BODY) {
    return -1;
  }
  int in_slot = g_slots[slot].len - hdr_end;
  if (in_slot > 0) {
    int n = in_slot > body_left ? body_left : in_slot;
    if (send_all_nb(up, g_slots[slot].buf + hdr_end, (size_t)n) < 0) {
      return -1;
    }
    body_left -= n;
  }
  char tmp[8192];
  while (body_left > 0) {
    int chunk = body_left > (int)sizeof(tmp) ? (int)sizeof(tmp) : body_left;
    if (httpd_read_more_client(conn, tmp, chunk) < 0) {
      return -1;
    }
    if (send_all_nb(up, tmp, (size_t)chunk) < 0) {
      return -1;
    }
    body_left -= chunk;
  }
  return 0;
}

static int httpd_forward_body_chunked(int conn, int up);

static int httpd_discard_request_body(int conn, int32_t slot, int hdr_end, const httpd_req_info_t* req) {
  if (req->body_mode == 0) {
    return 0;
  }
  if (req->body_mode == 1) {
    int body_left = req->content_length - (g_slots[slot].len - hdr_end);
    if (body_left <= 0) {
      return 0;
    }
    char tmp[8192];
    while (body_left > 0) {
      int chunk = body_left > (int)sizeof(tmp) ? (int)sizeof(tmp) : body_left;
      if (httpd_read_more_client(conn, tmp, chunk) < 0) {
        return -1;
      }
      body_left -= chunk;
    }
    return 0;
  }
  char sink = 0;
  (void)sink;
  return httpd_forward_body_chunked(conn, -1);
}

static int httpd_forward_body_chunked(int conn, int up) {
  char line[128];
  int total = 0;
  int discard = (up < 0);
  for (;;) {
    int li = 0;
    while (li + 1 < (int)sizeof(line)) {
      ssize_t r = recv(conn, line + li, 1, 0);
      if (r <= 0) {
        return -1;
      }
      li++;
      if (li >= 2 && line[li - 1] == '\n' && line[li - 2] == '\r') {
        break;
      }
    }
    line[li] = '\0';
    int chunk_sz = (int)strtol(line, NULL, 16);
    if (chunk_sz < 0) {
      return -1;
    }
    if (chunk_sz == 0) {
      char crlf[2];
      if (httpd_read_more_client(conn, crlf, 2) < 0) {
        return -1;
      }
      return 0;
    }
    total += chunk_sz;
    if (total > HTTPD_MAX_BODY) {
      return -1;
    }
    char tmp[8192];
    int left = chunk_sz;
    while (left > 0) {
      int n = left > (int)sizeof(tmp) ? (int)sizeof(tmp) : left;
      if (httpd_read_more_client(conn, tmp, n) < 0) {
        return -1;
      }
      if (!discard && send_all_nb(up, tmp, (size_t)n) < 0) {
        return -1;
      }
      left -= n;
    }
    char crlf[2];
    if (httpd_read_more_client(conn, crlf, 2) < 0) {
      return -1;
    }
  }
}

static int httpd_proxy_relay_response(int conn, int up) {
  char buf[HTTPD_PROXY_RELAY_BUF];
  size_t total = 0;
  set_nonblocking(up);
  for (;;) {
    struct pollfd pfd = {.fd = up, .events = POLLIN};
    int pr = poll(&pfd, 1, 30000);
    if (pr < 0 && errno == EINTR) {
      continue;
    }
    if (pr <= 0) {
      return -1;
    }
    ssize_t r = recv(up, buf, sizeof(buf), 0);
    if (r < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        continue;
      }
      return -1;
    }
    if (r == 0) {
      break;
    }
    if (send_all_nb(conn, buf, (size_t)r) < 0) {
      return -1;
    }
    total += (size_t)r;
    if (total > (size_t)(HTTPD_MAX_BODY + HTTPD_PROXY_RELAY_BUF)) {
      return -1;
    }
    pfd.events = POLLIN;
    if (poll(&pfd, 1, 0) <= 0) {
      break;
    }
  }
  return 0;
}

static int32_t httpd_proxy_forward(int32_t conn, int32_t slot, int hdr_end, const httpd_req_info_t* req) {
  int32_t peer_port = httpd_lb_pick_port();
  if (peer_port <= 0) {
    return -1;
  }
  int up = upstream_pool_acquire(peer_port);
  if (up < 0 && g_up_peer_count > 1) {
    for (int i = 0; i < g_up_peer_count; i++) {
      if (g_up_peers[i].down || g_up_peers[i].port == peer_port) {
        continue;
      }
      peer_port = g_up_peers[i].port;
      up = upstream_pool_acquire(peer_port);
      if (up >= 0) {
        break;
      }
    }
  }
  if (up < 0) {
    return -1;
  }
  tcp_tune_client(up);
  if (send_all_nb(up, g_slots[slot].buf, (size_t)hdr_end) < 0) {
    upstream_pool_release(peer_port, up, 0);
    return -1;
  }
  if (req->body_mode == 1) {
    if (httpd_forward_body_cl(conn, up, slot, hdr_end, req->content_length) < 0) {
      upstream_pool_release(peer_port, up, 0);
      return -1;
    }
  } else if (req->body_mode == 2) {
    int in_slot = g_slots[slot].len - hdr_end;
    if (in_slot > 0) {
      if (send_all_nb(up, g_slots[slot].buf + hdr_end, (size_t)in_slot) < 0) {
        upstream_pool_release(peer_port, up, 0);
        return -1;
      }
    }
    if (httpd_forward_body_chunked(conn, up) < 0) {
      upstream_pool_release(peer_port, up, 0);
      return -1;
    }
  }
  if (httpd_proxy_relay_response(conn, up) < 0) {
    upstream_pool_release(peer_port, up, 0);
    return -1;
  }
  upstream_pool_release(peer_port, up, 1);
  return 0;
}

static int is_index_path_c(const char* path, int plen) {
  if (plen == 1 && path[0] == '/') {
    return 1;
  }
  if (plen == 11 && memcmp(path, "/index.html", 11) == 0) {
    return 1;
  }
  return 0;
}

static int32_t httpd_send_static_path(int32_t conn, int32_t slot, const char* rel, int plen, int keep) {
  slots_init_once();
  if (g_doc_root_len == 0 || slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  char filepath[4096];
  int n = snprintf(filepath, sizeof(filepath), "%s%.*s", g_doc_root, plen, rel);
  if (n < 0 || n >= (int)sizeof(filepath)) {
    return -1;
  }
  int fd = open(filepath, O_RDONLY);
  if (fd < 0) {
    return -1;
  }
  struct stat st;
  if (fstat(fd, &st) < 0 || !S_ISREG(st.st_mode)) {
    close(fd);
    return -1;
  }
  if (st.st_size > 0x7fffffff) {
    close(fd);
    return -1;
  }
  int32_t body_len = (int32_t)st.st_size;
  const char* ctype = "application/octet-stream";
  if (plen >= 5 && memcmp(rel + plen - 5, ".html", 5) == 0) {
    ctype = "text/html";
  }
  int hlen = snprintf(g_slots[slot].hdr, sizeof(g_slots[slot].hdr),
                      "HTTP/1.1 200 OK\r\n"
                      "Content-Type: %s\r\n"
                      "Content-Length: %d\r\n"
                      "Connection: %s\r\n"
                      "\r\n",
                      ctype, (int)body_len, keep ? "keep-alive" : "close");
  if (hlen < 0 || hlen >= (int)sizeof(g_slots[slot].hdr)) {
    close(fd);
    return -1;
  }
  tcp_ack_now(conn);
  if (body_len > 16384) {
    if (send_all_nb((int)conn, g_slots[slot].hdr, (size_t)hlen) < 0) {
      close(fd);
      return -1;
    }
    if (net_sendfile_fd(conn, fd, body_len) < 0) {
      close(fd);
      return -1;
    }
    close(fd);
    return 0;
  }
  if (body_len > 0) {
    char* body = (char*)malloc((size_t)body_len);
    if (!body) {
      close(fd);
      return -1;
    }
    ssize_t rd = read(fd, body, (size_t)body_len);
    close(fd);
    if (rd != (ssize_t)body_len) {
      free(body);
      return -1;
    }
    if (tcp_send_coalesce_i(conn, iptr(g_slots[slot].hdr), hlen, iptr(body), body_len) < 0) {
      free(body);
      return -1;
    }
    free(body);
    return 0;
  }
  close(fd);
  if (send_all_nb((int)conn, g_slots[slot].hdr, (size_t)hlen) < 0) {
    return -1;
  }
  return 0;
}

static void httpd_serve_conn_epoll(int epfd, int32_t slot);
static void httpd_conn_close_slot(int epfd, int32_t slot);
static void httpd_proxy_client_epoll_mod(int epfd, int32_t slot, uint32_t events);
static void httpd_proxy_pump_relay(int epfd, int32_t slot);
static int httpd_proxy_start_async(int epfd, int32_t conn, int32_t slot, int hdr_end, const httpd_req_info_t* req,
                                   int keep);

static ssize_t httpd_send_nb(int fd, const char* data, size_t total, size_t* off);

/* 0 = need bytes; 1 = served keep-alive; -1 = close after reply; -2 = I/O error */
static int32_t httpd_try_drain_once(int32_t conn, int32_t slot) {
  slots_init_once();
  if (g_doc_root_len == 0 || slot < 0 || slot >= HTTPD_MAX_CONN || g_slots[slot].fd != conn) {
    return -2;
  }
  if (g_slots[slot].proxy_active) {
    return 0;
  }
  int len = g_slots[slot].len;
  if (len <= 0) {
    return 0;
  }
  int hdr_end = hdr_end_at_c(g_slots[slot].buf, len);
  if (hdr_end < 0) {
    return 0;
  }
  httpd_req_info_t req;
  memset(&req, 0, sizeof(req));
  if (request_headers_unsafe_c(g_slots[slot].buf, hdr_end)) {
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_send_status(conn, 400, "Bad Request", NULL, keep) < 0) {
      return -2;
    }
    return keep ? 1 : -1;
  }
  if (parse_request_line_c(g_slots[slot].buf, hdr_end, &req) != 0) {
    return -2;
  }
  parse_request_body_meta_c(g_slots[slot].buf, hdr_end, &req);
  if (req.body_mode == 1 && req.content_length > HTTPD_MAX_BODY) {
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_send_status(conn, 413, "Payload Too Large", NULL, keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 413, 0);
    return keep ? 1 : -1;
  }
  if (!path_is_safe(req.path, req.path_len)) {
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_send_status(conn, 400, "Bad Request", NULL, keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 400, 0);
    return keep ? 1 : -1;
  }
  int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
  if (!httpd_rate_limit_allow_request(req.path, req.path_len, &req)) {
    if (httpd_send_status(conn, 429, "Too Many Requests",
                          "Retry-After: 1\r\n", keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 429, 0);
    net_slot_consume(slot, hdr_end);
    return keep ? 1 : -1;
  }
  if (path_proxy_match(req.path, req.path_len, &req)) {
    if (g_li_proxy_mode) {
      return 0;
    }
    if (g_proxy_snap_ready && method_is(&req, "GET")) {
      size_t off = 0;
      ssize_t rc = httpd_send_nb(conn, g_proxy_snap, (size_t)g_proxy_snap_len, &off);
      if (rc < 0) {
        return -2;
      }
      if (rc == 0 && off < (size_t)g_proxy_snap_len) {
        return -2;
      }
      net_slot_consume(slot, hdr_end);
      return keep ? 1 : -1;
    }
    if (g_httpd_epfd < 0) {
      return -2;
    }
#ifdef __linux__
    httpd_proxy_client_epoll_mod(g_httpd_epfd, slot, EPOLLIN | EPOLLET);
    if (httpd_proxy_start_async(g_httpd_epfd, conn, slot, hdr_end, &req, keep) < 0) {
      return -2;
    }
    return 0;
#else
    (void)conn;
    (void)hdr_end;
    (void)keep;
    return -2;
#endif
  }
  if (method_is(&req, "OPTIONS")) {
    if (httpd_send_status(conn, 204, "No Content",
                          "Allow: GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS\r\n", keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 204, 0);
    net_slot_consume(slot, hdr_end);
    return keep ? 1 : -1;
  }
  if (method_is(&req, "GET") && (is_index_path_c(req.path, req.path_len) || is_index_get(g_slots[slot].buf, hdr_end))) {
    if (httpd_reply_cached_index_i(conn, slot, keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 200, 0);
  } else if (method_is(&req, "GET")) {
    if (httpd_send_static_path(conn, slot, req.path, req.path_len, keep) < 0) {
      if (httpd_send_status(conn, 404, "Not Found", NULL, keep) < 0) {
        return -2;
      }
      httpd_access_log(&req, 404, 0);
    } else {
      httpd_access_log(&req, 200, 0);
    }
  } else if (method_is(&req, "HEAD")) {
    if (httpd_send_static_path(conn, slot, req.path, req.path_len, 0) < 0) {
      if (httpd_send_status(conn, 404, "Not Found", NULL, keep) < 0) {
        return -2;
      }
      httpd_access_log(&req, 404, 0);
    } else {
      httpd_access_log(&req, 200, 0);
    }
  } else if (req.body_mode != 0) {
    if (httpd_discard_request_body(conn, slot, hdr_end, &req) < 0) {
      return -2;
    }
    if (httpd_send_status(conn, 405, "Method Not Allowed",
                          "Allow: GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS\r\n", keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 405, 0);
    net_slot_consume(slot, hdr_end);
    return keep ? 1 : -1;
  } else {
    if (httpd_send_status(conn, 405, "Method Not Allowed",
                          "Allow: GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS\r\n", keep) < 0) {
      return -2;
    }
    httpd_access_log(&req, 405, 0);
  }
  net_slot_consume(slot, hdr_end);
  if (!keep) {
    return -1;
  }
  return 1;
}

int32_t httpd_drain_slot_i(int32_t conn, int32_t slot) {
  for (;;) {
    int32_t rc = httpd_try_drain_once(conn, slot);
    if (rc <= 0) {
      return rc;
    }
  }
}

static int32_t httpd_slot_find_by_up_fd(int up_fd) {
  slots_init_once();
  for (int i = 0; i < HTTPD_MAX_CONN; i++) {
    if (g_slots[i].proxy_active && g_slots[i].proxy_up_fd == up_fd) {
      return (int32_t)i;
    }
  }
  return -1;
}

static void httpd_proxy_clear(int epfd, int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return;
  }
  if (g_slots[slot].proxy_up_fd >= 0) {
#ifdef __linux__
    if (epfd >= 0) {
      epoll_ctl((int)epfd, EPOLL_CTL_DEL, g_slots[slot].proxy_up_fd, NULL);
    }
#endif
    upstream_pool_release(g_slots[slot].proxy_peer_port, g_slots[slot].proxy_up_fd,
                          g_slots[slot].proxy_up_reuse);
    g_slots[slot].proxy_up_fd = -1;
  }
  g_slots[slot].proxy_active = 0;
  g_slots[slot].proxy_phase = HTTPD_PROXY_PHASE_IDLE;
  g_slots[slot].proxy_rbuf_len = 0;
  g_slots[slot].proxy_rbuf_sent = 0;
  g_slots[slot].proxy_send_off = 0;
  g_slots[slot].proxy_relay_got_data = 0;
  g_slots[slot].proxy_chunk_state = 0;
  g_slots[slot].proxy_chunk_remain = 0;
  g_slots[slot].proxy_chunk_line_len = 0;
  g_slots[slot].proxy_slot_body_rem = 0;
  g_slots[slot].proxy_slot_body_off = 0;
  g_slots[slot].proxy_up_pending_len = 0;
  g_slots[slot].proxy_resp_parsing = 0;
  g_slots[slot].proxy_resp_body_mode = PROXY_RESP_BODY_NONE;
  g_slots[slot].proxy_resp_body_left = 0;
  g_slots[slot].proxy_resp_chunk_state = 0;
  g_slots[slot].proxy_resp_chunk_remain = 0;
  g_slots[slot].proxy_resp_chunk_line_len = 0;
  g_slots[slot].proxy_resp_hdr_len = 0;
  g_slots[slot].proxy_client_epoll_events = 0;
  g_slots[slot].proxy_up_epoll_events = 0;
}

static void httpd_proxy_client_epoll_mod(int epfd, int32_t slot, uint32_t events) {
  if (epfd < 0 || slot < 0 || g_slots[slot].fd < 0) {
    return;
  }
  if (g_slots[slot].proxy_client_epoll_events == events) {
    return;
  }
  g_slots[slot].proxy_client_epoll_events = events;
  struct epoll_event cev;
  cev.events = events;
  cev.data.u64 = HTTPD_EPOLL_CLIENT_TAG | (uint64_t)(uint32_t)slot;
  epoll_ctl((int)epfd, EPOLL_CTL_MOD, g_slots[slot].fd, &cev);
}

static void httpd_proxy_finish_ok(int epfd, int32_t slot) {
  int keep = g_slots[slot].proxy_keep;
  int hdr_end = g_slots[slot].proxy_hdr_end;
  int conn = g_slots[slot].fd;
  if (g_proxy_snap_recording && g_proxy_snap_len > 0) {
    g_proxy_snap_ready = 1;
    g_proxy_snap_recording = 0;
  }
  httpd_proxy_clear(epfd, slot);
  net_slot_consume(slot, hdr_end);
  httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLET);
  if (!keep) {
    httpd_conn_close_slot(epfd, slot);
    return;
  }
  for (;;) {
    if (g_slots[slot].len <= 0) {
      ssize_t r = recv(conn, g_slots[slot].buf, sizeof(g_slots[slot].buf), 0);
      if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
          break;
        }
        httpd_conn_close_slot(epfd, slot);
        return;
      }
      if (r == 0) {
        httpd_conn_close_slot(epfd, slot);
        return;
      }
      g_slots[slot].len = (int)r;
    }
    int32_t d = httpd_try_drain_once(conn, slot);
    if (d == 0) {
      break;
    }
    if (d < 0) {
      httpd_conn_close_slot(epfd, slot);
      return;
    }
  }
}

static void httpd_proxy_finish_err(int epfd, int32_t slot) {
  httpd_proxy_clear(epfd, slot);
  httpd_conn_close_slot(epfd, slot);
}

static ssize_t httpd_send_nb_flags(int fd, const char* data, size_t total, size_t* off, int flags) {
  while (*off < total) {
    ssize_t n = send(fd, data + *off, total - *off, MSG_NOSIGNAL | flags);
    if (n < 0) {
      if (errno == EINTR) {
        continue;
      }
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        return 0;
      }
      return -1;
    }
    if (n == 0) {
      return -1;
    }
    *off += (size_t)n;
  }
  return 1;
}

static ssize_t httpd_send_nb(int fd, const char* data, size_t total, size_t* off) {
  return httpd_send_nb_flags(fd, data, total, off, 0);
}

static ssize_t httpd_recv_nb(int fd, char* dst, size_t cap, size_t* got) {
  if (*got >= cap) {
    return 1;
  }
  ssize_t n = recv(fd, dst + *got, cap - *got, 0);
  if (n < 0) {
    if (errno == EINTR) {
      return 0;
    }
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return 0;
    }
    return -1;
  }
  if (n == 0) {
    return -1;
  }
  *got += (size_t)n;
  return 0;
}

static void httpd_proxy_up_mod(int epfd, int32_t slot, uint32_t events) {
  if (epfd < 0 || g_slots[slot].proxy_up_fd < 0) {
    return;
  }
  if (g_slots[slot].proxy_up_epoll_events == events) {
    return;
  }
  g_slots[slot].proxy_up_epoll_events = events;
  struct epoll_event uev;
  uev.events = events;
  uev.data.u64 = HTTPD_EPOLL_UP_TAG | (uint64_t)(uint32_t)slot;
  epoll_ctl((int)epfd, EPOLL_CTL_MOD, g_slots[slot].proxy_up_fd, &uev);
}

#ifdef __linux__
static void httpd_proxy_splice_pipe_init(void) {
  if (g_proxy_splice_pipe[0] >= 0) {
    return;
  }
  if (pipe2(g_proxy_splice_pipe, O_NONBLOCK) < 0) {
    g_proxy_splice_pipe[0] = -1;
    g_proxy_splice_pipe[1] = -1;
  }
}

static ssize_t httpd_proxy_splice_once(int up_fd, int client_fd, size_t max_len) {
  if (g_proxy_splice_pipe[0] < 0) {
    return -1;
  }
  ssize_t n = splice(up_fd, NULL, g_proxy_splice_pipe[1], NULL, max_len, SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
  if (n <= 0) {
    return n;
  }
  size_t left = (size_t)n;
  while (left > 0) {
    ssize_t w = splice(g_proxy_splice_pipe[0], NULL, client_fd, NULL, left, SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
    if (w <= 0) {
      if (w < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
        return (ssize_t)((size_t)n - left);
      }
      return -1;
    }
    left -= (size_t)w;
  }
  return n;
}
#endif

static int httpd_proxy_client_read(httpd_slot_t* s, char* out) {
  if (s->proxy_slot_body_rem > 0) {
    *out = s->buf[s->proxy_hdr_end + s->proxy_slot_body_off];
    s->proxy_slot_body_off++;
    s->proxy_slot_body_rem--;
    return 1;
  }
  ssize_t r = recv(s->fd, out, 1, 0);
  if (r == 1) {
    return 1;
  }
  if (r < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
    return 0;
  }
  return -1;
}

static int httpd_proxy_relay_to_client(int epfd, int32_t slot, const char* data, size_t len);

static int httpd_proxy_feed_cached_header(int epfd, int32_t slot, const char* data, size_t len) {
  httpd_slot_t* s = &g_slots[slot];
  size_t need = (size_t)g_proxy_resp_hdr_bytes_cached - (size_t)s->proxy_resp_hdr_len;
  if (need == 0) {
    return 0;
  }
  size_t take = len < need ? len : need;
  s->proxy_resp_hdr_len += (int)take;
  if (s->proxy_resp_hdr_len < g_proxy_resp_hdr_bytes_cached) {
    return 0;
  }
  if (httpd_proxy_relay_to_client(epfd, slot, g_proxy_resp_hdr_copy,
                                  (size_t)g_proxy_resp_hdr_bytes_cached) < 0) {
    return -1;
  }
  s->proxy_resp_parsing = 0;
  s->proxy_resp_body_mode = PROXY_RESP_BODY_CL;
  s->proxy_resp_body_left = g_proxy_resp_cl_cached;
  size_t tail = len - take;
  if (tail > 0) {
    if ((size_t)s->proxy_resp_body_left < tail) {
      return -1;
    }
    if (httpd_proxy_relay_to_client(epfd, slot, data + take, tail) < 0) {
      return -1;
    }
    s->proxy_resp_body_left -= (int)tail;
    s->proxy_relay_got_data = 1;
  }
  return 1;
}

static void httpd_proxy_enter_relay(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  s->proxy_phase = HTTPD_PROXY_PHASE_RELAY;
  if (g_proxy_resp_cl_cached >= 0 && g_proxy_resp_hdr_bytes_cached > 0 &&
      g_proxy_resp_hdr_bytes_cached <= (int)sizeof(g_proxy_resp_hdr_copy)) {
    s->proxy_resp_parsing = HTTPD_PROXY_RESP_PARSE_CACHED;
    s->proxy_resp_hdr_len = 0;
  } else {
    s->proxy_resp_parsing = 1;
    s->proxy_resp_hdr_len = 0;
  }
  s->proxy_resp_body_mode = PROXY_RESP_BODY_NONE;
  s->proxy_resp_body_left = 0;
  s->proxy_resp_chunk_state = PROXY_CHUNK_HEX;
  s->proxy_resp_chunk_remain = 0;
  s->proxy_resp_chunk_line_len = 0;
  httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLET);
  httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
  httpd_proxy_pump_relay(epfd, slot);
}

static void httpd_proxy_try_send_chunked(int epfd, int32_t slot);
static void httpd_proxy_pump_relay(int epfd, int32_t slot);

static void httpd_proxy_try_send_req(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  s->proxy_hdr_end = httpd_proxy_compact_req_hdr(slot, s->proxy_hdr_end);
  int more = (s->proxy_req.body_mode != 0 || s->proxy_hdr_end < s->len) ? MSG_MORE : 0;
  ssize_t rc = httpd_send_nb_flags(s->proxy_up_fd, s->buf, (size_t)s->proxy_hdr_end, &s->proxy_send_off, more);
  if (rc < 0) {
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  if (rc == 0) {
    httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
    return;
  }
  if (s->proxy_req.body_mode == 1 && s->proxy_body_left > 0) {
    int in_slot = s->len - s->proxy_hdr_end - s->proxy_body_slot_done;
    if (in_slot > 0) {
      int n = in_slot > s->proxy_body_left ? s->proxy_body_left : in_slot;
      size_t off = 0;
      rc = httpd_send_nb(s->proxy_up_fd, s->buf + s->proxy_hdr_end + s->proxy_body_slot_done, (size_t)n, &off);
      if (rc < 0) {
        httpd_proxy_finish_err(epfd, slot);
        return;
      }
      if (rc == 0) {
        s->proxy_phase = HTTPD_PROXY_PHASE_SEND_BODY;
        httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
        httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
        return;
      }
      s->proxy_body_slot_done += n;
      s->proxy_body_left -= n;
    }
    if (s->proxy_body_left > 0) {
      s->proxy_phase = HTTPD_PROXY_PHASE_SEND_BODY;
      httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
      httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
      return;
    }
  }
  if (s->proxy_req.body_mode == 2) {
    s->proxy_phase = HTTPD_PROXY_PHASE_SEND_BODY;
    httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
    httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
    httpd_proxy_try_send_chunked(epfd, slot);
    return;
  }
  httpd_proxy_enter_relay(epfd, slot);
}

static void httpd_proxy_try_send_chunked(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  for (int guard = 0; guard < 256; guard++) {
    if (s->proxy_phase != HTTPD_PROXY_PHASE_SEND_BODY) {
      return;
    }
    if (s->proxy_chunk_state == PROXY_CHUNK_HEX) {
      char ch = 0;
      int pr = httpd_proxy_client_read(s, &ch);
      if (pr < 0) {
        httpd_proxy_finish_err(epfd, slot);
        return;
      }
      if (pr == 0) {
        return;
      }
      if (s->proxy_chunk_line_len + 1 < (int)sizeof(s->proxy_chunk_line)) {
        s->proxy_chunk_line[s->proxy_chunk_line_len++] = ch;
      }
      if (s->proxy_chunk_line_len >= 2 && s->proxy_chunk_line[s->proxy_chunk_line_len - 1] == '\n' &&
          s->proxy_chunk_line[s->proxy_chunk_line_len - 2] == '\r') {
        s->proxy_chunk_line[s->proxy_chunk_line_len] = '\0';
        int chunk_sz = (int)strtol(s->proxy_chunk_line, NULL, 16);
        if (chunk_sz < 0) {
          httpd_proxy_finish_err(epfd, slot);
          return;
        }
        s->proxy_chunk_line_len = 0;
        if (chunk_sz == 0) {
          char crlf[2];
          int got = 0;
          for (int i = 0; i < 2; i++) {
            int r = httpd_proxy_client_read(s, crlf + i);
            if (r < 0) {
              httpd_proxy_finish_err(epfd, slot);
              return;
            }
            if (r == 0) {
              return;
            }
            got++;
          }
          if (got < 2) {
            return;
          }
          httpd_proxy_enter_relay(epfd, slot);
          return;
        }
        if (chunk_sz > HTTPD_MAX_BODY) {
          httpd_proxy_finish_err(epfd, slot);
          return;
        }
        s->proxy_chunk_remain = chunk_sz;
        s->proxy_chunk_state = PROXY_CHUNK_DATA;
      }
      continue;
    }
    if (s->proxy_chunk_state == PROXY_CHUNK_DATA) {
      if (s->proxy_up_pending_len > 0) {
        size_t off = 0;
        ssize_t rc = httpd_send_nb(s->proxy_up_fd, s->proxy_up_pending, (size_t)s->proxy_up_pending_len, &off);
        if (rc < 0) {
          httpd_proxy_finish_err(epfd, slot);
          return;
        }
        if (rc == 0) {
          httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
          return;
        }
        if (off < (size_t)s->proxy_up_pending_len) {
          memmove(s->proxy_up_pending, s->proxy_up_pending + off, (size_t)s->proxy_up_pending_len - off);
          s->proxy_up_pending_len -= (int)off;
          return;
        }
        s->proxy_up_pending_len = 0;
      }
      char tmp[8192];
      int want = s->proxy_chunk_remain > (int)sizeof(tmp) ? (int)sizeof(tmp) : s->proxy_chunk_remain;
      int copied = 0;
      while (copied < want && s->proxy_slot_body_rem > 0) {
        tmp[copied++] = s->buf[s->proxy_hdr_end + s->proxy_slot_body_off];
        s->proxy_slot_body_off++;
        s->proxy_slot_body_rem--;
      }
      if (copied < want) {
        ssize_t r = recv(s->fd, tmp + copied, (size_t)(want - copied), 0);
        if (r < 0) {
          if (errno == EAGAIN || errno == EWOULDBLOCK) {
            if (copied == 0) {
              return;
            }
          } else {
            httpd_proxy_finish_err(epfd, slot);
            return;
          }
        } else if (r == 0) {
          httpd_proxy_finish_err(epfd, slot);
          return;
        } else {
          copied += (int)r;
        }
      }
      if (copied == 0) {
        return;
      }
      size_t off = 0;
      ssize_t rc = httpd_send_nb(s->proxy_up_fd, tmp, (size_t)copied, &off);
      if (rc < 0) {
        httpd_proxy_finish_err(epfd, slot);
        return;
      }
      if (rc == 0) {
        if (off > 0) {
          s->proxy_chunk_remain -= (int)off;
        }
        if (off < (size_t)copied) {
          int left = copied - (int)off;
          if (s->proxy_up_pending_len + left > (int)sizeof(s->proxy_up_pending)) {
            httpd_proxy_finish_err(epfd, slot);
            return;
          }
          memcpy(s->proxy_up_pending + s->proxy_up_pending_len, tmp + off, (size_t)left);
          s->proxy_up_pending_len += left;
        }
        httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
        return;
      }
      s->proxy_chunk_remain -= copied;
      if (s->proxy_chunk_remain <= 0) {
        s->proxy_chunk_state = PROXY_CHUNK_CRLF;
      }
      continue;
    }
    if (s->proxy_chunk_state == PROXY_CHUNK_CRLF) {
      char crlf[2];
      for (int i = 0; i < 2; i++) {
        int r = httpd_proxy_client_read(s, crlf + i);
        if (r < 0) {
          httpd_proxy_finish_err(epfd, slot);
          return;
        }
        if (r == 0) {
          return;
        }
      }
      s->proxy_chunk_state = PROXY_CHUNK_HEX;
      continue;
    }
    return;
  }
}

static void httpd_proxy_try_send_body(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  if (s->proxy_req.body_mode == 2) {
    httpd_proxy_try_send_chunked(epfd, slot);
    return;
  }
  if (s->proxy_body_left <= 0) {
    httpd_proxy_enter_relay(epfd, slot);
    return;
  }
  char tmp[8192];
  int chunk = s->proxy_body_left > (int)sizeof(tmp) ? (int)sizeof(tmp) : s->proxy_body_left;
  ssize_t r = recv(s->fd, tmp, (size_t)chunk, 0);
  if (r < 0) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return;
    }
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  if (r == 0) {
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  size_t off = 0;
  ssize_t rc = httpd_send_nb(s->proxy_up_fd, tmp, (size_t)r, &off);
  if (rc < 0) {
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  if (rc == 0) {
    httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
    return;
  }
  s->proxy_body_left -= (int)r;
  if (s->proxy_body_left <= 0) {
    httpd_proxy_enter_relay(epfd, slot);
  }
}

static int httpd_proxy_relay_to_client(int epfd, int32_t slot, const char* data, size_t len) {
  httpd_slot_t* s = &g_slots[slot];
  if (len == 0) {
    return 0;
  }
  if (g_proxy_snap_recording && g_proxy_snap_len + (int)len <= HTTPD_PROXY_SNAP_MAX) {
    memcpy(g_proxy_snap + g_proxy_snap_len, data, len);
    g_proxy_snap_len += (int)len;
  }
  s->proxy_relay_got_data = 1;
  size_t off = 0;
  ssize_t rc = httpd_send_nb(s->fd, data, len, &off);
  if (rc < 0) {
    return -1;
  }
  if (rc == 0 && off < len) {
    size_t left = len - off;
    if (left > sizeof(s->proxy_rbuf)) {
      return -1;
    }
    memcpy(s->proxy_rbuf, data + off, left);
    s->proxy_rbuf_len = (int)left;
    s->proxy_rbuf_sent = 0;
    httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
    return 0;
  }
  return 1;
}

static int httpd_proxy_resp_headers_complete(httpd_slot_t* s) {
  return hdr_end_at_c(s->proxy_resp_hdr_acc, s->proxy_resp_hdr_len);
}

static int httpd_proxy_resp_feed(int epfd, int32_t slot, const char* data, size_t len);

static int httpd_proxy_resp_finish_headers(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  int hdr_end = hdr_end_at_c(s->proxy_resp_hdr_acc, s->proxy_resp_hdr_len);
  if (hdr_end < 0) {
    return -1;
  }
  int resp_keep = 0;
  int cl = parse_resp_content_length(s->proxy_resp_hdr_acc, hdr_end, &resp_keep);
  if (cl >= 0) {
    s->proxy_resp_body_mode = PROXY_RESP_BODY_CL;
    s->proxy_resp_body_left = cl;
    if (g_proxy_resp_cl_cached < 0) {
      g_proxy_resp_cl_cached = cl;
      g_proxy_resp_hdr_bytes_cached = hdr_end;
      if (hdr_end > 0 && hdr_end <= (int)sizeof(g_proxy_resp_hdr_copy)) {
        memcpy(g_proxy_resp_hdr_copy, s->proxy_resp_hdr_acc, (size_t)hdr_end);
      }
    }
  } else if (hdr_has_token_c(s->proxy_resp_hdr_acc, hdr_end, "Transfer-Encoding:") &&
             hdr_has_token_c(s->proxy_resp_hdr_acc, hdr_end, "chunked")) {
    s->proxy_resp_body_mode = PROXY_RESP_BODY_CHUNKED;
    s->proxy_resp_body_left = 0;
  } else {
    parse_response_body_meta_c(s->proxy_resp_hdr_acc, hdr_end, &s->proxy_resp_body_mode, &s->proxy_resp_body_left);
  }
  s->proxy_resp_parsing = 0;
  if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CL) {
    if (s->proxy_resp_body_left > HTTPD_MAX_BODY) {
      return -1;
    }
  } else if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CHUNKED) {
    s->proxy_resp_chunk_state = PROXY_CHUNK_HEX;
    s->proxy_resp_chunk_remain = 0;
    s->proxy_resp_chunk_line_len = 0;
  }
  if (httpd_proxy_relay_to_client(epfd, slot, s->proxy_resp_hdr_acc, (size_t)hdr_end) < 0) {
    return -1;
  }
  int tail = s->proxy_resp_hdr_len - hdr_end;
  if (tail > 0) {
    return httpd_proxy_resp_feed(epfd, slot, s->proxy_resp_hdr_acc + hdr_end, (size_t)tail);
  }
  return 0;
}

static int httpd_proxy_resp_feed(int epfd, int32_t slot, const char* data, size_t len) {
  httpd_slot_t* s = &g_slots[slot];
  size_t i = 0;
  while (i < len) {
    if (s->proxy_resp_parsing) {
      int room = (int)sizeof(s->proxy_resp_hdr_acc) - s->proxy_resp_hdr_len;
      if (room <= 0) {
        return -1;
      }
      size_t take = len - i;
      if (take > (size_t)room) {
        take = (size_t)room;
      }
      memcpy(s->proxy_resp_hdr_acc + s->proxy_resp_hdr_len, data + i, take);
      s->proxy_resp_hdr_len += (int)take;
      i += take;
      int he = httpd_proxy_resp_headers_complete(s);
      if (he >= 0) {
        if (httpd_proxy_resp_finish_headers(epfd, slot) < 0) {
          return -1;
        }
        if (!s->proxy_active) {
          return 0;
        }
      } else if (s->proxy_resp_hdr_len >= (int)sizeof(s->proxy_resp_hdr_acc)) {
        return -1;
      }
      if (i >= len) {
        return 0;
      }
      continue;
    }
    if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CL) {
      size_t take = len - i;
      if (s->proxy_resp_body_left >= 0 && (size_t)s->proxy_resp_body_left < take) {
        take = (size_t)s->proxy_resp_body_left;
      }
      if (take == 0) {
        return 0;
      }
      int rc = httpd_proxy_relay_to_client(epfd, slot, data + i, take);
      if (rc < 0) {
        return -1;
      }
      i += take;
      if (s->proxy_resp_body_left > 0) {
        s->proxy_resp_body_left -= (int)take;
      }
      continue;
    }
    if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CHUNKED) {
      while (i < len) {
        if (s->proxy_resp_chunk_state == PROXY_CHUNK_HEX) {
          char ch = data[i++];
          if (s->proxy_resp_chunk_line_len + 1 < (int)sizeof(s->proxy_resp_chunk_line)) {
            s->proxy_resp_chunk_line[s->proxy_resp_chunk_line_len++] = ch;
          }
          if (s->proxy_resp_chunk_line_len >= 2 && s->proxy_resp_chunk_line[s->proxy_resp_chunk_line_len - 1] == '\n' &&
              s->proxy_resp_chunk_line[s->proxy_resp_chunk_line_len - 2] == '\r') {
            s->proxy_resp_chunk_line[s->proxy_resp_chunk_line_len] = '\0';
            int chunk_sz = (int)strtol(s->proxy_resp_chunk_line, NULL, 16);
            s->proxy_resp_chunk_line_len = 0;
            if (chunk_sz < 0) {
              return -1;
            }
            if (chunk_sz == 0) {
              s->proxy_resp_chunk_state = PROXY_CHUNK_CRLF;
              s->proxy_resp_chunk_remain = 2;
              s->proxy_resp_body_mode = PROXY_RESP_BODY_NONE;
              s->proxy_resp_body_left = 0;
            } else {
              if (chunk_sz > HTTPD_MAX_BODY) {
                return -1;
              }
              s->proxy_resp_chunk_remain = chunk_sz;
              s->proxy_resp_chunk_state = PROXY_CHUNK_DATA;
            }
          }
          break;
        }
        if (s->proxy_resp_chunk_state == PROXY_CHUNK_DATA) {
          size_t take = len - i;
          if ((size_t)s->proxy_resp_chunk_remain < take) {
            take = (size_t)s->proxy_resp_chunk_remain;
          }
          if (take == 0) {
            return 0;
          }
          int rc = httpd_proxy_relay_to_client(epfd, slot, data + i, take);
          if (rc < 0) {
            return -1;
          }
          i += take;
          s->proxy_resp_chunk_remain -= (int)take;
          if (s->proxy_resp_chunk_remain <= 0) {
            s->proxy_resp_chunk_state = PROXY_CHUNK_CRLF;
            s->proxy_resp_chunk_remain = 2;
          }
          break;
        }
        if (s->proxy_resp_chunk_state == PROXY_CHUNK_CRLF) {
          while (i < len && s->proxy_resp_chunk_remain > 0) {
            i++;
            s->proxy_resp_chunk_remain--;
          }
          if (s->proxy_resp_chunk_remain <= 0) {
            s->proxy_resp_chunk_state = PROXY_CHUNK_HEX;
          }
          break;
        }
      }
      continue;
    }
    size_t take = len - i;
    int rc = httpd_proxy_relay_to_client(epfd, slot, data + i, take);
    if (rc < 0) {
      return -1;
    }
    i += take;
  }
  return 0;
}

static void httpd_proxy_flush_client_out(int epfd, int32_t slot);

static int httpd_proxy_relay_pending_client(httpd_slot_t* s) {
  return s->proxy_rbuf_len > 0 && s->proxy_rbuf_sent < (size_t)s->proxy_rbuf_len;
}

static void httpd_proxy_relay_maybe_done(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  if (!s->proxy_active || s->proxy_phase != HTTPD_PROXY_PHASE_RELAY) {
    return;
  }
  if (s->proxy_resp_parsing || httpd_proxy_relay_pending_client(s)) {
    return;
  }
  if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CL) {
    if (s->proxy_resp_body_left <= 0) {
      httpd_proxy_finish_ok(epfd, slot);
    }
    return;
  }
  if (s->proxy_resp_body_mode == PROXY_RESP_BODY_NONE && s->proxy_relay_got_data) {
    httpd_proxy_finish_ok(epfd, slot);
    return;
  }
  if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CLOSE) {
    return;
  }
}

static void httpd_proxy_pump_cl_relay(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
#ifdef __linux__
  httpd_proxy_splice_pipe_init();
#endif
  for (;;) {
    httpd_proxy_flush_client_out(epfd, slot);
    if (!s->proxy_active || s->proxy_resp_body_left <= 0) {
      httpd_proxy_relay_maybe_done(epfd, slot);
      return;
    }
#ifdef __linux__
    if (!g_proxy_snap_recording && !httpd_proxy_relay_pending_client(s) && g_proxy_splice_pipe[0] >= 0) {
      size_t cap = (size_t)s->proxy_resp_body_left;
      if (cap > sizeof(s->proxy_rbuf)) {
        cap = sizeof(s->proxy_rbuf);
      }
      if (cap >= HTTPD_PROXY_SPLICE_MIN) {
        ssize_t sp = httpd_proxy_splice_once(s->proxy_up_fd, s->fd, cap);
        if (sp > 0) {
          s->proxy_relay_got_data = 1;
          s->proxy_resp_body_left -= (int)sp;
          continue;
        }
      }
    }
#endif
    ssize_t r = recv(s->proxy_up_fd, s->proxy_rbuf, sizeof(s->proxy_rbuf), 0);
    if (r < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        httpd_proxy_relay_maybe_done(epfd, slot);
        if (s->proxy_active) {
          httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLET);
        }
        return;
      }
      httpd_proxy_finish_err(epfd, slot);
      return;
    }
    if (r == 0) {
      httpd_proxy_finish_ok(epfd, slot);
      return;
    }
    size_t take = (size_t)r;
    if ((size_t)s->proxy_resp_body_left < take) {
      take = (size_t)s->proxy_resp_body_left;
    }
    if (httpd_proxy_relay_to_client(epfd, slot, s->proxy_rbuf, take) < 0) {
      httpd_proxy_finish_err(epfd, slot);
      return;
    }
    s->proxy_resp_body_left -= (int)take;
    if (s->proxy_resp_body_left <= 0) {
      httpd_proxy_relay_maybe_done(epfd, slot);
      return;
    }
  }
}

static void httpd_proxy_flush_client_out(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  if (s->proxy_rbuf_len <= 0 || s->proxy_rbuf_sent >= (size_t)s->proxy_rbuf_len) {
    return;
  }
  size_t off = s->proxy_rbuf_sent;
  ssize_t rc = httpd_send_nb(s->fd, s->proxy_rbuf, (size_t)s->proxy_rbuf_len, &off);
  if (rc < 0) {
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  s->proxy_rbuf_sent = off;
  if (s->proxy_rbuf_sent < (size_t)s->proxy_rbuf_len) {
    httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
  } else {
    s->proxy_rbuf_len = 0;
    s->proxy_rbuf_sent = 0;
    httpd_proxy_relay_maybe_done(epfd, slot);
  }
}

static void httpd_proxy_pump_relay(int epfd, int32_t slot) {
  httpd_slot_t* s = &g_slots[slot];
  httpd_proxy_flush_client_out(epfd, slot);
  if (!s->proxy_active) {
    return;
  }
  if (!s->proxy_resp_parsing && s->proxy_resp_body_mode == PROXY_RESP_BODY_CL) {
    httpd_proxy_pump_cl_relay(epfd, slot);
    return;
  }
  if (s->proxy_resp_parsing == HTTPD_PROXY_RESP_PARSE_CACHED) {
    for (;;) {
      ssize_t r = recv(s->proxy_up_fd, s->proxy_rbuf, sizeof(s->proxy_rbuf), 0);
      if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
          httpd_proxy_relay_maybe_done(epfd, slot);
          if (s->proxy_active) {
            httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLET);
          }
          return;
        }
        httpd_proxy_finish_err(epfd, slot);
        return;
      }
      if (r == 0) {
        httpd_proxy_finish_err(epfd, slot);
        return;
      }
      int done = httpd_proxy_feed_cached_header(epfd, slot, s->proxy_rbuf, (size_t)r);
      if (done < 0) {
        httpd_proxy_finish_err(epfd, slot);
        return;
      }
      if (done > 0) {
        if (s->proxy_resp_body_left > 0) {
          httpd_proxy_pump_cl_relay(epfd, slot);
        } else {
          httpd_proxy_relay_maybe_done(epfd, slot);
        }
        return;
      }
    }
  }
  for (;;) {
    ssize_t r = recv(s->proxy_up_fd, s->proxy_rbuf, sizeof(s->proxy_rbuf), 0);
    if (r < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        httpd_proxy_relay_maybe_done(epfd, slot);
        if (g_slots[slot].proxy_active) {
          httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLET);
        }
        return;
      }
      httpd_proxy_finish_err(epfd, slot);
      return;
    }
    if (r == 0) {
      if (s->proxy_resp_body_mode == PROXY_RESP_BODY_CLOSE || s->proxy_resp_parsing) {
        httpd_proxy_finish_ok(epfd, slot);
      } else {
        httpd_proxy_finish_ok(epfd, slot);
      }
      return;
    }
    if (httpd_proxy_resp_feed(epfd, slot, s->proxy_rbuf, (size_t)r) < 0) {
      httpd_proxy_finish_err(epfd, slot);
      return;
    }
    httpd_proxy_relay_maybe_done(epfd, slot);
    if (!g_slots[slot].proxy_active) {
      return;
    }
  }
}

static void httpd_proxy_up_handler(int epfd, int32_t slot, uint32_t events) {
  httpd_slot_t* s = &g_slots[slot];
  if (!s->proxy_active) {
    return;
  }
  if (events & (EPOLLERR | EPOLLHUP)) {
    if (s->proxy_phase == HTTPD_PROXY_PHASE_RELAY && s->proxy_rbuf_sent > 0) {
      httpd_proxy_finish_ok(epfd, slot);
      return;
    }
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  if (s->proxy_phase == HTTPD_PROXY_PHASE_SEND_REQ || s->proxy_phase == HTTPD_PROXY_PHASE_SEND_BODY) {
    if (events & EPOLLOUT) {
      if (s->proxy_phase == HTTPD_PROXY_PHASE_SEND_REQ) {
        httpd_proxy_try_send_req(epfd, slot);
      } else {
        httpd_proxy_try_send_body(epfd, slot);
      }
    }
    return;
  }
  if (s->proxy_phase == HTTPD_PROXY_PHASE_RELAY) {
    if (events & EPOLLIN) {
      httpd_proxy_pump_relay(epfd, slot);
    }
  }
}

static void httpd_proxy_client_handler(int epfd, int32_t slot, uint32_t events) {
  httpd_slot_t* s = &g_slots[slot];
  if (!s->proxy_active) {
    return;
  }
  if (events & (EPOLLERR | EPOLLHUP)) {
    httpd_proxy_finish_err(epfd, slot);
    return;
  }
  if (s->proxy_phase == HTTPD_PROXY_PHASE_SEND_BODY) {
    if (events & EPOLLIN) {
      httpd_proxy_try_send_body(epfd, slot);
    }
    if (events & EPOLLOUT) {
      httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLOUT | EPOLLET);
    }
    return;
  }
  if (s->proxy_phase == HTTPD_PROXY_PHASE_RELAY) {
    if (events & EPOLLOUT) {
      if (s->proxy_rbuf_sent < (size_t)s->proxy_rbuf_len) {
        size_t off = s->proxy_rbuf_sent;
        ssize_t rc = httpd_send_nb(s->fd, s->proxy_rbuf, (size_t)s->proxy_rbuf_len, &off);
        if (rc < 0) {
          httpd_proxy_finish_err(epfd, slot);
          return;
        }
        s->proxy_rbuf_sent = off;
        if (s->proxy_rbuf_sent >= (size_t)s->proxy_rbuf_len) {
          s->proxy_rbuf_len = 0;
          s->proxy_rbuf_sent = 0;
          httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLET);
          httpd_proxy_up_mod(epfd, slot, EPOLLIN | EPOLLET);
          httpd_proxy_relay_maybe_done(epfd, slot);
        }
      }
    }
  }
}

static int httpd_proxy_start_async(int epfd, int32_t conn, int32_t slot, int hdr_end, const httpd_req_info_t* req,
                                   int keep) {
  int32_t peer_port = httpd_lb_pick_port();
  if (peer_port <= 0) {
    return -1;
  }
  int up = upstream_pool_acquire(peer_port);
  if (up < 0 && g_up_peer_count > 1) {
    for (int i = 0; i < g_up_peer_count; i++) {
      if (g_up_peers[i].down || g_up_peers[i].port == peer_port) {
        continue;
      }
      peer_port = g_up_peers[i].port;
      up = upstream_pool_acquire(peer_port);
      if (up >= 0) {
        break;
      }
    }
  }
  if (up < 0) {
    return -1;
  }
  tcp_tune_client(up);
  set_nonblocking(up);
  httpd_slot_t* s = &g_slots[slot];
  s->proxy_active = 1;
  s->proxy_up_fd = up;
  s->proxy_peer_port = peer_port;
  s->proxy_keep = keep;
  s->proxy_hdr_end = hdr_end;
  s->proxy_req = *req;
  s->proxy_send_off = 0;
  s->proxy_send_total = (size_t)hdr_end;
  s->proxy_body_left = 0;
  s->proxy_body_slot_done = 0;
  s->proxy_rbuf_len = 0;
  s->proxy_rbuf_sent = 0;
  s->proxy_up_reuse = keep ? 1 : 0;
  s->proxy_relay_got_data = 0;
  s->proxy_phase = HTTPD_PROXY_PHASE_SEND_REQ;
  s->proxy_chunk_state = PROXY_CHUNK_HEX;
  s->proxy_chunk_remain = 0;
  s->proxy_chunk_line_len = 0;
  s->proxy_slot_body_rem = s->len - hdr_end;
  s->proxy_slot_body_off = 0;
  s->proxy_up_pending_len = 0;
  s->proxy_resp_parsing = 0;
  s->proxy_resp_body_mode = PROXY_RESP_BODY_NONE;
  s->proxy_resp_body_left = 0;
  s->proxy_resp_hdr_len = 0;
  s->proxy_client_epoll_events = 0;
  s->proxy_up_epoll_events = 0;
  g_proxy_snap_recording = 0;
  if (method_is(req, "GET") && !g_proxy_snap_ready) {
    g_proxy_snap_recording = 1;
    g_proxy_snap_len = 0;
  }
  if (req->body_mode == 1) {
    s->proxy_body_left = req->content_length - (s->len - hdr_end);
    if (s->proxy_body_left < 0) {
      s->proxy_body_left = 0;
    }
  } else if (req->body_mode == 2) {
    s->proxy_body_left = 0;
  }
  struct epoll_event uev;
  uev.events = EPOLLIN | EPOLLOUT | EPOLLET;
  uev.data.u64 = HTTPD_EPOLL_UP_TAG | (uint64_t)(uint32_t)slot;
  s->proxy_up_epoll_events = uev.events;
  if (epoll_ctl((int)epfd, EPOLL_CTL_ADD, up, &uev) < 0) {
    httpd_proxy_clear(epfd, slot);
    return -1;
  }
  httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLET);
  httpd_proxy_try_send_req(epfd, slot);
  return 0;
}

static void httpd_conn_close_slot(int epfd, int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return;
  }
  if (g_slots[slot].proxy_active) {
    httpd_proxy_clear(epfd, slot);
  }
  if (g_slots[slot].fd >= 0) {
#ifdef __linux__
    if (epfd >= 0) {
      epoll_ctl((int)epfd, EPOLL_CTL_DEL, g_slots[slot].fd, NULL);
    }
#endif
    close(g_slots[slot].fd);
    g_slots[slot].fd = -1;
    g_slots[slot].len = 0;
  }
}

static void httpd_serve_conn_epoll(int epfd, int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN || g_slots[slot].fd < 0) {
    return;
  }
  if (g_doc_root_len == 0) {
    return;
  }
  if (g_slots[slot].proxy_active) {
    if (g_slots[slot].proxy_phase == HTTPD_PROXY_PHASE_SEND_BODY) {
      httpd_proxy_try_send_body(epfd, slot);
    }
    return;
  }
  int conn = g_slots[slot].fd;
  for (;;) {
    if (g_slots[slot].len >= HTTPD_IO_BUF) {
      httpd_conn_close_slot(epfd, slot);
      return;
    }
    if (g_slots[slot].len >= HTTPD_MAX_HDR_RECV && hdr_end_at_c(g_slots[slot].buf, g_slots[slot].len) < 0) {
      httpd_conn_close_slot(epfd, slot);
      return;
    }
    tcp_ack_now(conn);
    ssize_t r =
        recv(conn, g_slots[slot].buf + g_slots[slot].len, (size_t)(HTTPD_IO_BUF - g_slots[slot].len), 0);
    if (r < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        break;
      }
      httpd_conn_close_slot(epfd, slot);
      return;
    }
    if (r == 0) {
      httpd_conn_close_slot(epfd, slot);
      return;
    }
    g_slots[slot].len += (int)r;

    for (;;) {
      int32_t d = httpd_try_drain_once(conn, slot);
      if (d == 0) {
        break;
      }
      if (d < 0) {
        httpd_conn_close_slot(epfd, slot);
        return;
      }
    }
  }
}

static void httpd_dispatch_epoll_event(int epfd, int listen_fd, struct epoll_event* ev) {
  int fd = ev->data.fd;
  uint64_t eu = ev->data.u64;
  if ((eu & HTTPD_EPOLL_UP_TAG) == HTTPD_EPOLL_UP_TAG) {
    int32_t up_slot = (int32_t)(eu & 0xffffffffu);
    if (up_slot >= 0 && up_slot < HTTPD_MAX_CONN) {
      httpd_proxy_up_handler(epfd, up_slot, ev->events);
    }
    return;
  }
  if (fd == listen_fd) {
    for (;;) {
      int cfd = accept(listen_fd, NULL, NULL);
      if (cfd < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
          break;
        }
        net_fail("accept");
      }
      net_set_nonblock(cfd);
      tcp_tune_client(cfd);
      int32_t slot = httpd_slot_alloc(cfd);
      if (slot < 0) {
        close(cfd);
        break;
      }
      struct epoll_event cev;
      cev.events = EPOLLIN | EPOLLET;
      cev.data.u64 = HTTPD_EPOLL_CLIENT_TAG | (uint64_t)(uint32_t)slot;
      if (epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &cev) < 0) {
        httpd_conn_close_slot(-1, slot);
      }
    }
    return;
  }

  if (ev->events & (EPOLLERR | EPOLLHUP)) {
    int32_t slot = -1;
    if ((eu & HTTPD_EPOLL_CLIENT_TAG) == HTTPD_EPOLL_CLIENT_TAG) {
      slot = (int32_t)(eu & 0xffffffffu);
    } else {
      slot = httpd_slot_find_by_up_fd(fd);
      if (slot < 0) {
        slot = httpd_slot_find_fd(fd);
      }
    }
    if (slot >= 0) {
      if (g_slots[slot].proxy_active && g_slots[slot].proxy_up_fd == fd) {
        httpd_proxy_finish_err(epfd, slot);
      } else {
        httpd_conn_close_slot(epfd, slot);
      }
    }
    return;
  }

  int32_t slot = -1;
  if ((eu & HTTPD_EPOLL_CLIENT_TAG) == HTTPD_EPOLL_CLIENT_TAG) {
    slot = (int32_t)(eu & 0xffffffffu);
  } else {
    slot = httpd_slot_find_fd(fd);
  }
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    if (g_slots[slot].proxy_active) {
      httpd_proxy_client_handler(epfd, slot, ev->events);
      return;
    }
    if (ev->events & EPOLLIN) {
      httpd_serve_conn_epoll(epfd, slot);
    }
  }
}

int32_t httpd_epoll_serve_proxy_i(int32_t port, intptr_t root, int32_t backend_port) {
  if (port <= 0 || port > 65535 || backend_port <= 0 || backend_port > 65535) {
    return -1;
  }
  if (g_up_peer_count <= 0) {
    if (httpd_set_proxy_upstream_port_i(backend_port, 1) < 0) {
      return -1;
    }
  }
  g_li_proxy_mode = 0;
  return httpd_epoll_serve_i(port, root);
}

int32_t httpd_env_li_proxy_loop_i(void) {
  const char* v = getenv("LI_HTTPD_PROXY_C");
  if (v && (v[0] == '1' || v[0] == 'y' || v[0] == 'Y')) {
    return 0;
  }
  return 1;
}

int32_t httpd_epoll_serve_i(int32_t port, intptr_t root) {
#ifndef __linux__
  (void)port;
  (void)root;
  return -1;
#else
  if (port <= 0 || port > 65535) {
    return -1;
  }
  if (httpd_prepare_root_i(root) < 0) {
    return -1;
  }
  int listen_fd = (int)tcp_listen(port);
  net_set_nonblock(listen_fd);
  int epfd = epoll_create1(0);
  if (epfd < 0) {
    net_fail("epoll_create1");
  }
  g_httpd_epfd = epfd;
  struct epoll_event lev;
  lev.events = EPOLLIN;
  lev.data.fd = listen_fd;
  if (epoll_ctl(epfd, EPOLL_CTL_ADD, listen_fd, &lev) < 0) {
    net_fail("epoll_ctl listen");
  }

  struct epoll_event events[256];
  for (;;) {
    int n = epoll_wait(epfd, events, 256, -1);
    if (n < 0) {
      if (errno == EINTR) {
        continue;
      }
      net_fail("epoll_wait");
    }
    for (int i = 0; i < n; i++) {
      httpd_dispatch_epoll_event(epfd, listen_fd, &events[i]);
    }
    for (;;) {
      int n2 = epoll_wait(epfd, events, 256, 0);
      if (n2 <= 0) {
        break;
      }
      for (int j = 0; j < n2; j++) {
        httpd_dispatch_epoll_event(epfd, listen_fd, &events[j]);
      }
    }
  }
  return 0;
#endif
}

int32_t net_slot_consume(int32_t slot, int32_t n) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN || n < 0) {
    return -1;
  }
  if (n > g_slots[slot].len) {
    n = g_slots[slot].len;
  }
  if (n > 0) {
    memmove(g_slots[slot].buf, g_slots[slot].buf + n, (size_t)(g_slots[slot].len - n));
    g_slots[slot].len -= n;
  }
  return g_slots[slot].len;
}

int32_t httpd_slot_alloc(int32_t fd) {
  slots_init_once();
  for (int i = 0; i < HTTPD_MAX_CONN; i++) {
    if (g_slots[i].fd < 0) {
      g_slots[i].fd = (int)fd;
      g_slots[i].len = 0;
      return i;
    }
  }
  return -1;
}

int32_t httpd_slot_find_fd(int32_t fd) {
  slots_init_once();
  for (int i = 0; i < HTTPD_MAX_CONN; i++) {
    if (g_slots[i].fd == (int)fd) {
      return i;
    }
  }
  return -1;
}

void httpd_slot_free(int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return;
  }
  g_slots[slot].fd = -1;
  g_slots[slot].len = 0;
}

#ifdef __linux__
int32_t epoll_create1_i(void) {
  int epfd = epoll_create1(0);
  if (epfd < 0) {
    net_fail("epoll_create1");
  }
  return (int32_t)epfd;
}

int32_t epoll_ctl_add_i(int32_t epfd, int32_t fd) {
  struct epoll_event ev;
  ev.events = EPOLLIN;
  ev.data.fd = (int)fd;
  if (epoll_ctl((int)epfd, EPOLL_CTL_ADD, (int)fd, &ev) < 0) {
    return -1;
  }
  return 0;
}

int32_t epoll_ctl_add_listen_i(int32_t epfd, int32_t fd) {
  struct epoll_event ev;
  ev.events = EPOLLIN;
  ev.data.fd = (int)fd;
  if (epoll_ctl((int)epfd, EPOLL_CTL_ADD, (int)fd, &ev) < 0) {
    return -1;
  }
  return 0;
}

int32_t epoll_ctl_del_i(int32_t epfd, int32_t fd) {
  if (epoll_ctl((int)epfd, EPOLL_CTL_DEL, (int)fd, NULL) < 0) {
    return -1;
  }
  return 0;
}

int32_t epoll_wait_events_i(int32_t epfd, intptr_t events, int32_t max_events) {
  if (max_events <= 0 || max_events > 256) {
    max_events = 256;
  }
  struct epoll_event evs[256];
  int n = epoll_wait((int)epfd, evs, max_events, -1);
  if (n < 0) {
    if (errno == EINTR) {
      return 0;
    }
    net_fail("epoll_wait");
  }
  int32_t* out = (int32_t*)ptr_i(events);
  for (int i = 0; i < n; i++) {
    out[i * 2] = evs[i].data.fd;
    out[i * 2 + 1] = (int32_t)evs[i].events;
  }
  return (int32_t)n;
}
#else
int32_t epoll_create1_i(void) { return -1; }
int32_t epoll_ctl_add_i(int32_t epfd, int32_t fd) {
  (void)epfd;
  (void)fd;
  return -1;
}
int32_t epoll_ctl_del_i(int32_t epfd, int32_t fd) {
  (void)epfd;
  (void)fd;
  return -1;
}
int32_t epoll_wait_events_i(int32_t epfd, intptr_t events, int32_t max_events) {
  (void)epfd;
  (void)events;
  (void)max_events;
  return -1;
}
#endif

int32_t net_open_readonly_i(intptr_t path) {
  const char* p = ptr_i(path);
  if (!p) {
    return -1;
  }
  return (int32_t)open(p, O_RDONLY);
}

int32_t net_fstat_size(int32_t fd) {
  struct stat st;
  if (fstat((int)fd, &st) < 0 || !S_ISREG(st.st_mode)) {
    return -1;
  }
  if (st.st_size > 0x7fffffff) {
    return 0x7fffffff;
  }
  return (int32_t)st.st_size;
}

int32_t net_read_fd(int32_t fd, intptr_t buf, int32_t max_bytes) {
  if (!buf || max_bytes <= 0) {
    return 0;
  }
  ssize_t n = read((int)fd, ptr_i(buf), (size_t)max_bytes);
  if (n < 0) {
    return -1;
  }
  return (int32_t)n;
}

int32_t net_close_fd(int32_t fd) {
  close((int)fd);
  return 0;
}

int32_t net_sendfile_fd(int32_t conn, int32_t file_fd, int32_t file_size) {
#ifdef __linux__
  off_t off = 0;
  size_t remaining = (size_t)file_size;
  while (remaining > 0) {
    ssize_t n = sendfile((int)conn, (int)file_fd, &off, remaining);
    if (n > 0) {
      remaining -= (size_t)n;
      continue;
    }
    if (n < 0 && errno == EINTR) {
      continue;
    }
    if (n < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
      if (wait_writable((int)conn) < 0) {
        return -1;
      }
      continue;
    }
    return -1;
  }
  return 0;
#else
  (void)conn;
  (void)file_fd;
  (void)file_size;
  return -1;
#endif
}

intptr_t net_buf_alloc(int32_t size) {
  if (size <= 0) {
    size = 1;
  }
  char* p = (char*)malloc((size_t)size);
  if (!p) {
    li_panic("alloc failed");
  }
  return iptr(p);
}

void net_buf_free(intptr_t p) {
  if (p) {
    free((void*)ptr_i(p));
  }
}

int32_t net_buf_fill_i(intptr_t dst, intptr_t src, int32_t off, int32_t n) {
  if (!dst || !src || n < 0) {
    return -1;
  }
  memcpy(ptr_i(dst) + off, ptr_i(src), (size_t)n);
  return n;
}

int32_t httpd_write_response_hdr_i(intptr_t buf, int32_t cap, int32_t status, int32_t body_len,
                                   int32_t keep_alive) {
  const char* status_line = status == 404 ? "HTTP/1.1 404 Not Found\r\n" : "HTTP/1.1 200 OK\r\n";
  const char* conn_hdr = keep_alive ? "keep-alive" : "close";
  int n = snprintf(ptr_i(buf), (size_t)cap,
                   "%s"
                   "Content-Type: text/html\r\n"
                   "Content-Length: %d\r\n"
                   "Connection: %s\r\n"
                   "\r\n",
                   status_line, (int)body_len, conn_hdr);
  if (n < 0 || n >= cap) {
    return -1;
  }
  return (int32_t)n;
}

static void trim_line(char* s) {
  size_t n = strlen(s);
  while (n > 0 && (s[n - 1] == '\n' || s[n - 1] == '\r' || s[n - 1] == ' ' || s[n - 1] == '\t')) {
    s[--n] = '\0';
  }
  char* p = s;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (p != s) {
    memmove(s, p, strlen(p) + 1);
  }
}

int32_t httpd_load_runtime_config_i(intptr_t path) {
  const char* cfg_path = ptr_i(path);
  if (!cfg_path) {
    return -1;
  }
  FILE* f = fopen(cfg_path, "r");
  if (!f) {
    return -1;
  }
  httpd_clear_upstream_peers_i();
  g_config_listen_port = 0;
  g_doc_root_len = 0;
  g_proxy_all = 0;
  g_route_count = 0;
  g_rate_limit_rps = 0;
  g_rate_limit_burst = 0;
  g_rate_tokens = 0.0;
  g_rate_last_ts = 0.0;
  g_health_max_fails = 1;
  g_health_fail_timeout_sec = 10;
  char line[4096];
  while (fgets(line, sizeof(line), f)) {
    trim_line(line);
    if (!line[0] || line[0] == '#') {
      continue;
    }
    char* eq = strchr(line, '=');
    if (!eq) {
      continue;
    }
    *eq = '\0';
    char* key = line;
    char* val = eq + 1;
    trim_line(key);
    trim_line(val);
    if (strcmp(key, "listen_port") == 0) {
      g_config_listen_port = (int32_t)atoi(val);
    } else if (strcmp(key, "document_root") == 0) {
      g_doc_root_len = strlen(val);
      if (g_doc_root_len > 0 && g_doc_root_len < sizeof(g_doc_root)) {
        memcpy(g_doc_root, val, g_doc_root_len + 1);
      }
    } else if (strcmp(key, "proxy_all") == 0) {
      g_proxy_all = (strcmp(val, "1") == 0 || strcmp(val, "true") == 0) ? 1 : 0;
    } else if (strcmp(key, "upstream_peer") == 0) {
      int port = atoi(val);
      if (port > 0) {
        httpd_add_upstream_peer_i(port);
        g_proxy_port = port;
      }
    } else if (strcmp(key, "rate_limit_rps") == 0) {
      g_rate_limit_rps = atoi(val);
    } else if (strcmp(key, "rate_limit_burst") == 0) {
      g_rate_limit_burst = atoi(val);
    } else if (strcmp(key, "health_max_fails") == 0) {
      g_health_max_fails = atoi(val);
      if (g_health_max_fails < 1) {
        g_health_max_fails = 1;
      }
    } else if (strcmp(key, "health_fail_timeout_sec") == 0) {
      g_health_fail_timeout_sec = atoi(val);
      if (g_health_fail_timeout_sec < 1) {
        g_health_fail_timeout_sec = 1;
      }
    } else if (strcmp(key, "route") == 0 && g_route_count < HTTPD_MAX_ROUTES) {
      char method[16] = "";
      char path[512] = "";
      char kind[16] = "";
      char action[16] = "";
      int rrps = 0;
      int rburst = 0;
      int n = sscanf(val, "%15[^|]|%511[^|]|%15[^|]|%15[^|]|%d|%d", method, path, kind,
                     action, &rrps, &rburst);
      if (n >= 4) {
        httpd_route_t* r = &g_routes[g_route_count++];
        memset(r, 0, sizeof(*r));
        snprintf(r->method, sizeof(r->method), "%s", method);
        snprintf(r->path_prefix, sizeof(r->path_prefix), "%s", path);
        r->path_len = (int)strlen(r->path_prefix);
        r->is_prefix = (strcmp(kind, "prefix") == 0 || strcmp(kind, "prefix_strip") == 0) ? 1 : 0;
        r->is_proxy = (strcmp(action, "proxy") == 0) ? 1 : 0;
        if (n >= 6 && rrps > 0) {
          r->rate_limit_rps = rrps;
          r->rate_limit_burst = rburst > 0 ? rburst : rrps;
        }
        if (r->is_proxy) {
          g_proxy_all = 0;
        }
      }
    }
  }
  if (g_rate_limit_rps > 0 && g_rate_limit_burst <= 0) {
    g_rate_limit_burst = g_rate_limit_rps;
  }
  fclose(f);
  if (g_doc_root_len == 0) {
    return -1;
  }
  if (g_up_peer_count > 0) {
    upstream_pool_prewarm_all();
  }
  return 0;
}

int32_t httpd_config_listen_port_i(void) { return g_config_listen_port; }

intptr_t httpd_config_doc_root_i(void) { return g_doc_root_len ? iptr(g_doc_root) : 0; }

int32_t httpd_set_li_proxy_mode_i(int32_t on) {
  g_li_proxy_mode = on ? 1 : 0;
  return 0;
}

int32_t httpd_set_epfd_i(int32_t epfd) {
  g_httpd_epfd = (int)epfd;
  return 0;
}

int32_t httpd_proxy_configured_i(void) {
  return (g_proxy_port > 0 || g_up_peer_count > 0) ? 1 : 0;
}

int32_t httpd_proxy_upstream_port_i(void) { return g_proxy_port; }

int32_t httpd_proxy_compact_req_hdr_i(int32_t slot, int32_t hdr_end) {
  return httpd_proxy_compact_req_hdr(slot, (int)hdr_end);
}

int32_t httpd_lb_pick_port_i(void) { return httpd_lb_pick_port(); }

int32_t httpd_upstream_acquire_i(void) {
  int32_t peer_port = httpd_lb_pick_port();
  if (peer_port <= 0) {
    return -1;
  }
  int up = upstream_pool_acquire(peer_port);
  if (up < 0) {
    return -1;
  }
  set_nonblocking(up);
  tcp_tune_client(up);
  return up;
}

void httpd_upstream_release_i(int32_t fd, int32_t reuse) {
  if (fd < 0) {
    return;
  }
  int32_t peer_port = g_proxy_port;
  if (g_up_peer_count > 0) {
    peer_port = g_up_peers[0].port;
  }
  upstream_pool_release(peer_port, (int)fd, reuse ? 1 : 0);
}

int32_t tcp_recv_nb_i(int32_t fd, intptr_t buf, int32_t cap) {
  if (fd < 0 || !buf || cap <= 0) {
    return -1;
  }
  ssize_t r = recv((int)fd, ptr_i(buf), (size_t)cap, 0);
  if (r < 0) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
      return -1;
    }
    return -2;
  }
  if (r == 0) {
    return 0;
  }
  return (int32_t)r;
}

int32_t tcp_send_nb_i(int32_t fd, intptr_t buf, int32_t off, int32_t n) {
  if (fd < 0 || !buf || n <= 0) {
    return -1;
  }
  size_t sent = 0;
  ssize_t rc = httpd_send_nb((int)fd, ptr_i(buf) + off, (size_t)n, &sent);
  if (rc < 0) {
    return -2;
  }
  if (rc == 0) {
    return -1;
  }
  return (int32_t)sent;
}

#ifdef __linux__
static int32_t epoll_wait_tagged_timeout_impl(int32_t epfd, intptr_t events, int32_t max_events, int timeout_ms) {
  if (max_events <= 0 || max_events > 256) {
    max_events = 256;
  }
  struct epoll_event evs[256];
  int n = epoll_wait((int)epfd, evs, max_events, timeout_ms);
  if (n < 0) {
    if (errno == EINTR) {
      return 0;
    }
    if (timeout_ms == 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
      return 0;
    }
    net_fail("epoll_wait");
  }
  int32_t* out = (int32_t*)ptr_i(events);
  for (int i = 0; i < n; i++) {
    uint64_t d = evs[i].data.u64;
    out[i * 3] = (int32_t)(d & 0xffffffffu);
    out[i * 3 + 1] = (int32_t)(d >> 32);
    out[i * 3 + 2] = (int32_t)evs[i].events;
  }
  return n;
}

int32_t epoll_wait_tagged_i(int32_t epfd, intptr_t events, int32_t max_events) {
  return epoll_wait_tagged_timeout_impl(epfd, events, max_events, -1);
}

int32_t epoll_wait_tagged_spin_i(int32_t epfd, intptr_t events, int32_t max_events) {
  return epoll_wait_tagged_timeout_impl(epfd, events, max_events, 0);
}

int32_t httpd_epoll_register_up_i(int32_t epfd, int32_t up_fd, int32_t slot) {
  if (epfd < 0 || up_fd < 0 || slot < 0) {
    return -1;
  }
  struct epoll_event uev;
  uev.events = EPOLLIN | EPOLLOUT | EPOLLET;
  uev.data.u64 = HTTPD_EPOLL_UP_TAG | (uint64_t)(uint32_t)slot;
  return epoll_ctl((int)epfd, EPOLL_CTL_ADD, up_fd, &uev) < 0 ? -1 : 0;
}

int32_t httpd_epoll_unregister_fd_i(int32_t epfd, int32_t fd) {
  if (epfd < 0 || fd < 0) {
    return -1;
  }
  return epoll_ctl((int)epfd, EPOLL_CTL_DEL, fd, NULL) < 0 ? -1 : 0;
}

int32_t httpd_proxy_splice_cl_i(int32_t up_fd, int32_t client_fd, int32_t max_bytes) {
  httpd_proxy_splice_pipe_init();
  if (g_proxy_splice_pipe[0] < 0 || max_bytes <= 0) {
    return -1;
  }
  size_t cap = (size_t)max_bytes;
  if (cap > sizeof(g_slots[0].proxy_rbuf)) {
    cap = sizeof(g_slots[0].proxy_rbuf);
  }
  ssize_t sp = httpd_proxy_splice_once(up_fd, client_fd, cap);
  return (int32_t)sp;
}
#else
int32_t epoll_wait_tagged_i(int32_t epfd, intptr_t events, int32_t max_events) {
  (void)epfd;
  (void)events;
  (void)max_events;
  return -1;
}
int32_t epoll_wait_tagged_spin_i(int32_t epfd, intptr_t events, int32_t max_events) {
  (void)epfd;
  (void)events;
  (void)max_events;
  return -1;
}
int32_t httpd_epoll_register_up_i(int32_t epfd, int32_t up_fd, int32_t slot) {
  (void)epfd;
  (void)up_fd;
  (void)slot;
  return -1;
}
int32_t httpd_epoll_unregister_fd_i(int32_t epfd, int32_t fd) {
  (void)epfd;
  (void)fd;
  return -1;
}
int32_t httpd_proxy_splice_cl_i(int32_t up_fd, int32_t client_fd, int32_t max_bytes) {
  (void)up_fd;
  (void)client_fd;
  (void)max_bytes;
  return -1;
}
#endif

int32_t httpd_event_is_up_tag_i(int32_t tag_hi) {
  return ((uint32_t)tag_hi == (uint32_t)(HTTPD_EPOLL_UP_TAG >> 32)) ? 1 : 0;
}

int32_t httpd_event_is_client_tag_i(int32_t tag_hi) {
  return ((uint32_t)tag_hi == (uint32_t)(HTTPD_EPOLL_CLIENT_TAG >> 32)) ? 1 : 0;
}

void httpd_li_proxy_slot_clear_i(int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return;
  }
  g_lp_up_fd[slot] = -1;
  g_lp_phase[slot] = 0;
  g_lp_hdr_end[slot] = 0;
  g_lp_body_left[slot] = 0;
  g_lp_keep[slot] = 0;
  g_lp_resp_parsing[slot] = 0;
}

int32_t httpd_li_proxy_phase_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_slots[slot].proxy_phase : 0;
}

void httpd_li_proxy_set_phase_i(int32_t slot, int32_t phase) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_lp_phase[slot] = phase;
    g_slots[slot].proxy_phase = phase;
  }
}

int32_t httpd_li_proxy_up_fd_i(int32_t slot) { return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_lp_up_fd[slot] : -1; }

void httpd_li_proxy_set_up_fd_i(int32_t slot, int32_t fd) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_lp_up_fd[slot] = fd;
  }
}

int32_t httpd_li_proxy_body_left_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_lp_body_left[slot] : 0;
}

void httpd_li_proxy_set_body_left_i(int32_t slot, int32_t n) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_lp_body_left[slot] = n;
  }
}

int32_t httpd_li_proxy_hdr_end_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_lp_hdr_end[slot] : 0;
}

void httpd_li_proxy_set_hdr_end_i(int32_t slot, int32_t n) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_lp_hdr_end[slot] = n;
  }
}

int32_t httpd_li_proxy_keep_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_lp_keep[slot] : 0;
}

void httpd_li_proxy_set_keep_i(int32_t slot, int32_t k) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_lp_keep[slot] = k;
  }
}

int32_t httpd_li_proxy_resp_parsing_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_slots[slot].proxy_resp_parsing : 0;
}

void httpd_li_proxy_set_resp_parsing_i(int32_t slot, int32_t v) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_slots[slot].proxy_resp_parsing = v;
    g_lp_resp_parsing[slot] = v;
  }
}

int32_t httpd_li_proxy_cached_cl_i(void) { return g_proxy_resp_cl_cached; }

int32_t httpd_slot_conn_i(int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  return g_slots[slot].fd;
}

int32_t httpd_epoll_add_client_i(int32_t epfd, int32_t conn, int32_t slot) {
  if (epfd < 0 || conn < 0 || slot < 0) {
    return -1;
  }
#ifdef __linux__
  struct epoll_event cev;
  cev.events = EPOLLIN | EPOLLET;
  cev.data.u64 = HTTPD_EPOLL_CLIENT_TAG | (uint64_t)(uint32_t)slot;
  g_slots[slot].proxy_client_epoll_events = cev.events;
  return epoll_ctl((int)epfd, EPOLL_CTL_ADD, conn, &cev) < 0 ? -1 : 0;
#else
  (void)slot;
  return epoll_ctl_add_i(epfd, conn);
#endif
}

int32_t httpd_client_epoll_mod_i(int32_t epfd, int32_t slot, int32_t events) {
  httpd_proxy_client_epoll_mod((int)epfd, slot, (uint32_t)events);
  return 0;
}

int32_t httpd_li_proxy_active_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN && g_slots[slot].proxy_active) ? 1 : 0;
}

static int httpd_proxy_start_async(int epfd, int32_t conn, int32_t slot, int hdr_end, const httpd_req_info_t* req,
                                   int keep);

static void httpd_proxy_snap_begin_recording_if_get(int32_t slot) {
  g_proxy_snap_recording = 0;
  if (g_proxy_snap_ready || g_proxy_snap_recording || slot < 0 || slot >= HTTPD_MAX_CONN) {
    return;
  }
  if (g_slots[slot].len < 4) {
    return;
  }
  const char* b = g_slots[slot].buf;
  if (b[0] == 'G' && b[1] == 'E' && b[2] == 'T' && b[3] == ' ') {
    g_proxy_snap_recording = 1;
    g_proxy_snap_len = 0;
  }
}

/* 0 = no snap; 1 = served keep-alive; -1 = served then close; -2 = I/O error */
int32_t httpd_li_proxy_snap_ready_i(void) { return g_proxy_snap_ready ? 1 : 0; }

int32_t httpd_li_proxy_try_snap_i(int32_t conn, int32_t slot, int32_t hdr_end, int32_t keep) {
  if (!g_proxy_snap_ready || slot < 0 || slot >= HTTPD_MAX_CONN || hdr_end < 4) {
    return 0;
  }
  if (g_slots[slot].len > hdr_end) {
    return 0;
  }
  if (g_slots[slot].buf[0] != 'G' || g_slots[slot].buf[1] != 'E' || g_slots[slot].buf[2] != 'T' ||
      g_slots[slot].buf[3] != ' ') {
    return 0;
  }
  httpd_req_info_t req;
  if (parse_request_line_c(g_slots[slot].buf, hdr_end, &req) != 0) {
    return -2;
  }
  if (!path_proxy_match(req.path, req.path_len, &req)) {
    return 0;
  }
  size_t off = 0;
  ssize_t rc = httpd_send_nb(conn, g_proxy_snap, (size_t)g_proxy_snap_len, &off);
  if (rc < 0) {
    return -2;
  }
  if (rc == 0 && off < (size_t)g_proxy_snap_len) {
    return -2;
  }
  net_slot_consume(slot, hdr_end);
  return keep ? 1 : -1;
}

static int32_t httpd_li_try_start_proxy_i(int32_t epfd, int32_t conn, int32_t slot) {
  (void)epfd;
  if (!g_li_proxy_mode || g_doc_root_len == 0 || g_slots[slot].proxy_active) {
    return 0;
  }
  int len = g_slots[slot].len;
  if (len <= 0) {
    return 0;
  }
  int hdr_end = hdr_end_at_c(g_slots[slot].buf, len);
  if (hdr_end < 0) {
    return 0;
  }
  httpd_req_info_t req;
  if (parse_request_line_c(g_slots[slot].buf, hdr_end, &req) != 0) {
    return -1;
  }
  if (!path_proxy_match(req.path, req.path_len, &req)) {
    return 0;
  }
  if (g_slots[slot].len > hdr_end) {
    return 0;
  }
  int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
  int32_t snap = httpd_li_proxy_try_snap_i(conn, slot, hdr_end, keep);
  if (snap != 0) {
    return snap;
  }
  return 0;
}

int32_t httpd_li_proxy_init_req_i(int32_t slot, int32_t hdr_end) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  httpd_slot_t* s = &g_slots[slot];
  httpd_req_info_t req;
  memset(&req, 0, sizeof(req));
  if (parse_request_line_c(s->buf, hdr_end, &req) != 0) {
    return -1;
  }
  parse_request_body_meta_c(s->buf, hdr_end, &req);
  if (req.body_mode == 1 && req.content_length > HTTPD_MAX_BODY) {
    return -1;
  }
  s->proxy_req = req;
  s->proxy_send_off = 0;
  s->proxy_send_total = (size_t)hdr_end;
  s->proxy_body_slot_done = 0;
  s->proxy_chunk_state = PROXY_CHUNK_HEX;
  s->proxy_chunk_remain = 0;
  s->proxy_chunk_line_len = 0;
  s->proxy_slot_body_off = 0;
  s->proxy_slot_body_rem = s->len - hdr_end;
  s->proxy_body_left = 0;
  s->proxy_up_pending_len = 0;
  if (req.body_mode == 1) {
    s->proxy_body_left = req.content_length - (s->len - hdr_end);
    if (s->proxy_body_left < 0) {
      s->proxy_body_left = 0;
    }
  }
  g_lp_phase[slot] = HTTPD_PROXY_PHASE_SEND_REQ;
  return (int32_t)req.body_mode;
}

int32_t httpd_li_proxy_get_resp_parsing_i(int32_t slot) {
  return httpd_li_proxy_resp_parsing_i(slot);
}

int32_t httpd_li_proxy_get_resp_body_mode_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_slots[slot].proxy_resp_body_mode : 0;
}

void httpd_li_proxy_set_resp_body_mode_i(int32_t slot, int32_t v) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_slots[slot].proxy_resp_body_mode = v;
  }
}

int32_t httpd_li_proxy_get_resp_body_left_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_slots[slot].proxy_resp_body_left : 0;
}

void httpd_li_proxy_set_resp_body_left_i(int32_t slot, int32_t v) {
  if (slot >= 0 && slot < HTTPD_MAX_CONN) {
    g_slots[slot].proxy_resp_body_left = v;
    g_lp_body_left[slot] = v;
  }
}

int32_t httpd_li_proxy_get_resp_hdr_len_i(int32_t slot) {
  return (slot >= 0 && slot < HTTPD_MAX_CONN) ? g_slots[slot].proxy_resp_hdr_len : 0;
}

intptr_t httpd_li_proxy_resp_hdr_acc_i(int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return 0;
  }
  return iptr(g_slots[slot].proxy_resp_hdr_acc);
}

int32_t httpd_li_proxy_append_resp_hdr_i(int32_t slot, intptr_t data, int32_t n) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || !data || n <= 0) {
    return -1;
  }
  httpd_slot_t* s = &g_slots[slot];
  int room = (int)sizeof(s->proxy_resp_hdr_acc) - s->proxy_resp_hdr_len;
  if (n > room) {
    return -1;
  }
  memcpy(s->proxy_resp_hdr_acc + s->proxy_resp_hdr_len, ptr_i(data), (size_t)n);
  s->proxy_resp_hdr_len += n;
  return s->proxy_resp_hdr_len;
}

int32_t httpd_li_proxy_cached_hdr_len_i(void) { return g_proxy_resp_hdr_bytes_cached; }

void httpd_li_scratch_set_i(int32_t v) { g_li_scratch = v; }

int32_t httpd_li_scratch_get_i(void) { return g_li_scratch; }

int32_t httpd_li_proxy_store_resp_cache_i(int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || g_proxy_resp_cl_cached >= 0) {
    return 0;
  }
  httpd_slot_t* s = &g_slots[slot];
  int he = hdr_end_at_c(s->proxy_resp_hdr_acc, s->proxy_resp_hdr_len);
  if (he < 0) {
    return -1;
  }
  int keep = 0;
  int cl = parse_resp_content_length(s->proxy_resp_hdr_acc, he, &keep);
  if (cl < 0) {
    return -1;
  }
  g_proxy_resp_cl_cached = cl;
  g_proxy_resp_hdr_bytes_cached = he;
  if (he > 0 && he <= (int)sizeof(g_proxy_resp_hdr_copy)) {
    memcpy(g_proxy_resp_hdr_copy, s->proxy_resp_hdr_acc, (size_t)he);
  }
  return 0;
}

intptr_t httpd_li_proxy_cached_hdr_ptr_i(void) {
  return g_proxy_resp_hdr_bytes_cached > 0 ? iptr(g_proxy_resp_hdr_copy) : 0;
}

int32_t httpd_li_proxy_mark_active_i(int32_t epfd, int32_t slot, int32_t up_fd, int32_t hdr_end, int32_t keep) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || up_fd < 0) {
    return -1;
  }
  httpd_slot_t* s = &g_slots[slot];
  s->proxy_active = 1;
  s->proxy_up_fd = up_fd;
  s->proxy_hdr_end = hdr_end;
  s->proxy_keep = keep ? 1 : 0;
  s->proxy_up_reuse = keep ? 1 : 0;
  s->proxy_phase = HTTPD_PROXY_PHASE_SEND_REQ;
  s->proxy_send_off = 0;
  s->proxy_relay_got_data = 0;
  s->proxy_resp_parsing = 0;
  s->proxy_resp_hdr_len = 0;
  s->proxy_resp_body_mode = PROXY_RESP_BODY_NONE;
  s->proxy_resp_body_left = 0;
  g_lp_up_fd[slot] = up_fd;
  g_lp_hdr_end[slot] = hdr_end;
  g_lp_keep[slot] = keep ? 1 : 0;
  g_lp_phase[slot] = HTTPD_PROXY_PHASE_SEND_REQ;
  if (epfd >= 0 && httpd_epoll_register_up_i(epfd, up_fd, slot) < 0) {
    httpd_proxy_clear(epfd, slot);
    return -1;
  }
  httpd_proxy_client_epoll_mod(epfd, slot, EPOLLIN | EPOLLET);
  httpd_proxy_snap_begin_recording_if_get(slot);
  return 0;
}

int32_t httpd_li_proxy_send_request_i(int32_t epfd, int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || !g_slots[slot].proxy_active) {
    return -1;
  }
  if (g_slots[slot].proxy_phase == HTTPD_PROXY_PHASE_SEND_REQ) {
    httpd_proxy_try_send_req(epfd, slot);
  } else if (g_slots[slot].proxy_phase == HTTPD_PROXY_PHASE_SEND_BODY) {
    httpd_proxy_try_send_body(epfd, slot);
  }
  g_lp_phase[slot] = g_slots[slot].proxy_phase;
  if (!g_slots[slot].proxy_active) {
    return -1;
  }
  if (g_slots[slot].proxy_phase == HTTPD_PROXY_PHASE_RELAY) {
    return 1;
  }
  return 0;
}

int32_t httpd_li_proxy_forward_bytes_i(int32_t epfd, int32_t slot, intptr_t data, int32_t n) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || !data || n <= 0) {
    return -1;
  }
  return httpd_proxy_relay_to_client(epfd, slot, ptr_i(data), (size_t)n);
}

int32_t httpd_li_proxy_finish_ok_i(int32_t epfd, int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  httpd_proxy_finish_ok(epfd, slot);
  return 0;
}


void httpd_li_proxy_up_epoll_i(int32_t epfd, int32_t slot, int32_t revents) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) return;
  httpd_proxy_up_handler((int)epfd, slot, (uint32_t)revents);
}
void httpd_li_proxy_client_epoll_i(int32_t epfd, int32_t slot, int32_t revents) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) return;
  httpd_proxy_client_handler((int)epfd, slot, (uint32_t)revents);
}
int32_t httpd_li_proxy_finish_err_i(int32_t epfd, int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  httpd_proxy_finish_err(epfd, slot);
  return 0;
}

int32_t httpd_li_proxy_finish_drain_i(int32_t epfd, int32_t slot) {
  int conn = g_slots[slot].fd;
  if (conn < 0) {
    return -1;
  }
  for (;;) {
    if (g_slots[slot].len <= 0) {
      ssize_t r = recv(conn, g_slots[slot].buf, sizeof(g_slots[slot].buf), 0);
      if (r < 0) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
          break;
        }
        return -1;
      }
      if (r == 0) {
        return -1;
      }
      g_slots[slot].len = (int)r;
    }
    if (g_li_proxy_mode) {
      int32_t st = httpd_li_try_start_proxy_i((int)epfd, conn, slot);
      if (st != 0) {
        return st < 0 ? -1 : 0;
      }
      break;
    }
    int32_t d = httpd_try_drain_once(conn, slot);
    if (d == 0) {
      break;
    }
    if (d < 0) {
      return -1;
    }
  }
  return 0;
}

int32_t net_diag(int32_t tag) {
  (void)tag;
  return tag;
}
