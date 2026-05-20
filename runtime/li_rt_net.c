/* Trusted Net seam — syscall/ABI primitives only; HTTP logic lives in Li. */
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
#include <unistd.h>
#include <stdint.h>

static void net_fail(const char* msg) {
  fprintf(stderr, "li net: %s: %s\n", msg, strerror(errno));
  li_panic("Net effect failed");
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
  size_t off = 0;
  while (off < (size_t)len) {
    ssize_t n = send((int)conn_fd, data + off, (size_t)len - off, MSG_NOSIGNAL);
    if (n < 0) {
      net_fail("send");
    }
    if (n == 0) {
      return -1;
    }
    off += (size_t)n;
  }
  return len;
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

void tcp_tune_client(int32_t fd) {
  int one = 1;
  setsockopt((int)fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one));
#ifdef TCP_QUICKACK
  setsockopt((int)fd, IPPROTO_TCP, TCP_QUICKACK, &one, sizeof(one));
#endif
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

/* Concatenate a+b into a new buffer; takes ownership of heap buffers a and b. */
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

const char* int_to_str(int32_t n) {
  char tmp[32];
  snprintf(tmp, sizeof(tmp), "%d", (int)n);
  return li_rt_strdup_buf(tmp, strlen(tmp));
}

/* Concatenate literals or heap strings; does not free inputs. */
const char* str_cat2(const char* a, const char* b) {
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

const char* str_path_join(const char* root, const char* path) {
  if (!root) {
    root = "";
  }
  if (!path || strcmp(path, "/") == 0) {
    const char* slash = "/index.html";
    return str_cat2(root, slash);
  }
  return str_cat2(root, path);
}

const char* file_read_all(const char* path, int32_t max_bytes) {
  if (!path || max_bytes <= 0) {
    return li_rt_strdup_buf("", 0);
  }
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    return li_rt_strdup_buf("", 0);
  }
  struct stat st;
  if (fstat(fd, &st) < 0 || !S_ISREG(st.st_mode)) {
    close(fd);
    return li_rt_strdup_buf("", 0);
  }
  size_t sz = (size_t)st.st_size;
  if (sz > (size_t)max_bytes) {
    sz = (size_t)max_bytes;
  }
  char* buf = (char*)malloc(sz + 1);
  if (!buf) {
    close(fd);
    li_panic("alloc failed");
  }
  size_t rd = 0;
  while (rd < sz) {
    ssize_t n = read(fd, buf + rd, sz - rd);
    if (n <= 0) {
      break;
    }
    rd += (size_t)n;
  }
  close(fd);
  buf[rd] = '\0';
  return buf;
}

int32_t httpd_parse_port(const char* s) {
  return net_atoi(s);
}

const char* net_empty_str(void) { return li_rt_strdup_buf("", 0); }

/* Static literal — safe as intptr handle for default document path. */
const char* net_slash_path(void) { return "/"; }

static const char* ptr_i(intptr_t p) { return (const char*)p; }
static intptr_t iptr(const char* p) { return (intptr_t)p; }

intptr_t tcp_recv_i(int32_t conn, int32_t max) { return iptr(tcp_recv(conn, max)); }

int32_t tcp_send_i(int32_t conn, intptr_t data) { return tcp_send(conn, ptr_i(data)); }

intptr_t li_rt_argv_i(int32_t index) { return iptr(li_rt_argv(index)); }

int32_t bytes_len_i(intptr_t b) { return bytes_len(ptr_i(b)); }

intptr_t bytes_slice_i(intptr_t b, int32_t off, int32_t n) {
  return iptr(bytes_slice(ptr_i(b), off, n));
}

intptr_t bytes_append_i(intptr_t a, intptr_t b) { return iptr(bytes_append(ptr_i(a), ptr_i(b))); }

int32_t net_byte_at_i(intptr_t b, int32_t off) { return net_byte_at(ptr_i(b), off); }

intptr_t int_to_str_i(int32_t n) { return iptr(int_to_str(n)); }

intptr_t str_cat2_i(intptr_t a, intptr_t b) { return iptr(str_cat2(ptr_i(a), ptr_i(b))); }

intptr_t str_path_join_i(intptr_t root, intptr_t path) {
  return iptr(str_path_join(ptr_i(root), ptr_i(path)));
}

intptr_t file_read_all_i(intptr_t path, int32_t max) { return iptr(file_read_all(ptr_i(path), max)); }

intptr_t net_empty_str_i(void) { return iptr(net_empty_str()); }

intptr_t net_slash_path_i(void) { return iptr(net_slash_path()); }

int32_t httpd_parse_port_i(intptr_t s) { return httpd_parse_port(ptr_i(s)); }

static int send_all_bytes(int conn, const void* data, size_t len) {
  const char* p = (const char*)data;
  size_t off = 0;
  while (off < len) {
    ssize_t n = send(conn, p + off, len - off, MSG_NOSIGNAL);
    if (n < 0) {
      return -1;
    }
    if (n == 0) {
      return -1;
    }
    off += (size_t)n;
  }
  return 0;
}

int32_t httpd_send_reply_i(int32_t conn, intptr_t body, int32_t keep_alive) {
  const char* b = ptr_i(body);
  int32_t blen = bytes_len(b);
  if (blen < 0) {
    blen = 0;
  }
  const char* conn_hdr = keep_alive ? "keep-alive" : "close";
  char hdr[256];
  int hlen = snprintf(hdr, sizeof(hdr),
                      "HTTP/1.1 200 OK\r\n"
                      "Content-Type: text/html\r\n"
                      "Content-Length: %d\r\n"
                      "Connection: %s\r\n"
                      "\r\n",
                      (int)blen, conn_hdr);
  if (hlen < 0 || (size_t)hlen >= sizeof(hdr)) {
    return -1;
  }
  char* blob = (char*)malloc((size_t)hlen + (size_t)blen);
  if (!blob) {
    return -1;
  }
  memcpy(blob, hdr, (size_t)hlen);
  if (blen > 0) {
    memcpy(blob + hlen, b, (size_t)blen);
  }
  int rc = send_all_bytes(conn, blob, (size_t)hlen + (size_t)blen);
  free(blob);
  return rc < 0 ? -1 : 0;
}

int32_t httpd_send_404_i(int32_t conn, int32_t keep_alive) {
  const char* msg = "not found";
  const char* conn_hdr = keep_alive ? "keep-alive" : "close";
  char hdr[256];
  int hlen = snprintf(hdr, sizeof(hdr),
                      "HTTP/1.1 404 Not Found\r\n"
                      "Content-Type: text/plain\r\n"
                      "Content-Length: %zu\r\n"
                      "Connection: %s\r\n"
                      "\r\n",
                      strlen(msg), conn_hdr);
  if (hlen < 0) {
    return -1;
  }
  if (send_all_bytes(conn, hdr, (size_t)hlen) < 0) {
    return -1;
  }
  return send_all_bytes(conn, msg, strlen(msg)) < 0 ? -1 : 0;
}

int32_t net_diag(int32_t tag) {
  FILE* f = fopen("/tmp/li-net-diag.log", "a");
  if (f) {
    fprintf(f, "diag %d\n", (int)tag);
    fclose(f);
  }
  fprintf(stderr, "li-net diag %d\n", (int)tag);
  fflush(stderr);
  return tag;
}
