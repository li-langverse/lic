# Agent instructions (Li compiler / `lic`)

1. Read [engineering-standards](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md) — **functionality, security, performance** (strict).
2. Read [vision-and-roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) — governance + milestones.
3. Read `docs/superpowers/plans/2026-05-14-li-master-plan.md` — current **PH-** phase.
4. **PR-only:** feature branch + PR; CI green; **do not self-merge** (see `.cursor/rules/li-pr-only.mdc`).
5. Synced agent-kit: `./scripts/sync-agent-kit.sh` after roadmap `agent-kit/` changes.
6. **std/** = 100% coverage; `lip publish` = ≥80%.
7. Perf status: https://li-langverse.github.io/benchmarks/
8. li-httpd: **`lis`** + [httpd prerequisites](docs/ecosystem/httpd-prerequisites.md).

Skills: `build-li-master-plan`, `create-li-package`, `li-ecosystem-discipline` (in `.cursor/skills/`).
