#!/usr/bin/env python3
"""Print desugared canonical routes from li-httpd.toml (M1 explain-config)."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from httpd_config import ConfigError, explain, load_httpd_config


def main() -> int:
    p = argparse.ArgumentParser(description="explain li-httpd.toml routes")
    p.add_argument(
        "config",
        type=Path,
        nargs="?",
        default=Path("packages/li-httpd/examples/minimal.toml"),
    )
    args = p.parse_args()
    if not args.config.is_file():
        print(f"explain-httpd-config: missing {args.config}", file=sys.stderr)
        return 1
    try:
        routes = load_httpd_config(args.config)
    except ConfigError as e:
        print(f"explain-httpd-config: {e}", file=sys.stderr)
        return 1
    print(explain(routes))
    return 0


if __name__ == "__main__":
    sys.exit(main())
