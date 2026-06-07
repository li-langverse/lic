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
        "agent_live": bool(runner.get("agent_live")),
        "agent": runner.get("agent") or "",
        "goal_file": runner.get("goal_file") or "",
        "status_note": runner.get("status_note") or "",
        "log_age_sec": runner.get("log_age_sec"),
        "last_state_at": (runner.get("last_state_at") or "")[:19],
        "state_iterations": runner.get("state_iterations", 0),
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
        sup = "up" if r.get("running") else "off"
        ag = "live" if r.get("agent_live") else "—"
        log_a = str(r.get("log_age_sec")) if r.get("log_age_sec") is not None else "—"
        active = r.get("active_todo_id") or (r.get("plan_pending") or ["—"])[0]
        note = (r.get("status_note") or "")[:40]
        runner_rows.append(
            f'          ["{r["name"]}", "{sup}", "{ag}", "{done}/{total}", "{log_a}s", "{active}", "{note}"],'
        )
    runner_table = "\n".join(runner_rows) if runner_rows else '          ["—", "—", "—", "—", "—", "—", "—"],'

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
    agentLive: {json.dumps(p["agent_live"])},
    agent: {json.dumps(p["agent"])},
    goalFile: {json.dumps(p["goal_file"])},
    statusNote: {json.dumps(p["status_note"])},
    logAgeSec: {json.dumps(p["log_age_sec"])},
    lastStateAt: {json.dumps(p["last_state_at"])},
    stateIterations: {p["state_iterations"]},
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
        activity_parts.append(f"{r['name']}: {r.get('status_note', '—')}")
        if r.get("agent_live") and r.get("goal_file"):
            activity_parts.append(f"  goal: {r.get('goal_file')}")
        if r.get("last_state_at"):
            activity_parts.append(
                f"  last state: {r.get('last_state_at', '')[:19]} todo={r.get('last_state_todo', '')} "
                f"gates={r.get('last_state_gates', '')}"
            )
        for line in r.get("activity") or []:
            activity_parts.append(f"  {line}")
    if not activity_parts:
        activity_parts = ["No runner status."]
    activity_const = ",\n".join(f"  {json.dumps(p)}" for p in activity_parts)

    running_count = sum(1 for r in runners if r.get("running"))
    agents_live = int(s.get("agents_live", sum(1 for r in runners if r.get("agent_live"))))

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
const AGENTS_LIVE = {agents_live};

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
    agentLive: boolean;
    agent: string;
    goalFile: string;
    statusNote: string;
    logAgeSec: number | null;
    lastStateAt: string;
    stateIterations: number;
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

      <Grid columns={{4}} gap={{12}}>
        <Stat
          value={{`${{AGENTS_LIVE}}`}}
          label="Agents coding now"
          tone={{AGENTS_LIVE > 0 ? "success" : "warning"}}
        />
        <Stat
          value={{`${{RUNNING_LOOPS}}/${{RUNNER_PANELS.length}}`}}
          label="Supervisors up"
        />
        <Stat
          value={{`${{panel.done}}/${{panel.total}}`}}
          label={{`${{panel.name}} todos`}}
        />
        <Stat
          value={{panel.logAgeSec !== null ? `${{panel.logAgeSec}}s` : "—"}}
          label="Log age (selected)"
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
        tone={{panel.agentLive ? "info" : panel.running ? "warning" : "warning"}}
        title={{panel.agentLive ? "Agent coding" : panel.running ? "Supervisor only" : "Loop idle"}}
      >
        <Stack gap={{6}}>
          <Text>{{panel.statusNote}}</Text>
          <Text tone="secondary" size="small">
            {{panel.iteration ||
              (panel.activeTodoId ? `Active todo: ${{panel.activeTodoId}}` : "No iteration line")}}
          </Text>
          {{panel.agentLive ? (
            <Text tone="secondary" size="small">
              {{panel.agent}} · {{panel.goalFile}}
            </Text>
          ) : null}}
          <Text tone="secondary" size="small">
            State iterations: {{panel.stateIterations}}
            {{panel.lastStateAt ? ` · last event ${{panel.lastStateAt}}` : ""}}
          </Text>
        </Stack>
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
        headers={{["Loop", "Supervisor", "Agent", "Progress", "Log", "Active todo", "Status"]}}
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
