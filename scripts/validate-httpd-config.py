#!/usr/bin/env python3
"""Validate a subset of li-httpd.toml (M1 — static + loopback proxy upstreams).

Exit 0 when config is safe; exit 1 with stderr message on reject.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from urllib.parse import urlparse

from httpd_config import ConfigError, load_httpd_config

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore

FORBIDDEN_SUBSTRINGS = ("..", "include ", "load_module", "proxy_pass http://")


def load(path: Path) -> dict:
    return tomllib.loads(path.read_text(encoding="utf-8"))


def collect_upstreams(cfg: dict) -> dict[str, list[str]]:
    pools: dict[str, list[str]] = {}
    nested = cfg.get("upstreams")
    if isinstance(nested, dict):
        for pool_id, val in nested.items():
            if isinstance(val, dict):
                peers = val.get("peers") or []
                if isinstance(peers, list):
                    pools[str(pool_id)] = [str(p) for p in peers]
    for key, val in cfg.items():
        if not key.startswith("upstreams."):
            continue
        pool_id = key.split(".", 1)[1]
        if isinstance(val, dict):
            peers = val.get("peers") or []
            if isinstance(peers, list):
                pools[pool_id] = [str(p) for p in peers]
    return pools


def validate_peer_url(url: str) -> str | None:
    u = urlparse(url)
    if u.scheme not in ("http", "https"):
        return f"peer must be http(s) URL: {url!r}"
    if u.hostname not in ("127.0.0.1", "::1", "localhost"):
        return f"peer must be loopback (M1): {url!r}"
    if not u.port:
        return f"peer must include explicit port: {url!r}"
    return None


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

    pools = collect_upstreams(cfg)
    for pool_id, peers in pools.items():
        if not peers:
            errs.append(f"upstreams.{pool_id}: peers must be non-empty")
        for peer in peers:
            err = validate_peer_url(peer)
            if err:
                errs.append(f"upstreams.{pool_id}: {err}")

    if routes:
        for key, action in routes.items():
            if not isinstance(key, str) or not isinstance(action, str):
                errs.append(f"routes entry must be strings: {key!r} -> {action!r}")
                continue
            if action.startswith("proxy:"):
                pool = action.split(":", 1)[1]
                if pool not in pools:
                    errs.append(f"proxy route {key!r} references unknown upstream {pool!r}")

    auth = cfg.get("auth") or {}
    if isinstance(auth, dict):
        req = auth.get("require_bearer")
        keys = auth.get("keys")
        if req and str(req).lower() not in ("0", "false", "no"):
            if not isinstance(keys, list) or not keys:
                errs.append('auth.require_bearer=true requires auth.keys = ["..."]')
            else:
                for k in keys:
                    if not str(k).strip():
                        errs.append("auth.keys must not contain empty strings")

    return errs


def validate_routes_desugar(path: Path) -> list[str]:
    errs: list[str] = []
    try:
        load_httpd_config(path)
    except ConfigError as e:
        errs.append(str(e))
    return errs


def main() -> int:
    p = argparse.ArgumentParser(description="validate li-httpd.toml (M1 subset)")
    p.add_argument(
        "config",
        type=Path,
        nargs="?",
        default=Path("li-tests/config_desugar/good/agent_gateway.toml"),
    )
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
    errs.extend(validate_routes_desugar(args.config))
    if errs:
        for e in errs:
            print(f"validate-httpd-config: {e}", file=sys.stderr)
        return 1
    print(f"validate-httpd-config: ok ({args.config})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
