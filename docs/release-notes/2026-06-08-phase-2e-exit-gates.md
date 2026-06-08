# Release notes: Phase 2e explicit exit gates (G-vc partial)

## Summary

Documents **Phase 2e v1** exit criteria and wires a composite CI gate so **G-vc** partial completion is measurable — not aspirational plan text.

## Agent continuation

1. **Read** [2026-05-14-phase-02e-contracts.md](../superpowers/plans/2026-05-14-phase-02e-contracts.md) and **G-vc** in [provability-gaps.md](../verification/provability-gaps.md).
2. **Run** `cmake --build build && ./scripts/check-phase-2e-gates.sh`.
3. **Then** close **2e-d** (float opaque ensures, loop vs closed-form) before **G-vc** → **Done** — overlaps **2f** / **G-lean**.

## Changed

| Path | Change |
|------|--------|
| `docs/superpowers/plans/2026-05-14-phase-02e-contracts.md` | New phase plan: sub-phases **2e-a…d**, v1 exit vs Done |
| `scripts/check-phase-2e-gates.sh` | Composite gate: `vc_emit_contracts`, `mir_vc_witness`, `contracts_discharge_corpus` |
| `scripts/check-master-plan-gates.sh` | Invoke `check-phase-2e-gates.sh`; fix missing `mir_vc_witness.sh` run |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | Tracker row cites explicit 2e v1 exit gates |
| `docs/verification/provability-gaps.md` | **G-vc** row — exit gate evidence + phase plan link |
| `docs/ecosystem/plan-cross-links.md` | Index **PH-2e** plan |

## Not changed

- **G-vc** status — still **Partial** (2e-d open).
- Compiler VC emit logic — documentation + CI wiring only.
- Default `lic build` open-VC policy.

## Breaking

N/A — additive docs and gate script.
