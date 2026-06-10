#!/usr/bin/env python3
"""Autonomous PH-DB cross-repo plan loop (Wave 3 wp-* todos).

Uses li-cursor-agents run-agent with per-todo workflow_repo (lis, lidb, benchmarks, agents).
Do not install retired systemd plan-loop units — async swarm only.

Usage:
  export CURSOR_API_KEY=cursor_...
  export LI_CURSOR_AGENTS_ROOT=/path/to/li-cursor-agents
  ./scripts/ph-db-plan-loop.py --once
  ./scripts/ph-db-plan-loop.py --max 12

State: data/ph-db-plan-loop/state.json
Plan:  docs/superpowers/plans/2026-06-03-ph-db-plan-loop.md
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LANGVERSE = Path(os.environ.get("LI_LANGVERSE_ROOT", ROOT.parent))
PLAN = ROOT / "docs/superpowers/plans/2026-06-03-ph-db-plan-loop.md"
STATE_DIR = ROOT / "data/ph-db-plan-loop"
STATE_FILE = STATE_DIR / "state.json"
GATES = ROOT / "scripts/ph-db-plan-gates.sh"
LOOP_BRANCH = os.environ.get("PH_DB_PLAN_PR_BRANCH", "cursor/ph-db-plan-loop")

TODO_ROUTING: dict[str, dict[str, str]] = {
    "wp-h-containers": {
        "agent": "code_implementer",
        "workflow_repo": "lis",
        "cwd": "lis",
        "branch": "cursor/wp-h-ph-db-containers",
    },
    "wp-g-ci-cross-repo": {
        "agent": "ci_maintainer",
        "workflow_repo": "li-cursor-agents",
        "cwd": "li-cursor-agents",
        "branch": "cursor/wp-g-ph-db-ci-cross-repo",
    },
    "wp-k-postgres-nightly": {
        "agent": "ci_maintainer",
        "workflow_repo": "benchmarks",
        "cwd": "benchmarks",
        "branch": "cursor/wp-k-ph-db-bench-postgres-ci",
    },
    "wp-pr-merge-wave": {
        "agent": "pr_merger",
        "workflow_repo": "lic",
        "cwd": "lic",
        "branch": LOOP_BRANCH,
    },
    "wp-h0-default-main": {
        "agent": "ci_maintainer",
        "workflow_repo": "lidb",
        "cwd": "lidb",
        "branch": "main",
    },
    "wp-n3-realtime": {
        "agent": "code_implementer",
        "workflow_repo": "lis",
        "cwd": "lis",
        "branch": "main",
    },
    "wp-n5-security-bench": {
        "agent": "bench_improver",
        "workflow_repo": "benchmarks",
        "cwd": "benchmarks",
        "branch": "main",
    },
    "wp-d-registry-v2": {
        "agent": "issue_planner",
        "workflow_repo": "lidb",
        "cwd": "lidb",
        "branch": "cursor/wp-d-ph-db-4-registry",
    },
    "wp-prod-lidb-default": {
        "agent": "human",
        "workflow_repo": "li-cursor-agents",
        "cwd": "li-cursor-agents",
        "branch": "main",
    },
}


def load_plan_todos() -> list[dict]:
    text = PLAN.read_text(encoding="utf-8")
    m = re.search(r"^todos:\s*\n(.*)^---\s*$", text, re.MULTILINE | re.DOTALL)
    block = m.group(1) if m else ""
    todos: list[dict] = []
    for match in re.finditer(
        r"- id: (\S+)\n(?:\s+content: \"?([^\"\n]+)\"?\n)?(?:\s+status: (\w+)\n)?",
        block,
    ):
        tid, content, status = match.group(1), (match.group(2) or "").strip(), match.group(3) or "pending"
        if not content:
            cm = re.search(
                rf"- id: {re.escape(tid)}\n\s+content: \"?([^\"\n]+)\"?\n\s+status: (\w+)",
                block,
            )
            if cm:
                content, status = cm.group(1).strip(), cm.group(2)
        todos.append({"id": tid, "content": content, "status": status})
    return todos


def pick_next(todos: list[dict], state: dict) -> dict | None:
    completed = set(state.get("completed_ids", []))
    for t in todos:
        if t["status"] == "completed" or t["id"] in completed:
            continue
        if t["status"] == "pending":
            route = TODO_ROUTING.get(t["id"], {})
            if route.get("agent") == "human":
                continue
            return t
    return None


def run_gates() -> tuple[bool, str]:
    if not GATES.is_file():
        return False, f"missing gates: {GATES}"
    proc = subprocess.run(
        ["bash", str(GATES)],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    out = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode == 0, out[-4000:]


def agents_root() -> Path | None:
    for candidate in [
        os.environ.get("LI_CURSOR_AGENTS_ROOT"),
        LANGVERSE / "li-cursor-agents",
    ]:
        if not candidate:
            continue
        p = Path(candidate)
        if (p / "package.json").is_file():
            return p
    return None


def write_goal(todo: dict) -> Path:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    route = TODO_ROUTING.get(todo["id"], {"workflow_repo": "lic", "cwd": "lic", "branch": LOOP_BRANCH})
    goal = STATE_DIR / f"goal-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.md"
    goal.write_text(
        f"# PH-DB plan iteration — `{todo['id']}`\n\n"
        f"**Plan:** `{PLAN.relative_to(ROOT)}`\n"
        f"**Primary repo:** `{route.get('workflow_repo', 'lic')}` "
        f"on branch `{route.get('branch', LOOP_BRANCH)}`\n\n"
        f"## Current todo\n"
        f"- **id:** {todo['id']}\n"
        f"- **content:** {todo['content']}\n\n"
        f"## Rules\n"
        f"1. Work in `{route.get('cwd', 'lic')}`.\n"
        f"2. Mark plan-loop + swarm canvas todo completed when gates pass.\n"
        f"3. Run `bash scripts/ph-db-plan-gates.sh` from lic before finishing.\n"
        f"4. PR-only; no production store flip without human sign-off.\n",
        encoding="utf-8",
    )
    return goal


def run_agent(todo: dict, goal_file: Path) -> int:
    ar = agents_root()
    if not ar:
        print("ph-db-plan-loop: LI_CURSOR_AGENTS_ROOT not found", file=sys.stderr)
        return 2
    run_agent_js = ar / "dist/cli/run-agent.js"
    if not run_agent_js.is_file():
        print(f"ph-db-plan-loop: missing {run_agent_js}", file=sys.stderr)
        return 2
    route = TODO_ROUTING.get(todo["id"], {"agent": "code_implementer", "workflow_repo": "lic", "cwd": "lic"})
    cwd = LANGVERSE / route.get("cwd", "lic")
    if not cwd.is_dir():
        cwd = ROOT
    env = {
        **os.environ,
        "LI_REPO_WORKFLOW_REPO": route.get("workflow_repo", "lic"),
        "LI_REPO_WORKFLOW_BRANCH": route.get("branch", LOOP_BRANCH),
    }
    cmd = [
        "node",
        str(run_agent_js),
        "--agent",
        route.get("agent", "code_implementer"),
        "--cwd",
        str(cwd),
        "--workflow-repo",
        route.get("workflow_repo", "lic"),
        "--goal-file",
        str(goal_file),
    ]
    bench = LANGVERSE / "benchmarks"
    if bench.is_dir():
        cmd.extend(["--benchmarks", str(bench)])
    log = STATE_DIR / f"iter-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.log"
    with log.open("w", encoding="utf-8") as logf:
        logf.write(f"# cmd: {' '.join(cmd)}\n\n")
        proc = subprocess.run(cmd, cwd=cwd, env=env, stdout=logf, stderr=subprocess.STDOUT)
    return proc.returncode


def load_state() -> dict:
    if STATE_FILE.is_file():
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    return {"completed_ids": [], "iterations": 0, "history": [], "note": "ph-db plan-loop supervisor"}


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--once", action="store_true")
    p.add_argument("--max", type=int, default=1)
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()
    max_iter = 1 if args.once else args.max

    if not PLAN.is_file():
        print(f"missing plan: {PLAN}", file=sys.stderr)
        return 1

    state = load_state()
    todos = load_plan_todos()

    for _ in range(max_iter):
        todo = pick_next(todos, state)
        if not todo:
            print("ph-db-plan-loop: no pending actionable todos", flush=True)
            return 0
        print(f"=== iteration {state.get('iterations', 0) + 1}: {todo['id']} ===", flush=True)
        if args.dry_run:
            print(json.dumps(todo, indent=2))
            return 0
        gates_ok, gates_out = run_gates()
        goal = write_goal(todo)
        exit_code = run_agent(todo, goal)
        state["iterations"] = state.get("iterations", 0) + 1
        state.setdefault("history", []).append(
            {
                "at": datetime.now(timezone.utc).isoformat(),
                "todo_id": todo["id"],
                "agent_exit": exit_code,
                "gates_ok": gates_ok,
            }
        )
        save_state(state)
        if exit_code != 0:
            print(gates_out[-2000:], file=sys.stderr)
            return exit_code
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
