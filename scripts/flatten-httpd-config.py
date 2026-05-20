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


def flatten(cfg: dict) -> list[str]:
    lines: list[str] = []
    server = cfg.get("server") or {}
    listen = server.get("listen")
    if listen:
        lines.append(f"listen_port={parse_listen(str(listen))}")
    root = server.get("document_root")
    if root:
        lines.append(f"document_root={root}")

    limits = cfg.get("limits") or {}
    if limits:
        lines.append("# limits validated in TOML")

    routes = cfg.get("routes") or {}
    proxy_all = 0
    upstream_ids: set[str] = set()
    for _key, action in routes.items():
        if isinstance(action, str) and action.startswith("proxy:"):
            proxy_all = 1
            upstream_ids.add(action.split(":", 1)[1])

    nested = cfg.get("upstreams") or {}
    if isinstance(nested, dict):
        for pool_id, val in nested.items():
            if isinstance(val, dict):
                for peer in val.get("peers") or []:
                    lines.append(f"upstream_peer={peer_port(str(peer))}")
                    upstream_ids.discard(str(pool_id))

    for key, val in cfg.items():
        if key.startswith("upstreams.") and isinstance(val, dict):
            for peer in val.get("peers") or []:
                lines.append(f"upstream_peer={peer_port(str(peer))}")

    if proxy_all or upstream_ids:
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
    cfg = tomllib.loads(args.config.read_text(encoding="utf-8"))
    lines = flatten(cfg)
    if not any(l.startswith("listen_port=") for l in lines):
        print("flatten-httpd-config: server.listen required", file=sys.stderr)
        return 1
    if not any(l.startswith("document_root=") for l in lines):
        print("flatten-httpd-config: server.document_root required", file=sys.stderr)
        return 1
    args.output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"flatten-httpd-config: wrote {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
