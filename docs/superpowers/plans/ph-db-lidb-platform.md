# Li data platform (PH-DB-0 … PH-DB-10)

**Status:** Roadmap-tracked; runtime not in **`lic`**.  
**Canonical ADR:** [lidb-li-data-platform](https://github.com/li-langverse/roadmap/blob/main/proposals/lidb-li-data-platform.md)  
**Research (PH-DB-G0):** [lidb-multi-model-gpu-research](https://github.com/li-langverse/roadmap/blob/main/proposals/lidb-multi-model-gpu-research.md)  
**Ecosystem copy:** [vision-and-roadmap § PH-DB](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md#li-data-platform-ph-db-0--ph-db-10) · **PKG-lidb:** [official-packages](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/official-packages.md)

**Cross-phase dependency (lip):** **`PH-8d-v2`** (remote registry, full trust store) **depends on `PH-DB-4`** (registry v2 central DB on `lidb`). Do not ship **8d v2** until PH-DB-4 exit gate is met.

```mermaid
flowchart LR
  lip8d["PH-8d-v2 lip registry v2"]
  phdb4["PH-DB-4 central registry DB"]
  lip8d --> phdb4
```

## Phase table

| Phase | ID | Depends |
|-------|-----|---------|
| 0 | **PH-DB-0** | — |
| 1 | **PH-DB-1** | PH-DB-0; human: create `li-langverse/lidb` |
| 2 | **PH-DB-2** | PH-DB-1 |
| 3 | **PH-DB-3** | PH-DB-1 |
| 4 | **PH-DB-4** | PH-DB-1–3, lip OpenAPI; **blocks PH-8d-v2** |
| 5 | **PH-DB-5** | PH-DB-4 |
| 6 | **PH-DB-6** | PH-DB-4 |
| 7 | **PH-DB-7** | PH-DB-4 |
| 8 | **PH-DB-8** | PH-DB-1 |
| 9 | **PH-DB-9** | PH-DB-4 |
| 10 | **PH-DB-10** | PH-DB-4 |

Deliverable detail (WAL, `liorm`, `lis db`, bench evidence) lives in the roadmap ADR — this file is the **lic master-plan cross-link** only.

## Repo home

| Trigger | Org repo | Agent rule |
|---------|----------|------------|
| **PH-DB-1** | [`lidb`](https://github.com/li-langverse/lidb) (*proposed*) | Ask human to create repo before engine work; supervisor stays in **`lis`** |

**Benchmark evidence:** [`tier_db_registry`](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/tier-db-registry-benchmark.md) — see [benchmark tier index](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/benchmark-tier-index.md).
