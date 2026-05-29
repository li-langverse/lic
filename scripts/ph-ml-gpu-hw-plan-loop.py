#!/usr/bin/env python3
"""Goal-directed loop: PH-ML GPU hardware WPs (CUDA-first on Linux NVIDIA).

Usage:
  export CURSOR_API_KEY=...
  export LI_CURSOR_AGENTS_ROOT=../li-cursor-agents
  export CUDA_HOME=/usr/lib/cuda
  ./scripts/ph-ml-gpu-hw-plan-loop.py --once
  ./scripts/ph-ml-gpu-hw-plan-loop.py --max 10
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import threading
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "docs/superpowers/plans/2026-05-29-ph-ml-gpu-hw-cuda-plan.md"
TRACKER = ROOT / "docs/game-dev/PH-ML-GPU-execution-tracker.md"
STATE_DIR = ROOT / "data/ph-ml-gpu-hw-plan-loop"
STATE_FILE = STATE_DIR / "state.json"
GATES = ROOT / "scripts/ph-ml-gpu-hw-gates.sh"
BRANCH = os.environ.get("PH_ML_GPU_HW_PR_BRANCH", "feat/ph-ml-gpu-swarm")

TODO_RE = re.compile(
    r"- id: (\S+)\n\s+content: \"([^\"]+)\"\n\s+status: (\w+)",
    re.MULTILINE,
)

PRIORITY = [
    "hw-cuda-08-device-matmul",
    "hw-cuda-08-lkir-dispatch",
    "hw-cuda-09-ptx-catalog",
    "hw-cuda-12-mlp-stub",
    "hw-cuda-bench-tracker",
]


def load_todos() -> list[dict]:
    text = PLAN.read_text(encoding="utf-8")
    m = re.search(r"^todos:\s*\n(.*)", text, re.MULTILINE | re.DOTALL)
    block = m.group(1) if m else text
    return [
        {"id": x.group(1), "content": x.group(2), "status": x.group(3)}
        for x in TODO_RE.finditer(block)
    ]


def load_state() -> dict:
    if STATE_FILE.is_file():
        import json

        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    return {"completed_ids": [], "history": []}


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    import json

    STATE_FILE.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")


def pick_next(todos: list[dict], state: dict) -> dict | None:
    completed = set(state.get("completed_ids", []))
    open_todos = [
        t
        for t in todos
        if t["status"] in ("pending", "in_progress") and t["id"] not in completed
    ]
    if not open_todos:
        return None

    def rank(t: dict) -> tuple[int, int, str]:
        try:
            p = PRIORITY.index(t["id"])
        except ValueError:
            p = 99
        status_rank = 0 if t["status"] == "in_progress" else 1
        return (status_rank, p, t["id"])

    open_todos.sort(key=rank)
    return open_todos[0]


def agents_root() -> Path | None:
    for candidate in [
        os.environ.get("LI_CURSOR_AGENTS_ROOT"),
        ROOT.parent / "li-cursor-agents",
        Path("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents"),
        Path.home() / "Documents/Cursor/li-langverse/li-cursor-agents",
    ]:
        if not candidate:
            continue
        p = Path(candidate)
        if (p / "package.json").is_file():
            return p
    return None


def agent_timeout_sec() -> int | None:
    raw = os.environ.get("LI_PH_ML_GPU_HW_AGENT_TIMEOUT_SEC", "2400").strip()
    if raw in ("0", "none", "off"):
        return None
    try:
        return max(120, int(raw))
    except ValueError:
        return 2400


def _tee_stream(pipe, logf, out) -> None:
    for line in iter(pipe.readline, ""):
        out.write(line)
        out.flush()
        logf.write(line)
        logf.flush()


def run_subprocess_streaming(cmd: list[str], cwd: Path, env: dict[str, str], log_path: Path) -> int:
    timeout = agent_timeout_sec()
    with log_path.open("w", encoding="utf-8") as logf:
        logf.write(f"# cmd: {' '.join(cmd)}\n# cwd: {cwd}\n\n")
        logf.flush()
        proc = subprocess.Popen(
            cmd,
            cwd=str(cwd),
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
            msg = f"agent timed out after {timeout}s\n"
            sys.stderr.write(msg)
            logf.write(msg)
            return 124
        finally:
            for t in threads:
                t.join(timeout=2)
        return rc


def build_instruction(todo: dict) -> str:
    tracker_excerpt = ""
    if TRACKER.is_file():
        tracker_excerpt = TRACKER.read_text(encoding="utf-8")[:4000]
    return f"""# PH-ML GPU hardware sprint — `{todo['id']}`

**Plan:** `{PLAN.relative_to(ROOT)}`
**Branch:** `{BRANCH}` (push every iteration)
**Host:** Linux NVIDIA — `CUDA_HOME=/usr/lib/cuda`

## Todo
- **id:** {todo['id']}
- **content:** {todo['content']}

## Rules
1. Work in this repo on `{BRANCH}`; commit + `git push origin {BRANCH}` before stopping.
2. Follow `ph-ml-stub-then-implement.mdc` and `ph-ml-gpu-honesty.mdc` — no fake `gpu_timing_ns`.
3. Run `bash scripts/ph-ml-gpu-hw-gates.sh` before finishing.
4. Update plan todo `status: completed` when done; update `PH-ML-GPU-execution-tracker.md` with evidence.
5. Add release note under `docs/release-notes/` when behavior changes.

