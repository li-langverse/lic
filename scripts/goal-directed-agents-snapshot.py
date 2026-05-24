#!/usr/bin/env python3
"""Collect goal-directed plan-loop status for the live agents canvas."""
from __future__ import annotations

import json
import os
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LANGVERSE = Path(os.environ.get("LI_LANGVERSE_ROOT", ROOT.parent))
SNAP_OUT = ROOT / "data/goal-directed-agents/snapshot.json"

RUNNERS: list[dict] = [
    {
        "id": "httpd",
        "name": "li-httpd gap parity",
        "repo": LANGVERSE / "lic",
        "branch": "cursor/httpd-plan-continue",
        "plan": "docs/superpowers/plans/2026-05-16-li-httpd-plan.md",
        "state": "data/httpd-plan-loop/state.json",
        "log": "data/httpd-plan-loop/gap-until-done.log",
        "pgrep": "httpd-plan-loop.py",
        "todo_filter": "gap-",
    },
    {
        "id": "compiler-studio",
        "name": "Compiler + Studio",
        "repo": LANGVERSE / "lic-worktrees/compiler-studio",
        "branch": "cursor/compiler-studio-plan-loop",
        "plan": "docs/superpowers/plans/2026-05-22-compiler-studio-plan-loop.md",
        "state": "data/compiler-studio-plan-loop/state.json",
        "log": "data/compiler-studio-plan-loop/runner.log",
        "pgrep": "compiler-studio-plan-loop.py",
    },
    {
        "id": "sim",
        "name": "Sim / algo registry",
        "repo": LANGVERSE / "lic-worktrees/sim-algo",
        "branch": "cursor/sim-algo-plan-loop",
        "plan": "docs/ecosystem/sim-algorithm-backlog.md",
        "state": "data/sim-plan-loop/state.json",
        "log": "data/sim-plan-loop/runner.log",
        "pgrep": "sim-plan-loop.py",
    },
]


def load_plan_todos(plan_path: Path) -> list[dict]:
    text = plan_path.read_text(encoding="utf-8")
    m = re.search(r"^todos:\s*\n(.*)^---\s*$", text, re.MULTILINE | re.DOTALL)
    block = m.group(1) if m else text
    todos: list[dict] = []
    for match in re.finditer(
        r"- id: (\S+)\n\s+content: \"?([^\"\n]+)\"?\n\s+status: (\w+)",
        block,
    ):
        todos.append(
            {
                "id": match.group(1),
                "content": match.group(2).strip(),
                "status": match.group(3),
            }
        )
    return todos


def process_running(pgrep: str) -> tuple[bool, str]:
    proc = subprocess.run(["pgrep", "-af", pgrep], capture_output=True, text=True)
    for line in (proc.stdout or "").splitlines():
        if "python3" in line and "pgrep" not in line:
            return True, line.strip()[:120]
    return False, ""


def tail_activity(log_path: Path, limit: int = 8) -> list[str]:
    if not log_path.is_file():
        return []
    lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()
    picked: list[str] = []
    for line in reversed(lines):
        if (
            line.startswith("=== iteration")
            or "agent exit" in line
            or line.startswith("gates:")
            or "[sdk]" in line
        ):
            picked.append(line[-140:] if len(line) > 140 else line)
            if len(picked) >= limit:
                break
    return list(reversed(picked))


def current_iteration_line(log_path: Path) -> str:
    if not log_path.is_file():
        return ""
    for line in reversed(log_path.read_text(encoding="utf-8", errors="replace").splitlines()):
        if line.startswith("=== iteration"):
            return line
    return ""


def git_head(repo: Path) -> str:
    if not (repo / ".git").exists():
        return ""
    proc = subprocess.run(
        ["git", "-C", str(repo), "rev-parse", "--short", "HEAD"],
        capture_output=True,
        text=True,
    )
    return (proc.stdout or "").strip()


def build_runner(cfg: dict) -> dict:
    repo: Path = cfg["repo"]
    plan_p = repo / cfg["plan"]
    state_p = repo / cfg["state"]
    log_p = repo / cfg["log"]
    running, process = process_running(cfg["pgrep"])
    entry: dict = {
        "id": cfg["id"],
        "name": cfg["name"],
        "branch": cfg.get("branch", ""),
        "head": git_head(repo),
        "running": running,
        "process": process,
        "log_path": str(log_p),
    }
    todo_filter = cfg.get("todo_filter")
    if plan_p.is_file():
        todos = load_plan_todos(plan_p)
        if todo_filter:
            todos = [t for t in todos if t["id"].startswith(todo_filter)]
        entry["todos"] = todos
        entry["plan_completed"] = sum(1 for t in todos if t["status"] == "completed")
        entry["plan_total"] = len(todos)
        entry["plan_pending"] = [t["id"] for t in todos if t["status"] == "pending"]
    if state_p.is_file():
        entry["state"] = json.loads(state_p.read_text(encoding="utf-8"))
    iter_line = current_iteration_line(log_p)
    entry["current_iteration"] = iter_line
    entry["activity"] = tail_activity(log_p)
    if running and iter_line:
        m = re.search(r"=== iteration \d+: (\S+) ===", iter_line)
        if m:
            entry["active_todo_id"] = m.group(1)
    elif entry.get("plan_pending"):
        entry["active_todo_id"] = entry["plan_pending"][0]
    return entry


def main() -> int:
    SNAP_OUT.parent.mkdir(parents=True, exist_ok=True)
    runners = [build_runner(cfg) for cfg in RUNNERS]
    history: list[dict] = []
    for r in runners:
        for row in (r.get("state") or {}).get("history") or []:
            history.append(
                {
                    "runner": r["id"],
                    "at": row.get("at", ""),
                    "todo_id": row.get("todo_id", ""),
                    "agent_exit": row.get("agent_exit", ""),
                    "gates_ok": row.get("gates_ok", ""),
                }
            )
    history.sort(key=lambda x: x.get("at", ""), reverse=True)

    snap = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "tz": os.environ.get("HTTPD_PLAN_TZ", "Europe/Berlin"),
        "runners": runners,
        "history": history[:12],
    }
    SNAP_OUT.write_text(json.dumps(snap, indent=2), encoding="utf-8")
    print(f"snapshot: {SNAP_OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
