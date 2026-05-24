"""Tier B: validate-httpd-config rejects non-loopback upstream peers (DNS resolver class)."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Any

REPO = Path(__file__).resolve().parents[3]
SCRIPTS = REPO / "scripts"
HARNESS = REPO / "benchmarks" / "harness"
for p in (str(SCRIPTS), str(HARNESS)):
    if p not in sys.path:
        sys.path.insert(0, p)

from http_exploit_toml import resolve_server_config  # noqa: E402


def run(cfg: dict[str, Any], *, lang: str, stub: bool, port: int) -> dict[str, Any]:
    if lang != "li":
        return {"no_crash": True, "validate_config_fails": False}
    if stub:
        return {
            "no_crash": True,
            "validate_config_fails": True,
            "reject_or_close_attack": True,
        }
    server_cfg = resolve_server_config(cfg)
    script = REPO / "scripts" / "validate-httpd-config.py"
    proc = subprocess.run(
        [sys.executable, str(script), str(server_cfg)],
        capture_output=True,
        text=True,
    )
    failed = proc.returncode != 0
    return {
        "no_crash": True,
        "validate_config_fails": failed,
        "reject_or_close_attack": failed,
        "stderr": (proc.stderr or "").strip()[:200],
    }
