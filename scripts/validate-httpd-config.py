#!/usr/bin/env python3
"""Validate a subset of li-httpd.toml (M1 wave 1 — no listen until wired to binary).

Exit 0 when config is safe to document; exit 1 with stderr message on reject.
Future: fold into `lic validate-config` when HTTP config module lands.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore

FORBIDDEN_SUBSTRINGS = ("..", "include ", "load_module", "proxy_pass http://")


def load(path: Path) -> dict:
    return tomllib.loads(path.read_text(encoding="utf-8"))


def validate(cfg: dict) -> list[str]:
    errs: list[str] = []
    raw = str(cfg)
    for bad in FORBIDDEN_SUBSTRINGS:
        if bad in raw:
            errs.append(f"forbidden pattern: {bad!r}")

    server = cfg.get("server") or {}
    if not server.get("listen"):
        errs.append("server.listen is required")
    if not server.get("document_root"):
        errs.append("server.document_root is required")

    limits = cfg.get("limits") or {}
    if not limits.get("max_body"):
        errs.append("limits.max_body is required")
    if not limits.get("max_header"):
        errs.append("limits.max_header is required")

    routes = cfg.get("routes")
    if routes is None:
        errs.append("routes table is required (may be empty in tests)")

    if routes:
        for key, action in routes.items():
            if not isinstance(key, str) or not isinstance(action, str):
                errs.append(f"routes entry must be strings: {key!r} -> {action!r}")
                continue
            if "proxy:" in action and "allowlist" not in raw:
                # wave 1: no proxy routes without future upstream block
                errs.append(
                    f"proxy route {key!r} rejected in wave 1 — add [[upstreams]] when proxy ships"
                )
    return errs


def main() -> int:
    p = argparse.ArgumentParser(description="validate li-httpd.toml (M1 subset)")
    p.add_argument("config", type=Path, nargs="?", default=Path("packages/li-httpd/examples/minimal.toml"))
    args = p.parse_args()
    if not args.config.is_file():
        print(f"validate-httpd-config: missing {args.config}", file=sys.stderr)
        return 1
    try:
        cfg = load(args.config)
    except Exception as e:
        print(f"validate-httpd-config: parse error: {e}", file=sys.stderr)
        return 1
    errs = validate(cfg)
    if errs:
        for e in errs:
            print(f"validate-httpd-config: {e}", file=sys.stderr)
        return 1
    print(f"validate-httpd-config: ok ({args.config})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
