/* M2 TLS 1.3 terminate — OpenSSL 3.x loaded at runtime (dlopen / LoadLibrary). */
#if !defined(_WIN32)
#define _GNU_SOURCE
#endif
#include "li_rt_tls.h"
#include "li_rt_dl_compat.h"
#include "li_rt_posix_compat.h"

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <poll.h>
#if !defined(_WIN32)
#include <unistd.h>
#endif

typedef struct ssl_st SSL;
typedef struct ssl_ctx_st SSL_CTX;
typedef struct ssl_method_st SSL_METHOD;

typedef long (*ssl_read_fn)(SSL*, void*, int);
typedef long (*ssl_write_fn)(SSL*, const void*, int);
typedef int (*ssl_accept_fn)(SSL*);
typedef void (*ssl_free_fn)(SSL*);
typedef SSL* (*ssl_new_fn)(SSL_CTX*);
typedef int (*ssl_set_fd_fn)(SSL*, int);
typedef void (*ssl_ctx_free_fn)(SSL_CTX*);
typedef SSL_CTX* (*ssl_ctx_new_fn)(const SSL_METHOD*);
typedef const SSL_METHOD* (*tls_server_method_fn)(void);
typedef int (*ssl_ctx_use_cert_fn)(SSL_CTX*, const char*, int);
typedef int (*ssl_ctx_use_key_fn)(SSL_CTX*, const char*, int);
typedef int (*ssl_ctx_set_min_proto_fn)(SSL_CTX*, int);
typedef int (*ssl_ctx_set_alpn_fn)(SSL_CTX*, const unsigned char*, unsigned int);
typedef int (*ssl_ctx_set_alpn_cb_fn)(SSL_CTX*, int (*)(SSL*, const unsigned char**, unsigned char*,
                                                          const unsigned char*, unsigned int, void*),
                                      void*);
typedef int (*ssl_select_next_proto_fn)(unsigned char**, unsigned char*, const unsigned char*,
                                        unsigned int, const unsigned char*, unsigned int);
typedef void (*ssl_get_alpn_fn)(const SSL*, const unsigned char**, unsigned int*);
typedef int (*openssl_init_fn)(uint64_t, const void*);
typedef unsigned long (*ssl_get_error_fn)(const SSL*, int);

#define TLS1_3_VERSION 0x0304

static void* g_ssl_lib;
static void* g_crypto_lib;
static ssl_read_fn p_SSL_read;
static ssl_write_fn p_SSL_write;
static ssl_accept_fn p_SSL_accept;
static ssl_free_fn p_SSL_free;
static ssl_new_fn p_SSL_new;
static ssl_set_fd_fn p_SSL_set_fd;
static ssl_ctx_free_fn p_SSL_CTX_free;
static ssl_ctx_new_fn p_SSL_CTX_new;
static tls_server_method_fn p_TLS_server_method;
static ssl_ctx_use_cert_fn p_SSL_CTX_use_certificate_file;
static ssl_ctx_use_key_fn p_SSL_CTX_use_PrivateKey_file;
static ssl_ctx_set_min_proto_fn p_SSL_CTX_set_min_proto_version;
static ssl_ctx_set_alpn_fn p_SSL_CTX_set_alpn_protos;
static ssl_ctx_set_alpn_cb_fn p_SSL_CTX_set_alpn_select_cb;
static ssl_select_next_proto_fn p_SSL_select_next_proto;
static ssl_get_alpn_fn p_SSL_get0_alpn_selected;
static openssl_init_fn p_OPENSSL_init_ssl;
static ssl_get_error_fn p_SSL_get_error;
typedef long (*ssl_set_mode_fn)(SSL*, long);
static ssl_set_mode_fn p_SSL_set_mode;
typedef int (*ssl_clear_fn)(SSL*);
static ssl_clear_fn p_SSL_clear;

static SSL_CTX* g_tls_ctx;
static int g_tls_wanted;
static int g_tls_ready;
static int g_tls_http2;
static const unsigned char g_alpn_protos[] = {0x02, 'h', '2', 0x08, 'h', 't', 't', 'p', '/', '1', '.', '1'};

