#!/usr/bin/env python3
"""Collect goal-directed plan-loop status for the live agents canvas."""
from __future__ import annotations

import json
import os
import re
import subprocess
import time
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
        "pgrep_patterns": [
            "httpd-plan-loop.py",
            "httpd-plan-loop-systemd",
            "gap-until-done",
            "httpd-plan-until-deadline",
        ],
        "systemd_unit": "li-httpd-plan-loop.service",
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
        "pgrep_patterns": [
            "compiler-studio-plan-loop.py",
            "compiler-studio-plan-until-deadline",
            "compiler-studio-plan-loop-systemd",
        ],
        "systemd_unit": "li-compiler-studio-plan-loop.service",
    },
    {
        "id": "sim",
        "name": "Sim / algo registry",
        "repo": LANGVERSE / "lic-worktrees/sim-algo",
        "branch": "cursor/sim-algo-plan-loop",
        "plan": "docs/ecosystem/sim-algorithm-backlog.md",
        "state": "data/sim-plan-loop/state.json",
        "log": "data/sim-plan-loop/runner.log",
        "pgrep_patterns": [
            "sim-plan-loop.py",
            "sim-plan-run-until-done",
            "sim-algo-plan-loop",
        ],
        "systemd_unit": "li-sim-algo-plan-loop.service",
    },
    {
        "id": "studio-ui-ux",
        "name": "Studio UI/UX",
        "repo": LANGVERSE / "lic-studio-ui",
        "branch": "cursor/studio-ui-ux-plan-loop",
        "plan": "docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md",
        "state": "data/studio-ui-ux-plan-loop/state.json",
        "log": "data/studio-ui-ux-plan-loop/runner.log",
        "pgrep_patterns": [
            "studio-ui-ux-plan-loop",
            "studio-ui-ux-run-until-done",
            "studio_ui_ux_builder",
        ],
        "systemd_unit": "li-studio-ui-ux-plan-loop.service",
        "todo_id_prefix": "studio-ux-",
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


def _line_matches_repo(line: str, repo: Path) -> bool:
    repo_s = str(repo)
    name = repo.name
    return repo_s in line or f"/{name}/" in line or line.endswith(f"/{name}")


def _line_is_loop_process(line: str) -> bool:
    if "pgrep" in line:
        return False
    markers = (
        "python3",
        "run-agent.js",
        "plan-loop",
        "until-done",
        "until-deadline",
        "systemd.sh",
        "run-until-done",
    )
    return any(m in line for m in markers)


def systemd_active(unit: str) -> tuple[bool, str]:
    proc = subprocess.run(
        ["systemctl", "--user", "is-active", unit],
        capture_output=True,
        text=True,
    )
    state = (proc.stdout or "").strip()
    if state in ("active", "activating"):
        return True, f"systemd:{unit} ({state})"
    return False, ""


def detect_loop_running(cfg: dict, log_path: Path) -> tuple[bool, str]:
    repo: Path = cfg["repo"]

    unit = cfg.get("systemd_unit")
    if unit:
        ok, hint = systemd_active(unit)
        if ok:
            return True, hint

    patterns: list[str] = list(cfg.get("pgrep_patterns") or [])
    if cfg.get("pgrep"):
        patterns.append(cfg["pgrep"])
    patterns.append(repo.name)

    seen: set[str] = set()
    for pattern in patterns:
        if not pattern or pattern in seen:
            continue
        seen.add(pattern)
        proc = subprocess.run(["pgrep", "-af", pattern], capture_output=True, text=True)
        for line in (proc.stdout or "").splitlines():
            if not _line_is_loop_process(line):
                continue
            if _line_matches_repo(line, repo) or pattern in line:
                return True, line.strip()[:120]

    agent_proc = subprocess.run(
        ["pgrep", "-af", "run-agent.js"],
        capture_output=True,
        text=True,
    )
    for line in (agent_proc.stdout or "").splitlines():
        if _line_matches_repo(line, repo):
            return True, line.strip()[:120]

    if log_path.is_file():
        age = time.time() - log_path.stat().st_mtime
        if age < 180:
            return True, f"log activity ({int(age)}s ago)"

    return False, ""


def resolve_runner_log(repo: Path, configured: str) -> Path:
    """Pick the freshest plan-loop log in the data dir (not a stale one-shot file)."""
    log_p = repo / configured
    log_dir = log_p.parent
    if not log_dir.is_dir():
        return log_p
    patterns = (
        "until-deadline-*.log",
        "iter-*.log",
        "runner.log",
        "gap-until-done.log",
        "gap-parity-*.log",
    )
    candidates: list[Path] = []
    for pat in patterns:
        candidates.extend(log_dir.glob(pat))
    if log_p.is_file():
        candidates.append(log_p)
    if not candidates:
        return log_p
    return max(candidates, key=lambda p: p.stat().st_mtime)


def tail_activity(log_path: Path, limit: int = 8) -> list[str]:
    if not log_path.is_file():
        return []
    lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()
    picked: list[str] = []
    for line in reversed(lines):
        if (
            line.startswith("=== iteration")
            or line.startswith("==> batch ")
            or "agent exit" in line
            or "All actionable todos" in line
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
        if line.startswith("=== iteration") or line.startswith("==> batch "):
            return line.strip()
    return ""


def detect_agent(repo: Path) -> dict:
    proc = subprocess.run(
        ["pgrep", "-af", "run-agent.js"],
        capture_output=True,
        text=True,
    )
    repo_s = str(repo.resolve())
    for line in (proc.stdout or "").splitlines():
        cwd_m = re.search(r"--cwd\s+(\S+)", line)
        if not cwd_m:
            continue
        cwd = str(Path(cwd_m.group(1)).resolve())
        if cwd != repo_s:
            continue
        agent_m = re.search(r"--agent\s+(\S+)", line)
        goal_m = re.search(r"goal-file\s+(\S+)", line)
        goal_path = goal_m.group(1) if goal_m else ""
        goal_name = Path(goal_path).name if goal_path else ""
        return {
            "agent_live": True,
            "agent": agent_m.group(1) if agent_m else "",
            "goal_file": goal_name,
        }
    return {"agent_live": False, "agent": "", "goal_file": ""}


def log_age_sec(log_path: Path) -> int | None:
    if not log_path.is_file():
        return None
    return int(max(0, time.time() - log_path.stat().st_mtime))


def last_state_event(state: dict | None) -> dict:
    if not state:
        return {}
    hist = state.get("history") or []
    return hist[-1] if hist else {}


def plan_complete_polling(runner: dict) -> bool:
    texts = [runner.get("current_iteration") or "", *(runner.get("activity") or [])]
    return any("All actionable todos complete" in t for t in texts)


def status_note(runner: dict) -> str:
    if runner.get("agent_live"):
        return f"agent coding ({runner.get('agent', '')})"
    if not runner.get("running"):
        return "supervisor off"
    if plan_complete_polling(runner):
        return "plan complete — supervisor polling until deadline (no agent)"
    act = runner.get("activity") or []
    age = runner.get("log_age_sec")
    if age is not None and age > 300:
        return f"supervisor idle (log {age}s stale — check log_path)"
    if act and "agent exit" in act[-1]:
        return "loop stopped after agent exit — retry pending"
    if act and act[-1].startswith("gates:"):
        return act[-1]
    return "supervisor up, between agent runs"


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
    log_p = resolve_runner_log(repo, cfg["log"])
    running, process = detect_loop_running(cfg, log_p)
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
    todo_prefix = cfg.get("todo_id_prefix")
    if plan_p.is_file():
        todos = load_plan_todos(plan_p)
        if todo_filter:
            todos = [t for t in todos if t["id"].startswith(todo_filter)]
        elif todo_prefix:
            todos = [t for t in todos if t["id"].startswith(todo_prefix)]
        entry["todos"] = todos
        entry["plan_completed"] = sum(1 for t in todos if t["status"] == "completed")
        entry["plan_total"] = len(todos)
        entry["plan_pending"] = [t["id"] for t in todos if t["status"] == "pending"]
    state_data: dict | None = None
    if state_p.is_file():
        state_data = json.loads(state_p.read_text(encoding="utf-8"))
        entry["state"] = state_data
        entry["state_iterations"] = state_data.get("iterations", 0)
    entry.update(detect_agent(repo))
    entry["log_age_sec"] = log_age_sec(log_p)
    last_ev = last_state_event(state_data)
    entry["last_state_at"] = last_ev.get("at", "")
    entry["last_state_todo"] = last_ev.get("todo_id", "")
    entry["last_state_gates"] = last_ev.get("gates_ok", "")
    iter_line = current_iteration_line(log_p)
    entry["current_iteration"] = iter_line
    entry["activity"] = tail_activity(log_p)
    entry["status_note"] = status_note(entry)
    if running and iter_line:
        m = re.search(r"=== iteration \d+: (\S+) ===", iter_line)
        if m:
            entry["active_todo_id"] = m.group(1)
        elif "All actionable todos complete" in iter_line or any(
            "All actionable todos complete" in a for a in entry.get("activity") or []
        ):
            entry["active_todo_id"] = "(plan complete — polling)"
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

    agents_live = sum(1 for r in runners if r.get("agent_live"))
    snap = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "tz": os.environ.get("HTTPD_PLAN_TZ", "Europe/Berlin"),
        "agents_live": agents_live,
        "runners": runners,
        "history": history[:12],
    }
    SNAP_OUT.write_text(json.dumps(snap, indent=2), encoding="utf-8")
    print(f"snapshot: {SNAP_OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
