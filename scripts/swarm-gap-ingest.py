#!/usr/bin/env python3
"""Merge briefing audits + goal-directed snapshot into swarm-gap-registry/registry.yaml."""

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
LANGVERSE = Path(os.environ.get("LI_LANGVERSE_ROOT", ROOT.parent))
BENCHMARKS = Path(os.environ.get("BENCHMARKS_ROOT", LANGVERSE / "benchmarks"))
REGISTRY_DIR = ROOT / "data/swarm-gap-registry"
REGISTRY = REGISTRY_DIR / "registry.yaml"
SNAPSHOT = ROOT / "data/goal-directed-agents/snapshot.json"
LATEST = BENCHMARKS / "data/latest"


def _load_yaml(path: Path) -> dict:
    if yaml is None:
        sys.exit("swarm-gap-ingest: PyYAML required (pip install pyyaml)")
    if not path.is_file():
        return {"version": 1, "gaps": []}
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    if not isinstance(data, dict):
        return {"version": 1, "gaps": []}
    data.setdefault("gaps", [])
    return data


def _save_yaml(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data["updated_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    path.write_text(yaml.dump(data, sort_keys=False, default_flow_style=False), encoding="utf-8")


def _gap_index(gaps: list[dict]) -> dict[str, dict]:
    return {g["id"]: g for g in gaps if isinstance(g, dict) and g.get("id")}


def _slug(s: str, max_len: int = 48) -> str:
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s.lower()).strip("-")
    return s[:max_len] or "item"


def _normalize_plan_todo_id(todo_id: str, runner_id: str) -> str:
    """Strip apply-actions mirror prefixes (gap-{runner}- repeated)."""
    tid = str(todo_id).strip()
    prefix = f"gap-{runner_id}-"
    while tid.startswith(prefix):
        tid = tid[len(prefix) :]
    return tid or str(todo_id)


def ingest_missing_std(explorer: dict, gaps_by_id: dict[str, dict]) -> int:
    added = 0
    for row in explorer.get("missing_std_modules") or []:
        if not isinstance(row, dict):
            continue
        mod = row.get("module") or row.get("name") or ""
        if not mod or row.get("status") not in (None, "missing", "partial"):
            continue
        gid = f"gap-missing-std-{_slug(mod)}"
        if gid in gaps_by_id:
            continue
        gaps_by_id[gid] = {
            "id": gid,
            "gap_kind": "missing_package",
            "title": f"Missing std module {mod}",
            "status": "open",
            "priority": 6,
            "discovered_by": "gap_explorer",
            "evidence": [row.get("why") or f"explorer: {mod}"],
            "ph_id": row.get("ph_id"),
            "target_backlog": "docs/ecosystem/ecosystem-package-backlog.md",
            "target_todo_id": f"pkg-{_slug(mod.replace('.', '-'))}",
            "suggested_loop": None,
            "handoff_to": ["issue_planner", "package_architect"],
        }
        added += 1
    return added


def ingest_plan_debt(audit: dict, gaps_by_id: dict[str, dict]) -> int:
    added = 0
    for item in (audit.get("master_plan_open") or [])[:12]:
        if not isinstance(item, dict):
            continue
        text = (item.get("item") or "")[:120]
        src = item.get("source") or "plan"
        gid = f"gap-plan-debt-{_slug(f'{src}-{text}')}"
        if gid in gaps_by_id:
            continue
        gaps_by_id[gid] = {
            "id": gid,
            "gap_kind": "plan_debt",
            "title": text,
            "status": "open",
            "priority": 5,
            "discovered_by": "plan_verifier",
            "evidence": [f"{src}: {text}"],
            "target_backlog": None,
            "suggested_loop": None,
            "handoff_to": ["plan_verifier", "issue_planner"],
        }
        added += 1
    return added


def ingest_snapshot_plan_pending(snap: dict, gaps_by_id: dict[str, dict]) -> int:
    added = 0
    for runner in snap.get("runners") or []:
        if not isinstance(runner, dict):
            continue
        rid = runner.get("id") or "runner"
        for todo_id in runner.get("plan_pending") or []:
            norm = _normalize_plan_todo_id(str(todo_id), rid)
            gid = f"gap-plan-pending-{rid}-{_slug(norm)}"
            if gid in gaps_by_id:
                continue
            gaps_by_id[gid] = {
                "id": gid,
                "gap_kind": "plan_debt",
                "title": f"{rid}: pending plan todo {norm}",
                "status": "open",
                "priority": 7,
                "discovered_by": "plan_verifier",
                "evidence": [f"snapshot runner={rid} plan_pending={norm}"],
                "runner_id": rid,
                "plan_todo_id": norm,
                "suggested_loop": rid,
                "handoff_to": ["swarm_observer"],
            }
            added += 1
    return added


def dedupe_plan_pending_gaps(gaps_by_id: dict[str, dict]) -> int:
    """Close duplicate open plan_debt rows sharing runner + normalized plan_todo_id."""
    closed = 0
    canonical: dict[tuple[str, str], str] = {}
    for gid, gap in sorted(gaps_by_id.items()):
        if gap.get("status") != "open" or gap.get("gap_kind") != "plan_debt":
            continue
        rid = gap.get("runner_id") or ""
        raw = gap.get("plan_todo_id")
        if not rid or not raw:
            continue
        key = (rid, _normalize_plan_todo_id(str(raw), rid))
        if key not in canonical:
            canonical[key] = gid
            continue
        gap["status"] = "closed"
        ev = gap.setdefault("evidence", [])
        note = f"deduped to {canonical[key]}"
        if note not in ev:
            ev.append(note)
        closed += 1
    return closed


def reconcile_snapshot_completed(snap: dict, gaps_by_id: dict[str, dict]) -> int:
    """Close plan_debt rows whose todo is in runner state.completed_ids."""
    closed = 0
    for runner in snap.get("runners") or []:
        if not isinstance(runner, dict):
            continue
        rid = runner.get("id") or "runner"
        completed = set(runner.get("state", {}).get("completed_ids") or [])
        for gap in gaps_by_id.values():
            if not isinstance(gap, dict) or gap.get("status") != "open":
                continue
            if gap.get("runner_id") != rid:
                continue
            raw = gap.get("plan_todo_id")
            if not raw:
                continue
            norm = _normalize_plan_todo_id(str(raw), rid)
            if norm in completed or raw in completed:
                gap["status"] = "closed"
                ev = gap.setdefault("evidence", [])
                note = f"snapshot {rid} completed_ids includes {norm}"
                if note not in ev:
                    ev.append(note)
                closed += 1
    return closed


def ingest_competitor_catalog(explorer: dict, gaps_by_id: dict[str, dict]) -> int:
    added = 0
    catalog = explorer.get("catalog") or {}
    for gap in catalog.get("suggested_catalog_gaps") or []:
        if not isinstance(gap, dict):
            continue
        name = gap.get("id") or gap.get("name") or gap.get("title") or ""
        if not name:
            continue
        gid = f"gap-competitor-{_slug(name)}"
        if gid in gaps_by_id:
            continue
        gaps_by_id[gid] = {
            "id": gid,
            "gap_kind": "competitor_feature",
            "title": str(gap.get("title") or name),
            "status": "open",
            "priority": 5,
            "discovered_by": "gap_explorer",
            "evidence": [json.dumps(gap, default=str)[:200]],
            "suggested_loop": None,
            "handoff_to": ["gap_explorer", "numerics_researcher"],
        }
        added += 1
    return added


def ingest_ci_blocked_swarm(triage: dict, gaps_by_id: dict[str, dict]) -> int:
    """Upsert gap-ci-blocked-swarm-pr from benchmarks ci-bug-triage swarm queue."""
    gid = "gap-ci-blocked-swarm-pr"
    swarm = [r for r in (triage.get("swarm_work_queue") or []) if isinstance(r, dict)]
    if not swarm:
        gap = gaps_by_id.get(gid)
        if gap and gap.get("status") == "open":
            gap["status"] = "closed"
            ev = gap.setdefault("evidence", [])
            note = "ci-bug-triage swarm_work_queue empty"
            if note not in ev:
                ev.append(note)
        return 0

    evidence = [
        f"{r.get('repo')}#{r.get('number')} {r.get('reason', '')}".strip()
        for r in swarm[:8]
    ]
    if gid in gaps_by_id:
        gap = gaps_by_id[gid]
        gap["status"] = "open"
        gap["title"] = f"Swarm agent PR(s) blocked on CI ({len(swarm)} in queue)"
        gap["evidence"] = evidence
        gap["priority"] = max(int(gap.get("priority") or 7), 7)
        return 0

    gaps_by_id[gid] = {
        "id": gid,
        "gap_kind": "ci_blocked",
        "title": f"Swarm agent PR(s) blocked on CI ({len(swarm)} in queue)",
        "status": "open",
        "priority": 8,
        "discovered_by": "ci_bug_triage",
        "evidence": evidence,
        "suggested_loop": None,
        "handoff_to": ["bug_fixer"],
    }
    return 1


def ingest_verticals_stubs(gaps_by_id: dict[str, dict]) -> int:
    vert = ROOT / "benchmarks/competitive/verticals.toml"
    if not vert.is_file():
        vert = LANGVERSE / "benchmarks/competitive/verticals.toml"
    if not vert.is_file():
        return 0
    text = vert.read_text(encoding="utf-8")
    added = 0
    for m in re.finditer(r'^\s*id\s*=\s*"([^"]+)"\s*$', text, re.MULTILINE):
        vid = m.group(1)
        chunk_start = m.start()
        chunk = text[chunk_start : chunk_start + 400]
        if "stub" not in chunk.lower() and "honest" not in chunk.lower():
            continue
        gid = f"gap-vertical-stub-{_slug(vid)}"
        if gid in gaps_by_id:
            continue
        gaps_by_id[gid] = {
            "id": gid,
            "gap_kind": "competitor_feature",
            "title": f"verticals.toml stub/honesty: {vid}",
            "status": "open",
            "priority": 4,
            "discovered_by": "gap_explorer",
            "evidence": [f"verticals.toml id={vid}"],
            "suggested_loop": "sim-md-research",
            "handoff_to": ["numerics_researcher"],
        }
        added += 1
    return added


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dry-run", action="store_true", help="Print summary only")
    p.add_argument("--registry", type=Path, default=REGISTRY)
    args = p.parse_args()

    data = _load_yaml(args.registry)
    gaps_by_id = _gap_index(data.get("gaps") or [])

    explorer_path = LATEST / "ecosystem-explorer.json"
    audit_path = LATEST / "plan-completion-audit.json"
    explorer = json.loads(explorer_path.read_text(encoding="utf-8")) if explorer_path.is_file() else {}
    audit = json.loads(audit_path.read_text(encoding="utf-8")) if audit_path.is_file() else {}
    snap = json.loads(SNAPSHOT.read_text(encoding="utf-8")) if SNAPSHOT.is_file() else {}
    triage_path = LATEST / "ci-bug-triage.json"
    triage = json.loads(triage_path.read_text(encoding="utf-8")) if triage_path.is_file() else {}

    stats = {
        "missing_std": ingest_missing_std(explorer, gaps_by_id),
        "plan_debt_audit": ingest_plan_debt(audit, gaps_by_id),
        "plan_debt_snapshot": ingest_snapshot_plan_pending(snap, gaps_by_id),
        "snapshot_completed": reconcile_snapshot_completed(snap, gaps_by_id),
        "plan_debt_dedupe": dedupe_plan_pending_gaps(gaps_by_id),
        "competitor_catalog": ingest_competitor_catalog(explorer, gaps_by_id),
        "verticals_stubs": ingest_verticals_stubs(gaps_by_id),
        "ci_blocked_swarm": ingest_ci_blocked_swarm(triage, gaps_by_id),
    }

    data["gaps"] = list(gaps_by_id.values())
    data["version"] = 1
    by_kind: dict[str, int] = {}
    for g in data["gaps"]:
        k = g.get("gap_kind") or "unknown"
        by_kind[k] = by_kind.get(k, 0) + 1

    print(f"registry gaps: {len(data['gaps'])} ({by_kind}) added={stats}")
    if args.dry_run:
        return 0

    _save_yaml(args.registry, data)
    print(f"wrote {args.registry}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
