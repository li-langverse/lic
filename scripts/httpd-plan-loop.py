#!/usr/bin/env python3
"""Autonomous loop: drive li-httpd master plan until todos complete or max iterations.

Uses li-cursor-agents + Cursor SDK (local) when CURSOR_API_KEY is set. Invokes a
**reusable** registry agent (default ``code_implementer``) with the todo slice as
``--goal`` / ``LI_AGENT_EXTRA_INSTRUCTION`` — not a dedicated httpd agent id.

Usage:
  export CURSOR_API_KEY=cursor_...
  export LI_CURSOR_AGENTS_ROOT=/path/to/li-cursor-agents
  export BENCHMARKS_ROOT=/path/to/benchmarks   # optional, for preflight
  ./scripts/httpd-plan-loop.py --once          # single iteration
  ./scripts/httpd-plan-loop.py --max 50        # up to 50 agent runs
  ./scripts/httpd-plan-loop.py --dry-run         # pick todo + print prompt only

State: data/httpd-plan-loop/state.json
Logs:  data/httpd-plan-loop/iter-*.log
"""
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
sys.path.insert(0, str(ROOT / "scripts"))
from plan_todo_normalize import normalize_plan_todo_id

HTTPD_RUNNER_ID = "httpd"
HTTPD_PR_BRANCH = os.environ.get("HTTPD_PLAN_PR_BRANCH", "cursor/httpd-plan-continue")
PLAN = ROOT / "docs/superpowers/plans/2026-05-16-li-httpd-plan.md"
BASELINE = ROOT / "docs/ecosystem/httpd-m1-baseline.md"
STATE_DIR = ROOT / "data/httpd-plan-loop"
STATE_FILE = STATE_DIR / "state.json"
GATES = ROOT / "scripts/httpd-plan-gates.sh"

TODO_RE = re.compile(
    r"^\s+-\s+id:\s+(\S+)\s*\n"
    r"(?:\s+content:\s+\"([^\"]+)\"|\s+content:\s+(.+?))\s*\n"
    r"\s+status:\s+(\w+)\s*$",
    re.MULTILINE,
)


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


def is_server_milestone(todo_id: str) -> bool:
    """Server/httpd plan todos for parity loop (excludes prob-hoare, pkg-workspace-only)."""
    if todo_id in ("prob-hoare", "pkg-workspace", "rng-concepts"):
        return False
    prefixes = (
        "w0",
        "w1",
        "m0-",
        "m1",
        "m15",
        "m2",
        "m3",
        "gap-",
        "bench-harness",
        "nginx-",
        "exploit-",
        "rng-exploit",
        "setup-censor",
        "li-log",
    )
    return todo_id.startswith(prefixes) or todo_id in ("setup-censor-schema",)


def server_tier(todo_id: str) -> int:
    if todo_id.startswith("w0"):
        return 0
    if todo_id.startswith("w1"):
        return 1
    if todo_id.startswith("m0"):
        return 2
    if todo_id.startswith("m1"):
        return 3
    if todo_id.startswith("m15"):
        return 4
    if todo_id.startswith("m2"):
        return 5
    if todo_id.startswith("m3"):
        return 6
    if todo_id.startswith("h-"):
        return 7
    if todo_id.startswith("gap-"):
        return 8
    return 9


def canonical_todo_id(todo_id: str) -> str:
    return normalize_plan_todo_id(todo_id, HTTPD_RUNNER_ID)


def completed_canonical(state: dict) -> set[str]:
    return {canonical_todo_id(t) for t in state.get("completed_ids") or []}


def repair_state(state: dict) -> dict:
    """Normalize completed_ids — collapse mirror gap-httpd-* duplicates."""
    seen: set[str] = set()
    repaired: list[str] = []
    for tid in state.get("completed_ids") or []:
        canon = canonical_todo_id(str(tid))
        if canon not in seen:
            seen.add(canon)
            repaired.append(canon)
    state["completed_ids"] = repaired
    for row in state.get("history") or []:
        if isinstance(row, dict) and row.get("todo_id"):
            row["todo_id"] = canonical_todo_id(str(row["todo_id"]))
    return state


