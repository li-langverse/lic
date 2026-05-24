#!/usr/bin/env python3
"""Goal-directed loop for simulation algorithm backlog (mirrors httpd-plan-loop.py)."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKLOG = ROOT / "docs/ecosystem/sim-algorithm-backlog.md"
GATES = ROOT / "scripts/sim-plan-gates.sh"
STATE_DIR = ROOT / "data/sim-plan-loop"
STATE_FILE = STATE_DIR / "state.json"

TODO_RE = re.compile(
    r"- id: (\S+)\n\s+content: \"([^\"]+)\"\n\s+status: (\w+)",
    re.MULTILINE,
)


def load_todos() -> list[dict]:
    text = BACKLOG.read_text(encoding="utf-8")
    return [
        {"id": m.group(1), "content": m.group(2), "status": m.group(3)}
        for m in TODO_RE.finditer(text)
    ]


def pick_todo(todos: list[dict]) -> dict | None:
    for t in todos:
        if t["status"] in ("pending", "in_progress"):
            return t
    return None


def run_agent(todo: dict, *, dry_run: bool) -> int:
    key = os.environ.get("CURSOR_API_KEY", "")
    agents_root = os.environ.get("LI_CURSOR_AGENTS_ROOT", "")
    if not key or not agents_root:
        print(
            "sim-plan-loop: set CURSOR_API_KEY and LI_CURSOR_AGENTS_ROOT",
            file=sys.stderr,
        )
        return 2

    goal = (
        f"Implement simulation backlog todo `{todo['id']}`: {todo['content']}. "
        "Use packages under packages/li-sim* and li-physics-*. "
        "Gate with ./scripts/bench-package.sh li-sim-scientific --write-summary "
        "and ./scripts/sim-plan-gates.sh — do NOT run full bench.py --tier 12. "
        "Update algo_registry implemented_smoke when done. "
        "See docs/ecosystem/sim-agent-handoff.md."
    )
    if dry_run:
        print(goal)
        return 0

    agent = os.environ.get("LI_SIM_PLAN_AGENT", "code_implementer")
    run_js = Path(agents_root) / "run-agent.js"
    if not run_js.is_file():
        print(f"sim-plan-loop: missing {run_js}", file=sys.stderr)
        return 2

    cmd = [
        "node",
        str(run_js),
        "--agent",
        agent,
        "--goal",
        goal,
        "--repo",
        str(ROOT),
    ]
    print("+", " ".join(cmd[:6]), "...", flush=True)
    return subprocess.call(cmd, cwd=agents_root)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--once", action="store_true")
    p.add_argument("--max", type=int, default=1)
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    if not BACKLOG.is_file():
        print(f"missing {BACKLOG}", file=sys.stderr)
        return 1

    todos = load_todos()
    todo = pick_todo(todos)
    if not todo:
        print("sim-plan-loop: no pending todos")
        return 0

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    print(f"sim-plan-loop: {todo['id']} — {todo['content']}")

    if args.dry_run:
        return run_agent(todo, dry_run=True)

    rc = run_agent(todo, dry_run=False)
    if rc != 0:
        return rc

    if GATES.is_file():
        print("==> sim-plan-gates.sh")
        rc = subprocess.call(["bash", str(GATES)], cwd=ROOT)
        if rc != 0:
            return rc

    STATE_FILE.write_text(
        f'{{"last":"{todo["id"]}","at":"{datetime.now(timezone.utc).isoformat()}"}}\n'
    )
    print("sim-plan-loop: iteration ok (todo still pending until agent marks done in backlog)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
