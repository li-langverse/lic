#!/usr/bin/env python3
"""Autonomous MD/chem algorithm research plan loop (numerics_researcher / autoresearch)."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import threading
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERT = os.environ.get("SIM_RESEARCH_VERTICAL", "").strip()
if VERT not in ("md", "chem"):
    sys.exit("sim-algo-research-plan-loop: set SIM_RESEARCH_VERTICAL=md|chem")

BACKLOG = ROOT / f"docs/ecosystem/sim-{VERT}-research-backlog.md"
GATES = ROOT / "scripts/sim-algo-research-gates.sh"
GRADING = ROOT / "docs/ecosystem/sim-algo-research-grading.md"
BRANCH = os.environ.get(
    "SIM_RESEARCH_PR_BRANCH",
    f"cursor/sim-{VERT}-research-loop",
)
STATE_DIR = ROOT / f"data/sim-{VERT}-research-loop"
STATE_FILE = STATE_DIR / "state.json"
GOAL_ID = "md_sim_algorithms" if VERT == "md" else "chem_sim_algorithms"
LANGVERSE = Path(os.environ.get("LI_LANGVERSE_ROOT", ROOT.parent))
IMPL_BACKLOG = LANGVERSE / "lic-worktrees/sim-algo/docs/ecosystem/sim-algorithm-backlog.md"

TODO_BLOCK_RE = re.compile(
    r"- id: (\S+)\n"
    r"\s+content: \"([^\"]+)\"\n"
    r"\s+status: (\w+)"
    r"(?:\n\s+study_only: (true|false))?"
    r"(?:\n\s+handoff_implement: (\S+))?"
    r"(?:\n\s+novel: (true|false))?",
    re.MULTILINE,
)


def load_todos() -> list[dict]:
    if not BACKLOG.is_file():
        return []
    text = BACKLOG.read_text(encoding="utf-8")
    todos: list[dict] = []
    for m in TODO_BLOCK_RE.finditer(text):
        todos.append(
            {
                "id": m.group(1),
                "content": m.group(2),
                "status": m.group(3),
                "study_only": m.group(4) == "true" if m.group(4) else False,
                "handoff_implement": m.group(5) or "",
                "novel": m.group(6) == "true" if m.group(6) else False,
            }
        )
    return todos


def pick_work(todos: list[dict], state: dict) -> dict | None:
    done = set(state.get("completed_ids", []))
    for t in todos:
        if t["status"] in ("pending", "in_progress") and t["id"] not in done:
            return t
    return None


def agents_root() -> Path | None:
    raw = os.environ.get("LI_CURSOR_AGENTS_ROOT", "")
    if raw:
        p = Path(raw)
        if p.is_dir():
            return p
    for c in [ROOT.parent / "li-cursor-agents", LANGVERSE / "li-cursor-agents"]:
        if (c / "dist/cli/run-agent.js").is_file():
            return c.resolve()
    return None


def study_path_for(work_id: str) -> Path:
    day = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    return ROOT / "docs/numerics/studies" / f"{day}-{work_id}.md"


def build_instruction(work: dict) -> str:
    study = study_path_for(work["id"])
    agent = "autoresearch" if work.get("novel") else os.environ.get(
        "LI_SIM_RESEARCH_AGENT", "numerics_researcher"
    )
    handoff = work.get("handoff_implement") or ""
    handoff_block = ""
    if handoff:
        handoff_block = f"""
## Implement handoff
When research is complete and gates pass, ensure implement loop picks up **`{handoff}`** on `cursor/sim-algo-plan-loop`.
Link study: `{study.relative_to(ROOT)}`
"""
    return f"""---
workflow_repo: lic
cwd: .
research_goal_id: {GOAL_ID}
vertical: {VERT}
---

# Sim algorithm research — `{work['id']}`

**Branch:** `{BRANCH}` (commit + push before stopping)  
**Grading:** `{GRADING.relative_to(ROOT)}`  
**Agent:** `{agent}`

## Work item
- **id:** {work['id']}
- **content:** {work['content']}
- **study_only:** {work.get('study_only', False)}

## Mandatory deliverables
1. Write **`{study.relative_to(ROOT)}`** with:
   - 2–4 **Learned from** references (URLs) for external libraries (LAMMPS/GROMACS/OpenMM or Gaussian/Psi4/PySCF).
   - **Size scaling** table (≥3 sizes: N, grid, or basis count).
   - **Grade matrix** and **Tradeoffs** section (validity locked).
2. Map findings to `benchmarks/competitive/algo_registry.json` rows for this vertical.
3. Run gates after any bench-touching edits: `SIM_RESEARCH_VERTICAL={VERT} ./scripts/sim-algo-research-gates.sh`
4. **Commit + push:** `git push -u origin {BRANCH}`

