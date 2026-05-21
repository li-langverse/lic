#!/usr/bin/env python3
"""Flatten validated li-httpd.toml to httpd.runtime.conf for C loader.

Usage:
  python3 scripts/flatten-httpd-config.py packages/li-httpd/examples/proxy_loopback.toml \\
    -o /tmp/httpd.runtime.conf
  ./build/li-httpd /tmp/httpd.runtime.conf
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore

from httpd_config import ConfigError, load_httpd_config


def parse_listen(raw: str) -> int:
    raw = raw.strip()
    if raw.startswith(":"):
        return int(raw[1:])
    if ":" in raw:
        return int(raw.rsplit(":", 1)[1])
    return int(raw)


def peer_port(url: str) -> int:
    m = re.match(r"https?://[^:]+:(\d+)", url.strip())
    if not m:
        raise ValueError(f"peer URL must be loopback with port: {url!r}")
    return int(m.group(1))


def flatten(cfg_path: Path) -> list[str]:
    data = tomllib.loads(cfg_path.read_text(encoding="utf-8"))
    lines: list[str] = []
    server = data.get("server") or {}
    listen = server.get("listen")
    if listen:
        lines.append(f"listen_port={parse_listen(str(listen))}")
    root = server.get("document_root")
    if root:
        rp = Path(str(root))
        if not rp.is_absolute():
            rp = (cfg_path.parent / rp).resolve()
        lines.append(f"document_root={rp}")

    health = data.get("health") or {}
    if isinstance(health, dict):
        if health.get("max_fails") is not None:
            lines.append(f"health_max_fails={int(health['max_fails'])}")
        ft = health.get("fail_timeout") or health.get("fail_timeout_sec")
        if ft is not None:
            s = str(ft).strip().rstrip("s")
            if s.isdigit():
                lines.append(f"health_fail_timeout_sec={int(s)}")

    limits = data.get("limits") or {}
    if limits.get("rate_limit_rps") is not None:
        lines.append(f"rate_limit_rps={int(limits['rate_limit_rps'])}")
    if limits.get("rate_limit_burst") is not None:
        lines.append(f"rate_limit_burst={int(limits['rate_limit_burst'])}")

    routes = load_httpd_config(cfg_path)
    proxy_any = False
    upstream_ids: set[str] = set()
    for r in routes:
        kind = r.path_kind if r.path_kind in ("exact", "prefix", "prefix_strip") else "prefix"
        action = "proxy" if r.action.startswith("proxy:") else "static"
        if action == "proxy":
            proxy_any = True
            upstream_ids.add(r.action.split(":", 1)[1])
        if r.rate_limit_rps > 0:
            burst = r.rate_limit_burst if r.rate_limit_burst > 0 else r.rate_limit_rps
            lines.append(
                f"route={r.method}|{r.path}|{kind}|{action}|{r.rate_limit_rps}|{burst}"
            )
        else:
            lines.append(f"route={r.method}|{r.path}|{kind}|{action}")

    nested = data.get("upstreams") or {}
    if isinstance(nested, dict):
        for pool_id, val in nested.items():
            if isinstance(val, dict):
                for peer in val.get("peers") or []:
                    lines.append(f"upstream_peer={peer_port(str(peer))}")
                    upstream_ids.discard(str(pool_id))

    for key, val in data.items():
        if key.startswith("upstreams.") and isinstance(val, dict):
            for peer in val.get("peers") or []:
                lines.append(f"upstream_peer={peer_port(str(peer))}")

    if proxy_any and not routes:
        lines.append("proxy_all=1")
    elif proxy_any and not any(l.startswith("upstream_peer=") for l in lines):
        lines.append("proxy_all=1")

    return lines


def main() -> int:
    p = argparse.ArgumentParser(description="flatten li-httpd.toml to runtime.conf")
    p.add_argument("config", type=Path)
    p.add_argument("-o", "--output", type=Path, required=True)
    args = p.parse_args()
    if not args.config.is_file():
        print(f"flatten-httpd-config: missing {args.config}", file=sys.stderr)
        return 1
    try:
        lines = flatten(args.config)
    except (ConfigError, ValueError) as e:
        print(f"flatten-httpd-config: {e}", file=sys.stderr)
        return 1
    if not any(l.startswith("listen_port=") for l in lines):
        print("flatten-httpd-config: server.listen required", file=sys.stderr)
        return 1
    if not any(l.startswith("document_root=") for l in lines):
        print("flatten-httpd-config: server.document_root required", file=sys.stderr)
        return 1
    args.output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"flatten-httpd-config: wrote {args.output} ({len(lines)} lines)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
