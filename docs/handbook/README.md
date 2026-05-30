# Li handbook index (in-repo)

Canonical **language** handbook is published from [li-language](https://github.com/li-langverse/li-language) → [li-langverse.github.io/li-language](https://li-langverse.github.io/li-language/). This tree under `lic/docs/` is the **compiler + verification** source of truth until submodule wiring completes; edit [lic-docs](https://github.com/li-langverse/lic-docs) for user-facing Pages when split.

## Start here

| I want to… | Doc |
|------------|-----|
| Install and first build | [Getting started](../guide/getting-started-tools.md) |
| Language surface (honest status) | [Language overview](../language/overview.md) |
| What `lic build` proves **today** | [Provability gaps](../verification/provability-gaps.md) |
| PH order and repo policy | [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) |
| Map plans ↔ gaps ↔ benchmarks | [Plan cross-links](../ecosystem/plan-cross-links.md) |
| Org vision (human merge) | [Vision & roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| Perf dashboard (not proof) | [Benchmarks](https://li-langverse.github.io/benchmarks/) |

## Satellite package handbooks (GitHub Pages)

Deploy-pending until each repo merges `site/` + `.github/workflows/pages.yml` to `main`:

| Repo | Live URL (after deploy) | In-repo handbook |
|------|-------------------------|------------------|
| lip | https://li-langverse.github.io/lip/ | [lip/docs/handbook.md](https://github.com/li-langverse/lip/blob/main/docs/handbook.md) |
| lit | https://li-langverse.github.io/lit/ | [lit/docs/handbook.md](https://github.com/li-langverse/lit/blob/main/docs/handbook.md) |
| lis | https://li-langverse.github.io/lis/ | [lis/docs/handbook.md](https://github.com/li-langverse/lis/blob/main/docs/handbook.md) |
| li-net | https://li-langverse.github.io/li-net/ | [li-net/docs/handbook.md](https://github.com/li-langverse/li-net/blob/main/docs/handbook.md) |
| li-httpd | https://li-langverse.github.io/li-httpd/ | [li-httpd/docs/handbook.md](https://github.com/li-langverse/li-httpd/blob/main/docs/handbook.md) |
| li-std-core | https://li-langverse.github.io/li-std-core/ | [li-std-core/docs/handbook.md](https://github.com/li-langverse/li-std-core/blob/main/docs/handbook.md) |
| li-std-math | https://li-langverse.github.io/li-std-math/ | [li-std-math/docs/handbook.md](https://github.com/li-langverse/li-std-math/blob/main/docs/handbook.md) |
| li-demo | https://li-langverse.github.io/li-demo/ | [li-demo/docs/handbook.md](https://github.com/li-langverse/li-demo/blob/main/docs/handbook.md) |

## Honesty

- Benchmark green ≠ **G-*** Done — cite `li-tests`, Lean, or VC evidence in [provability-gaps](../verification/provability-gaps.md).
- Engineering standards: [roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md).
