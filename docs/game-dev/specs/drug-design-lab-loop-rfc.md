# RFC: AI drug design — Lab-in-the-Loop (PH-DRUG)

**Status:** Draft  
**Track:** PH-DRUG  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Drug discovery loops need hypothesis → generate → **QM** → lab ingest → retrain with an adaptive UI, not static forms.

## Proposal

| Layer | Package / API |
|-------|----------------|
| Workflow stages | `li-sim-drug-design` — `lab_loop_*` |
| QM | `li-chem` — `dft_run_*`, `tddft_run_stub` |
| Adaptive UI | `li-studio` — `studio_adaptive_panel_for_stage` |
| Agents | MCP `engine_chem_stub` (see [agent-mcp-sketch.md](../agent-mcp-sketch.md)) |

Roche Lab-in-the-Loop–class: stage-gated panels, audit on CRITICAL exports.

## Phases

DRUG-0 stubs → DRUG-1 real `chem.dft` backend → DRUG-2 LIMS ingest (trusted).

**Extension:** [competitive-bioengineering-rfc.md](competitive-bioengineering-rfc.md) (PH-BIOENG) — DBTL stages on this spine.

## Compliance

`li-chem` + `li-sim-drug-design` — CRITICAL tier; model cards (PH-COMPLY).
