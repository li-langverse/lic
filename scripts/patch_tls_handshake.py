#!/usr/bin/env python3
"""Patch li_rt_tls + lib.li for faster non-blocking TLS handshakes."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TLS_C = ROOT / "runtime" / "li_rt_tls.c"
TLS_H = ROOT / "runtime" / "li_rt_tls.h"
NET_C = ROOT / "runtime" / "li_rt_net.c"
RT_H = ROOT / "runtime" / "li_rt.h"
SEAM = ROOT / "std" / "runtime" / "seam.li"
LIB = ROOT / "packages" / "li-net-httpd" / "src" / "lib.li"

HS_BLOCK_OLD = """int32_t httpd_tls_handshake_slot(int32_t slot, int32_t fd) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_tls_ctx || !p_SSL_new) {
    return -1;
  }
  httpd_tls_free_slot(slot);
  SSL* ssl = p_SSL_new(g_tls_ctx);
  if (!ssl) {
    return -1;
  }
  p_SSL_set_fd(ssl, (int)fd);
  int flags = fcntl((int)fd, F_GETFL, 0);
  if (flags >= 0) {
    fcntl((int)fd, F_SETFL, flags & ~O_NONBLOCK);
  }
  int rc = p_SSL_accept(ssl);
  if (flags >= 0) {
    fcntl((int)fd, F_SETFL, flags);
  }
  if (rc != 1) {
    p_SSL_free(ssl);
    return -1;
  }
  g_slot_ssl[slot] = ssl;
  g_slot_proto[slot] = 1;
  if (g_tls_http2 && p_SSL_get0_alpn_selected) {
    const unsigned char* alpn = NULL;
    unsigned int alpn_len = 0;
    p_SSL_get0_alpn_selected(ssl, &alpn, &alpn_len);
    if (alpn_len == 2 && alpn[0] == 'h' && alpn[1] == '2') {
      g_slot_proto[slot] = 2;
    }
  }
  return 0;
}"""

HS_BLOCK_NEW = """static int g_slot_hs_pending[LI_HTTPD_MAX_CONN_TLS];

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
  if (err == 2 || err == 3) {
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
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_tls_ctx || !p_SSL_new) {
    return -1;
  }
  httpd_tls_free_slot(slot);
  SSL* ssl = p_SSL_new(g_tls_ctx);
  if (!ssl) {
    return -1;
  }
  p_SSL_set_fd(ssl, (int)fd);
  g_slot_ssl[slot] = ssl;
  g_slot_proto[slot] = 0;
  g_slot_hs_pending[slot] = 1;
  return httpd_tls_accept_step(slot);
}

int32_t httpd_tls_handshake_continue(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_slot_hs_pending[slot]) {
    return g_slot_proto[slot] ? 0 : -1;
  }
  return httpd_tls_accept_step(slot);
}

int32_t httpd_tls_handshake_slot(int32_t slot, int32_t fd) {
  int32_t rc = httpd_tls_handshake_begin(slot, fd);
  while (rc == 1) {
    rc = httpd_tls_handshake_continue(slot);
  }
  return rc;
}"""

FREE_SLOT_OLD = """  g_slot_ssl[slot] = NULL;
  g_slot_proto[slot] = 0;
"""

FREE_SLOT_NEW = """  g_slot_ssl[slot] = NULL;
  g_slot_proto[slot] = 0;
  g_slot_hs_pending[slot] = 0;
"""

INIT_MEMSET_OLD = """  memset(g_slot_proto, 0, sizeof(g_slot_proto));
  memset(g_slot_ssl, 0, sizeof(g_slot_ssl));
"""

INIT_MEMSET_NEW = """  memset(g_slot_proto, 0, sizeof(g_slot_proto));
  memset(g_slot_ssl, 0, sizeof(g_slot_ssl));
  memset(g_slot_hs_pending, 0, sizeof(g_slot_hs_pending));
