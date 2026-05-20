/* Trusted Net seam — POSIX syscalls and I/O buffers only; HTTP lives in Li. */
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
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>

#ifdef __linux__
#include <sys/epoll.h>
#include <sys/sendfile.h>
#include <sys/uio.h>
#endif

#define HTTPD_MAX_CONN 512
#define HTTPD_IO_BUF 16384

typedef struct {
  int fd;
  char buf[HTTPD_IO_BUF];
  char hdr[512];
  int len;
} httpd_slot_t;

static httpd_slot_t g_slots[HTTPD_MAX_CONN];
static int g_slots_inited = 0;

static char g_cached_body[HTTPD_IO_BUF];
static int32_t g_cached_sz = 0;
static int g_cache_ready = 0;

static void slots_init_once(void) {
  if (g_slots_inited) {
    return;
  }
  for (int i = 0; i < HTTPD_MAX_CONN; i++) {
    g_slots[i].fd = -1;
    g_slots[i].len = 0;
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
  char path[4096];
  int n = snprintf(path, sizeof(path), "%s/index.html", r);
  if (n < 0 || n >= (int)sizeof(path)) {
    return -1;
  }
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    return -1;
  }
  struct stat st;
  if (fstat(fd, &st) < 0 || !S_ISREG(st.st_mode) || st.st_size > HTTPD_IO_BUF) {
    close(fd);
    return -1;
  }
  ssize_t rd = read(fd, g_cached_body, (size_t)st.st_size);
  close(fd);
  if (rd < 0) {
    return -1;
  }
  g_cached_sz = (int32_t)rd;
  g_cache_ready = 1;
  return 0;
}

int32_t httpd_cache_ready_i(void) { return g_cache_ready; }

intptr_t httpd_cached_body_i(void) { return iptr(g_cached_body); }

int32_t httpd_cached_sz_i(void) { return g_cached_sz; }

int32_t httpd_reply_cached_index_i(int32_t conn, int32_t slot, int32_t keep_alive) {
  if (!g_cache_ready || slot < 0 || slot >= HTTPD_MAX_CONN) {
    return -1;
  }
  char* hdr = g_slots[slot].hdr;
  int32_t hlen =
      httpd_write_response_hdr_i(iptr(hdr), 512, 200, g_cached_sz, keep_alive);
  if (hlen < 0) {
    return -1;
  }
  return tcp_send_coalesce_i(conn, iptr(hdr), hlen, iptr(g_cached_body), g_cached_sz);
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

/* Drain pipelined GET /index requests. Returns -2 I/O close, -1 close after reply, 0 need bytes, 1 drained. */
int32_t httpd_drain_slot_i(int32_t conn, int32_t slot) {
  slots_init_once();
  if (!g_cache_ready || slot < 0 || slot >= HTTPD_MAX_CONN || g_slots[slot].fd != conn) {
    return -2;
  }
  for (;;) {
    int len = g_slots[slot].len;
    if (len <= 0) {
      return 0;
    }
    int hdr_end = hdr_end_at_c(g_slots[slot].buf, len);
    if (hdr_end < 0) {
      return 0;
    }
    if (!is_index_get(g_slots[slot].buf, hdr_end)) {
      return -2;
    }
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_reply_cached_index_i(conn, slot, keep) < 0) {
      return -2;
    }
    net_slot_consume(slot, hdr_end);
    if (!keep) {
      return -1;
    }
  }
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
  ev.events = EPOLLIN | EPOLLET;
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

int32_t net_diag(int32_t tag) {
  (void)tag;
  return tag;
}
