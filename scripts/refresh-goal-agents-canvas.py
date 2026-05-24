#!/usr/bin/env python3
"""Regenerate goal-directed-agents-live.canvas.tsx from snapshot.json."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SNAP = ROOT / "data/goal-directed-agents/snapshot.json"
CANVAS = Path.home() / ".cursor/projects/home-s4il0r-Documents-Cursor/canvases/goal-directed-agents-live.canvas.tsx"


def todo_status(runner: dict, todo_id: str, plan_status: str) -> str:
    if plan_status == "completed":
        return "completed"
    if runner.get("active_todo_id") == todo_id and runner.get("running"):
        return "in_progress"
    if plan_status == "in_progress":
        return "in_progress"
    return "pending"


def main() -> int:
    if not SNAP.is_file():
        print("refresh-goal-agents-canvas: run goal-directed-agents-snapshot.py first")
        return 1
    s = json.loads(SNAP.read_text(encoding="utf-8"))
    runners = s.get("runners") or []
    httpd = next((r for r in runners if r["id"] == "httpd"), None)

    runner_rows: list[str] = []
    for r in runners:
        done = r.get("plan_completed", 0)
        total = r.get("plan_total", 0)
        status = "running" if r.get("running") else "idle"
        active = r.get("active_todo_id") or (r.get("plan_pending") or ["—"])[0]
        runner_rows.append(
            f'          ["{r["name"]}", "{status}", "{done}/{total}", "{r.get("branch", "")}", "{active}"],'
        )
    runner_table = "\n".join(runner_rows) if runner_rows else '          ["—", "—", "—", "—", "—"],'

    hist_rows: list[str] = []
    for row in s.get("history") or []:
        hist_rows.append(
            f'          ["{row.get("runner", "")}", "{row.get("todo_id", "")}", '
            f'"{row.get("agent_exit", "")}", "{row.get("gates_ok", "")}", "{row.get("at", "")[:19]}"],'
        )
    hist_table = "\n".join(hist_rows) if hist_rows else '          ["—", "—", "—", "—", "—"],'

    gap_todos: list[dict] = []
    if httpd:
        for t in httpd.get("todos") or []:
            st = todo_status(httpd, t["id"], t.get("status", "pending"))
            gap_todos.append(
                {"id": t["id"], "content": t.get("content", "")[:100], "status": st}
            )

    gap_items = ",\n".join(
        f'    {{ id: {json.dumps(t["id"])}, content: {json.dumps(t["content"])}, status: {json.dumps(t["status"])} }}'
        for t in gap_todos
    )
    if not gap_items:
        gap_items = '    { id: "—", content: "No gap todos in snapshot", status: "pending" }'

    activity_parts: list[str] = []
    for r in runners:
        if not r.get("running") and not r.get("activity"):
            continue
        activity_parts.append(r["name"] + ":")
        activity_parts.extend(r.get("activity") or [])
    if not activity_parts:
        activity_parts = ["No active agent log lines."]
    activity_const = ",\n".join(f"  {json.dumps(p)}" for p in activity_parts)

    httpd_done = httpd.get("plan_completed", 0) if httpd else 0
    httpd_total = httpd.get("plan_total", 0) if httpd else 0
    httpd_running = "yes" if httpd and httpd.get("running") else "no"
    httpd_iter = httpd.get("current_iteration", "") if httpd else ""
    running_count = sum(1 for r in runners if r.get("running"))

    content = f'''import {{
  Callout,
  Divider,
  Grid,
  H1,
  H2,
  Stack,
  Stat,
  Table,
  Text,
  TodoListCard,
  UsageBar,
}} from "cursor/canvas";

const GENERATED_AT = {json.dumps(s.get("generated_at", ""))};
const TZ = {json.dumps(s.get("tz", "UTC"))};
const RUNNING_LOOPS = {running_count};
const HTTPD_DONE = {httpd_done};
const HTTPD_TOTAL = {httpd_total};
const HTTPD_RUNNING = {json.dumps(httpd_running)};
const HTTPD_ITERATION = {json.dumps(httpd_iter)};

const RUNNER_ROWS: string[][] = [
{runner_table}
];

const HIST_ROWS: string[][] = [
{hist_table}
];

const GAP_TODOS = [
{gap_items}
] as const;

const ACTIVITY_LINES: string[] = [
{activity_const}
];

export default function GoalDirectedAgentsLive() {{
  const httpdPct =
    HTTPD_TOTAL > 0 ? Math.round((HTTPD_DONE / HTTPD_TOTAL) * 1000) / 10 : 0;

  return (
    <Stack gap={{20}}>
      <Stack gap={{4}}>
        <H1>Goal-directed agents — live</H1>
        <Text tone="secondary" size="small">
          Updated {{GENERATED_AT}} ({{TZ}})
        </Text>
        <Text tone="secondary" size="small">
          Source: lic/data/goal-directed-agents/snapshot.json · live refresh every 15s
          via scripts/agent-canvases-watch.sh
        </Text>
      </Stack>

      <Grid columns={{3}} gap={{12}}>
        <Stat
          value={{`${{RUNNING_LOOPS}}`}}
          label="Loops running"
          tone={{RUNNING_LOOPS > 0 ? "success" : "warning"}}
        />
        <Stat
          value={{`${{HTTPD_DONE}}/${{HTTPD_TOTAL}}`}}
          label="httpd gap todos"
        />
        <Stat
          value={{HTTPD_RUNNING === "yes" ? "active" : "idle"}}
          label="httpd loop"
          tone={{HTTPD_RUNNING === "yes" ? "success" : undefined}}
        />
      </Grid>

      <Callout
        tone={{HTTPD_RUNNING === "yes" ? "info" : "warning"}}
        title={{HTTPD_RUNNING === "yes" ? "Agent working" : "httpd loop idle"}}
      >
        <Text>{{HTTPD_ITERATION || "No iteration line in gap-until-done.log"}}</Text>
      </Callout>

      <UsageBar
        total={{HTTPD_TOTAL}}
        topLeftLabel={{`${{httpdPct}}% gap track complete`}}
        topRightLabel={{`${{HTTPD_TOTAL - HTTPD_DONE}} remaining`}}
        segments={{[{{ id: "done", value: HTTPD_DONE, color: "green" }}]}}
      />

      <TodoListCard todos={{[...GAP_TODOS]}} defaultExpanded />

      <Divider />

      <H2>All plan loops</H2>
      <Table
        headers={{["Loop", "State", "Progress", "Branch", "Active todo"]}}
        rows={{RUNNER_ROWS}}
      />

      <H2>Recent iterations</H2>
      <Table
        headers={{["Loop", "Todo", "Exit", "Gates", "At (UTC)"]}}
        rows={{HIST_ROWS}}
      />

      <Divider />

      <H2>Live log tail</H2>
      <Stack gap={{4}}>
        {{ACTIVITY_LINES.map((line, i) => (
          <Text key={{i}} size="small" tone="secondary">
            {{line}}
          </Text>
        ))}}
      </Stack>
    </Stack>
  );
}}
'''
    CANVAS.parent.mkdir(parents=True, exist_ok=True)
    CANVAS.write_text(content, encoding="utf-8")
    print(f"refresh-goal-agents-canvas: {CANVAS}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
