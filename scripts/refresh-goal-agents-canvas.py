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


def build_panel(runner: dict) -> dict:
    todos_out: list[dict] = []
    for t in runner.get("todos") or []:
        st = todo_status(runner, t["id"], t.get("status", "pending"))
        todos_out.append(
            {
                "id": t["id"],
                "content": (t.get("content") or "")[:120],
                "status": st,
            }
        )
    if not todos_out:
        todos_out = [
            {
                "id": "—",
                "content": "No plan todos in snapshot for this loop",
                "status": "pending",
            }
        ]
    return {
        "id": runner.get("id", ""),
        "name": runner.get("name", ""),
        "branch": runner.get("branch", ""),
        "done": runner.get("plan_completed", 0),
        "total": runner.get("plan_total", 0),
        "running": bool(runner.get("running")),
        "iteration": runner.get("current_iteration") or "",
        "active_todo_id": runner.get("active_todo_id") or "",
        "todos": todos_out,
    }


def main() -> int:
    if not SNAP.is_file():
        print("refresh-goal-agents-canvas: run goal-directed-agents-snapshot.py first")
        return 1
    s = json.loads(SNAP.read_text(encoding="utf-8"))
    runners = s.get("runners") or []
    panels = [build_panel(r) for r in runners]
    if not panels:
        panels = [
            {
                "id": "none",
                "name": "No runners",
                "branch": "",
                "done": 0,
                "total": 0,
                "running": False,
                "iteration": "",
                "active_todo_id": "",
                "todos": [
                    {
                        "id": "—",
                        "content": "Run goal-directed-agents-snapshot.py",
                        "status": "pending",
                    }
                ],
            }
        ]

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

    panel_blocks: list[str] = []
    for p in panels:
        todo_items = ",\n".join(
            f'        {{ id: {json.dumps(t["id"])}, content: {json.dumps(t["content"])}, status: {json.dumps(t["status"])} }}'
            for t in p["todos"]
        )
        panel_blocks.append(
            f"""  {{
    id: {json.dumps(p["id"])},
    name: {json.dumps(p["name"])},
    branch: {json.dumps(p["branch"])},
    done: {p["done"]},
    total: {p["total"]},
    running: {json.dumps(p["running"])},
    iteration: {json.dumps(p["iteration"])},
    activeTodoId: {json.dumps(p["active_todo_id"])},
    todos: [
{todo_items}
    ],
  }}"""
        )
    panels_const = ",\n".join(panel_blocks)

    activity_parts: list[str] = []
    for r in runners:
        if not r.get("running") and not r.get("activity"):
            continue
        activity_parts.append(r["name"] + ":")
        activity_parts.extend(r.get("activity") or [])
    if not activity_parts:
        activity_parts = ["No active agent log lines."]
    activity_const = ",\n".join(f"  {json.dumps(p)}" for p in activity_parts)

    running_count = sum(1 for r in runners if r.get("running"))

    content = f'''import {{
  Callout,
  Divider,
  Grid,
  H1,
  H2,
  IconButton,
  Row,
  Stack,
  Stat,
  Table,
  Text,
  TodoListCard,
  UsageBar,
  useCanvasState,
}} from "cursor/canvas";

const GENERATED_AT = {json.dumps(s.get("generated_at", ""))};
const TZ = {json.dumps(s.get("tz", "UTC"))};
const RUNNING_LOOPS = {running_count};

const RUNNER_ROWS: string[][] = [
{runner_table}
];

const HIST_ROWS: string[][] = [
{hist_table}
];

type AgentPanel = {{
  id: string;
  name: string;
  branch: string;
  done: number;
  total: number;
  running: boolean;
  iteration: string;
  activeTodoId: string;
  todos: ReadonlyArray<{{ id: string; content: string; status: "pending" | "in_progress" | "completed" }}>;
}};

const RUNNER_PANELS: readonly AgentPanel[] = [
{panels_const}
] as const;

const ACTIVITY_LINES: string[] = [
{activity_const}
];

export default function GoalDirectedAgentsLive() {{
  const [agentIndex, setAgentIndex] = useCanvasState("goal-agents-runner-index", 0);
  const safeIndex =
    RUNNER_PANELS.length === 0
      ? 0
      : ((agentIndex % RUNNER_PANELS.length) + RUNNER_PANELS.length) % RUNNER_PANELS.length;
  const panel = RUNNER_PANELS[safeIndex] ?? RUNNER_PANELS[0];
  const pct =
    panel.total > 0 ? Math.round((panel.done / panel.total) * 1000) / 10 : 0;

  const goPrev = () =>
    setAgentIndex((i) =>
      RUNNER_PANELS.length === 0
        ? 0
        : (i - 1 + RUNNER_PANELS.length) % RUNNER_PANELS.length,
    );
  const goNext = () =>
    setAgentIndex((i) =>
      RUNNER_PANELS.length === 0 ? 0 : (i + 1) % RUNNER_PANELS.length,
    );

  return (
    <Stack gap={{20}}>
      <Stack gap={{4}}>
        <H1>Goal-directed agents — live</H1>
        <Text tone="secondary" size="small">
          Updated {{GENERATED_AT}} ({{TZ}})
        </Text>
        <Text tone="secondary" size="small">
          Source: lic/data/goal-directed-agents/snapshot.json · live refresh every 15s
        </Text>
      </Stack>

      <Grid columns={{3}} gap={{12}}>
        <Stat
          value={{`${{RUNNING_LOOPS}}`}}
          label="Loops running"
          tone={{RUNNING_LOOPS > 0 ? "success" : "warning"}}
        />
        <Stat
          value={{`${{panel.done}}/${{panel.total}}`}}
          label={{`${{panel.name}} todos`}}
        />
        <Stat
          value={{panel.running ? "active" : "idle"}}
          label="Selected loop"
          tone={{panel.running ? "success" : undefined}}
        />
      </Grid>

      <Row gap={{12}} style={{{{ alignItems: "center", justifyContent: "space-between" }}}}>
        <Row gap={{8}} style={{{{ alignItems: "center" }}}}>
          <IconButton title="Previous agent" onClick={{goPrev}}>
            ←
          </IconButton>
          <Stack gap={{2}}>
            <Text weight="medium">{{panel.name}}</Text>
            <Text tone="secondary" size="small">
              Agent {{safeIndex + 1}} of {{RUNNER_PANELS.length}} · {{panel.branch}}
            </Text>
          </Stack>
          <IconButton title="Next agent" onClick={{goNext}}>
            →
          </IconButton>
        </Row>
        <Text tone="secondary" size="small">
          Use arrows to switch plan todos
        </Text>
      </Row>

      <Callout
        tone={{panel.running ? "info" : "warning"}}
        title={{panel.running ? "Agent working" : "Loop idle"}}
      >
        <Text>
          {{panel.iteration ||
            (panel.activeTodoId
              ? `Active: ${{panel.activeTodoId}}`
              : "No iteration line in runner log")}}
        </Text>
      </Callout>

      <UsageBar
        total={{panel.total}}
        topLeftLabel={{`${{pct}}% complete (${{panel.name}})`}}
        topRightLabel={{`${{panel.total - panel.done}} remaining`}}
        segments={{[{{ id: "done", value: panel.done, color: "green" }}]}}
      />

      <TodoListCard todos={{[...panel.todos]}} defaultExpanded />

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
