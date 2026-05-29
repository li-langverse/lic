# Live documentation (org)

<!-- DOC-ecosystem-live-documentation -->

Published handbook and dashboards for the Li org. **Source** may live in one repo; **Pages** may publish from another (see table).

| Site | URL | Source repo | Notes |
|------|-----|-------------|--------|
| **Language handbook** | [li-langverse.github.io/li-language](https://li-langverse.github.io/li-language/) | [`lic`](https://github.com/li-langverse/lic) | Built from `docs/` on **`main`** via [`.github/workflows/docs.yml`](https://github.com/li-langverse/lic/blob/main/.github/workflows/docs.yml); Pages URL is legacy **`li-language`** site name. [`li-language`](https://github.com/li-langverse/li-language) is archived — do not edit handbook there. |
| **Benchmarks dashboard** | [li-langverse.github.io/benchmarks](https://li-langverse.github.io/benchmarks/) | [`benchmarks`](https://github.com/li-langverse/benchmarks) | Tier-1/2 posture; honest labels only |
| **Org development overview** | [li-langverse.github.io/roadmap/development-overview](https://li-langverse.github.io/roadmap/development-overview/) | [`roadmap`](https://github.com/li-langverse/roadmap) | PR queue, branch CI, live-docs smoke |
| **Governance (canonical)** | [roadmap `docs/ecosystem`](https://github.com/li-langverse/roadmap/tree/main/docs/ecosystem) | [`roadmap`](https://github.com/li-langverse/roadmap) | Human merge; mirrored under **Ecosystem** in the handbook |
| **Package handbooks** | [Ecosystem → Package handbooks](overview.md#package-handbooks-live-site) | [`lic`](https://github.com/li-langverse/lic) `docs/ecosystem/` | lip, lit, lis, li-net, li-httpd, li-std-*, li-demo — same **lic** Pages deploy (URLs under `/ecosystem/<repo>/`) |

## Mirror / tooling repos

Official mirrors ship in-repo **`docs/handbook.md`** (see [package mirror template](../../scripts/templates/package-mirror/docs/handbook.md.template)) **and** a published handbook page under **Ecosystem → Package handbooks** after **lic** → **li-language** Pages deploy.

## Agents

- **Honest proof status:** always link [provability gaps](../verification/provability-gaps.md) when describing `lic build` or **G-*** rows.
- **Perf claims:** cite the [benchmarks dashboard](https://li-langverse.github.io/benchmarks/) or `li-tests/` evidence — no dashboard row → no “beats C++” claim.
- **Ecosystem audit:** `benchmarks/scripts/ecosystem-audit.py` treats `lic` handbook as `li-language` Pages and `roadmap` development overview as live docs.
