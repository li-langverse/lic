#!/usr/bin/env bash
# Daily 08:00 operator report — plan progress, UX scores, bench/memory, validity.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a

export TZ="${STUDIO_UI_UX_TZ:-Europe/Berlin}"
DAY="$(date +%Y-%m-%d)"
REPORT_DIR="${ROOT}/docs/reports/studio-ui-ux/daily"
OUT="${REPORT_DIR}/${DAY}.md"
SNAP="${ROOT}/data/studio-ui-ux-plan-loop/daily-snapshot.json"
mkdir -p "$REPORT_DIR" "$(dirname "$SNAP")"

python3 - "$ROOT" "$DAY" "$SNAP" <<'PY' >"$OUT"
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

root = Path(sys.argv[1])
day = sys.argv[2]
snap_path = Path(sys.argv[3])

plan = root / "docs/superpowers/plans/2026-05-24-studio-ui-ux-plan-loop.md"
state_path = root / "data/studio-ui-ux-plan-loop/state.json"
bench_path = root / "data/studio-ui-ux-plan-loop/latest-bench.json"
ux_path = root / "data/studio-ui-ux-plan-loop/latest-ux-assessment.json"

todos_total = todos_done = 0
if plan.is_file():
    import re
    text = plan.read_text()
    todos_total = len(re.findall(r"- id: studio-ux-", text))
    todos_done = len(re.findall(r"status: completed", text))

state = json.loads(state_path.read_text()) if state_path.is_file() else {}
completed = state.get("completed_ids", [])
bench = json.loads(bench_path.read_text()) if bench_path.is_file() else {}
ux = json.loads(ux_path.read_text()) if ux_path.is_file() else {}
history = state.get("history", [])[-8:]

branch = subprocess.run(
    ["git", "-C", str(root), "branch", "--show-current"],
    capture_output=True,
    text=True,
).stdout.strip() or "unknown"
sha = subprocess.run(
    ["git", "-C", str(root), "rev-parse", "--short", "HEAD"],
    capture_output=True,
    text=True,
).stdout.strip() or "unknown"

issue = ""
ti = root / "data/studio-ui-ux-plan-loop/tracking-issue.txt"
if ti.is_file():
    issue = ti.read_text().strip()

snap = {
    "report_date": day,
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "tz": __import__("os").environ.get("TZ", "Europe/Berlin"),
    "branch": branch,
    "head": sha,
    "plan_todos_total": todos_total,
    "plan_todos_completed_yaml": todos_done,
    "state_completed_count": len(completed),
    "state_completed_ids": completed,
    "state_iterations": state.get("iterations", 0),
    "ux_pass": ux.get("pass", False),
    "ux_avg_score": ux.get("avg_score"),
    "ux_min_score": ux.get("min_score"),
    "ux_dimensions": ux.get("dimensions", {}),
    "bench": bench,
    "history": history,
    "tracking_issue": issue,
    "runner_log": "data/studio-ui-ux-plan-loop/runner.log",
}
snap_path.write_text(json.dumps(snap, indent=2) + "\n")

lines = [
    f"# Studio UI/UX — daily report {day}",
    "",
    f"_Generated {snap['generated_at']} ({snap['tz']})_",
    "",
    "## Summary",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    f"| Plan todos (state) | **{len(completed)}** completed ids |",
    f"| Iterations run | **{state.get('iterations', 0)}** |",
    f"| UX gate pass | **{ux.get('pass', False)}** |",
    f"| UX avg / min | {ux.get('avg_score', '—')} / {ux.get('min_score', '—')} |",
    f"| Branch | `{branch}` |",
    f"| HEAD | `{sha}` |",
    f"| Tracking issue | {('#' + issue) if issue else '—'} |",
    "",
    "## Last iterations",
    "",
]
if history:
    for row in history:
        lines.append(
            f"- {row.get('at', '')}: `{row.get('todo_id', '')}` "
            f"agent={row.get('agent_exit')} gates={row.get('gates_ok')} ux={row.get('ux_pass')}"
        )
else:
    lines.append("_No history in state.json yet._")

lines.extend(["", "## Bench (latest)", "", "```json", json.dumps(bench, indent=2)[:5000], "```", ""])
lines.extend(["", "## UX dimensions", ""])
dims = ux.get("dimensions") or {}
if dims:
    lines.append("| ID | Score |")
    lines.append("|----|------:|")
    for k, v in sorted(dims.items()):
        sc = v.get("score", v) if isinstance(v, dict) else v
        lines.append(f"| {k} | {sc} |")
else:
    lines.append("_No latest-ux-assessment.json_")

lines.extend([
    "",
    "## Canvas",
    "",
    "Open `canvases/studio-ui-ux-daily-report.canvas.tsx` in Cursor (refreshed by cron).",
    "",
    "## Gates per iteration",
    "",
    "| Gate | Script |",
    "|------|--------|",
    "| Design system | `studio-ui-ux-generate-design-system.sh` |",
    "| Validity + build | `studio-ui-ux-plan-gates.sh` |",
    "| Perf / memory | `bench-studio-viewport-perf.sh`, `profile-animate-memory.sh` |",
    "| Capture | `studio-ui-ux-capture-progress.sh` |",
    "| Publish | `studio-ui-ux-commit-push.sh` |",
    "",
])
print("\n".join(lines))
PY

cp -f "$OUT" "${REPORT_DIR}/LATEST.md"
echo "studio-ui-ux-daily-report: $OUT"

# Refresh Cursor canvas from snapshot
if [[ -x "${ROOT}/scripts/studio-ui-ux-refresh-canvas.py" ]]; then
  python3 "${ROOT}/scripts/studio-ui-ux-refresh-canvas.py" || true
fi

echo "$(date -Iseconds) daily completed=${SNAP}" >> "${ROOT}/data/studio-ui-ux-plan-loop/daily.log" 2>/dev/null || true
