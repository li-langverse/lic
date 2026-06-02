#!/usr/bin/env python3
"""Second-pass TLS handshake perf: SSL_clear reuse, accept spin, ctx tuning."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TLS_C = ROOT / "runtime" / "li_rt_tls.c"
TLS_H = ROOT / "runtime" / "li_rt_tls.h"
NET_C = ROOT / "runtime" / "li_rt_net.c"
RT_H = ROOT / "runtime" / "li_rt.h"
SEAM = ROOT / "std/runtime/seam.li"
LIB = ROOT / "packages/li-net-httpd/src/lib.li"

ACCEPT_STEP_OLD = """/* 0=done, 1=want_io, -1=error */
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
}"""

ACCEPT_STEP_NEW = """/* 0=done, 1=want_io, -1=error */
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
}"""

HS_WANT_DECL = "static int g_slot_hs_pending[LI_HTTPD_MAX_CONN_TLS];"
HS_WANT_NEW = """static int g_slot_hs_pending[LI_HTTPD_MAX_CONN_TLS];
static int g_slot_hs_want_write[LI_HTTPD_MAX_CONN_TLS];
static int g_tls_ssl_reuse = 1;"""

BEGIN_OLD = """int32_t httpd_tls_handshake_begin(int32_t slot, int32_t fd) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS || !g_tls_ctx || !p_SSL_new) {
    return -1;
  }
  httpd_tls_free_slot(slot);
  SSL* ssl = p_SSL_new(g_tls_ctx);
  if (!ssl) {
    return -1;
  }
  p_SSL_set_fd(ssl, (int)fd);
  if (p_SSL_set_mode) {
    p_SSL_set_mode(ssl, 0x00000002L | 0x00000010L);
  }
  g_slot_ssl[slot] = ssl;
  g_slot_proto[slot] = 0;
  g_slot_hs_pending[slot] = 1;
  return httpd_tls_accept_step(slot);
}"""

BEGIN_NEW = """int32_t httpd_tls_handshake_begin(int32_t slot, int32_t fd) {
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
}"""

FREE_OLD = """void httpd_tls_free_slot(int32_t slot) {
  if (slot < 0 || slot >= LI_HTTPD_MAX_CONN_TLS) {
    return;
  }
  if (g_slot_ssl[slot] && p_SSL_free) {
    p_SSL_free(g_slot_ssl[slot]);
  }
  g_slot_ssl[slot] = NULL;
  g_slot_proto[slot] = 0;
  g_slot_hs_pending[slot] = 0;
}"""

FREE_NEW = """void httpd_tls_free_slot(int32_t slot) {
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
}"""

SLOT_OLD = """int32_t httpd_tls_handshake_slot(int32_t slot, int32_t fd) {
  int32_t rc = httpd_tls_handshake_begin(slot, fd);
  while (rc == 1) {
    rc = httpd_tls_handshake_continue(slot);
  }
  return rc;
}"""

SLOT_NEW = """int32_t httpd_tls_handshake_spin(int32_t slot, int32_t fd, int32_t max_rounds) {
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
}"""

LOAD_SSL_CLEAR = """  if (tls_load_sym(g_ssl_lib, "SSL_set_mode", (void**)&p_SSL_set_mode) != 0) {
    p_SSL_set_mode = NULL;
  }"""

LOAD_SSL_CLEAR_NEW = """  if (tls_load_sym(g_ssl_lib, "SSL_set_mode", (void**)&p_SSL_set_mode) != 0) {
    p_SSL_set_mode = NULL;
  }
  if (tls_load_sym(g_ssl_lib, "SSL_clear", (void**)&p_SSL_clear) != 0) {
    p_SSL_clear = NULL;
  }"""

CTX_TUNING = """      p_ciphersuites(g_tls_ctx, "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384");
    }
  }
  if (!g_tls_ctx) {"""

CTX_TUNING_NEW = """      p_ciphersuites(g_tls_ctx, "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384");
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
  if (!g_tls_ctx) {"""

INIT_ENV = """  if (p_OPENSSL_init_ssl) {
    p_OPENSSL_init_ssl(0, NULL);
  }
  g_tls_ready = 1;
  return 0;
}"""

INIT_ENV_NEW = """  if (p_OPENSSL_init_ssl) {
    p_OPENSSL_init_ssl(0, NULL);
  }
  {
    const char* reuse = getenv("LI_HTTPD_TLS_SSL_REUSE");
    g_tls_ssl_reuse = (reuse && (reuse[0] == '0' || reuse[0] == 'f' || reuse[0] == 'F')) ? 0 : 1;
  }
  g_tls_ready = 1;
  return 0;
}"""


def patch_tls_c() -> None:
    t = TLS_C.read_text(encoding="utf-8")
    if "httpd_tls_handshake_spin" in t:
        print("li_rt_tls.c v2 already applied")
        return
    t = t.replace(HS_WANT_DECL, HS_WANT_NEW, 1)
    t = t.replace(ACCEPT_STEP_OLD, ACCEPT_STEP_NEW, 1)
    t = t.replace(BEGIN_OLD, BEGIN_NEW, 1)
    t = t.replace(FREE_OLD, FREE_NEW, 1)
    t = t.replace(SLOT_OLD, SLOT_NEW, 1)
    if "p_SSL_clear" not in t:
        t = t.replace(
            "typedef long (*ssl_set_mode_fn)(SSL*, long);\nstatic ssl_set_mode_fn p_SSL_set_mode;",
            "typedef long (*ssl_set_mode_fn)(SSL*, long);\nstatic ssl_set_mode_fn p_SSL_set_mode;\n"
            "typedef int (*ssl_clear_fn)(SSL*);\nstatic ssl_clear_fn p_SSL_clear;",
            1,
        )
        t = t.replace(LOAD_SSL_CLEAR, LOAD_SSL_CLEAR_NEW, 1)
    if "SSL_CTX_set_num_tickets" not in t:
        t = t.replace(CTX_TUNING, CTX_TUNING_NEW, 1)
    if "LI_HTTPD_TLS_SSL_REUSE" not in t:
        t = t.replace(INIT_ENV, INIT_ENV_NEW, 1)
    TLS_C.write_text(t, encoding="utf-8")
    print("patched li_rt_tls.c v2")


def patch_headers_and_exports() -> None:
    th = TLS_H.read_text(encoding="utf-8")
    if "httpd_tls_handshake_spin" not in th:
        th = th.replace(
            "int32_t httpd_tls_handshake_pending(int32_t slot);\n",
            "int32_t httpd_tls_handshake_pending(int32_t slot);\n"
            "/* Spin accept with poll until done (max_rounds) or still want_io. */\n"
            "int32_t httpd_tls_handshake_spin(int32_t slot, int32_t fd, int32_t max_rounds);\n",
            1,
        )
        TLS_H.write_text(th, encoding="utf-8")
    rh = RT_H.read_text(encoding="utf-8")
    if "httpd_tls_handshake_spin_i" not in rh:
        rh = rh.replace(
            "int32_t httpd_tls_handshake_pending_i(int32_t slot);\n",
            "int32_t httpd_tls_handshake_pending_i(int32_t slot);\n"
            "int32_t httpd_tls_handshake_spin_i(int32_t slot, int32_t fd, int32_t max_rounds);\n",
            1,
        )
        RT_H.write_text(rh, encoding="utf-8")
    nc = NET_C.read_text(encoding="utf-8")
    if "httpd_tls_handshake_spin_i" not in nc:
        nc = nc.replace(
            "int32_t httpd_tls_handshake_pending_i(int32_t slot) { return httpd_tls_handshake_pending(slot); }\n",
            "int32_t httpd_tls_handshake_pending_i(int32_t slot) { return httpd_tls_handshake_pending(slot); }\n"
            "int32_t httpd_tls_handshake_spin_i(int32_t slot, int32_t fd, int32_t max_rounds) {\n"
            "  return httpd_tls_handshake_spin(slot, fd, max_rounds);\n"
            "}\n",
            1,
        )
        NET_C.write_text(nc, encoding="utf-8")
    sm = SEAM.read_text(encoding="utf-8")
    if "httpd_tls_handshake_spin_i" not in sm:
        sm = sm.replace(
            "extern proc httpd_tls_handshake_pending_i(slot: var int) -> int\n"
            "  requires 0 <= slot\n"
            "  ensures true\n"
            "  decreases 0\n",
            "extern proc httpd_tls_handshake_pending_i(slot: var int) -> int\n"
            "  requires 0 <= slot\n"
            "  ensures true\n"
            "  decreases 0\n\n"
            "extern proc httpd_tls_handshake_spin_i(slot: var int, fd: var int, max_rounds: var int) -> int\n"
            "  requires 0 <= slot\n"
            "  requires fd >= 0\n"
            "  ensures true\n"
            "  decreases 0\n",
            1,
        )
        SEAM.write_text(sm, encoding="utf-8")


def patch_lib() -> None:
    t = LIB.read_text(encoding="utf-8")
    old = """        if tls_ok == 1:
          tls_hs_done = 0
      if tls_ok < 0:
        tcp_close(conn)
        httpd_slot_free(slot)
        return accepted
    if httpd_epoll_add_client_tls_i(epfd, conn, slot) < 0:"""
    new = """        if tls_ok == 1:
          var spin: int = httpd_tls_handshake_spin_i(slot, conn, 512)
          if spin == 0:
            tls_ok = 0
            tls_hs_done = 1
          if spin < 0:
            tls_ok = -1
      if tls_ok < 0:
        tcp_close(conn)
        httpd_slot_free(slot)
        return accepted
    if httpd_epoll_add_client_tls_i(epfd, conn, slot) < 0:"""
    if "httpd_tls_handshake_spin_i" not in t:
        t = t.replace(old, new, 1)
        LIB.write_text(t, encoding="utf-8")
        print("patched lib.li v2")


def main() -> None:
    patch_tls_c()
    patch_headers_and_exports()
    patch_lib()


if __name__ == "__main__":
    main()