static int tls_alpn_select_cb(SSL* ssl, const unsigned char** out, unsigned char* outlen,
                              const unsigned char* in, unsigned int inlen, void* arg) {
  (void)ssl;
  (void)arg;
  if (!p_SSL_select_next_proto) {
    return 0; /* SSL_TLSEXT_ERR_NOACK */
  }
  if (p_SSL_select_next_proto((unsigned char**)out, outlen, g_alpn_protos, (unsigned int)sizeof(g_alpn_protos),
                              in, inlen) == 0) {
    return 1; /* SSL_TLSEXT_ERR_OK */
  }
  return 0;
}
static int g_slot_proto[LI_HTTPD_MAX_CONN_TLS];
static SSL* g_slot_ssl[LI_HTTPD_MAX_CONN_TLS];
static int g_slot_hs_pending[LI_HTTPD_MAX_CONN_TLS];
static int g_slot_hs_want_write[LI_HTTPD_MAX_CONN_TLS];
static int g_tls_ssl_reuse = 1;
static int g_pure_li_tls;
static int g_legacy_openssl = 1;
static int g_pure_slot_active[LI_HTTPD_MAX_CONN_TLS];
static int g_pure_slot_alpn[LI_HTTPD_MAX_CONN_TLS];

static void tls_read_env_mode(void) {
  const char* legacy = getenv("LI_HTTPD_TLS_LEGACY_OPENSSL");
  if (legacy && (legacy[0] == '0' || legacy[0] == 'f' || legacy[0] == 'F')) {
    g_legacy_openssl = 0;
  }
  const char* pure = getenv("LI_HTTPD_TLS_PURE_LI");
  if (pure && pure[0] == '1') {
    g_pure_li_tls = 1;
    g_legacy_openssl = 0;
  }
}

int32_t httpd_pure_li_tls_enabled(void) {
  return g_pure_li_tls && !g_legacy_openssl;
}

int32_t httpd_pure_tls_slot_active(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return 0;
  }
  return g_pure_slot_active[slot] ? 1 : 0;
}

int32_t httpd_pure_tls_attach(int32_t slot, int32_t conn) {
  (void)conn;
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return -1;
  }
  g_pure_slot_active[slot] = 1;
  g_pure_slot_alpn[slot] = 0;
  return 0;
}

int32_t httpd_pure_tls_poll(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_pure_slot_active[slot]) {
    return -1;
  }
  if (g_slot_ssl[slot]) {
    return 1;
  }
  return 0;
}

ssize_t httpd_pure_tls_read_app(int32_t slot, int max_bytes) {
  (void)max_bytes;
  return -1;
}

ssize_t httpd_pure_tls_write_app(int32_t slot, int len) {
  (void)slot;
  (void)len;
  return -1;
}

int32_t httpd_pure_tls_alpn(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return 0;
  }
  if (g_slot_proto[slot] == 2) {
    return 1;
  }
  if (g_slot_proto[slot] == 1) {
    return 2;
  }
  return g_pure_slot_alpn[slot];
}


static int tls_load_sym(void* lib, const char* name, void** out) {
  void* sym = li_rt_dlsym(lib, name);
  if (!sym) {
    return -1;
  }
  *out = sym;
  return 0;
}

