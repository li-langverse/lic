# Numerics research notes (lic)

Agent **`numerics_researcher`** and skill **`research-li-numerics`** deposit SOTA surveys and repro commands here. Each note must cite a **bench id** and a command that produces evidence (see org agent deliverable gate).

## Index

| Date | Bench focus | Doc |
|------|-------------|-----|
| 2026-05-18 | `horner_pure_li` lexer regression | [autoresearch-horner-lexer-2026-05-18.md](autoresearch-horner-lexer-2026-05-18.md) |
| 2026-05-20 | P0 horner DCE + near-limit tier-1/2 | [2026-05-20-researcher-pass.md](2026-05-20-researcher-pass.md) |

## Repro (local)

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
./li-tests/run_all.sh lexer_parser
LIC=build/compiler/lic/lic python3 benchmarks/harness/bench.py --tier 1 --runs 3
./scripts/benchmark-failures-report.sh
```

Dashboard (org ingest, may lag local): https://li-langverse.github.io/benchmarks/
