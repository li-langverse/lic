#!/usr/bin/env python3
"""Wire Li-native proxy relay: lib.li, seam.li, C runtime, docs, tests."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

NATIVE_BLOCK = '''
import proxy_relay_native

def proxy_relay_native_selftest() -> int
  requires true
  ensures -30 <= result
  ensures result <= 0
  decreases 0
=
  return relay_native_oracle_selftest()

def proxy_li_native_pending(slot: var int) raises IO -> int
  requires 0 <= slot
  ensures result == 0 or result == 1
  decreases 0
=
  var rbuf: int = httpd_native_proxy_get_rbuf_pending_i(slot)
  var defer: int = httpd_native_proxy_get_tls_defer_i(slot)
  var wbio: int = httpd_native_proxy_get_tls_wbio_pending_i(slot)
  var ssl: int = httpd_native_proxy_get_tls_ssl_pending_i(slot)
  return relay_pending_client(rbuf, defer, wbio, ssl)

def proxy_li_sync_body_left(slot: var int, consumed: int) raises IO -> unit
  requires 0 <= slot
  requires 0 <= consumed
  ensures true
  decreases consumed
=
  var left: int = httpd_li_proxy_get_resp_body_left_i(slot)
  var cl_active: int = httpd_native_proxy_get_cl_body_active_i(slot)
  left = relay_account_body(left, consumed, cl_active)
  httpd_li_proxy_set_resp_body_left_i(slot, left)

def proxy_li_upstream_blocked(slot: var int) raises IO -> int
  requires 0 <= slot
  ensures result == 0 or result == 1
  decreases 0
=
  var defer: int = httpd_native_proxy_get_tls_defer_i(slot)
  var rbuf: int = httpd_native_proxy_get_rbuf_pending_i(slot)
  var wbio: int = httpd_native_proxy_get_tls_wbio_pending_i(slot)
  var ssl: int = httpd_native_proxy_get_tls_ssl_pending_i(slot)
  var body_left: int = httpd_li_proxy_get_resp_body_left_i(slot)
  return relay_upstream_blocked(defer, rbuf, wbio, ssl, body_left)

def proxy_li_try_finish(epfd: var int, slot: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures -1 <= result
  ensures result <= 1
  decreases 0
=
  if httpd_li_proxy_active_i(slot) == 0:
    return -1
  var body_left: int = httpd_li_proxy_get_resp_body_left_i(slot)
  var defer: int = httpd_native_proxy_get_tls_defer_i(slot)
  var rbuf: int = httpd_native_proxy_get_rbuf_pending_i(slot)
  var wbio: int = httpd_native_proxy_get_tls_wbio_pending_i(slot)
  var ssl: int = httpd_native_proxy_get_tls_ssl_pending_i(slot)
  var parsing: int = httpd_li_proxy_get_resp_parsing_i(slot)
  var cl_active: int = httpd_native_proxy_get_cl_body_active_i(slot)
  if relay_finish_ready(body_left, defer, rbuf, wbio, ssl, parsing, cl_active) != 1:
    return 0
  if httpd_native_proxy_relay_complete_i(slot) != 1:
    return 0
  httpd_li_proxy_finish_ok_i(epfd, slot)
  return 1

def proxy_li_service_slot(epfd: var int, slot: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0
=
  if httpd_native_proxy_slot_needs_work_i(slot) != 1:
    return 0
  httpd_native_proxy_pump_budget_reset_i(slot)
  var tf: int = httpd_native_proxy_tls_defer_flush_i(epfd, slot)
  if httpd_li_proxy_active_i(slot) == 0:
    return tf
  var fo: int = httpd_native_proxy_flush_client_out_i(epfd, slot)
  if httpd_li_proxy_active_i(slot) == 0:
    return fo
  var dr: int = httpd_native_proxy_drain_client_i(epfd, slot)
  if httpd_li_proxy_active_i(slot) == 0:
    return dr
  var hf: int = httpd_native_proxy_hdr_flush_resume_i(epfd, slot)
  if hf < 0:
    return proxy_li_finish_err(epfd, slot)
  if httpd_li_proxy_active_i(slot) == 0:
    return 0
  if proxy_li_native_pending(slot) == 1:
    return 0
  if proxy_li_upstream_blocked(slot) == 1:
    return 0
  var parsing: int = httpd_li_proxy_get_resp_parsing_i(slot)
  if parsing == 0:
    if httpd_li_proxy_get_resp_body_mode_i(slot) == proxy_body_cl():
      return proxy_li_pump_cl(epfd, slot)
  var fin: int = proxy_li_try_finish(epfd, slot)
  if fin == 1:
    return 0
  return 0

def proxy_native_fair_relay_round(epfd: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  ensures true
  decreases 0
=
  if httpd_use_native_proxy_relay_i() != 1:
    return httpd_proxy_fair_relay_round_i(epfd)
  httpd_native_proxy_reconcile_i(epfd)
  var max_conn: int = httpd_max_conn_i()
  var start: int = httpd_native_proxy_fair_cursor_i()
  var pass_idx: int = 0
  while pass_idx < 2:
    var n: int = 0
    while n < max_conn:
      var slot: int = httpd_native_proxy_fair_slot_i(start, n, pass_idx)
      if slot >= 0:
        if httpd_native_proxy_slot_needs_work_i(slot) == 1:
          proxy_li_service_slot(epfd, slot)
      n = n + 1
    pass_idx = pass_idx + 1
  return 0

'''

SEAM_EXTERNS = '''
extern proc httpd_use_native_proxy_relay_i() -> int
  requires true
  ensures result == 0 or result == 1
  decreases 0

extern proc httpd_max_conn_i() -> int
  requires true
  ensures result > 0
  decreases 0

extern proc httpd_native_proxy_get_rbuf_pending_i(slot: var int) -> int
  requires 0 <= slot
  ensures 0 <= result
  decreases 0

extern proc httpd_native_proxy_get_tls_defer_i(slot: var int) -> int
  requires 0 <= slot
  ensures 0 <= result
  decreases 0

extern proc httpd_native_proxy_get_tls_wbio_pending_i(slot: var int) -> int
  requires 0 <= slot
  ensures 0 <= result
  decreases 0

extern proc httpd_native_proxy_get_tls_ssl_pending_i(slot: var int) -> int
  requires 0 <= slot
  ensures 0 <= result
  decreases 0

extern proc httpd_native_proxy_get_cl_body_active_i(slot: var int) -> int
  requires 0 <= slot
  ensures result == 0 or result == 1
  decreases 0

extern proc httpd_native_proxy_slot_needs_work_i(slot: var int) -> int
  requires 0 <= slot
  ensures result == 0 or result == 1
  decreases 0

extern proc httpd_native_proxy_relay_complete_i(slot: var int) -> int
  requires 0 <= slot
  ensures result == 0 or result == 1
  decreases 0

extern proc httpd_native_proxy_hdr_flush_resume_i(epfd: var int, slot: var int) -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0

extern proc httpd_native_proxy_drain_client_i(epfd: var int, slot: var int) -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0

extern proc httpd_native_proxy_tls_defer_flush_i(epfd: var int, slot: var int) -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0

extern proc httpd_native_proxy_flush_client_out_i(epfd: var int, slot: var int) -> int
  requires epfd >= 0
  requires 0 <= slot
  ensures true
  decreases 0

extern proc httpd_native_proxy_pump_budget_reset_i(slot: var int) -> unit
  requires 0 <= slot
  ensures true
  decreases 0

extern proc httpd_native_proxy_fair_cursor_i() -> int
  requires true
  ensures 0 <= result
  decreases 0

extern proc httpd_native_proxy_fair_slot_i(start: int, n: int, pass_idx: int) -> int
  requires 0 <= n
  ensures true
  decreases n

extern proc httpd_native_proxy_reconcile_i(epfd: var int) -> unit
  requires epfd >= 0
  ensures true
  decreases 0

'''


def patch_lib():
    p = ROOT / "packages/li-net-httpd/src/lib.li"
    t = p.read_text(encoding="utf-8")
    if "import proxy_relay_native" not in t:
        t = t.replace("import tls\n", "import tls\nimport proxy_relay_native\n")
    if "def proxy_relay_native_selftest" not in t:
        t = t.replace("def proxy_li_finish_err(", NATIVE_BLOCK + "\ndef proxy_li_finish_err(")

    # Native pump_cl
    old_pump = """def proxy_li_pump_cl(epfd: var int, slot: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  ensures true
  decreases 0
=
  var up: int = httpd_li_proxy_up_fd_i(slot)
  var conn: int = httpd_slot_conn_i(slot)
  var left: int = httpd_li_proxy_get_resp_body_left_i(slot)
  var chunk: ptr = net_buf_alloc(8192)
  while left > 0:
    var max_sp: int = left
    if max_sp > 8192:
      max_sp = 8192
    var sp: int = httpd_proxy_splice_cl_i(up, conn, max_sp)
    if sp > 0:
      left = left - sp
      httpd_li_proxy_set_resp_body_left_i(slot, left)"""

    new_pump = """def proxy_li_pump_cl(epfd: var int, slot: var int) raises Net, Alloc, IO -> int
  requires epfd >= 0
  ensures true
  decreases 0
=
  var up: int = httpd_li_proxy_up_fd_i(slot)
  var conn: int = httpd_slot_conn_i(slot)
  var left: int = httpd_li_proxy_get_resp_body_left_i(slot)
  var native: int = httpd_use_native_proxy_relay_i()
  var chunk: ptr = net_buf_alloc(8192)
  while left > 0:
    if native == 1:
      if proxy_li_upstream_blocked(slot) == 1:
        net_buf_free(chunk)
        return 0
    var max_sp: int = left
    if max_sp > 8192:
      max_sp = 8192
    if native == 1:
      max_sp = relay_cl_take(max_sp, left)
    var sp: int = httpd_proxy_splice_cl_i(up, conn, max_sp)
    if sp > 0:
      if native == 1:
        proxy_li_sync_body_left(slot, sp)
      if native != 1:
        left = left - sp
        httpd_li_proxy_set_resp_body_left_i(slot, left)"""

    if old_pump in t:
        t = t.replace(old_pump, new_pump)

    old_take = """      var take: int = r
      if take > left:
        take = left
      var fwd: int = httpd_li_proxy_forward_bytes_i(epfd, slot, chunk, take)"""
    new_take = """      var take: int = r
      if native == 1:
        take = relay_cl_take(r, left)
      if native != 1:
        if take > left:
          take = left
      var fwd: int = httpd_li_proxy_forward_bytes_i(epfd, slot, chunk, take)"""
    if old_take in t:
        t = t.replace(old_take, new_take)

    old_fin = """  net_buf_free(chunk)
  if httpd_li_proxy_relay_pending_i(slot) == 1:
    return 0
  httpd_li_proxy_finish_ok_i(epfd, slot)
  return 0

def proxy_li_finish_resp_headers"""
    new_fin = """  net_buf_free(chunk)
  if httpd_li_proxy_relay_pending_i(slot) == 1:
    return 0
  if native == 1:
    var fin: int = proxy_li_try_finish(epfd, slot)
    if fin == 1:
      return 0
    return 0
  httpd_li_proxy_finish_ok_i(epfd, slot)
  return 0

def proxy_li_finish_resp_headers"""
    if old_fin in t:
        t = t.replace(old_fin, new_fin)

    # dispatch: proxy tags before hangup short-circuit
    old_disp = """  if net_epoll_hangup(net_events_loaded_revents_i()) == 1:
    return proxy_dispatch_hangup_loaded(epfd)
  if proxy_epoll_tag_is_up(net_events_loaded_hi_i()) == 1:
    return proxy_dispatch_up_loaded(epfd, net_events_loaded_lo_i(), net_events_loaded_revents_i())
  if proxy_epoll_tag_is_client(net_events_loaded_hi_i()) == 1:
    return proxy_dispatch_client_loaded(epfd, net_events_loaded_lo_i(), net_events_loaded_revents_i())"""
    new_disp = """  if proxy_epoll_tag_is_up(net_events_loaded_hi_i()) == 1:
    return proxy_dispatch_up_loaded(epfd, net_events_loaded_lo_i(), net_events_loaded_revents_i())
  if proxy_epoll_tag_is_client(net_events_loaded_hi_i()) == 1:
    return proxy_dispatch_client_loaded(epfd, net_events_loaded_lo_i(), net_events_loaded_revents_i())
  if net_epoll_hangup(net_events_loaded_revents_i()) == 1:
    return proxy_dispatch_hangup_loaded(epfd)"""
    if old_disp in t:
        t = t.replace(old_disp, new_disp)

    t = t.replace("httpd_proxy_fair_relay_round_i(epfd)", "proxy_native_fair_relay_round(epfd)")

    p.write_text(t, encoding="utf-8", newline="\n")
    print("patched lib.li")


def patch_seam():
    p = ROOT / "std/runtime/seam.li"
    t = p.read_text(encoding="utf-8")
    if "httpd_use_native_proxy_relay_i" not in t:
        anchor = "extern proc httpd_proxy_fair_relay_round_i(epfd: var int) -> int"
        if anchor in t:
            t = t.replace(anchor, SEAM_EXTERNS.strip() + "\n\n" + anchor)
        else:
            t += "\n" + SEAM_EXTERNS
    p.write_text(t, encoding="utf-8", newline="\n")
    print("patched seam.li")


def patch_c():
    p = ROOT / "runtime/li_rt_net.c"
    t = p.read_text(encoding="utf-8")

    # Revert global skip in relay_cl_account (breaks C selftest); native accounts in Li pump
    t = t.replace(
        """static void httpd_proxy_relay_cl_account(httpd_slot_t* s, int32_t slot, size_t consumed) {
  size_t dec;
  if (httpd_use_native_proxy_relay_i()) {
    return;
  }
  if (s->proxy_resp_body_mode != PROXY_RESP_BODY_CL || consumed == 0 || !s->proxy_cl_body_active) {""",
        """static void httpd_proxy_relay_cl_account(httpd_slot_t* s, int32_t slot, size_t consumed) {
  size_t dec;
  if (s->proxy_resp_body_mode != PROXY_RESP_BODY_CL || consumed == 0 || !s->proxy_cl_body_active) {""",
    )

    if "httpd_native_proxy_tls_defer_flush_i" not in t:
        t = t.replace(
            "void httpd_native_proxy_pump_budget_reset_i(int32_t slot) { httpd_proxy_pump_budget_reset(slot); }",
            """int32_t httpd_native_proxy_tls_defer_flush_i(int32_t epfd, int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || !g_slots[slot].proxy_active) {
    return 0;
  }
  httpd_proxy_tls_cl_defer_flush((int)epfd, slot);
  return g_slots[slot].proxy_active ? 0 : -1;
}

int32_t httpd_native_proxy_flush_client_out_i(int32_t epfd, int32_t slot) {
  if (slot < 0 || slot >= HTTPD_MAX_CONN || !g_slots[slot].proxy_active) {
    return 0;
  }
  httpd_proxy_flush_client_out((int)epfd, slot);
  return g_slots[slot].proxy_active ? 0 : -1;
}

void httpd_native_proxy_pump_budget_reset_i(int32_t slot) { httpd_proxy_pump_budget_reset(slot); }""",
        )

    # Native mode: CL body relay driven by Li fair round; epoll C pump skips CL splice loop
    if "httpd_use_native_proxy_relay_i()) {\n    return;\n  }\n  httpd_slot_t* s = &g_slots[slot];\n  if (!(httpd_tls_slot_proto" not in t:
        t = t.replace(
            "static void httpd_proxy_pump_cl_relay(int epfd, int32_t slot) {\n  httpd_slot_t* s = &g_slots[slot];",
            """static void httpd_proxy_pump_cl_relay(int epfd, int32_t slot) {
  if (httpd_use_native_proxy_relay_i()) {
    return;
  }
  httpd_slot_t* s = &g_slots[slot];""",
        )

    if "httpd_li_proxy_forward_bytes_i" in t and "!httpd_use_native_proxy_relay_i()" not in t:
        t = t.replace(
            "  if (rc > 0 && !s->proxy_resp_parsing && s->proxy_resp_body_mode == PROXY_RESP_BODY_CL) {\n    httpd_proxy_relay_cl_account(s, slot, (size_t)rc);\n  }\n  return rc;\n}\n\nint32_t httpd_li_proxy_forward_ptr_off_i",
            "  if (!httpd_use_native_proxy_relay_i() && rc > 0 && !s->proxy_resp_parsing &&\n      s->proxy_resp_body_mode == PROXY_RESP_BODY_CL) {\n    httpd_proxy_relay_cl_account(s, slot, (size_t)rc);\n  }\n  return rc;\n}\n\nint32_t httpd_li_proxy_forward_ptr_off_i",
        )

    p.write_text(t, encoding="utf-8", newline="\n")
    print("patched li_rt_net.c")


def write_docs():
    doc = ROOT / "packages/li-net-httpd/docs/proxy-relay-native.md"
    doc.parent.mkdir(parents=True, exist_ok=True)
    doc.write_text(
        """# Li-native proxy relay (`use_native_proxy_relay`)

## Architecture (C shim vs Li)

| Concern | C (`runtime/li_rt_net.c`) | Li (`proxy_relay_native.li`, `lib.li`) |
|--------|---------------------------|----------------------------------------|
| epoll / tagged fds | `epoll_wait_tagged_*`, listen accept | `httpd_upstream_proxy_epoll_loop` |
| Request + response headers | `httpd_li_proxy_*_epoll_i` (unchanged) | — |
| CL body relay under load | `httpd_proxy_pump_cl_relay` **skipped** when native | `proxy_li_pump_cl` + `relay_cl_take` |
| Fairness / TLS starvation | reconcile + sweep shims | `proxy_native_fair_relay_round` → `proxy_li_service_slot` |
| Byte accounting | mirror getters only | `relay_account_body`, `proxy_li_sync_body_left` |
| Finish gate | `httpd_native_proxy_relay_complete_i` | `relay_finish_ready`, `proxy_li_try_finish` |
| Upstream hold | TLS/rbuf pending in C | `relay_upstream_blocked` |

## State machine

`READ_UPSTREAM` → `RELAY_CLIENT` → `DRAIN_TLS` → `FINISH`

Implemented in Li oracle; C epoll handles phases 1–2 headers; native fair round drives CL relay + finish.

## Feature flag

- Config: `[limits] use_native_proxy_relay = true`
- Env: `LI_HTTPD_USE_NATIVE_PROXY_RELAY=1`
- C API: `httpd_use_native_proxy_relay_i()`

Legacy C relay remains when flag is off (`httpd_proxy_fair_relay_round_i`).

## Tests

- `packages/li-net-httpd/src/proxy_relay_native.li` — standalone oracle
- `li-tests/httpd/proxy_relay_native_test.li` — imports `net.httpd`
- Docker: `test/gitlab-proxy/` parallel 18 gate
""",
        encoding="utf-8",
    )
    print("wrote docs")


if __name__ == "__main__":
    patch_lib()
    patch_seam()
    patch_c()
    write_docs()
