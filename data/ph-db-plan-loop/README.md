# PH-DB plan loop state

Tracks cross-repo PH-DB sprint progress (`docs/superpowers/plans/ph-db-swarm-plan.md`).

- **Production agents** default `LI_CONTROL_PLANE_STORE=lidb` (li-cursor-agents `main`, #105).
- **Plan loops** in `lic/scripts/*-plan-loop*` intentionally use `disk` (no Docker/lidb required in CI).
