#!/usr/bin/env python3
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "packages/li-net-httpd/src/lib.li"
text = p.read_text(encoding="utf-8")
old = """  if httpd_tls_enabled_i() == 1 and http_port > 0 and http_port != port:
    listen_http = tcp_listen(http_port)
    if listen_http < 0:
      return 1
    net_set_nonblock(listen_http)
    if epoll_ctl_add_listen_i(epfd, listen_http) < 0:
      return 1"""
new = """  if httpd_tls_enabled_i() == 1 and http_port > 0 and http_port != port:
    var lh: int = tcp_listen(http_port)
    if lh < 0:
      return 1
    listen_http = lh
    net_set_nonblock(lh)
    if epoll_ctl_add_listen_i(epfd, lh) < 0:
      return 1"""
if old not in text:
    raise SystemExit("fix_dual_listen_verify: block missing")
p.write_text(text.replace(old, new), encoding="utf-8")
print("fix_dual_listen_verify: OK")
