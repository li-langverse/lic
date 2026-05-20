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
static char g_cached_blob_ka[512 + HTTPD_IO_BUF];
static int32_t g_cached_blob_ka_len = 0;
static char g_cached_blob_close[512 + HTTPD_IO_BUF];
static int32_t g_cached_blob_close_len = 0;
static char g_doc_root[4096];
static size_t g_doc_root_len = 0;
static char g_proxy_host[64] = "127.0.0.1";
static int32_t g_proxy_port = 0;
static int g_proxy_all = 0;

#define HTTPD_MAX_UPSTREAM_PEERS 8
#define HTTPD_POOL_PER_PEER 32
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
  int32_t port;
  int fds[HTTPD_POOL_PER_PEER];
  int in_use[HTTPD_POOL_PER_PEER];
  int active;
  int down;
} httpd_upstream_peer_t;

static httpd_upstream_peer_t g_up_peers[HTTPD_MAX_UPSTREAM_PEERS];
static int g_up_peer_count = 0;
static int g_lb_rr = 0;
static int g_lb_mode = 0; /* 0=round_robin, 1=least_conn */
static int32_t g_config_listen_port = 0;

static void upstream_pool_prewarm_all(void);

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

intptr_t net_lit_loopback_i(void) { return iptr("127.0.0.1"); }

int32_t httpd_set_proxy_upstream_port_i(int32_t port, int32_t proxy_all) {
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
  if (!g_cache_ready || slot < 0 || slot >= HTTPD_MAX_CONN) {
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

int32_t httpd_mark_upstream_peer_down_i(int32_t port) {
  httpd_upstream_peer_t* p = upstream_peer_find(port);
  if (!p) {
    return -1;
  }
  p->down = 1;
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] >= 0) {
      close(p->fds[i]);
      p->fds[i] = -1;
      p->in_use[i] = 0;
    }
  }
  return 0;
}

static int32_t httpd_lb_pick_port(void) {
  if (g_up_peer_count <= 0) {
    return g_proxy_port;
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
  if (p && p->down) {
    return -1;
  }
  if (!p) {
    int fd = tcp_connect_loopback_port((int)port);
    if (fd >= 0) {
      set_nonblocking(fd);
      p = upstream_peer_get_or_add(port);
      if (p) {
        p->active++;
      }
    }
    return fd;
  }
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] >= 0 && !p->in_use[i]) {
      p->in_use[i] = 1;
      p->active++;
      return p->fds[i];
    }
  }
  for (int i = 0; i < HTTPD_POOL_PER_PEER; i++) {
    if (p->fds[i] < 0) {
      int fd = tcp_connect_loopback_port((int)port);
      if (fd < 0) {
        return -1;
      }
      set_nonblocking(fd);
      p->fds[i] = fd;
      p->in_use[i] = 1;
      p->active++;
      return fd;
    }
  }
  {
    int fd = tcp_connect_loopback_port((int)port);
    if (fd >= 0) {
      set_nonblocking(fd);
      p->active++;
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
      }
      return;
    }
  }
  close(fd);
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