def pick_next(todos: list[dict], state: dict) -> dict | None:
    completed = completed_canonical(state)
    close_server = os.environ.get("LI_HTTPD_PLAN_CLOSE_SERVER_MILESTONES", "1").strip() not in (
        "0",
        "false",
        "no",
        "off",
    )

    def order_key(t: dict) -> tuple[int, int, str]:
        status_rank = 0 if t["status"] == "in_progress" else 1
        return (status_rank, server_tier(t["id"]), t["id"])

    open_todos = [
        t
        for t in todos
        if t["status"] in ("in_progress", "pending") and canonical_todo_id(t["id"]) not in completed
    ]
    if not open_todos:
        return None
    gap_open = [t for t in open_todos if t["id"].startswith("gap-")]
    gap_only = os.environ.get("LI_HTTPD_PLAN_GAP_ONLY", "").strip().lower() in (
        "1",
        "true",
        "yes",
        "on",
    )
    if gap_only:
        if not gap_open:
            return None
        open_todos = gap_open
    elif gap_open:
        # Phase-2 nginx gaps: always feed agents gap-* before other milestones.
        open_todos = gap_open
    elif close_server:
        scoped = [t for t in open_todos if is_server_milestone(t["id"])]
        if scoped:
            open_todos = scoped
    elif os.environ.get("LI_HTTPD_PLAN_INCLUDE_BLOCKERS", "").strip() not in ("1", "true", "yes"):
        m1_open = [t for t in open_todos if t["id"].startswith("m1")]
        if m1_open:
            open_todos = m1_open
    open_todos.sort(key=order_key)
    return open_todos[0]


def run_gates() -> tuple[bool, str]:
    if not GATES.is_file():
        return False, f"missing gates script: {GATES}"
    env = {**os.environ, "LI_REPO_ROOT": str(ROOT)}
    proc = subprocess.run(
        ["bash", str(GATES)],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
    )
    out = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode == 0, out[-8000:]


def agents_root() -> Path | None:
    for candidate in [
        os.environ.get("LI_CURSOR_AGENTS_ROOT"),
        ROOT.parent / "li-cursor-agents",
        Path("/workspace/li-cursor-agents"),
    ]:
        if not candidate:
            continue
        p = Path(candidate)
        if (p / "package.json").is_file():
            return p
    return None


def _tee_stream(pipe, logf, out) -> None:
    """Copy subprocess line-by-line to terminal and log (live, unbuffered)."""
    for line in iter(pipe.readline, ""):
        out.write(line)
        out.flush()
        logf.write(line)
        logf.flush()


def httpd_workflow_env() -> dict[str, str]:
    branch = HTTPD_PR_BRANCH
    return {
        "LI_HTTPD_PLAN_LOOP": "1",
        "LI_REPO_WORKFLOW_REPO": "lic",
        "LI_REPO_WORKFLOW_BRANCH": branch,
        "LI_REPO_WORKFLOW_TRACK_REMOTE": "1",
        "LI_REPO_WORKFLOW_OPEN_PR": "1",
        "HTTPD_PLAN_PR_BRANCH": branch,
    }


def _git(cwd: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
        check=False,
    )


def recover_unpushed_work(lic_root: Path, agents_root: Path | None, branch: str) -> None:
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not token:
        print("recover: skip (no GH_TOKEN)", flush=True)
        return

    def push_repo(repo_dir: Path, label: str) -> None:
        if not (repo_dir / ".git").is_dir():
            return
        cur = _git(repo_dir, "branch", "--show-current").stdout.strip()
        if cur and cur != branch:
            print(f"recover: skip {label} (branch {cur!r} != {branch!r})", flush=True)
            return
        if cur != branch:
            _git(repo_dir, "checkout", "-B", branch, f"origin/{branch}")
        dirty = _git(repo_dir, "status", "--porcelain").stdout.strip()
        if dirty:
            _git(repo_dir, "add", "-A")
            _git(repo_dir, "commit", "-m", f"chore(httpd): plan loop recovery ({label})")
        ahead = _git(repo_dir, "rev-list", "--count", f"origin/{branch}..HEAD")
        if ahead.returncode == 0 and ahead.stdout.strip() not in ("", "0"):
            push = _git(repo_dir, "push", "-u", "origin", branch)
            if push.returncode == 0:
                print(f"recover: pushed {label}", flush=True)

    push_repo(lic_root, "lic checkout")
    if not agents_root:
        return
    ws = agents_root / "data" / "workspaces"
    if not ws.is_dir():
        return
    clones: list[Path] = []
    for org_dir in ws.iterdir():
        if not org_dir.is_dir():
            continue
        lic_dir = org_dir / "lic"
        if not lic_dir.is_dir():
            continue
        for run_dir in lic_dir.iterdir():
            repo = run_dir / "repo"
            if (repo / ".git").is_dir():
                clones.append(repo)
    clones.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    for repo in clones[:3]:
        push_repo(repo, repo.parent.name)