"""

# Add poll include after fcntl includes
INCLUDES_ANCHOR = "#include <fcntl.h>"
INCLUDES_ADD = "#include <fcntl.h>\n#include <poll.h>"

CTX_ANCHOR = "  g_tls_ctx = p_SSL_CTX_new(method);"
CTX_ADD = """  g_tls_ctx = p_SSL_CTX_new(method);
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
  }"""

def patch_tls_c() -> None:
    t = TLS_C.read_text(encoding="utf-8")
    if HS_BLOCK_OLD not in t:
        if "httpd_tls_handshake_begin" in t:
            print("li_rt_tls.c already patched")
            return
        raise SystemExit("handshake block not found")
    t = t.replace(HS_BLOCK_OLD, HS_BLOCK_NEW, 1)
    t = t.replace(FREE_SLOT_OLD, FREE_SLOT_NEW, 1)
    if INIT_MEMSET_OLD in t:
        t = t.replace(INIT_MEMSET_OLD, INIT_MEMSET_NEW, 1)
    if "#include <poll.h>" not in t:
        t = t.replace(INCLUDES_ANCHOR, INCLUDES_ADD, 1)
    if "SSL_CTX_set_ciphersuites" not in t:
        t = t.replace(CTX_ANCHOR, CTX_ADD, 1)
    TLS_C.write_text(t, encoding="utf-8")
    print("patched li_rt_tls.c")


def patch_tls_h() -> None:
    t = TLS_H.read_text(encoding="utf-8")
    insert = """/* 0=done, 1=want_io, -1=error */
int32_t httpd_tls_handshake_begin(int32_t slot, int32_t fd);
int32_t httpd_tls_handshake_continue(int32_t slot);
int32_t httpd_tls_handshake_pending(int32_t slot);

"""
    old = "/* Non-blocking TLS accept after TCP accept; sets slot proto. Returns 0 ok, -1 fail. */\n"
    if "httpd_tls_handshake_begin" not in t:
        t = t.replace(old, insert + old, 1)
        TLS_H.write_text(t, encoding="utf-8")
        print("patched li_rt_tls.h")


def patch_rt_h() -> None:
    t = RT_H.read_text(encoding="utf-8")
    block = """int32_t httpd_tls_handshake_begin_i(int32_t slot, int32_t fd);
int32_t httpd_tls_handshake_continue_i(int32_t slot);
int32_t httpd_tls_handshake_pending_i(int32_t slot);
"""
    if "httpd_tls_handshake_begin_i" not in t:
        t = t.replace(
            "int32_t httpd_tls_handshake_slot_i(int32_t slot, int32_t fd);\n",
            "int32_t httpd_tls_handshake_slot_i(int32_t slot, int32_t fd);\n" + block,
            1,
        )
        RT_H.write_text(t, encoding="utf-8")
        print("patched li_rt.h")


def patch_net_c() -> None:
    t = NET_C.read_text(encoding="utf-8")
    old = "int32_t httpd_tls_handshake_slot_i(int32_t slot, int32_t fd) { return httpd_tls_handshake_slot(slot, fd); }"
    new = """int32_t httpd_tls_handshake_slot_i(int32_t slot, int32_t fd) { return httpd_tls_handshake_slot(slot, fd); }
int32_t httpd_tls_handshake_begin_i(int32_t slot, int32_t fd) { return httpd_tls_handshake_begin(slot, fd); }
int32_t httpd_tls_handshake_continue_i(int32_t slot) { return httpd_tls_handshake_continue(slot); }
int32_t httpd_tls_handshake_pending_i(int32_t slot) { return httpd_tls_handshake_pending(slot); }
int32_t httpd_epoll_add_client_tls_i(int32_t epfd, int32_t conn, int32_t slot) {
  if (epfd < 0 || conn < 0 || slot < 0) {
    return -1;
  }
#ifdef __linux__
  struct epoll_event cev;
  cev.events = EPOLLIN | EPOLLET;
  if (httpd_tls_handshake_pending(slot)) {
    cev.events |= EPOLLOUT;
  }
  cev.data.u64 = HTTPD_EPOLL_CLIENT_TAG | (uint64_t)(uint32_t)slot;
  g_slots[slot].proxy_client_epoll_events = cev.events;
  return epoll_ctl((int)epfd, EPOLL_CTL_ADD, conn, &cev) < 0 ? -1 : 0;
#else
  (void)slot;
  return epoll_ctl_add_i(epfd, conn);
#endif
}"""
    if "httpd_tls_handshake_begin_i" not in t:
        t = t.replace(old, new, 1)
        NET_C.write_text(t, encoding="utf-8")
        print("patched li_rt_net.c")


def patch_seam() -> None:
    t = SEAM.read_text(encoding="utf-8")
    block = """extern proc httpd_tls_handshake_begin_i(slot: var int, fd: var int) -> int
  requires true
  ensures true
  decreases 0

extern proc httpd_tls_handshake_continue_i(slot: var int) -> int
  requires true
  ensures true
  decreases 0

