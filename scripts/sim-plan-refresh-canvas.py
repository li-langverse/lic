#!/usr/bin/env python3
"""Regenerate sim-plan-daily-report.canvas.tsx from daily-snapshot.json."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SNAP = ROOT / "data/sim-plan-loop/daily-snapshot.json"
CANVAS = Path.home() / ".cursor/projects/home-s4il0r-Documents-Cursor/canvases/sim-plan-daily-report.canvas.tsx"


def main() -> int:
    if not SNAP.is_file():
        print("sim-plan-refresh-canvas: no snapshot — run sim-plan-write-snapshot.py first")
        return 1
    s = json.loads(SNAP.read_text(encoding="utf-8"))
    families = s.get("families") or []
    impl = s.get("impl_by_family") or {}
    rem = s.get("rem_by_family") or {}
    impl_series = ", ".join(str(impl.get(f, 0)) for f in families)
    rem_series = ", ".join(str(rem.get(f, 0)) for f in families)
    fam_const = ", ".join(json.dumps(f) for f in families)

    perf_rows = []
    for row in s.get("perf_rows") or []:
        perf_rows.append(
            f'          [{", ".join(json.dumps(c) for c in row)}],'
        )
    perf_str = "\n".join(perf_rows) if perf_rows else '          ["—", "—", "—", "—", "—"],'

    hist = s.get("history") or []
    hist_rows = []
    for row in hist:
        line = (
            f"{str(row.get('at', ''))[:19]}: {row.get('todo_id', '')} "
            f"exit={row.get('agent_exit')} gates={row.get('gates_ok')}"
        )
        hist_rows.append(f"          [{json.dumps(line)}, {json.dumps(str(row.get('agent_exit', '')))}, "
                         f"{json.dumps(str(row.get('gates_ok', '')))}, {json.dumps(str(row.get('at', ''))[:19])}],")
    hist_str = "\n".join(hist_rows) if hist_rows else '          ["—", "—", "—", "—"],'
    hist_section = """      <Table
        headers={["When", "Exit", "Gates", "At"]}
        rows={HIST_ROWS}
      />""" if hist_rows else """      <Text tone="secondary">
        No entries in data/sim-plan-loop/state.json yet. See runner.log for live iterations.
      </Text>"""

    running = s.get("running")
    callout_tone = "info" if running else "warning"
    callout_title = "Goal-directed loop active" if running else "Loop idle"
    total = int(s.get("total_algos") or 0)
    implemented = int(s.get("implemented") or 0)
    remaining = int(s.get("remaining") or max(0, total - implemented))

    content = f'''import {{
  BarChart,
  Callout,
  Divider,
  Grid,
  H1,
  H2,
  PieChart,
  Stack,
  Stat,
  Table,
  Text,
  UsageBar,
}} from "cursor/canvas";

const REPORT_DATE = {json.dumps(s.get("report_date", ""))};
const GENERATED_AT = {json.dumps(s.get("generated_at", ""))} ({json.dumps(s.get("tz", ""))});
const BRANCH = {json.dumps(s.get("branch", ""))};
const HEAD = {json.dumps(s.get("head", ""))};
const TOTAL_ALGOS = {total};
const IMPLEMENTED = {implemented};
const REMAINING = {remaining};
const PCT = TOTAL_ALGOS > 0 ? Math.round((IMPLEMENTED / TOTAL_ALGOS) * 1000) / 10 : 0;
const LOOP_RUNNING = {json.dumps("yes" if running else "no")};

const FAMILIES = [{fam_const}] as const;

const IMPL_BY_FAMILY: Record<string, number> = {{
{chr(10).join(f'  {json.dumps(k)}: {v},' for k, v in impl.items() if v)}
}};

const REM_BY_FAMILY: Record<string, number> = {{
{chr(10).join(f'  {json.dumps(k)}: {v},' for k, v in rem.items() if v)}
}};

const PERF_ROWS: string[][] = [
{perf_str}
];

const HIST_ROWS: string[][] = [
{hist_str}
];

export default function SimPlanDailyReport() {{
  const implSeries = FAMILIES.map((f) => IMPL_BY_FAMILY[f] ?? 0);
  const remSeries = FAMILIES.map((f) => REM_BY_FAMILY[f] ?? 0);

  return (
    <Stack gap={{20}}>
      <Stack gap={{4}}>
        <H1>Sim plan — live report</H1>
        <Text tone="secondary" size="small">
          {{REPORT_DATE}} · generated {{GENERATED_AT}}
        </Text>
        <Text tone="secondary" size="small">
          Source: benchmarks/competitive/algo_registry.json · refreshed every 15s
          via scripts/agent-canvases-watch.sh
        </Text>
      </Stack>

      <Grid columns={{4}} gap={{12}}>
        <Stat value={{`${{IMPLEMENTED}}`}} label="Smokes implemented" tone="success" />
        <Stat value={{`${{REMAINING}}`}} label="Remaining" tone="warning" />
        <Stat value={{`${{PCT}}%`}} label="Registry coverage" />
        <Stat value={{LOOP_RUNNING === "yes" ? "active" : "idle"}} label="Loop" />
      </Grid>

      <UsageBar
        total={{TOTAL_ALGOS}}
        topLeftLabel={{`${{PCT}}% implemented (${{IMPLEMENTED}} / ${{TOTAL_ALGOS}})`}}
        topRightLabel={{`${{REMAINING}} algos without smoke`}}
        segments={{[{{ id: "done", value: IMPLEMENTED, color: "green" }}]}}
      />

      <Grid columns={{2}} gap={{16}}>
        <Stack gap={{8}}>
          <H2>Registry completion</H2>
          <PieChart
            size={{200}}
            donut
            data={{[
              {{ label: "implemented_smoke", value: IMPLEMENTED, tone: "success" }},
              {{ label: "stub / pending", value: REMAINING, tone: "neutral" }},
            ]}}
          />
        </Stack>

        <Stack gap={{8}}>
          <H2>By family</H2>
          <BarChart
            categories={{[...FAMILIES]}}
            series={{[
              {{ name: "implemented_smoke", data: implSeries, tone: "success" }},
              {{ name: "remaining", data: remSeries, tone: "warning" }},
            ]}}
            stacked
            horizontal
            height={{220}}
            valueSuffix=" algos"
          />
        </Stack>
      </Grid>

      <Divider />

      <H2>Autonomous runner</H2>
      <Callout tone="{callout_tone}" title="{callout_title}">
        <Stack gap={{6}}>
          <Text>
            sim-plan-run-until-done.sh on branch {{BRANCH}} (HEAD {{HEAD}}).
          </Text>
          <Text tone="secondary" size="small">
            Log: data/sim-plan-loop/runner.log
          </Text>
        </Stack>
      </Callout>

      <H2>Last iterations</H2>
{hist_section}

      <Divider />

      <H2>Performance (scoped latest.csv)</H2>
      <Table
        headers={{["Benchmark", "Lang", "Metric", "Value", "Unit"]}}
        rows={{PERF_ROWS}}
      />

      <Divider />

      <H2>Gate checklist (per iteration)</H2>
      <Table
        headers={{["Gate", "Tool"]}}
        rows={{[
          ["Validity", "bench_sim.py + validate-sim-summary.sh"],
          ["Performance", "bench-package.sh --timing"],
          ["Memory", "sim-bench-memory.sh (peak RSS)"],
          ["Docs", "sim-plan-iteration-report.py"],
          ["Publish", "sim-plan-commit-push.sh"],
        ]}}
      />
    </Stack>
  );
}}
'''
    CANVAS.parent.mkdir(parents=True, exist_ok=True)
    CANVAS.write_text(content, encoding="utf-8")
    print(f"sim-plan-refresh-canvas: {CANVAS}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
