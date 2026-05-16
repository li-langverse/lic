# Security audits

Li treats **compiler robustness** and **parallel safety** as security properties.

## 1. Malformed input (no crashes)

**Goal:** Attacker-controlled `.li` text must not crash `lic`.

**Harness:** `li-tests/run_security.sh`

| Input | Expectation |
|-------|-------------|
| `empty.li` | Clean exit |
| `deep_indent.li` | Clean exit |
| `many_tokens.li` | Clean exit |
| `unclosed_paren.li` | Clean exit |
| `unclosed_string.li` | Clean exit |
| `nested_parens.li` | Clean exit |
| `truncated_proc.li` | Clean exit |
| Huge comment (generated) | Clean exit |

**Rule:** exit code 0 or 1 only — never signal (segfault, abort).

**CI:** every `scripts/ci.sh` on Linux/macOS; Windows job runs the same harness.

## 2. Parser fuzzing (continuous)

**Tool:** `parse_fuzz` (libFuzzer + Clang)

**Workflow:** `.github/workflows/fuzz.yml`

| Trigger | Work |
|---------|------|
| Pull request | 5000 runs, parser paths |
| Daily cron | Longer budget, corpus merge |
| Manual | `workflow_dispatch` |

**Corpus learning:**

1. Download prior `fuzz-corpus` artifact.
2. Run fuzz with crash artifacts saved.
3. `scripts/merge_fuzz_corpus.sh` dedupes and adds `regressions/`.
4. Bot opens PR with new seeds (on `main` schedule).

## 3. Parallel race exploits

**Goal:** Unsafe shared memory must **not compile**.

**Harness:** `li-tests/race_shared_memory/` + `manifest.toml`

Documented in [Tests overview](overview.md#race-exploit-suite-security-of-parallelism).

## 4. Policy gate (forbidden constructs)

`compiler/types/policy.cpp` rejects:

- `Any`
- Obvious parallel anti-patterns (shared slot writes, missing disjoint, …)

This complements Lean, not replaces it.

## 5. Memory CI (Linux)

`scripts/memory-ci.sh`:

- Security corpus again
- RSS profiling
- ASan build of MD kernel / `lic` when available

## 6. What we do not claim yet

| Gap | Status |
|-----|--------|
| Full `lic check` fuzzing | Parser only today |
| Formal proof of C++ compiler | Roadmap |
| Side-channel freedom | Out of scope |
| Supply-chain attestation | Standard open-source practice |

## Reporting issues

Open a GitHub issue with:

- Input file (minimal)
- `lic` version / commit
- Expected vs actual (crash vs diagnostic)

For security-sensitive reports, follow responsible disclosure in the repository’s security policy when published.
