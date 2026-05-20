#!/usr/bin/env python3
"""Emit tier5_http exploit stub TOMLs from nginx_mitigations.toml (no nginx submodule required)."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore[no-redef]


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1] / ".." / "vendor" / "lis-tier5" / "benchmarks" / "tier5_http",
        help="tier5_http directory (or lis mirror)",
    )
    args = p.parse_args()
    root = args.root.resolve()
    mit_path = root / "nginx_mitigations.toml"
    if not mit_path.is_file():
        # benchmarks workspace layout
        root = Path(__file__).resolve().parents[2] / "vendor" / "lis-tier5" / "benchmarks" / "tier5_http"
        mit_path = root / "nginx_mitigations.toml"
    if not mit_path.is_file():
        print(f"audit-nginx-mitigations: missing {mit_path}", file=sys.stderr)
        return 1
    data = tomllib.loads(mit_path.read_text(encoding="utf-8"))
    exploits_dir = root / "exploits"
    exploits_dir.mkdir(parents=True, exist_ok=True)
    created = 0
    for row in data.get("mitigation") or []:
        exploit_rel = row.get("exploit") or ""
        if not exploit_rel:
            continue
        name = Path(exploit_rel).stem
        path = exploits_dir / f"{name}.toml"
        if path.is_file():
            continue
        stub = f'''id = "{name}"
tier = "A"
enabled = false
refs = []

[nginx_src]
mitigation_id = "{row.get("id", name)}"

[attack]
driver = "{name}"

[expect]
no_crash = true
reject_or_close_attack = true
legitimate_client_ok = true
'''
        path.write_text(stub, encoding="utf-8")
        created += 1
        print(f"created stub {path}")
    print(f"audit-nginx-mitigations: {created} new stub(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