static int tls_load_openssl(void) {
  if (g_tls_ready) {
    return 0;
  }
#if defined(_WIN32)
  const char* ssl_names[] = {"libssl-3-x64.dll", "libssl-3.dll", "libssl.dll", NULL};
  const char* crypto_names[] = {"libcrypto-3-x64.dll", "libcrypto-3.dll", "libcrypto.dll", NULL};
#else
  const char* ssl_names[] = {"libssl.so.3", "libssl.so", NULL};
  const char* crypto_names[] = {"libcrypto.so.3", "libcrypto.so", NULL};
#endif
  for (int i = 0; crypto_names[i]; i++) {
    g_crypto_lib = li_rt_dlopen(crypto_names[i], RTLD_NOW | RTLD_GLOBAL);
    if (g_crypto_lib) {
      break;
    }
  }
  for (int i = 0; ssl_names[i]; i++) {
    g_ssl_lib = li_rt_dlopen(ssl_names[i], RTLD_NOW | RTLD_GLOBAL);
    if (g_ssl_lib) {
      break;
    }
  }
  if (!g_crypto_lib) {
    fprintf(stderr, "li-httpd tls: dlopen crypto: %s\n", li_rt_dlerror());
    return -1;
  }
  if (!g_ssl_lib) {
    fprintf(stderr, "li-httpd tls: dlopen ssl: %s\n", li_rt_dlerror());
    return -1;
  }
#define LOAD(fn, name)                                                                  \
  do {                                                                                  \
    if (tls_load_sym(g_ssl_lib, name, (void**)&p_##fn) != 0) {                          \
      fprintf(stderr, "li-httpd tls: missing symbol %s: %s\n", name, li_rt_dlerror());        \
      return -1;                                                                        \
    }                                                                                   \
  } while (0)
  LOAD(SSL_read, "SSL_read");
  LOAD(SSL_write, "SSL_write");
  LOAD(SSL_accept, "SSL_accept");
  LOAD(SSL_free, "SSL_free");
  LOAD(SSL_new, "SSL_new");
  LOAD(SSL_set_fd, "SSL_set_fd");
  LOAD(SSL_CTX_free, "SSL_CTX_free");
  LOAD(SSL_CTX_new, "SSL_CTX_new");
  LOAD(TLS_server_method, "TLS_server_method");
  LOAD(SSL_CTX_use_certificate_file, "SSL_CTX_use_certificate_file");
  LOAD(SSL_CTX_use_PrivateKey_file, "SSL_CTX_use_PrivateKey_file");
  if (tls_load_sym(g_ssl_lib, "SSL_CTX_set_min_proto_version", (void**)&p_SSL_CTX_set_min_proto_version) != 0) {
    p_SSL_CTX_set_min_proto_version = NULL;
  }
  LOAD(SSL_CTX_set_alpn_protos, "SSL_CTX_set_alpn_protos");
  if (tls_load_sym(g_ssl_lib, "SSL_CTX_set_alpn_select_cb", (void**)&p_SSL_CTX_set_alpn_select_cb) != 0) {
    p_SSL_CTX_set_alpn_select_cb = NULL;
  }
  if (tls_load_sym(g_ssl_lib, "SSL_select_next_proto", (void**)&p_SSL_select_next_proto) != 0) {
    p_SSL_select_next_proto = NULL;
  }
  LOAD(SSL_get0_alpn_selected, "SSL_get0_alpn_selected");
  LOAD(SSL_get_error, "SSL_get_error");
  if (tls_load_sym(g_ssl_lib, "SSL_set_mode", (void**)&p_SSL_set_mode) != 0) {
    p_SSL_set_mode = NULL;
  }
#undef LOAD
  if (tls_load_sym(g_ssl_lib, "OPENSSL_init_ssl", (void**)&p_OPENSSL_init_ssl) != 0) {
    p_OPENSSL_init_ssl = NULL;
  }
  if (p_OPENSSL_init_ssl) {
    p_OPENSSL_init_ssl(0, NULL);
  }
  {
    const char* reuse = getenv("LI_HTTPD_TLS_SSL_REUSE");
    g_tls_ssl_reuse = (reuse && (reuse[0] == '0' || reuse[0] == 'f' || reuse[0] == 'F')) ? 0 : 1;
  }
  g_tls_ready = 1;
  return 0;
}

int32_t httpd_tls_runtime_wanted(void) { return g_tls_wanted; }

int32_t httpd_tls_runtime_ready(void) { return g_tls_ready && g_tls_ctx != NULL; }

int32_t httpd_tls_slot_proto(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return 0;
  }
  return g_slot_proto[slot];
}

void* httpd_tls_slot_ssl(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return NULL;
  }
  return g_slot_ssl[slot];
}