static int path_proxy_match(const char* path, int plen) {
  if (g_proxy_port <= 0) {
    return 0;
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

/* 0 = need bytes; 1 = served keep-alive; -1 = close after reply; -2 = I/O error */
static int32_t httpd_try_drain_once(int32_t conn, int32_t slot) {
  slots_init_once();
  if (!g_cache_ready || slot < 0 || slot >= HTTPD_MAX_CONN || g_slots[slot].fd != conn) {
    return -2;
  }
  int len = g_slots[slot].len;
  if (len <= 0) {
    return 0;
  }
  int hdr_end = hdr_end_at_c(g_slots[slot].buf, len);
  if (hdr_end < 0) {
    return 0;
  }
  if (request_headers_unsafe_c(g_slots[slot].buf, hdr_end)) {
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_send_status(conn, 400, "Bad Request", NULL, keep) < 0) {
      return -2;
    }
    return keep ? 1 : -1;
  }
  httpd_req_info_t req;
  if (parse_request_line_c(g_slots[slot].buf, hdr_end, &req) != 0) {
    return -2;
  }
  parse_request_body_meta_c(g_slots[slot].buf, hdr_end, &req);
  if (req.body_mode == 1 && req.content_length > HTTPD_MAX_BODY) {
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_send_status(conn, 413, "Payload Too Large", NULL, keep) < 0) {
      return -2;
    }
    return keep ? 1 : -1;
  }
  if (!path_is_safe(req.path, req.path_len)) {
    int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
    if (httpd_send_status(conn, 400, "Bad Request", NULL, keep) < 0) {
      return -2;
    }
    return keep ? 1 : -1;
  }
  int keep = !wants_connection_close(g_slots[slot].buf, hdr_end);
  if (path_proxy_match(req.path, req.path_len)) {
    if (httpd_proxy_forward(conn, slot, hdr_end, &req) < 0) {
      return -2;
    }
    net_slot_consume(slot, hdr_end);
    if (!keep) {
      return -1;
    }
    return 1;
  }
  if (method_is(&req, "OPTIONS")) {
    if (httpd_send_status(conn, 204, "No Content",
                          "Allow: GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS\r\n", keep) < 0) {
      return -2;
    }
    net_slot_consume(slot, hdr_end);
    return keep ? 1 : -1;
  }
  if (method_is(&req, "GET") && (is_index_path_c(req.path, req.path_len) || is_index_get(g_slots[slot].buf, hdr_end))) {
    if (httpd_reply_cached_index_i(conn, slot, keep) < 0) {
      return -2;
    }
  } else if (method_is(&req, "GET")) {
    if (httpd_send_static_path(conn, slot, req.path, req.path_len, keep) < 0) {
      if (httpd_send_status(conn, 404, "Not Found", NULL, keep) < 0) {
        return -2;
      }
    }
  } else if (method_is(&req, "HEAD")) {
    if (httpd_send_static_path(conn, slot, req.path, req.path_len, 0) < 0) {
      if (httpd_send_status(conn, 404, "Not Found", NULL, keep) < 0) {
        return -2;
      }
    }
  } else if (req.body_mode != 0) {
    if (httpd_discard_request_body(conn, slot, hdr_end, &req) < 0) {
      return -2;
    }
    if (httpd_send_status(conn, 405, "Method Not Allowed",
                          "Allow: GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS\r\n", keep) < 0) {
      return -2;
    }
    net_slot_consume(slot, hdr_end);
    return keep ? 1 : -1;
  } else {
    if (httpd_send_status(conn, 405, "Method Not Allowed",
                          "Allow: GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS\r\n", keep) < 0) {
      return -2;
    }
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

static void httpd_conn_close_slot(int epfd, int32_t slot) {
  slots_init_once();
  if (slot < 0 || slot >= HTTPD_MAX_CONN) {
    return;
  }
  if (g_slots[slot].fd >= 0) {
    if (epfd >= 0) {
      epoll_ctl((int)epfd, EPOLL_CTL_DEL, g_slots[slot].fd, NULL);
    }
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
  if (!g_cache_ready) {
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
      cev.events = EPOLLIN;
      cev.data.fd = cfd;
      if (epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &cev) < 0) {
        httpd_conn_close_slot(-1, slot);
      }
    }
    return;
  }

  if (ev->events & (EPOLLERR | EPOLLHUP)) {
    int32_t slot = httpd_slot_find_fd(fd);
    if (slot >= 0) {
      httpd_conn_close_slot(epfd, slot);
    }
    return;
  }

  if (ev->events & EPOLLIN) {
    int32_t slot = httpd_slot_find_fd(fd);
    if (slot >= 0) {
      httpd_serve_conn_epoll(epfd, slot);
    }
  }
}

int32_t httpd_epoll_serve_i(int32_t port, intptr_t root) {
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
    }
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

int32_t net_diag(int32_t tag) {
  (void)tag;
  return tag;
}
