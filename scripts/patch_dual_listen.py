#!/usr/bin/env python3
"""Add dual HTTP+HTTPS listen (listen_port_http) for li-httpd."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch(path: Path, old: str, new: str, *, count: int = 1) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"patch_dual_listen: missing snippet in {path}")
    path.write_text(text.replace(old, new, count), encoding="utf-8")


def main() -> None:
    net = ROOT / "runtime/li_rt_net.c"
    patch(
        net,
        "static int32_t g_config_listen_port = 0;",
        "static int32_t g_config_listen_port = 0;\nstatic int32_t g_config_listen_port_http = 0;",
    )
    patch(net, "  g_config_listen_port = 0;", "  g_config_listen_port = 0;\n  g_config_listen_port_http = 0;")
    patch(
        net,
        '    if (strcmp(key, "listen_port") == 0) {\n'
        "      g_config_listen_port = (int32_t)atoi(val);\n"
        '    } else if (strcmp(key, "workers") == 0) {',
        '    if (strcmp(key, "listen_port") == 0) {\n'
        "      g_config_listen_port = (int32_t)atoi(val);\n"
        '    } else if (strcmp(key, "listen_port_http") == 0) {\n'
        "      g_config_listen_port_http = (int32_t)atoi(val);\n"
        '    } else if (strcmp(key, "workers") == 0) {',
    )
    patch(
        net,
        "int32_t httpd_config_listen_port_i(void) { return g_config_listen_port; }\n",
        "int32_t httpd_config_listen_port_i(void) { return g_config_listen_port; }\n\n"
        "int32_t httpd_config_listen_port_http_i(void) { return g_config_listen_port_http; }\n",
    )

    h = ROOT / "runtime/li_rt.h"
    patch(
        h,
        "int32_t httpd_config_listen_port_i(void);\n",
        "int32_t httpd_config_listen_port_i(void);\n"
        "int32_t httpd_config_listen_port_http_i(void);\n",
    )

    seam = ROOT / "std/runtime/seam.li"
    patch(
        seam,
        "extern proc httpd_config_listen_port_i() -> int\n"
        "  requires true\n"
        "  ensures true\n"
        "  decreases 0\n\n"
        "extern proc httpd_config_doc_root_i() -> ptr\n",
        "extern proc httpd_config_listen_port_i() -> int\n"
        "  requires true\n"
        "  ensures true\n"
        "  decreases 0\n\n"
        "extern proc httpd_config_listen_port_http_i() -> int\n"
        "  requires true\n"
        "  ensures true\n"
        "  decreases 0\n\n"
        "extern proc httpd_config_doc_root_i() -> ptr\n",
    )

    flatten = ROOT / "scripts/flatten-httpd-config.py"
    patch(
        flatten,
        "    listen = server.get(\"listen\")\n"
        "    if listen:\n"
        "        lines.append(f\"listen_port={parse_listen(str(listen))}\")\n",
        "    listen = server.get(\"listen\")\n"
        "    if listen:\n"
        "        lines.append(f\"listen_port={parse_listen(str(listen))}\")\n"
        "    listen_http = server.get(\"listen_http\")\n"
        "    if listen_http:\n"
        "        lines.append(f\"listen_port_http={parse_listen(str(listen_http))}\")\n",
    )

    lib = ROOT / "packages/li-net-httpd/src/lib.li"
    text = lib.read_text(encoding="utf-8")

    old_batch_sig = "def proxy_accept_batch(epfd: var int, listen_fd: var int) raises Net, Alloc, IO -> int"
    new_batch_sig = (
        "def proxy_accept_batch(epfd: var int, listen_fd: var int, use_tls: var int) "
        "raises Net, Alloc, IO -> int"
    )
    if old_batch_sig not in text:
        raise SystemExit("proxy_accept_batch signature not found")
    text = text.replace(old_batch_sig, new_batch_sig)

    text = text.replace(
        "    var tls_hs_done: int = 1\n"
        "    if httpd_tls_enabled_i() == 1:\n",
        "    var tls_hs_done: int = 1\n"
        "    if use_tls == 1 and httpd_tls_enabled_i() == 1:\n",
        1,
    )

    old_dispatch_sig = (
        "def proxy_dispatch_one(epfd: var int, listen_fd: var int, events: var ptr, idx: int) "
        "raises Net, Alloc, IO -> int"
    )
    new_dispatch_sig = (
        "def proxy_dispatch_one(epfd: var int, listen_tls: var int, listen_http: var int, "
        "events: var ptr, idx: int) raises Net, Alloc, IO -> int"
    )
    if old_dispatch_sig not in text:
        raise SystemExit("proxy_dispatch_one signature not found")
    text = text.replace(old_dispatch_sig, new_dispatch_sig)

    text = text.replace(
        "  net_events_tagged_load_i(events, idx)\n"
        "  if net_events_loaded_lo_i() == listen_fd:\n"
        "    proxy_accept_batch(epfd, listen_fd)\n"
        "    return 0\n",
        "  net_events_tagged_load_i(events, idx)\n"
        "  var lo: int = net_events_loaded_lo_i()\n"
        "  if lo == listen_tls:\n"
        "    proxy_accept_batch(epfd, listen_tls, 1)\n"
        "    return 0\n"
        "  if listen_http >= 0 and lo == listen_http:\n"
        "    proxy_accept_batch(epfd, listen_http, 0)\n"
        "    return 0\n",
        1,
    )

    old_loop_listen = (
        "  var listen_fd: int = tcp_listen(port)\n"
        "  if listen_fd < 0:\n"
        "    return 1\n"
        "  net_set_nonblock(listen_fd)\n"
        "  if epoll_ctl_add_listen_i(epfd, listen_fd) < 0:\n"
        "    return 1\n"
    )
    new_loop_listen = (
        "  var listen_tls: int = tcp_listen(port)\n"
        "  if listen_tls < 0:\n"
        "    return 1\n"
        "  net_set_nonblock(listen_tls)\n"
        "  if epoll_ctl_add_listen_i(epfd, listen_tls) < 0:\n"
        "    return 1\n"
        "  var listen_http: int = -1\n"
        "  var http_port: int = httpd_config_listen_port_http_i()\n"
        "  if httpd_tls_enabled_i() == 1 and http_port > 0 and http_port != port:\n"
        "    listen_http = tcp_listen(http_port)\n"
        "    if listen_http < 0:\n"
        "      return 1\n"
        "    net_set_nonblock(listen_http)\n"
        "    if epoll_ctl_add_listen_i(epfd, listen_http) < 0:\n"
        "      return 1\n"
    )
    if old_loop_listen not in text:
        raise SystemExit("epoll loop listen block not found")
    text = text.replace(old_loop_listen, new_loop_listen, 1)

    text = text.replace(
        "        proxy_dispatch_one(epfd, listen_fd, evbuf, i)",
        "        proxy_dispatch_one(epfd, listen_tls, listen_http, evbuf, i)",
    )
    text = text.replace(
        "            proxy_dispatch_one(epfd, listen_fd, evbuf, j)",
        "            proxy_dispatch_one(epfd, listen_tls, listen_http, evbuf, j)",
    )

    lib.write_text(text, encoding="utf-8")
    print("patch_dual_listen: OK")


if __name__ == "__main__":
    main()