void httpd_tls_free_slot(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return;
  }
  if (g_tls_ssl_reuse && g_slot_ssl[slot]) {
    g_slot_proto[slot] = 0;
    g_slot_hs_pending[slot] = 0;
    return;
  }
  if (g_slot_ssl[slot] && p_SSL_free) {
    p_SSL_free(g_slot_ssl[slot]);
  }
  g_slot_ssl[slot] = NULL;
  g_slot_proto[slot] = 0;
  g_slot_hs_pending[slot] = 0;
}

static int32_t httpd_tls_global_init_files(const char* cert_path, const char* key_path);


int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on) {
  return httpd_tls_global_init_paths(cert_dir, NULL, NULL, http2_on);
}

int32_t httpd_tls_global_init_paths(const char* cert_dir, const char* manual_cert,
                                    const char* manual_key, int32_t http2_on) {
  static char cert_path[4096];
  static char key_path[4096];
  cert_path[0] = key_path[0] = '\0';
  if (manual_cert && manual_cert[0] && manual_key && manual_key[0]) {
    strncpy(cert_path, manual_cert, sizeof(cert_path) - 1);
    strncpy(key_path, manual_key, sizeof(key_path) - 1);
  } else if (cert_dir && cert_dir[0]) {
    snprintf(cert_path, sizeof(cert_path), "%s/fullchain.pem", cert_dir);
    snprintf(key_path, sizeof(key_path), "%s/privkey.pem", cert_dir);
  }
  g_tls_http2 = http2_on ? 1 : 0;
  return httpd_tls_global_init_files(cert_path, key_path);
}


int32_t httpd_tls_global_init_files(const char* cert_path, const char* key_path) {
  tls_read_env_mode();
  g_tls_wanted = 1;
  memset(g_slot_proto, 0, sizeof(g_slot_proto));
  memset(g_slot_ssl, 0, sizeof(g_slot_ssl));
  memset(g_slot_hs_pending, 0, sizeof(g_slot_hs_pending));
  memset(g_slot_hs_want_write, 0, sizeof(g_slot_hs_want_write));
  if (httpd_pure_li_tls_enabled()) {
    g_tls_ready = 1;
    return 0;
  }
  if (tls_load_openssl() != 0) {
    fprintf(stderr, "li-httpd tls: failed to load libssl (install openssl)\n");
    return -1;
  }
  if (!cert_path || !cert_path[0] || !key_path || !key_path[0]) {
    return -1;
  }
  if (access(cert_path, R_OK) != 0 || access(key_path, R_OK) != 0) {
    fprintf(stderr, "li-httpd tls: missing %s or %s (run setup-tls)\n", cert_path, key_path);
    return -1;
  }
  const SSL_METHOD* method = p_TLS_server_method();
  if (!method) {
    return -1;
  }
  g_tls_ctx = p_SSL_CTX_new(method);
  if (g_tls_ctx) {
    typedef long (*ssl_ctx_set_options_fn)(SSL_CTX*, long);
    ssl_ctx_set_options_fn p_opts = NULL;
    if (tls_load_sym(g_ssl_lib, "SSL_CTX_set_options", (void**)&p_opts) == 0 && p_opts) {
      p_opts(g_tls_ctx, 0x00080000L); /* SSL_OP_SINGLE_ECDH_USE */
    }
    typedef int (*ssl_ctx_set_ciphersuites_fn)(SSL_CTX*, const char*);
    ssl_ctx_set_ciphersuites_fn p_ciphersuites = NULL;
    if (tls_load_sym(g_ssl_lib, "SSL_CTX_set_ciphersuites", (void**)&p_ciphersuites) == 0 &&
        p_ciphersuites) {
      p_ciphersuites(g_tls_ctx, "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384");
    }
    typedef void (*ssl_ctx_set_num_tickets_fn)(SSL_CTX*, size_t);
    ssl_ctx_set_num_tickets_fn p_num_tickets = NULL;
    if (tls_load_sym(g_ssl_lib, "SSL_CTX_set_num_tickets", (void**)&p_num_tickets) == 0 &&
        p_num_tickets) {
      p_num_tickets(g_tls_ctx, 0);
    }
    typedef long (*ssl_ctx_set_mode_fn)(SSL_CTX*, long);
    ssl_ctx_set_mode_fn p_ctx_mode = NULL;
    if (tls_load_sym(g_ssl_lib, "SSL_CTX_set_mode", (void**)&p_ctx_mode) == 0 && p_ctx_mode) {
      p_ctx_mode(g_tls_ctx, 0x00000020L); /* SSL_MODE_RELEASE_BUFFERS */
    }
  }
  if (!g_tls_ctx) {
    return -1;
  }
  if (p_SSL_CTX_set_min_proto_version) {
    if (p_SSL_CTX_set_min_proto_version(g_tls_ctx, TLS1_3_VERSION) != 1) {
      fprintf(stderr, "li-httpd tls: TLS 1.3 min_protocol required\n");
      p_SSL_CTX_free(g_tls_ctx);
      g_tls_ctx = NULL;
      return -1;
    }
  }
  if (p_SSL_CTX_use_certificate_file(g_tls_ctx, cert_path, 1) != 1 ||
      p_SSL_CTX_use_PrivateKey_file(g_tls_ctx, key_path, 1) != 1) {
    fprintf(stderr, "li-httpd tls: failed to load cert/key\n");
    p_SSL_CTX_free(g_tls_ctx);
    g_tls_ctx = NULL;
    return -1;
  }
  if (g_tls_http2) {
    if (p_SSL_CTX_set_alpn_select_cb) {
      p_SSL_CTX_set_alpn_select_cb(g_tls_ctx, tls_alpn_select_cb, NULL);
    } else if (p_SSL_CTX_set_alpn_protos) {
      if (p_SSL_CTX_set_alpn_protos(g_tls_ctx, g_alpn_protos, (unsigned int)sizeof(g_alpn_protos)) != 0) {
        fprintf(stderr, "li-httpd tls: ALPN protos rejected\n");
        p_SSL_CTX_free(g_tls_ctx);
        g_tls_ctx = NULL;
        return -1;
      }
    }
  }
  return 0;
}