extern proc httpd_tls_handshake_pending_i(slot: var int) -> int
  requires true
  ensures true
  decreases 0

extern proc httpd_epoll_add_client_tls_i(epfd: var int, conn: var int, slot: var int) -> int
  requires true
  ensures true
  decreases 0

"""
    if "httpd_tls_handshake_begin_i" not in t:
        t = t.replace(
            "extern proc httpd_tls_handshake_slot_i(slot: var int, fd: var int) -> int\n",
            "extern proc httpd_tls_handshake_slot_i(slot: var int, fd: var int) -> int\n" + block,
            1,
        )
        SEAM.write_text(t, encoding="utf-8")
        print("patched seam.li")


def patch_lib() -> None:
    t = LIB.read_text(encoding="utf-8")
    accept_old = """    if httpd_tls_enabled_i() == 1:
      var tls_ok: int = 0
      if httpd_pure_li_tls_i() == 1:
        tls_ok = tls_server_attach(slot, conn)
      if httpd_pure_li_tls_i() != 1:
        tls_ok = httpd_tls_handshake_slot_i(slot, conn)
      if tls_ok < 0:
        tcp_close(conn)
        httpd_slot_free(slot)
        return accepted
    if httpd_epoll_add_client_i(epfd, conn, slot) < 0:
      tcp_close(conn)
      httpd_slot_free(slot)
      return accepted
    proxy_handle_client_in(epfd, slot)
    accepted = accepted + 1"""
    accept_new = """    var tls_hs_done: int = 1
    if httpd_tls_enabled_i() == 1:
      var tls_ok: int = 0
      if httpd_pure_li_tls_i() == 1:
        tls_ok = tls_server_attach(slot, conn)
        if tls_ok < 0:
          tls_hs_done = 0
      if httpd_pure_li_tls_i() != 1:
        tls_ok = httpd_tls_handshake_begin_i(slot, conn)
        if tls_ok < 0:
          tls_hs_done = 0
        if tls_ok == 1:
          tls_hs_done = 0
      if tls_ok < 0:
        tcp_close(conn)
        httpd_slot_free(slot)
        return accepted
    if httpd_epoll_add_client_tls_i(epfd, conn, slot) < 0:
      tcp_close(conn)
      httpd_slot_free(slot)
      return accepted
    if tls_hs_done == 1:
      proxy_handle_client_in(epfd, slot)
    accepted = accepted + 1"""
    if accept_old not in t:
        if "httpd_tls_handshake_begin_i" in t:
            print("lib.li already patched")
        else:
            raise SystemExit("proxy_accept_batch block not found")
    else:
        t = t.replace(accept_old, accept_new, 1)

    handle_old = """def proxy_handle_client_in(epfd: var int, slot: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0
=
  if httpd_pure_li_tls_i() == 1:"""
    handle_new = """def proxy_handle_client_in(epfd: var int, slot: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0
=
  if httpd_tls_enabled_i() == 1:
    if httpd_pure_li_tls_i() != 1:
      if httpd_tls_handshake_pending_i(slot) == 1:
        var hs: int = httpd_tls_handshake_continue_i(slot)
        if hs == 1:
          return 0
        if hs < 0:
          return -1
  if httpd_pure_li_tls_i() == 1:"""
    if handle_old in t and "httpd_tls_handshake_pending_i" not in t:
        t = t.replace(handle_old, handle_new, 1)

    client_old = """  if net_epoll_readable(rev) == 1:
    var rc2: int = proxy_handle_client_in(epfd, slot_c)
    if rc2 < 0:"""
    client_new = """  if httpd_tls_handshake_pending_i(slot_c) == 1:
    var hs2: int = httpd_tls_handshake_continue_i(slot_c)
    if hs2 == 1:
      return 0
    if hs2 < 0:
      var conn_hs: int = httpd_slot_conn_i(slot_c)
      epoll_ctl_del_i(epfd, conn_hs)
      tcp_close(conn_hs)
      httpd_slot_free(slot_c)
      return 0
  if net_epoll_readable(rev) == 1:
    var rc2: int = proxy_handle_client_in(epfd, slot_c)
    if rc2 < 0:"""
    if client_old in t and "hs2:" not in t:
        t = t.replace(client_old, client_new, 1)

    LIB.write_text(t, encoding="utf-8")
    print("patched lib.li")


def main() -> None:
    patch_tls_c()
    patch_tls_h()
    patch_rt_h()
    patch_net_c()
    patch_seam()
    patch_lib()


if __name__ == "__main__":
    main()
