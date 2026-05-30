# Ecosystem package backlog (gap orchestrator targets)

**Status:** Active  
**Maintained by:** `swarm-gap-apply-actions.py` + `swarm_observer`  
**Handoff:** `issue_planner` / `package_architect` for new `li-*` packages

---

todos:
- id: pkg-std-io
  content: "Missing std module std.io"
  status: completed
  gap_orchestrator: true
  gap_ref: gap-missing-std-std-io
  note: "std.io present per ecosystem-explorer 2026-05-26; registry closed orch-r3"
- id: pkg-std-csv
  content: "Missing std module std.csv"
  status: completed
  gap_orchestrator: true
  gap_ref: gap-missing-std-std-csv
  note: "std.csv present per ecosystem-explorer 2026-05-26; registry closed orch-r3"
- id: pkg-std-summary
  content: "Missing std module std.summary"
  status: pending
  gap_orchestrator: true
- id: pkg-std-plot
  content: "Missing std module std.plot"
  status: pending
  gap_orchestrator: true
- id: pkg-line-profiler
  content: "li-line-profiler — line-level profiling package (seed) — gap orchestrator"
  status: pending
  gap_ref: gap-line-profiler-001

---

## Notes

- Todos are appended or set to `pending` when matching `gap_kind: missing_package` rows exist in the gap registry.
- Do not remove rows manually if a gap is still `open` in `data/swarm-gap-registry/registry.yaml`.