void httpd_tls_global_shutdown(void) {
  for (int i = 0; i < LI_HTTPD_MAX_CONN_TLS; i++) {
    httpd_tls_free_slot(i);
  }
  if (g_tls_ctx && p_SSL_CTX_free) {
    p_SSL_CTX_free(g_tls_ctx);
  }
  g_tls_ctx = NULL;
  g_tls_wanted = 0;
  g_tls_ready = 0;
  if (g_ssl_lib) {
    dlclose(g_ssl_lib);
    g_ssl_lib = NULL;
  }
  if (g_crypto_lib) {
    dlclose(g_crypto_lib);
    g_crypto_lib = NULL;
  }
}

static void httpd_tls_finish_handshake_slot(int32_t slot, SSL* ssl) {
  g_slot_proto[slot] = 1;
  if (g_tls_http2 && p_SSL_get0_alpn_selected) {
    const unsigned char* alpn = NULL;
    unsigned int alpn_len = 0;
    p_SSL_get0_alpn_selected(ssl, &alpn, &alpn_len);
    if (alpn_len == 2 && alpn[0] == 'h' && alpn[1] == '2') {
      g_slot_proto[slot] = 2;
    }
  }
  g_slot_hs_pending[slot] = 0;
}

/* 0=done, 1=want_io, -1=error */
static int32_t httpd_tls_accept_step(int32_t slot) {
  SSL* ssl = g_slot_ssl[slot];
  if (!ssl || !p_SSL_accept) {
    return -1;
  }
  int rc = p_SSL_accept(ssl);
  if (rc == 1) {
    httpd_tls_finish_handshake_slot(slot, ssl);
    return 0;
  }
  if (!p_SSL_get_error) {
    return -1;
  }
  int err = p_SSL_get_error(ssl, rc);
  if (err == 2) {
    g_slot_hs_want_write[slot] = 0;
    return 1;
  }
  if (err == 3) {
    g_slot_hs_want_write[slot] = 1;
    return 1;
  }
  return -1;
}

