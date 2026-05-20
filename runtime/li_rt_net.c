/* Trusted Net seam + static HTTP server for tier-5 benches (POSIX). */
#include "li_rt.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <poll.h>
#include <unistd.h>

#ifdef __linux__
#include <sys/epoll.h>
#include <sys/sendfile.h>
#endif

#define HTTPD_MAX_CONN 512
#define HTTPD_IO_BUF 16384

static void net_fail(const char* msg) {
  fprintf(stderr, "li net: %s: %s\n", msg, strerror(errno));
  li_panic("Net effect failed");
}

static void tcp_tune_client(int fd) {
  int one = 1;
  setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one));
#ifdef TCP_QUICKACK
  setsockopt(fd, IPPROTO_TCP, TCP_QUICKACK, &one, sizeof(one));
#endif
}

static void tcp_ack_now(int fd) {
#ifdef TCP_QUICKACK
  int one = 1;
  setsockopt(fd, IPPROTO_TCP, TCP_QUICKACK, &one, sizeof(one));
#endif
  (void)fd;
}

static int set_nonblocking(int fd) {
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags < 0) {
    return -1;
  }
  return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
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
  size_t len = strlen(data);
  size_t off = 0;
  while (off < len) {
    ssize_t n = send((int)conn_fd, data + off, len - off, 0);
    if (n < 0) {
      net_fail("send");
    }
    off += (size_t)n;
  }
  return (int32_t)len;
}

