# lit — test runner & coverage gate

<!-- DOC-ecosystem-lit -->

**Repository:** [`li-langverse/lit`](https://github.com/li-langverse/lit) · **Package id:** `PKG-lit`

**lit** runs package tests and enforces **≥ 80%** line coverage (CLI v1). Implementation and bootstrap scripts live in the [**lip**](https://github.com/li-langverse/lip) repo layout; **lit** tracks the subtree + dedicated CI.

## Status

| Area | Status |
|------|--------|
| Bootstrap / CI | In place — see [lip](lip.md) combined workflow |
| `lit test` / coverage | **Partial** — commands planned; see [package manager plan](../superpowers/plans/2026-05-16-li-package-manager-lip.md) |
| Publish gate | Required with **lip** publish: `lic build` + **lit** coverage |

## Quick start

```bash
cd ../lic && ./scripts/build.sh
cd ../lit && ./scripts/ci.sh
```

## In-repo docs

| Doc | Topic |
|-----|--------|
| [lip/docs/lit.md](https://github.com/li-langverse/lip/blob/main/docs/lit.md) | User-facing lit reference |
| [lit/docs/handbook.md](https://github.com/li-langverse/lit/blob/main/docs/handbook.md) | Cross-links |

## Cross-links

| Doc | Role |
|-----|------|
| [lip](lip.md) | Package manager + shared bootstrap |
| [Provability gaps](../verification/provability-gaps.md) | Proof certificate vs `lic check` |
| [Engineering standards](engineering-standards.md) | Coverage thresholds |
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | PH-8 ecosystem |
