# Ecosystem package backlog (gap orchestrator targets)

**Status:** Active  
**Maintained by:** `swarm-gap-apply-actions.py` + `swarm_observer`  
**Handoff:** `issue_planner` / `package_architect` for new `li-*` packages

---

todos:
- id: pkg-std-io
  content: "std.io — PH-IO-4 compile harness (`std/io/io.li`, `import std.io`)"
  status: completed
  gap_orchestrator: true
  gap_ref: gap-missing-std-std-io
- id: pkg-std-csv
  content: "std.csv — PH-IO-4 compile harness (`std/csv/csv.li`, `import std.csv`)"
  status: completed
  gap_orchestrator: true
  gap_ref: gap-missing-std-std-csv
- id: pkg-std-summary
  content: "std.summary — PH-IO-7 compile harness (`std/summary/summary.li`, `import std.summary`)"
  status: completed
  gap_orchestrator: true
  gap_ref: gap-missing-std-std-summary
- id: pkg-std-plot
  content: "std.plot — PH-IO-5 compile harness (`std/plot/plot.li`, `import std.plot`)"
  status: completed
  gap_orchestrator: true
  gap_ref: gap-missing-std-std-plot





- id: pkg-line-profiler
  content: "li-line-profiler — line-level profiling package (seed) — gap orchestrator"
  status: pending
  gap_ref: gap-line-profiler-001

---

## Notes

- Todos are appended or set to `pending` when matching `gap_kind: missing_package` rows exist in the gap registry.
- Do not remove rows manually if a gap is still `open` in `data/swarm-gap-registry/registry.yaml`.
