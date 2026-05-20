/* Trusted Net seam + M0 static HTTP server for tier-5 benches (POSIX). */
#include "li_rt.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/wait.h>

static void net_fail(const char* msg) {
  fprintf(stderr, "li net: %s: %s\n", msg, strerror(errno));
  li_panic("Net effect failed");
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

static int send_simple_response(int conn, int status, const char* body, size_t body_len,
                                const char* content_type) {
  char hdr[512];
  int hlen = snprintf(hdr, sizeof(hdr),
                      "HTTP/1.1 %d OK\r\n"
                      "Content-Type: %s\r\n"
                      "Content-Length: %zu\r\n"
                      "Connection: close\r\n"
                      "\r\n",
                      status, content_type, body_len);
  if (hlen < 0 || (size_t)hlen >= sizeof(hdr)) {
    return -1;
  }
  tcp_send(conn, hdr);
  if (body_len > 0 && body) {
    ssize_t off = 0;
    while ((size_t)off < body_len) {
      ssize_t n = send(conn, body + off, body_len - (size_t)off, 0);
      if (n <= 0) {
        return -1;
      }
      off += n;
    }
  }
  return 0;
}

static int handle_connection(int conn, const char* root) {
  const char* req = tcp_recv(conn, 8192);
  if (!req) {
    return -1;
  }
  const char* path = "/";
  if (strncmp(req, "GET ", 4) == 0) {
    const char* start = req + 4;
    const char* end = strchr(start, ' ');
    if (end && end > start) {
      static char pathbuf[4096];
      size_t len = (size_t)(end - start);
      if (len >= sizeof(pathbuf)) {
        len = sizeof(pathbuf) - 1;
      }
      memcpy(pathbuf, start, len);
      pathbuf[len] = '\0';
      path = pathbuf;
    }
  }
  free((void*)req);

  char filepath[4096];
  if (strcmp(path, "/") == 0) {
    snprintf(filepath, sizeof(filepath), "%s/index.html", root);
  } else {
    snprintf(filepath, sizeof(filepath), "%s%s", root, path);
  }

  int fd = open(filepath, O_RDONLY);
  if (fd < 0) {
    const char* msg = "not found";
    send_simple_response(conn, 404, msg, strlen(msg), "text/plain");
    return 0;
  }
  struct stat st;
  if (fstat(fd, &st) < 0 || !S_ISREG(st.st_mode)) {
    close(fd);
    const char* msg = "not found";
    send_simple_response(conn, 404, msg, strlen(msg), "text/plain");
    return 0;
  }
  size_t sz = (size_t)st.st_size;
  char* body = (char*)malloc(sz + 1);
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
  const char* ctype = "text/html";
  if (strstr(filepath, ".css")) {
    ctype = "text/css";
  } else if (strstr(filepath, ".js")) {
    ctype = "application/javascript";
  }
  send_simple_response(conn, 200, body, rd, ctype);
  free(body);
  return 0;
}

int32_t httpd_parse_port(const char* s) {
  if (!s || !*s) {
    return 8080;
  }
  return (int32_t)atoi(s);
}

/* CLI entry for li-net-httpd main (argv already set by lic runtime). */
int32_t httpd_run_from_argv(void) {
  if (li_rt_argc() < 3) {
    return 1;
  }
  int32_t port = httpd_parse_port(li_rt_argv(1));
  return httpd_serve_static_blocking(port, li_rt_argv(2));
}

/* Blocking static server for bench subprocess (returns only on error). */
int32_t httpd_serve_static_blocking(int32_t port, const char* root) {
  fprintf(stderr, "li-httpd: serve port=%d root=%s\n", (int)port, root ? root : "(null)");
  fflush(stderr);
  if (!root || port <= 0 || port > 65535) {
    li_panic("invalid httpd config");
  }
  int32_t listen_fd = tcp_listen(port);
  for (;;) {
    int32_t conn = tcp_accept(listen_fd);
    pid_t pid = fork();
    if (pid == 0) {
      tcp_close(listen_fd);
      handle_connection(conn, root);
      tcp_close(conn);
      _exit(0);
    }
    tcp_close(conn);
    while (waitpid(-1, NULL, WNOHANG) > 0) {
    }
  }
  return 0;
}