## Skill
Use `.cursor/skills/research-li-numerics` before proposing new kernels.

{handoff_block}

## Rules
- Do **not** weaken verify thresholds or mark `implemented_smoke` without gates.
- Performance/memory improvements must document tradeoffs vs validity.
- Survey-only todos: study file is the primary artifact; benches optional unless you change code.
"""


def agent_timeout_sec() -> int | None:
    raw = os.environ.get("LI_SIM_RESEARCH_AGENT_TIMEOUT_SEC", "3600").strip()
    if raw in ("0", "none", "off"):
        return None
    try:
        return max(60, int(raw))
    except ValueError:
        return 3600


def _tee_stream(stream, logf, out):
    for line in stream:
        if line:
            out.write(line)
            out.flush()
            logf.write(line)
            logf.flush()


def run_agent_streaming(work: dict, *, dry_run: bool) -> tuple[int, str]:
    root = agents_root()
    if not root:
        return 2, "LI_CURSOR_AGENTS_ROOT not found"

    instruction = build_instruction(work)
    if dry_run:
        print(instruction)
        return 0, "dry-run"

    if not os.environ.get("CURSOR_API_KEY") and not os.environ.get("CURSOR_SDK_KEY"):
        return 2, "CURSOR_API_KEY not set"

    dist = root / "dist/cli/run-agent.js"
    if not dist.is_file():
        subprocess.run(["npm", "ci"], cwd=root, check=False)
        subprocess.run(["npm", "run", "build"], cwd=root, check=True)

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    goal_path = STATE_DIR / f"goal-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.md"
    goal_path.write_text(instruction, encoding="utf-8")
    log_path = STATE_DIR / f"iter-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.log"

    agent = "autoresearch" if work.get("novel") else os.environ.get(
        "LI_SIM_RESEARCH_AGENT", "numerics_researcher"
    )
    env = {
        **os.environ,
        "PYTHONUNBUFFERED": "1",
        "LI_SDK_TERMINAL_STREAM": os.environ.get("LI_SDK_TERMINAL_STREAM", "1"),
        "LI_AGENT_MINIMAL_PROMPT": "1",
        "LIC_ROOT": str(ROOT),
        "LI_AGENT_EXTRA_INSTRUCTION": instruction,
        "LI_AGENT_GOAL": instruction,
        "SIM_RESEARCH_PR_BRANCH": BRANCH,
    }
    cmd = [
        "node",
        str(dist),
        "--agent",
        agent,
        "--cwd",
        str(ROOT),
        "--workflow-repo",
        "lic",
        "--goal-file",
        str(goal_path),
    ]
    timeout = agent_timeout_sec()
    with log_path.open("w", encoding="utf-8") as logf:
        logf.write(f"# cmd: {' '.join(cmd)}\n\n")
        proc = subprocess.Popen(
            cmd,
            cwd=str(root),
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
        )
        threads = [
            threading.Thread(target=_tee_stream, args=(proc.stdout, logf, sys.stdout), daemon=True),
            threading.Thread(target=_tee_stream, args=(proc.stderr, logf, sys.stderr), daemon=True),
        ]
        for t in threads:
            t.start()
        try:
            rc = proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            proc.kill()
            rc = proc.wait()
            logf.write(f"\n# timeout after {timeout}s\n")
            rc = 124
        for t in threads:
            t.join(timeout=2)

    return rc, f"log={log_path}"


def run_gates(work: dict) -> tuple[bool, str]:
    if not GATES.is_file():
        return False, "missing sim-algo-research-gates.sh"
    study = study_path_for(work["id"])
    env = {
        **os.environ,
        "SIM_RESEARCH_VERTICAL": VERT,
        "SIM_RESEARCH_STATE_DIR": str(STATE_DIR),
        "LIC_ROOT": str(ROOT),
        "LI_REPO_ROOT": str(ROOT),
    }
    env["SIM_RESEARCH_STUDY_ONLY"] = "0"
    env["SIM_RESEARCH_BACKLOG_STUDY_ONLY"] = "0"
    if work.get("study_only"):
        env["SIM_RESEARCH_BACKLOG_STUDY_ONLY"] = "1"
        env["SIM_RESEARCH_STUDY_ONLY"] = "1"
        if study.is_file():
            env["SIM_RESEARCH_REQUIRE_STUDY"] = str(study.relative_to(ROOT))
        else:
            env.pop("SIM_RESEARCH_REQUIRE_STUDY", None)

    proc = subprocess.run(
        ["bash", str(GATES)], cwd=ROOT, env=env, capture_output=True, text=True
    )
    out = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode == 0, out


def mark_backlog_todo_completed(todo_id: str) -> None:
    if not BACKLOG.is_file():
        return
    text = BACKLOG.read_text(encoding="utf-8")
    pattern = (
        rf"(- id: {re.escape(todo_id)}\n\s+content: \"[^\"]+\"\n\s+status: )(\w+)"
    )
    new_text, n = re.subn(pattern, r"\1completed", text, count=1)
    if n:
        BACKLOG.write_text(new_text, encoding="utf-8")


def handoff_to_implement_loop(implement_id: str, study_rel: str) -> None:
    if not implement_id or not IMPL_BACKLOG.is_file():
        return
    text = IMPL_BACKLOG.read_text(encoding="utf-8")
    pattern = (
        rf"(- id: {re.escape(implement_id)}\n\s+content: \")([^\"]+)(\"\n\s+status: )(\w+)"
    )

    def repl(m: re.Match[str]) -> str:
        content = m.group(2)
        if study_rel not in content:
            content = f"{content} — research: {study_rel}"
        return f"{m.group(1)}{content}{m.group(3)}pending"

    new_text, n = re.subn(pattern, repl, text, count=1)
    if n:
        IMPL_BACKLOG.write_text(new_text, encoding="utf-8")
        print(f"handoff: set {implement_id} pending in sim-algorithm-backlog.md")


def load_state() -> dict:
    if STATE_FILE.is_file():
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    return {"completed_ids": [], "iterations": 0, "history": [], "vertical": VERT}


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    state["vertical"] = VERT
    STATE_FILE.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")


def commit_push(work_id: str) -> None:
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    subprocess.run(["git", "add", "-A"], cwd=ROOT, check=False)
    subprocess.run(
        ["git", "commit", "-m", f"docs(research/{VERT}): {work_id} — study + gates"],
        cwd=ROOT,
        check=False,
    )
    if token:
        subprocess.run(
            [
                "git",
                "push",
                f"https://x-access-token:{token}@github.com/li-langverse/lic.git",
                f"HEAD:{BRANCH}",
            ],
            cwd=ROOT,
            check=False,
        )
    else:
        subprocess.run(["git", "push", "-u", "origin", BRANCH], cwd=ROOT, check=False)


def refresh_canvases() -> None:
    script = ROOT / "scripts/refresh-all-agent-canvases.sh"
    if script.is_file():
        subprocess.run(["bash", str(script)], check=False)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--once", action="store_true")
    p.add_argument("--max", type=int, default=0)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--skip-agent", action="store_true")
    args = p.parse_args()

    todos = load_todos()
    pending = [t for t in todos if t["status"] != "completed"]
    print(f"vertical={VERT} backlog todos: {len(pending)} pending/in_progress")

    state = load_state()
    max_iter = 1 if args.once else (args.max or 999_999)
    iteration = 0

    while iteration < max_iter:
        work = pick_work(todos, state)
        if not work:
            print("sim-algo-research-plan-loop: all todos done")
            return 0

        print(f"\n=== iteration {iteration + 1}: {work['id']} ===")
        print(f"    {work['content']}")

        if args.dry_run:
            print(build_instruction(work))
            return 0

        if args.skip_agent:
            ok, out = run_gates(work)
            print(out[-1500:])
            return 0 if ok else 1

        code, msg = run_agent_streaming(work, dry_run=False)
        print(msg, flush=True)

        ok, gate_out = run_gates(work)
        if not ok:
            print("gates: FAIL", file=sys.stderr)
            print(gate_out[-2000:], file=sys.stderr)
        else:
            print("gates: OK")

        state["iterations"] = state.get("iterations", 0) + 1
        state.setdefault("history", []).append(
            {
                "at": datetime.now(timezone.utc).isoformat(),
                "todo_id": work["id"],
                "agent_exit": code,
                "gates_ok": ok,
            }
        )
        save_state(state)

        if code != 0:
            print(f"agent exit {code} — stopping", file=sys.stderr)
            return code
        if not ok:
            print("gates failed — stopping", file=sys.stderr)
            return 1

        study_rel = str(study_path_for(work["id"]).relative_to(ROOT))
        if work.get("handoff_implement"):
            handoff_to_implement_loop(work["handoff_implement"], study_rel)

        wid = work["id"]
        if wid not in state.setdefault("completed_ids", []):
            state["completed_ids"].append(wid)
        mark_backlog_todo_completed(wid)
        save_state(state)
        commit_push(wid)
        refresh_canvases()

        iteration += 1
        if args.once:
            break
        todos = load_todos()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
