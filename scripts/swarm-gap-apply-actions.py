#!/usr/bin/env python3
"""Apply open swarm gaps to markdown backlogs + swarm-gap-actions.json (programmatic handoff)."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    yaml = None  # type: ignore

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from plan_todo_normalize import normalize_plan_todo_id
LANGVERSE = Path(os.environ.get("LI_LANGVERSE_ROOT", ROOT.parent))
BENCHMARKS = Path(os.environ.get("BENCHMARKS_ROOT", LANGVERSE / "benchmarks"))
REGISTRY = ROOT / "data/swarm-gap-registry/registry.yaml"
ACTIONS_OUT = BENCHMARKS / "data/latest/swarm-gap-actions.json"

RUNNER_BACKLOGS: dict[str, str] = {
    "httpd": "docs/superpowers/plans/2026-05-16-li-httpd-plan.md",
    "sim": "docs/ecosystem/sim-algorithm-backlog.md",
    "sim-md-research": "docs/ecosystem/sim-md-research-backlog.md",
    "sim-chem-research": "docs/ecosystem/sim-chem-research-backlog.md",
    "compiler-studio": "docs/superpowers/plans/2026-05-22-compiler-studio-plan-loop.md",
    "studio-ui-ux": "docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md",
}

TODO_BLOCK_RE = re.compile(
    r"- id: (\S+)\n\s+content: \"([^\"]*)\"\n\s+status: (\w+)",
    re.MULTILINE,
)

KNOWN_LOOPS = frozenset(
    {
        "sim-algo",
        "httpd",
        "compiler-studio",
        "studio-ui-ux",
        "sim-md-research",
        "sim-chem-research",
        "swarm-observer",
    }
)


def _load_registry(path: Path) -> list[dict]:
    if yaml is None:
        sys.exit("swarm-gap-apply-actions: PyYAML required")
    if not path.is_file():
        return []
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    gaps = data.get("gaps") or []
    return [g for g in gaps if isinstance(g, dict) and g.get("status", "open") == "open"]


def _ensure_todo_in_backlog(
    backlog_path: Path,
    todo_id: str,
    content: str,
    *,
    dry_run: bool,
) -> str:
    if not backlog_path.is_file():
        return f"skip missing backlog {backlog_path}"
    text = backlog_path.read_text(encoding="utf-8")
    if re.search(rf"- id: {re.escape(todo_id)}\n", text):
        pattern = (
            rf"(- id: {re.escape(todo_id)}\n\s+content: \")([^\"]*)(\"\n\s+status: )(\w+)"
        )

        def repl(m: re.Match[str]) -> str:
            new_content = m.group(2)
            if content and content not in new_content:
                new_content = f"{content} — gap orchestrator"
            return f"{m.group(1)}{new_content}{m.group(3)}pending"

        new_text, n = re.subn(pattern, repl, text, count=1)
        if n:
            if not dry_run:
                backlog_path.write_text(new_text, encoding="utf-8")
            return f"patched {todo_id} → pending in {backlog_path.name}"
        return f"exists {todo_id} (no status change)"

    block = (
        f"  - id: {todo_id}\n"
        f'    content: "{content.replace(chr(34), chr(39))}"\n'
        f"    status: pending\n"
        f"    gap_orchestrator: true\n"
    )
    fm = re.search(r"^(todos:\s*\n)(.*?)(^---\s*$)", text, re.MULTILINE | re.DOTALL)
    if fm:
        new_text = text[: fm.end(2)] + block + text[fm.end(2) :]
    elif "todos:" in text:
        idx = text.index("todos:")
        insert_at = text.find("\n\n", idx)
        if insert_at < 0:
            insert_at = len(text)
        new_text = text[:insert_at] + "\n" + block + text[insert_at:]
    else:
        new_text = text.rstrip() + "\n\ntodos:\n" + block
    if not dry_run:
        backlog_path.write_text(new_text, encoding="utf-8")
    return f"appended {todo_id} to {backlog_path.name}"


def _plan_debt_todo_id(gap: dict) -> str:
    runner = gap.get("runner_id") or gap.get("suggested_loop") or "plan"
    raw = gap.get("plan_todo_id") or _slug(gap.get("title", "debt"))
    return normalize_plan_todo_id(str(raw), runner)


def _slug(s: str) -> str:
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s.lower()).strip("-")
    return s[:40] or "item"


def apply_gaps(gaps: list[dict], *, dry_run: bool) -> dict[str, Any]:
    actions: list[dict] = []
    patches: list[str] = []
    suggested_loops: list[str] = []

    for gap in gaps:
        kind = gap.get("gap_kind") or "unknown"
        gid = gap.get("id") or ""
        title = gap.get("title") or gid
        action: dict[str, Any] = {
            "gap_id": gid,
            "gap_kind": kind,
            "title": title,
            "at": datetime.now(timezone.utc).isoformat(),
        }

        if kind == "missing_package":
            backlog_rel = gap.get("target_backlog") or "docs/ecosystem/ecosystem-package-backlog.md"
            todo_id = gap.get("target_todo_id") or f"pkg-{_slug(title)}"
            bp = ROOT / backlog_rel
            msg = _ensure_todo_in_backlog(bp, todo_id, title, dry_run=dry_run)
            action["patch"] = msg
            patches.append(msg)

        elif kind == "plan_debt":
            runner = gap.get("runner_id") or gap.get("suggested_loop")
            if runner and runner in RUNNER_BACKLOGS:
                bp = ROOT / RUNNER_BACKLOGS[runner]
                todo_id = _plan_debt_todo_id(gap)
                msg = _ensure_todo_in_backlog(bp, todo_id, title, dry_run=dry_run)
                action["patch"] = msg
                patches.append(msg)
            else:
                action["patch"] = "deferred (no runner backlog mapping)"

        elif kind == "competitor_feature":
            loop = gap.get("suggested_loop")
            if loop and loop in RUNNER_BACKLOGS:
                bp = ROOT / RUNNER_BACKLOGS[loop]
                todo_id = f"gap-competitor-{_slug(gid)}"
                msg = _ensure_todo_in_backlog(bp, todo_id, title, dry_run=dry_run)
                action["patch"] = msg
                patches.append(msg)

        elif kind == "ui_ux":
            bp = ROOT / RUNNER_BACKLOGS.get("studio-ui-ux", "")
            if bp.is_file():
                todo_id = f"gap-ux-{_slug(gid)}"
                msg = _ensure_todo_in_backlog(bp, todo_id, title, dry_run=dry_run)
                action["patch"] = msg
                patches.append(msg)

        loop_id = gap.get("suggested_loop")
        if loop_id and loop_id not in KNOWN_LOOPS and loop_id not in suggested_loops:
            suggested_loops.append(loop_id)
            action["suggest_systemd_loop"] = loop_id

        actions.append(action)

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "dry_run": dry_run,
        "open_gaps": len(gaps),
        "by_kind": {},
        "actions": actions,
        "suggested_new_loops": suggested_loops,
        "patches": patches,
    }
    for g in gaps:
        k = g.get("gap_kind") or "unknown"
        payload["by_kind"][k] = payload["by_kind"].get(k, 0) + 1
    return payload


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--registry", type=Path, default=REGISTRY)
    args = p.parse_args()

    gaps = _load_registry(args.registry)
    payload = apply_gaps(gaps, dry_run=args.dry_run)

    print(json.dumps(payload, indent=2))
    if args.dry_run:
        print(f"(dry-run) would write {ACTIONS_OUT}")
        return 0

    ACTIONS_OUT.parent.mkdir(parents=True, exist_ok=True)
    ACTIONS_OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {ACTIONS_OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