static char* li_rt_strdup_buf(const char* src, size_t n) {
  char* out = (char*)malloc(n + 1);
  if (!out) {
    li_panic("alloc failed");
  }
  memcpy(out, src, n);
  out[n] = '\0';
  return out;
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

static ssize_t send_all(int conn, const void* data, size_t len) {
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

static int header_has_connection_close(const char* hdr, size_t hdr_len) {
  const char* p = hdr;
  const char* end = hdr + hdr_len;
  while (p < end) {
    const char* line_end = memchr(p, '\n', (size_t)(end - p));
    if (!line_end) {
      break;
    }
    size_t line_len = (size_t)(line_end - p);
    if (line_len >= 15) {
      if (strncasecmp(p, "Connection:", 11) == 0) {
        const char* v = p + 11;
        while (v < line_end && (*v == ' ' || *v == '\t')) {
          v++;
        }
        if (line_len >= (size_t)(v - p) + 5 && strncasecmp(v, "close", 5) == 0) {
          return 1;
        }
      }
    }
    p = line_end + 1;
  }
  return 0;
}

static int parse_get_path(const char* req, size_t req_len, char* pathbuf, size_t pathbuf_sz) {
  if (req_len < 4 || strncmp(req, "GET ", 4) != 0) {
    return -1;
  }
  const char* start = req + 4;
  const char* end = memchr(start, ' ', (size_t)(req + req_len - start));
  if (!end || end <= start) {
    return -1;
  }
  size_t len = (size_t)(end - start);
  if (len >= pathbuf_sz) {
    len = pathbuf_sz - 1;
  }
  memcpy(pathbuf, start, len);
  pathbuf[len] = '\0';
  return 0;
}

static const char* content_type_for_path(const char* filepath) {
  if (strstr(filepath, ".css")) {
    return "text/css";
  }
  if (strstr(filepath, ".js")) {
    return "application/javascript";
  }
  return "text/html";
}

static int resolve_filepath(const char* root, const char* path, char* filepath, size_t sz) {
  if (strcmp(path, "/") == 0) {
    return snprintf(filepath, sz, "%s/index.html", root) >= (int)sz ? -1 : 0;
  }
  return snprintf(filepath, sz, "%s%s", root, path) >= (int)sz ? -1 : 0;
}

static int send_error(int conn, int status, const char* msg, int keep_alive) {
  char hdr[512];
  const char* conn_hdr = keep_alive ? "keep-alive" : "close";
  int hlen = snprintf(hdr, sizeof(hdr),
                      "HTTP/1.1 %d %s\r\n"
                      "Content-Type: text/plain\r\n"
                      "Content-Length: %zu\r\n"
                      "Connection: %s\r\n"
                      "\r\n",
                      status, status == 404 ? "Not Found" : "Error", strlen(msg), conn_hdr);
  if (hlen < 0 || (size_t)hlen >= sizeof(hdr)) {
    return -1;
  }
  if (send_all(conn, hdr, (size_t)hlen) < 0) {
    return -1;
  }
  return (int)send_all(conn, msg, strlen(msg));
}

static int send_static_file(int conn, const char* filepath, int keep_alive) {
  tcp_ack_now(conn);
  int fd = open(filepath, O_RDONLY);
  if (fd < 0) {
    return send_error(conn, 404, "not found", keep_alive);
  }
  struct stat st;
  if (fstat(fd, &st) < 0 || !S_ISREG(st.st_mode)) {
    close(fd);
    return send_error(conn, 404, "not found", keep_alive);
  }

  size_t sz = (size_t)st.st_size;
  const char* ctype = content_type_for_path(filepath);
  const char* conn_hdr = keep_alive ? "keep-alive" : "close";
  char hdr[512];
  int hlen = snprintf(hdr, sizeof(hdr),
                      "HTTP/1.1 200 OK\r\n"
                      "Content-Type: %s\r\n"
                      "Content-Length: %zu\r\n"
                      "Connection: %s\r\n"
                      "\r\n",
                      ctype, sz, conn_hdr);
  if (hlen < 0 || (size_t)hlen >= sizeof(hdr)) {
    close(fd);
    return -1;
  }

  /* Small static files: one TCP segment (header+body) avoids delayed-ACK stalls on keep-alive. */
  if (sz <= 16384) {
    char* blob = (char*)malloc((size_t)hlen + sz);
    if (!blob) {
      close(fd);
      return -1;
    }
    memcpy(blob, hdr, (size_t)hlen);
    size_t rd = 0;
    while (rd < sz) {
      ssize_t n = read(fd, blob + hlen + rd, sz - rd);
      if (n <= 0) {
        break;
      }
      rd += (size_t)n;
    }
    close(fd);
    int rc = (int)send_all(conn, blob, (size_t)hlen + rd);
    free(blob);
    return rc < 0 ? -1 : 0;
  }

  if (send_all(conn, hdr, (size_t)hlen) < 0) {
    close(fd);
    return -1;
  }

#ifdef __linux__
  off_t off = 0;
  while ((size_t)off < sz) {
    ssize_t n = sendfile(conn, fd, &off, sz - (size_t)off);
    if (n > 0) {
      continue;
    }
    if (n < 0 && errno == EINTR) {
      continue;
    }
    if (n < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
      if (wait_writable(conn) < 0) {
        close(fd);
        return -1;
      }
      continue;
    }
    close(fd);
    return -1;
  }
  close(fd);
  return 0;
#else
  char stack[8192];
  char* body = sz <= sizeof(stack) ? stack : (char*)malloc(sz);
  if (!body) {
    close(fd);
    return -1;
  }
  size_t rd = 0;
  while (rd < sz) {
    ssize_t n = read(fd, body + rd, sz - rd);
    if (n <= 0) {
      break;
    }
    rd += (size_t)n;
  }
  close(fd);
  int rc = (int)send_all(conn, body, rd);
  if (body != stack) {
    free(body);
  }
  return rc < 0 ? -1 : 0;
#endif
}

static int serve_one_request(int conn, const char* root, const char* req, size_t req_len, int* close_after) {
  char pathbuf[4096];
  if (parse_get_path(req, req_len, pathbuf, sizeof(pathbuf)) != 0) {
    return send_error(conn, 400, "bad request", 0);
  }

  const char* hdr_end = NULL;
  if (req_len >= 4) {
    for (size_t i = 0; i + 3 < req_len; i++) {
      if (req[i] == '\r' && req[i + 1] == '\n' && req[i + 2] == '\r' && req[i + 3] == '\n') {
        hdr_end = req + i + 4;
        break;
      }
    }
  }
  size_t hdr_len = hdr_end ? (size_t)(hdr_end - req) : req_len;
  int client_close = header_has_connection_close(req, hdr_len);
  int keep_alive = !client_close;

  char filepath[4096];
  if (resolve_filepath(root, pathbuf, filepath, sizeof(filepath)) != 0) {
    *close_after = 1;
    return send_error(conn, 404, "not found", 0);
  }

  int rc = send_static_file(conn, filepath, keep_alive);
  *close_after = client_close || rc < 0;
  return rc;
}

static size_t drain_requests(int conn, const char* root, char* buf, size_t len, int* done) {
  size_t consumed = 0;
  *done = 0;

  while (consumed < len) {
    const char* scan = buf + consumed;
    size_t remain = len - consumed;
    const char* hdr_end = NULL;
    for (size_t i = 0; i + 3 < remain; i++) {
      if (scan[i] == '\r' && scan[i + 1] == '\n' && scan[i + 2] == '\r' && scan[i + 3] == '\n') {
        hdr_end = scan + i + 4;
        break;
      }
    }
    if (!hdr_end) {
      break;
    }

    size_t req_len = (size_t)(hdr_end - scan);
    int close_after = 0;
    if (serve_one_request(conn, root, scan, req_len, &close_after) < 0) {
      *done = 1;
      return len;
    }
    consumed += req_len;
    if (close_after) {
      *done = 1;
      return consumed;
    }
  }
  return consumed;
}

typedef struct {
  int fd;
  char buf[HTTPD_IO_BUF];
  size_t len;
} httpd_conn_t;

static void httpd_conn_close(httpd_conn_t* c, int epfd) {
  if (c->fd < 0) {
    return;
  }
#ifdef __linux__
  if (epfd >= 0) {
    epoll_ctl(epfd, EPOLL_CTL_DEL, c->fd, NULL);
  }
#endif
  close(c->fd);
  c->fd = -1;
  c->len = 0;
}

#ifdef __linux__
static int httpd_epoll_loop(int listen_fd, const char* root) {
  int epfd = epoll_create1(0);
  if (epfd < 0) {
    net_fail("epoll_create1");
  }

  set_nonblocking(listen_fd);
  struct epoll_event ev;
  ev.events = EPOLLIN;
  ev.data.fd = listen_fd;
  if (epoll_ctl(epfd, EPOLL_CTL_ADD, listen_fd, &ev) < 0) {
    net_fail("epoll_ctl listen");
  }

  httpd_conn_t* conns = (httpd_conn_t*)calloc((size_t)HTTPD_MAX_CONN, sizeof(httpd_conn_t));
  if (!conns) {
    li_panic("alloc failed");
  }
  for (int i = 0; i < HTTPD_MAX_CONN; i++) {
    conns[i].fd = -1;
    conns[i].len = 0;
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
      int fd = events[i].data.fd;
      if (fd == listen_fd) {
        for (;;) {
          int cfd = accept(listen_fd, NULL, NULL);
          if (cfd < 0) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
              break;
            }
            net_fail("accept");
          }
          set_nonblocking(cfd);
          tcp_tune_client(cfd);
          int slot = -1;
          for (int j = 0; j < HTTPD_MAX_CONN; j++) {
            if (conns[j].fd < 0) {
              slot = j;
              break;
            }
          }
          if (slot < 0) {
            close(cfd);
            continue;
          }
          conns[slot].fd = cfd;
          conns[slot].len = 0;
          struct epoll_event cev;
          cev.events = EPOLLIN;
          cev.data.fd = cfd;
          if (epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &cev) < 0) {
            close(cfd);
            conns[slot].fd = -1;
          }
        }
        continue;
      }

      httpd_conn_t* c = NULL;
      for (int j = 0; j < HTTPD_MAX_CONN; j++) {
        if (conns[j].fd == fd) {
          c = &conns[j];
          break;
        }
      }
      if (!c) {
        continue;
      }

      if (events[i].events & (EPOLLERR | EPOLLHUP)) {
        httpd_conn_close(c, epfd);
        continue;
      }

      if (events[i].events & EPOLLIN) {
        for (;;) {
          if (c->len >= HTTPD_IO_BUF) {
            httpd_conn_close(c, epfd);
            break;
          }
          tcp_ack_now(c->fd);
          ssize_t r = recv(c->fd, c->buf + c->len, HTTPD_IO_BUF - c->len, 0);
          if (r < 0) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
              break;
            }
            httpd_conn_close(c, epfd);
            break;
          }
          if (r == 0) {
            httpd_conn_close(c, epfd);
            break;
          }
          c->len += (size_t)r;

          int done = 0;
          size_t used = drain_requests(c->fd, root, c->buf, c->len, &done);
          if (used > 0) {
            memmove(c->buf, c->buf + used, c->len - used);
            c->len -= used;
          }
          if (done) {
            httpd_conn_close(c, epfd);
            break;
          }
        }
      }
    }
  }
  return 0;
}
#endif

