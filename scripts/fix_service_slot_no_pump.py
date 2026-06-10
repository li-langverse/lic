#!/usr/bin/env python3
from pathlib import Path

p = Path("packages/li-net-httpd/src/lib.li")
t = p.read_text(encoding="utf-8")
old = """  var parsing: int = httpd_li_proxy_get_resp_parsing_i(slot)
  if parsing == 0:
    if httpd_li_proxy_get_resp_body_mode_i(slot) == proxy_body_cl():
      return proxy_li_pump_cl(epfd, slot)
  var fin: int = proxy_li_try_finish(epfd, slot)"""
new = """  var fin: int = proxy_li_try_finish(epfd, slot)"""
if old in t:
    t = t.replace(old, new)
    p.write_text(t, encoding="utf-8", newline="\n")
    print("removed duplicate pump_cl from service_slot")
else:
    print("block not found")
