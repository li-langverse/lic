#!/usr/bin/env python3
"""Validate a subset of li-httpd.toml (M1 — static + loopback proxy upstreams).

Exit 0 when config is safe; exit 1 with stderr message on reject.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from urllib.parse import urlparse

from httpd_config import ConfigError, load_httpd_config, load_httpd_sites
from httpd_rng import validate_rng_config

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore

FORBIDDEN_SUBSTRINGS = ("..", "include ", "load_module", "proxy_pass http://")
LOOPBACK_HOSTS = frozenset({"127.0.0.1", "::1", "localhost"})
UPSTREAM_BALANCE_ALLOW = frozenset({"round_robin", "least_conn", "ip_hash", "cookie"})


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


def validate_peer_url(url: str, allow_hosts: frozenset[str]) -> str | None:
    u = urlparse(url)
    if u.scheme not in ("http", "https"):
        return f"peer must be http(s) URL: {url!r}"
    if u.hostname not in LOOPBACK_HOSTS and u.hostname not in allow_hosts:
        return f"peer must be loopback (M1) or --allow-peer-host: {url!r}"
    if not u.port:
        return f"peer must include explicit port: {url!r}"
    return None


def validate(cfg: dict, allow_hosts: frozenset[str]) -> list[str]:
    errs: list[str] = []
    raw = str(cfg)
    for bad in FORBIDDEN_SUBSTRINGS:
        if bad in raw:
            errs.append(f"forbidden pattern: {bad!r}")

    server = cfg.get("server") or {}
    if not server.get("listen") and not cfg.get("site"):
        errs.append("server.listen is required (or [[site]].listen)")
    if not server.get("document_root"):
        errs.append("server.document_root is required")

    limits = cfg.get("limits") or {}
    if not limits.get("max_body"):
        errs.append("limits.max_body is required")
    if not limits.get("max_header"):
        errs.append("limits.max_header is required")

    routes = cfg.get("routes")
    sites = cfg.get("site")
    if routes is None and sites is None:
        errs.append("routes table or [[site]] is required (may be empty in tests)")

    def pool_balance(pool_id: str, block: dict) -> str | None:
        bal = block.get("balance")
        if bal is None:
            return None
        name = str(bal).strip()
        if name not in UPSTREAM_BALANCE_ALLOW:
            return (
                f"upstreams.{pool_id}.balance must be one of "
                f"{sorted(UPSTREAM_BALANCE_ALLOW)} (got {name!r})"
            )
        return None

    pools = collect_upstreams(cfg)
    nested = cfg.get("upstreams")
    if isinstance(nested, dict):
        for pool_id, val in nested.items():
            if isinstance(val, dict):
                err = pool_balance(str(pool_id), val)
                if err:
                    errs.append(err)
    for key, val in cfg.items():
        if key.startswith("upstreams.") and isinstance(val, dict):
            pool_id = key.split(".", 1)[1]
            err = pool_balance(pool_id, val)
            if err:
                errs.append(err)

    for pool_id, peers in pools.items():
        if not peers:
            errs.append(f"upstreams.{pool_id}: peers must be non-empty")
        for peer in peers:
            err = validate_peer_url(peer, allow_hosts)
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

    if isinstance(sites, list):
        for i, site in enumerate(sites):
            if not isinstance(site, dict):
                errs.append(f"[[site]] entry {i} must be a table")
                continue
            if not str(site.get("host", "")).strip():
                errs.append(f"[[site]] entry {i}: host required")
            site_routes = site.get("routes") or {}
            if isinstance(site_routes, dict):
                for key, action in site_routes.items():
                    if isinstance(action, str) and action.startswith("proxy:"):
                        pool = action.split(":", 1)[1]
                        if pool not in pools:
                            errs.append(
                                f"site {i} route {key!r} references unknown upstream {pool!r}"
                            )

    rng_errs, _ = validate_rng_config(cfg)
    errs.extend(rng_errs)
    return errs


def validate_routes_desugar(path: Path) -> list[str]:
    errs: list[str] = []
    try:
        cfg = load(path)
        if cfg.get("site") is not None:
            load_httpd_sites(path)
        else:
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
    p.add_argument(
        "--allow-peer-host",
        action="append",
        default=[],
        metavar="HOST",
        help="allow upstream peer hostname (staging); repeatable",
    )
    args = p.parse_args()
    allow_hosts = frozenset(str(h).strip() for h in args.allow_peer_host if str(h).strip())
    if not args.config.is_file():
        print(f"validate-httpd-config: missing {args.config}", file=sys.stderr)
        return 1
    try:
        cfg = load(args.config)
    except Exception as e:
        print(f"validate-httpd-config: parse error: {e}", file=sys.stderr)
        return 1
    errs = validate(cfg, allow_hosts)
    errs.extend(validate_routes_desugar(args.config))
    if errs:
        for e in errs:
            print(f"validate-httpd-config: {e}", file=sys.stderr)
        return 1
    print(f"validate-httpd-config: ok ({args.config})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
