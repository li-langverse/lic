#!/usr/bin/env python3
"""Goal-directed loop for PH-DB-11 Li Data Studio workpackages.

Usage:
  ./scripts/ph-studio-plan-loop.py --once
  ./scripts/ph-studio-plan-loop.py --list

State: data/ph-studio-plan-loop/state.json
Plan: docs/superpowers/plans/ph-db-11-li-data-studio.md
"""
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "docs/superpowers/plans/ph-db-11-li-data-studio.md"
STATE_FILE = ROOT / "data/ph-studio-plan-loop/state.json"


def load_plan_todos() -> list[dict]:
    text = PLAN.read_text(encoding="utf-8")
    m = re.search(r"^todos:\s*\n(.*)^---\s*$", text, re.MULTILINE | re.DOTALL)
    block = m.group(1) if m else ""
    todos: list[dict] = []
    for match in re.finditer(
        r"- id: (\S+)\n\s+content: \"?([^\"\n]+)\"?\n\s+status: (\w+)",
        block,
    ):
        todos.append(
            {"id": match.group(1), "content": match.group(2).strip(), "status": match.group(3)}
        )
    return todos


def load_state() -> dict:
    if STATE_FILE.is_file():
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    return {"completed_ids": [], "pending_ids": [], "history": [], "iterations": 0}


def save_state(state: dict) -> None:
    state["updated_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")


def pick_next(todos: list[dict], state: dict) -> dict | None:
    completed = set(state.get("completed_ids", []))
    open_todos = [
        t
        for t in todos
        if t["id"].startswith("wp-s")
        and t["status"] in ("in_progress", "pending")
        and t["id"] not in completed
    ]
    if not open_todos:
        return None

    def order_key(t: dict) -> tuple[int, str]:
        return (0 if t["status"] == "in_progress" else 1, t["id"])

    open_todos.sort(key=order_key)
    return open_todos[0]


def main() -> int:
    parser = argparse.ArgumentParser(description="PH-DB-11 Li Data Studio plan loop")
    parser.add_argument("--once", action="store_true", help="Print next todo and exit")
    parser.add_argument("--list", action="store_true", help="List all todos with state")
    args = parser.parse_args()

    if not PLAN.is_file():
        print(f"missing plan: {PLAN}")
        return 1

    todos = load_plan_todos()
    state = load_state()
    completed = set(state.get("completed_ids", []))

    if args.list:
        for t in todos:
            mark = "done" if t["id"] in completed else t["status"]
            print(f"{t['id']}: [{mark}] {t['content']}")
        return 0

    nxt = pick_next(todos, state)
    if nxt is None:
        print("PH-DB-11: all workpackages complete or none pending")
        return 0

    print(f"next: {nxt['id']}")
    print(f"  {nxt['content']}")
    print(f"  plan: {PLAN.relative_to(ROOT)}")
    print(f"  impl: lis/data-studio-ui/ (branch feat/ph-db-11-data-studio-ui)")
    if args.once:
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