def refresh_live_pages() -> None:
    """Local Pages publish (no GHA). See lic/.cursor/skills/run-local-pages-benchmarks/."""
    if os.environ.get("HTTPD_REFRESH_PAGES", "").strip() in ("0", "false", "no"):
        return
    bench_root = Path(os.environ.get("BENCHMARKS_ROOT", str(ROOT.parent / "benchmarks")))
    script = bench_root / "scripts/refresh-live-sites.sh"
    if not script.is_file():
        print("pages: skip (no benchmarks/scripts/refresh-live-sites.sh)", flush=True)
        return
    env = {
        **os.environ,
        "LIC_ROOT": str(ROOT),
        "SKIP_BENCH": os.environ.get("HTTPD_PAGES_SKIP_BENCH", "1"),
        "SKIP_ROADMAP": os.environ.get("HTTPD_PAGES_SKIP_ROADMAP", "0"),
    }
    print("pages: refresh-live-sites.sh", flush=True)
    proc = subprocess.run(["bash", str(script)], cwd=bench_root, env=env, check=False)
    if proc.returncode != 0:
        print(f"pages: refresh exit {proc.returncode}", flush=True)


def agent_timeout_sec() -> int | None:
    raw = os.environ.get("LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC", "2700").strip()
    if raw in ("0", "none", "off"):
        return None
    try:
        return max(60, int(raw))
    except ValueError:
        return 2700


def run_subprocess_streaming(cmd: list[str], cwd: Path, env: dict[str, str], log_path: Path) -> int:
    """Run child with stdout/stderr streamed to this terminal and log_path."""
    timeout = agent_timeout_sec()
    with log_path.open("w", encoding="utf-8") as logf:
        logf.write(f"# cmd: {' '.join(cmd)}\n# cwd: {cwd}\n\n")
        logf.flush()
        hint = f", timeout={timeout}s" if timeout else ""
        print(f"==> agent subprocess (live; also {log_path}{hint})", flush=True)
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
            threading.Thread(
                target=_tee_stream,
                args=(proc.stdout, logf, sys.stdout),
                daemon=True,
            ),
            threading.Thread(
                target=_tee_stream,
                args=(proc.stderr, logf, sys.stderr),
                daemon=True,
            ),
        ]
        for t in threads:
            t.start()
        try:
            rc = proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            proc.kill()
            rc = proc.wait()
            msg = f"agent timed out after {timeout}s — killed\n"
            sys.stderr.write(msg)
            logf.write(msg)
            return 124
        finally:
            for t in threads:
                t.join(timeout=2)
        return rc


