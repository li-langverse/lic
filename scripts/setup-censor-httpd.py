#!/usr/bin/env python3
"""li-httpd setup-censor — migrations/OpenAPI hints → leak_censor.generated.toml."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from httpd_leak_censor import write_generated_toml
from schema_catalog import merge_catalog, parse_migrations_dir


def main() -> int:
    p = argparse.ArgumentParser(description="Generate leak_censor.generated.toml from DB migrations")
    p.add_argument(
        "--migrations",
        type=Path,
        required=True,
        help="Directory of applied *.sql migrations",
    )
    p.add_argument(
        "-o",
        "--output-dir",
        type=Path,
        default=Path("."),
        help="Directory for leak_censor.generated.toml (default: cwd)",
    )
    p.add_argument(
        "--openapi",
        type=Path,
        default=None,
        help="Optional OpenAPI YAML (v1: ignored except path recorded in comment)",
    )
    args = p.parse_args()

    if not args.migrations.is_dir():
        print(f"setup-censor: missing migrations dir {args.migrations}", file=sys.stderr)
        return 1

    catalog = merge_catalog(parse_migrations_dir(args.migrations))
    if args.openapi and args.openapi.is_file():
        catalog.sources.append(args.openapi.name)

    out = args.output_dir / "leak_censor.generated.toml"
    args.output_dir.mkdir(parents=True, exist_ok=True)
    write_generated_toml(out, catalog.json_paths, catalog.header_deny, catalog.sources)
    print(f"setup-censor: wrote {out} ({len(catalog.json_paths)} json paths)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
