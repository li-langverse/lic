#!/usr/bin/env python3
"""Sync packages/li-net-httpd → sibling li-httpd standalone repo."""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

KEEP = {
    ".git",
    ".cursor",
    "site",
    "AGENTS.md",
    "LICENSE",
    "scripts/sync-agent-kit.sh",
    "scripts/expected-agent-kit-version",
}


def rsync(src: Path, dest: Path) -> None:
    if shutil.which("rsync"):
        subprocess.run(
            ["rsync", "-a", "--delete", *[f"--exclude={x}" for x in KEEP], f"{src}/", f"{dest}/"],
            check=True,
        )
        return
    for item in dest.iterdir():
        if item.name in KEEP:
            continue
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()
    for item in src.iterdir():
        if item.name in KEEP:
            continue
        target = dest / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy2(item, target)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dest", type=Path, default=None, help="li-httpd repo root")
    args = ap.parse_args()
    lic = Path(__file__).resolve().parents[1]
    dest = args.dest or (lic.parent / "li-httpd")
    src = lic / "packages" / "li-net-httpd"
    if not src.is_dir():
        print(f"missing {src}", file=sys.stderr)
        return 1
    dest.mkdir(parents=True, exist_ok=True)
    rsync(src, dest)

    commit = subprocess.run(
        ["git", "rev-parse", "HEAD"],
        cwd=lic,
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    short = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"],
        cwd=lic,
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    version = (lic / "VERSION").read_text(encoding="utf-8").strip()
    (dest / "li-toolchain.toml").write_text(
        f"# Pin lic for reproducible CI (synced from lic @ {short}).\n"
        "[toolchain]\n"
        f'lic_version = "{version}"\n'
        f'lic_commit = "{commit}"\n'
        'lit_version = "0.1.0"\n',
        encoding="utf-8",
    )

    li_toml = dest / "li.toml"
    text = li_toml.read_text(encoding="utf-8")
    text = text.replace('name = "li-net-httpd"', 'name = "li-httpd"')
    text = text.replace('github_repo = "li-net-httpd"', 'github_repo = "li-httpd"')
    text = text.replace("PKG-li-net-httpd", "PKG-li-httpd")
    text = re.sub(r"github\.com/li-langverse/li-net-httpd", "github.com/li-langverse/li-httpd", text)
    li_toml.write_text(text, encoding="utf-8")

    build_sh = dest / "scripts" / "build-li-httpd.sh"
    build_sh.parent.mkdir(parents=True, exist_ok=True)
    build_sh.write_text(
        """#!/usr/bin/env bash
# Build li-httpd via lic (compiler + C runtime live in the lic monorepo).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC_ROOT="${LIC_ROOT:-$ROOT/../lic-pure-https}"
if [[ ! -f "$LIC_ROOT/scripts/build-li-httpd.sh" ]] && [[ -f "$ROOT/../lic/scripts/build-li-httpd.sh" ]]; then
  LIC_ROOT="$ROOT/../lic"
fi
if [[ ! -f "$LIC_ROOT/scripts/build-li-httpd.sh" ]]; then
  echo "build-li-httpd: clone lic and set LIC_ROOT (needs scripts/build-li-httpd.sh)" >&2
  exit 1
fi
LIC_ROOT="$(cd "$LIC_ROOT" && pwd)"
export LI_REPO_ROOT="$LIC_ROOT"
mkdir -p "$ROOT/build"
( cd "$LIC_ROOT" && ./scripts/build-li-httpd.sh )
if [[ -f "$LIC_ROOT/build/li-httpd" ]]; then
  cp -f "$LIC_ROOT/build/li-httpd" "$ROOT/build/li-httpd"
  echo "build-li-httpd: copied -> $ROOT/build/li-httpd"
fi
""",
        encoding="utf-8",
        newline="\n",
    )
    build_sh.chmod(build_sh.stat().st_mode | 0o755)

    readme = dest / "README.md"
    readme.write_text(
        f"""# li-httpd

Li-native HTTP/HTTPS server (epoll, TLS terminate, reverse proxy). **Official repo** — package source is developed in [lic](https://github.com/li-langverse/lic) (`packages/li-net-httpd`) and synced here.

## Build

Requires a sibling **lic** checkout (compiler + C runtime). Pinned in `li-toolchain.toml` (currently `{short}`).

```bash
export LIC_ROOT=../lic-pure-https   # or ../lic on main
./scripts/build-li-httpd.sh
./build/li-httpd path/to/runtime.conf
```

Env: `LI_HTTPD_TLS_LEGACY_OPENSSL=1`, `LI_HTTPD_WORKERS=0`, `LI_HTTPD_M2_HTTP2=0` for tier5 parity.

## Config

TOML → runtime conf via lic's `scripts/flatten-httpd-config.py`, or hand-write `listen_port`, `listen_port_http` (dual HTTP+HTTPS), `tls_enabled=1`, etc.

Examples in `examples/`. See `docs/proxy-nginx-li-migration.md`.

## Import

```li
import net.httpd
```

Composable API in `src/lib.li`; `src/main.li` is the CLI entry.

## CI

Checks out pinned **lic** and runs `lic check` / smoke build (see `.github/workflows/ci.yml`).
""",
        encoding="utf-8",
    )

    print(f"sync-li-httpd-standalone: ok -> {dest} (lic {short})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