def run_cursor_agent(todo: dict, dry_run: bool) -> tuple[int, str]:
    root = agents_root()
    if not root:
        return 2, "li-cursor-agents not found (clone next to lic or set LI_CURSOR_AGENTS_ROOT)"

    instruction = build_instruction(todo)
    if dry_run:
        return 0, instruction

    if not os.environ.get("CURSOR_API_KEY") and not os.environ.get("CURSOR_SDK_KEY"):
        return 2, "CURSOR_API_KEY not set — export key or use Cloud Agent with pasted instruction"

    dist = root / "dist/cli/run-agent.js"
    if not dist.is_file():
        subprocess.run(["npm", "ci"], cwd=root, check=False)
        subprocess.run(["npm", "run", "build"], cwd=root, check=True)

    benchmarks = os.environ.get("BENCHMARKS_ROOT")
    if benchmarks and not Path(benchmarks, "scripts/agent-briefing.py").is_file():
        benchmarks = None
    if not benchmarks:
        for c in [ROOT.parent / "benchmarks", Path("/workspace")]:
            if (c / "scripts/agent-briefing.py").is_file():
                benchmarks = str(c)
                break

    agent = os.environ.get("LI_HTTPD_PLAN_AGENT", "code_implementer")
    goal_path = STATE_DIR / f"goal-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.md"
    goal_path.write_text(instruction, encoding="utf-8")

    env = {
        **os.environ,
        **httpd_workflow_env(),
        "PYTHONUNBUFFERED": "1",
        "LI_SDK_TERMINAL_STREAM": os.environ.get("LI_SDK_TERMINAL_STREAM", "1"),
        "LI_AGENT_MINIMAL_PROMPT": "1",
        "LIC_ROOT": str(ROOT),
        "BENCHMARKS_ROOT": benchmarks or os.environ.get("BENCHMARKS_ROOT", str(ROOT.parent / "benchmarks")),
        "LI_AGENT_EXTRA_INSTRUCTION": instruction,
        "LI_AGENT_GOAL": instruction,
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
    if benchmarks:
        cmd.extend(["--benchmarks", benchmarks])

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    log_path = STATE_DIR / f"iter-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.log"
    rc = run_subprocess_streaming(cmd, root, env, log_path)
    recover_unpushed_work(ROOT, root, HTTPD_PR_BRANCH)
    return rc, f"log={log_path} (streamed above)"


def build_instruction(todo: dict) -> str:
    baseline = ""
    if BASELINE.is_file():
        baseline = BASELINE.read_text(encoding="utf-8")[:6000]
    mission = ""
    if os.environ.get("LI_HTTPD_PLAN_CLOSE_SERVER_MILESTONES", "1").strip() not in ("0", "false", "no", "off"):
        mission = """
## Loop mission (server parity — close all pending)

Work through **every pending server milestone** in the plan (`w0`/`w1` → `m0` → `m1*` → `m15*` → `m2*` runtime rows).
**Oracle/config-only is not enough** for `*-runtime` and `m0-ship-gate-full` todos — require running `build/li-httpd`, tier5 bench/exploit vs nginx where cited.
See plan section **Parity milestones (agent-gateway vs nginx oracle)**.
"""
        if todo["id"].startswith("gap-"):
            mission += """
## Gap parity targets (measurable)

- **Security:** every `tier5_http/exploits/*.toml` row passes on **running** `build/li-httpd`; map each exploit to OWASP/CWE in file header; li must be **stricter-or-equal** vs nginx (`[expect]` / `li_stricter`).
- **Performance:** tier5 + Next.js toy scenarios — publish ratios in `benchmarks/results/`; default pass bar **li RPS ≥ 0.85× nginx** and **p99 ≤ 2× nginx** unless documented variant.
- **LB / proxy / streaming:** runtime tests, not config-only; include sticky sessions (`ip_hash` or cookie) where multi-backend Next.js needs affinity.
"""
        if todo["id"].startswith("gap-phase2-"):
            mission += """
## Phase-2 strict nginx oracle (close remaining gaps)

- Run gates with `HTTPD_RUN_PHASE2_GATES=1` after your changes (loop sets this for gap-phase2 todos).
- **Perf:** `check-tier5-perf-wrk-soak.sh` needs wrk+nginx; 30s soak, no `HTTPD_BENCH_SKIP_TIMING`.
- **Mitigations:** every `nginx_mitigations.toml` row must link a real exploit TOML + driver; enable disabled rows when runtime exists.
- **Streaming:** `check-tier5-streaming-soak.sh` with timing, not verify-only.
- Mark plan YAML `status: completed` only when gates pass; push to `cursor/httpd-plan-continue`.
"""
    return f"""# httpd plan iteration — todo `{todo['id']}`

**Plan:** `{PLAN.relative_to(ROOT)}`
**Status in plan frontmatter:** update to `completed` when this todo is fully done.
{mission}
## Current todo
- **id:** {todo['id']}
- **content:** {todo['content']}

## Rules (mandatory)
1. Work only in **lic** on branch `{HTTPD_PR_BRANCH}` (workspace tracks `origin/{HTTPD_PR_BRANCH}`).
2. **Push before you stop:** commit, `git push -u origin {HTTPD_PR_BRANCH}`, open/update PR — never leave work only in a local clone.
3. PR-only — do **not** merge to main yourself.
4. Run `./scripts/httpd-plan-gates.sh` (or `HTTPD_GATES_SKIP_LIC_BUILD=1` for Python-only) before finishing.
5. Release notes per li-release-notes policy when user-visible behavior changes.
6. After tier-5 httpd runtime changes, refresh HTTP bench matrix per `.cursor/rules/li-httpd-bench-matrix.mdc`.

## Live sites (local publish — no GitHub Actions)
When benchmarks or org-visible status change, refresh public Pages from sibling **benchmarks** repo:
```bash
cd ../benchmarks && LIC_ROOT=../lic ./scripts/refresh-live-sites.sh
```
- **Benchmarks dashboard:** ratios vs cpp + hardware banner only (no raw wall times in UI).
- **Development overview:** `roadmap/scripts/regenerate-development-overview-md.py` + deploy.
- Skill: `lic/.cursor/skills/run-local-pages-benchmarks/SKILL.md`
- Use `SKIP_BENCH=1` if no new CSV; still redeploy roadmap snapshot when PR queue changed.

## Baseline record
{baseline}

## Deliverable
- Implement the todo slice with tests.
- Update plan YAML todo status for `{todo['id']}` when done.
- PR URL + test commands + note if live sites were refreshed.
"""


def load_state() -> dict:
    if STATE_FILE.is_file():
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    return {"completed_ids": [], "iterations": 0, "history": []}


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Autonomous li-httpd plan loop")
    parser.add_argument("--max", type=int, default=0, help="Max agent iterations (0 = until done)")
    parser.add_argument("--once", action="store_true", help="Single iteration")
    parser.add_argument("--dry-run", action="store_true", help="No SDK call; print instruction only")
    parser.add_argument("--skip-agent", action="store_true", help="Only run gates")
    parser.add_argument("--repair-state", action="store_true", help="Normalize completed_ids in state.json")
    parser.add_argument("--mark-done", metavar="ID", help="Record todo id completed in state")
    args = parser.parse_args()

    if args.repair_state:
        state = load_state()
        before = list(state.get("completed_ids") or [])
        state = repair_state(state)
        after = list(state.get("completed_ids") or [])
        if not before and not after:
            print("repair-state: state.json already empty — no changes", file=sys.stderr)
            return 1
        save_state(state)
        print(f"repaired state: {len(after)} canonical completed_ids (was {len(before)})")
        return 0

    if args.mark_done:
        state = load_state()
        canon = canonical_todo_id(args.mark_done)
        if canon not in state.setdefault("completed_ids", []):
            state["completed_ids"].append(canon)
        save_state(state)
        print(f"marked done: {canon}")
        return 0

    if not PLAN.is_file():
        print(f"error: plan missing: {PLAN}", file=sys.stderr)
        return 1

    todos = load_plan_todos()
    state = load_state()
    repaired = repair_state(state)
    if repaired["completed_ids"] != state.get("completed_ids"):
        save_state(repaired)
    state = repaired
    pending = [t for t in todos if t["status"] in ("pending", "in_progress")]
    done_count = len([t for t in todos if t["status"] == "completed"])
    print(f"plan todos: {len(todos)} total, {done_count} completed in plan, {len(pending)} open")

    max_iter = 1 if args.once else (args.max or 999)
    iteration = 0
    while iteration < max_iter:
        todo = pick_next(todos, state)
        if not todo:
            print("All actionable todos complete (or none in pending/in_progress).")
            return 0

        print(f"\n=== iteration {iteration + 1}: {todo['id']} ===")
        print(f"    {todo['content']}")

        if todo["id"].startswith("gap-phase2-"):
            os.environ["HTTPD_RUN_PHASE2_GATES"] = "1"
        else:
            os.environ.pop("HTTPD_RUN_PHASE2_GATES", None)

        if not args.dry_run:
            ok, gate_out = run_gates()
            if not ok:
                print("gates: FAIL (agent should fix first)")
                print(gate_out[-2000:])
            else:
                print("gates: OK")
        else:
            ok = True
            print("gates: skipped (--dry-run)")

        if args.skip_agent:
            return 0 if ok else 1

        code, msg = run_cursor_agent(todo, args.dry_run)
        print(msg, flush=True)
        if args.dry_run:
            return 0

        if code != 0:
            state["iterations"] = state.get("iterations", 0) + 1
            state.setdefault("history", []).append(
                {
                    "at": datetime.now(timezone.utc).isoformat(),
                    "todo_id": todo["id"],
                    "agent_exit": code,
                    "gates_ok": False,
                }
            )
            save_state(state)
            print(f"agent exit {code} — stopping loop (fix and re-run)", file=sys.stderr)
            return code

        ok, gate_out = run_gates()
        if not ok:
            print("gates: FAIL after agent (not marking done)", file=sys.stderr)
            print(gate_out[-2000:], file=sys.stderr)
        else:
            print("gates: OK after agent")

        state["iterations"] = state.get("iterations", 0) + 1
        state.setdefault("history", []).append(
            {
                "at": datetime.now(timezone.utc).isoformat(),
                "todo_id": todo["id"],
                "agent_exit": code,
                "gates_ok": ok,
            }
        )
        save_state(state)

        if not ok:
            return 1

        refresh_live_pages()

        tid = canonical_todo_id(todo["id"])
        if tid not in state.setdefault("completed_ids", []):
            state["completed_ids"].append(tid)
            save_state(state)
            print(f"todo {tid}: gates OK — advancing loop (marked done in state.json)", flush=True)
        else:
            print(f"todo {tid}: gates OK (already marked done)", flush=True)

        iteration += 1
        todos = load_plan_todos()

    print("max iterations reached")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
