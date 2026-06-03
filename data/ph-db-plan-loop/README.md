# PH-DB plan loop state

Tracks cross-repo PH-DB sprint progress.

- **Plan loop (supervisor):** `docs/superpowers/plans/2026-06-03-ph-db-plan-loop.md`
- **Canvas:** `docs/superpowers/plans/ph-db-swarm-plan.md`
- **Loop:** `scripts/ph-db-plan-loop.py` · **Gates:** `scripts/ph-db-plan-gates.sh`

- **Production agents** default `LI_CONTROL_PLANE_STORE=lidb` (li-cursor-agents `main`, #105).
- **Plan loops** in `lic/scripts/*-plan-loop*` intentionally use `disk` (no Docker/lidb required in CI).
