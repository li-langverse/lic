from pathlib import Path

p = Path(__file__).resolve().parents[1] / "runtime/li_rt_tls.c"
t = p.read_text(encoding="utf-8")
if "static ssl_clear_fn p_SSL_clear" not in t:
    t = t.replace(
        "static ssl_set_mode_fn p_SSL_set_mode;",
        "static ssl_set_mode_fn p_SSL_set_mode;\ntypedef int (*ssl_clear_fn)(SSL*);\nstatic ssl_clear_fn p_SSL_clear;",
        1,
    )
needle = "  if (tls_load_sym(g_ssl_lib, \"SSL_set_mode\", (void**)&p_SSL_set_mode) != 0) {\n    p_SSL_set_mode = NULL;\n  }\n"
if "SSL_clear" not in t and needle in t:
    t = t.replace(
        needle,
        needle
        + "  if (tls_load_sym(g_ssl_lib, \"SSL_clear\", (void**)&p_SSL_clear) != 0) {\n    p_SSL_clear = NULL;\n  }\n",
        1,
    )
if "g_slot_hs_want_write" in t and "memset(g_slot_hs_want_write" not in t:
    t = t.replace(
        "memset(g_slot_hs_pending, 0, sizeof(g_slot_hs_pending));",
        "memset(g_slot_hs_pending, 0, sizeof(g_slot_hs_pending));\n  memset(g_slot_hs_want_write, 0, sizeof(g_slot_hs_want_write));",
        1,
    )
p.write_text(t, encoding="utf-8")
print("ok")
