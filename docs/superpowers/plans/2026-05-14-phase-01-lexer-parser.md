# Phase 1: Lexer + Parser (C++)

**Master plan:** [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) · **Phase index:** [phase-plans-index.md](../../ecosystem/phase-plans-index.md) · **Gaps:** [provability-gaps.md](../../verification/provability-gaps.md)

**Goal:** Tokenize and parse Nim-like Li surface syntax into an AST.

**Architecture:** `compiler/lexer` → `compiler/parser` → `compiler/ast`; diagnostics in `compiler/diagnostics`.

**Tech stack:** C++17

**Exit gate:**
```bash
./scripts/build.sh
LIC=./build/compiler/lic/lic ./li-tests/run_all.sh lexer_parser
```

**CLI:** `lic parse <file.li>`
