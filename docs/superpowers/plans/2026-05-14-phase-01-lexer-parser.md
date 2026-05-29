# Phase 1: Lexer + Parser (C++)

**Honest proof status:** [Provability gaps](../../verification/provability-gaps.md) · [Master plan](2026-05-14-li-master-plan.md)

**Goal:** Tokenize and parse Nim-like Li surface syntax into an AST.

**Architecture:** `compiler/lexer` → `compiler/parser` → `compiler/ast`; diagnostics in `compiler/diagnostics`.

**Tech stack:** C++17

**Exit gate:**
```bash
./scripts/build.sh
LIC=./build/compiler/lic/lic ./li-tests/run_all.sh lexer_parser
```

**CLI:** `lic parse <file.li>`