## CUDA verify
```bash
export CUDA_HOME=/usr/lib/cuda PATH=/usr/lib/cuda/bin:$PATH
bash scripts/ph-ml-gpu-hw-gates.sh
bash scripts/lig-cuda-timing-probe.sh
```

## Tracker excerpt
```
{tracker_excerpt}
```
"""


def workflow_env() -> dict[str, str]:
    return {
        "LI_PH_ML_GPU_HW_PLAN_LOOP": "1",
        "LI_REPO_WORKFLOW_REPO": "lic",
        "LI_REPO_WORKFLOW_BRANCH": BRANCH,
        "LI_REPO_WORKFLOW_TRACK_REMOTE": "1",
        "CUDA_HOME": os.environ.get("CUDA_HOME", "/usr/lib/cuda"),
        "LIG_EMIT_CUDA": os.environ.get("LIG_EMIT_CUDA", "1"),
    }


def run_gates() -> tuple[bool, str]:
    if not GATES.is_file():
        return False, "missing gates"
    proc = subprocess.run(
        ["bash", str(GATES)],
        cwd=ROOT,
        env={**os.environ, "LIC_ROOT": str(ROOT)},
        capture_output=True,
        text=True,
    )
    out = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode == 0, out[-6000:]


def run_agent(todo: dict, *, dry_run: bool) -> tuple[int, str]:
    root = agents_root()
    if not root:
        return 2, "li-cursor-agents not found"

    instruction = build_instruction(todo)
    if dry_run:
        print(instruction)
        return 0, "dry-run"

    if not os.environ.get("CURSOR_API_KEY") and not os.environ.get("CURSOR_SDK_KEY"):
        return 2, "CURSOR_API_KEY not set"

    dist = root / "dist/cli/run-agent.js"
    if not dist.is_file():
        subprocess.run(["npm", "run", "build"], cwd=root, check=True)

    benchmarks = os.environ.get("BENCHMARKS_ROOT", str(ROOT.parent / "benchmarks"))
    goal_path = STATE_DIR / f"goal-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.md"
    goal_path.write_text(instruction, encoding="utf-8")

    agent = os.environ.get("LI_PH_ML_GPU_HW_AGENT", "code_implementer")
    env = {
        **os.environ,
        **workflow_env(),
        "PYTHONUNBUFFERED": "1",
        "LI_SDK_TERMINAL_STREAM": os.environ.get("LI_SDK_TERMINAL_STREAM", "1"),
        "LIC_ROOT": str(ROOT),
        "BENCHMARKS_ROOT": benchmarks,
        "LI_AGENT_GOAL": instruction,
        "LI_AGENT_EXTRA_INSTRUCTION": instruction,
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
        "--benchmarks",
        benchmarks,
    ]
    log_path = STATE_DIR / f"iter-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.log"
    rc = run_subprocess_streaming(cmd, root, env, log_path)
    return rc, str(log_path)


def mark_plan_todo_done(todo_id: str) -> None:
    if not PLAN.is_file():
        return
    text = PLAN.read_text(encoding="utf-8")
    pattern = (
        rf"(- id: {re.escape(todo_id)}\n\s+content: \"[^\"]+\"\n\s+status: )(\w+)"
    )
    new_text, n = re.subn(pattern, r"\1completed", text, count=1)
    if n:
        PLAN.write_text(new_text, encoding="utf-8")


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--once", action="store_true")
    p.add_argument("--max", type=int, default=1)
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    if not PLAN.is_file():
        print(f"missing {PLAN}", file=sys.stderr)
        return 1

    state = load_state()
    iterations = 0
    max_iter = 1 if args.once else max(1, args.max)

    while iterations < max_iter:
        todos = load_todos()
        todo = pick_next(todos, state)
        if not todo:
            print("ph-ml-gpu-hw-plan-loop: all todos done")
            return 0

        print(f"ph-ml-gpu-hw-plan-loop: {todo['id']} — {todo['content']}", flush=True)
        rc, note = run_agent(todo, dry_run=args.dry_run)
        print(f"ph-ml-gpu-hw-plan-loop: agent exit {rc} ({note})", flush=True)

        gates_ok = False
        if rc == 0 and not args.dry_run:
            gates_ok, gate_out = run_gates()
            print(f"ph-ml-gpu-hw-plan-loop: gates {'OK' if gates_ok else 'FAIL'}", flush=True)
            if not gates_ok:
                print(gate_out[-2000:], file=sys.stderr)

        state.setdefault("history", []).append(
            {
                "at": datetime.now(timezone.utc).isoformat(),
                "todo_id": todo["id"],
                "agent_exit": rc,
                "gates_ok": gates_ok,
            }
        )
        if rc == 0 and gates_ok:
            completed = set(state.get("completed_ids", []))
            completed.add(todo["id"])
            state["completed_ids"] = sorted(completed)
            mark_plan_todo_done(todo["id"])
        save_state(state)

        iterations += 1
        if rc != 0:
            return rc

    return 0


if __name__ == "__main__":
    sys.exit(main())