static int httpd_accept_loop(int listen_fd, const char* root) {
  for (;;) {
    int conn = (int)tcp_accept(listen_fd);
    tcp_tune_client(conn);
    char buf[HTTPD_IO_BUF];
    size_t len = 0;
    int done = 0;

    while (!done) {
      tcp_ack_now(conn);
      ssize_t r = recv(conn, buf + len, HTTPD_IO_BUF - len, 0);
      if (r <= 0) {
        break;
      }
      len += (size_t)r;
      size_t used = drain_requests(conn, root, buf, len, &done);
      if (used > 0) {
        memmove(buf, buf + used, len - used);
        len -= used;
      }
      if (done) {
        break;
      }
    }
    tcp_close(conn);
  }
  return 0;
}

int32_t httpd_parse_port(const char* s) {
  if (!s || !*s) {
    return 8080;
  }
  return (int32_t)atoi(s);
}

int32_t httpd_run_from_argv(void) {
  if (li_rt_argc() < 3) {
    return 1;
  }
  int32_t port = httpd_parse_port(li_rt_argv(1));
  return httpd_serve_static_blocking(port, li_rt_argv(2));
}

int32_t httpd_serve_static_blocking(int32_t port, const char* root) {
  fprintf(stderr, "li-httpd: serve port=%d root=%s (keep-alive, pipeline, epoll)\n", (int)port,
          root ? root : "(null)");
  fflush(stderr);
  if (!root || port <= 0 || port > 65535) {
    li_panic("invalid httpd config");
  }
  int32_t listen_fd = tcp_listen(port);
  const char* mode = getenv("LI_HTTPD_EPOLL");
  if (!mode || strcmp(mode, "1") == 0) {
#ifdef __linux__
    return (int32_t)httpd_epoll_loop((int)listen_fd, root);
#endif
  }
  return (int32_t)httpd_accept_loop((int)listen_fd, root);
}