int32_t httpd_tls_handshake_pending(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return 0;
  }
  return g_slot_hs_pending[slot] ? 1 : 0;
}

int32_t httpd_tls_handshake_begin(int32_t slot, int32_t fd) {
  SSL* ssl;
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_tls_ctx || !p_SSL_new) {
    return -1;
  }
  g_slot_proto[slot] = 0;
  g_slot_hs_pending[slot] = 0;
  ssl = g_slot_ssl[slot];
  if (g_tls_ssl_reuse && ssl && p_SSL_clear) {
    if (p_SSL_clear(ssl) != 1) {
      p_SSL_free(ssl);
      ssl = NULL;
      g_slot_ssl[slot] = NULL;
    }
  } else if (ssl && p_SSL_free) {
    p_SSL_free(ssl);
    ssl = NULL;
    g_slot_ssl[slot] = NULL;
  }
  if (!ssl) {
    ssl = p_SSL_new(g_tls_ctx);
    if (!ssl) {
      return -1;
    }
    g_slot_ssl[slot] = ssl;
  }
  p_SSL_set_fd(ssl, (int)fd);
  if (p_SSL_set_mode) {
    p_SSL_set_mode(ssl, 0x00000002L | 0x00000010L);
  }
  g_slot_hs_pending[slot] = 1;
  return httpd_tls_accept_step(slot);
}

int32_t httpd_tls_handshake_continue(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_slot_hs_pending[slot]) {
    return g_slot_proto[slot] ? 0 : -1;
  }
  return httpd_tls_accept_step(slot);
}

int32_t httpd_tls_handshake_spin(int32_t slot, int32_t fd, int32_t max_rounds) {
  struct pollfd pfd;
  int32_t rounds = max_rounds > 0 ? max_rounds : 256;
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || fd < 0) {
    return -1;
  }
  while (g_slot_hs_pending[slot] && rounds-- > 0) {
    int32_t rc = httpd_tls_accept_step(slot);
    if (rc != 1) {
      return rc;
    }
    pfd.fd = (int)fd;
    pfd.events = (short)(g_slot_hs_want_write[slot] ? POLLOUT : POLLIN);
    pfd.revents = 0;
    if (poll(&pfd, 1, 1) <= 0) {
      return 1;
    }
  }
  return g_slot_hs_pending[slot] ? 1 : 0;
}

int32_t httpd_tls_handshake_slot(int32_t slot, int32_t fd) {
  int32_t rc = httpd_tls_handshake_begin(slot, fd);
  if (rc == 1) {
    rc = httpd_tls_handshake_spin(slot, fd, 4096);
  }
  return rc;
}

ssize_t httpd_tls_read_slot(int32_t slot, void* buf, size_t cap) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_slot_ssl[slot] || !p_SSL_read) {
    return -1;
  }
  int r = (int)p_SSL_read(g_slot_ssl[slot], buf, (int)(cap > INT_MAX ? INT_MAX : cap));
  if (r <= 0) {
    int err = p_SSL_get_error(g_slot_ssl[slot], r);
    if (err == 2 || err == 3) {
      return 0;
    }
    return -1;
  }
  return (ssize_t)r;
}

ssize_t httpd_tls_write_fd(int32_t fd, const void* buf, size_t len) {
  (void)fd;
  /* Caller should use httpd_tls_write_slot; fd kept for API compat. */
  (void)buf;
  (void)len;
  return -1;
}

ssize_t httpd_tls_write_slot(int32_t slot, const void* buf, size_t len) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_slot_ssl[slot] || !p_SSL_write) {
    return -1;
  }
  size_t off = 0;
  while (off < len) {
    int chunk = (int)((len - off) > 16384 ? 16384 : (len - off));
    int w = (int)p_SSL_write(g_slot_ssl[slot], (const char*)buf + off, chunk);
    if (w <= 0) {
      int err = p_SSL_get_error(g_slot_ssl[slot], w);
      if (err == 2 || err == 3 && off == 0) {
        return 0;
      }
      return off > 0 ? (ssize_t)off : -1;
    }
    off += (size_t)w;
  }
  return (ssize_t)off;
}
