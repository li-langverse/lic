# Tests and quality gates

All conformance tests live in **`li-tests/`**. Nothing is scattered under `compiler/` as one-off files.

## Run everything

```bash
./scripts/build.sh
export LIC=./build/compiler/lic/lic
./li-tests/run_all.sh
```

CI shortcut:

```bash
./scripts/ci.sh
```

## Manifest

Every test is listed in `li-tests/manifest.toml` with an expected **outcome**:

| Outcome | Meaning |
|---------|---------|
| `parse_ok` | Parser accepts |
| `parse_fail` | Parser rejects |
| `compile_ok` | Builds (types + policy) |
| `compile_fail` | Must reject with diagnostic |
| `verify_ok` | Full `lic build` + proof path |
| `verify_fail` | Proof must fail |

## Test suites (complete list)

| Suite | What it guards |
|-------|----------------|
| `lexer_parser` | Tokens, indentation, parse errors |
| `typecheck` | Types, numeric traps, index errors |
| `prove_reject` | `Any`, `sorry`, missing contracts |
| `contracts_verify` | Small proved examples |
| `borrow` | `mut` / `imm`, use-after-move |
| `effects` | `raises IO`, `raises Alloc` |
| `race_shared_memory` | Parallel **exploit** programs must fail |
| `simd` | Vector types and lane rules |
| `parallel_codegen` | OpenMP lowering smoke |
| `generics` | PEP 695, `Protocol`, `Callable` |
| `collections` | `list`, `dict`, `tuple`, `enum`, … |
| `runtime` | `extern`, linking |
| `benchmarks` | Tier-0 physics/math correctness |
| `tetris` | Game OOB must fail compile |
| `integration` | Bootstrap compiler build |

## Race exploit suite (security of parallelism)

Files in `li-tests/race_shared_memory/` are **deliberate bugs**:

| File | Attack |
|------|--------|
| `shared_mut_write.li` | All threads write same cell |
| `overlap_par_slice.li` | Overlapping slices |
| `missing_disjoint_clause.li` | No disjoint proof |
| `mut_capture_no_sync.li` | Unsafe capture |
| `borrow_mut_across_iters.li` | `borrow mut` in parallel loop |
| `false_disjoint_proof.li` | Lying proof |

Positive control: `good_disjoint_parallel.li` **must build**.

Run alone:

```bash
./scripts/test_race_reject.sh
```

## Security testing (malformed input)

Separate from manifest — **`li-tests/run_security.sh`**:

- Every file in `li-tests/security/*.li`
- `lic parse` and `lic check` must exit 0 or 1, **never crash** (no signal)
- Generated huge-comment stress

Runs on **every** `scripts/ci.sh` and in the Windows CI job.

Details: [Security audits](security.md).

## Fuzz testing (parser)

**libFuzzer** target: `compiler/fuzz/parse_fuzz`

- Corpus: `compiler/fuzz/corpus/`
- Merge script: `scripts/merge_fuzz_corpus.sh`
- CI: daily [`.github/workflows/fuzz.yml`](https://github.com/cap-jmk-real/li-language/blob/dev/.github/workflows/fuzz.yml) + PR smoke

## Memory / sanitizer (optional CI)

[`.github/workflows/memory.yml`](https://github.com/cap-jmk-real/li-language/blob/dev/.github/workflows/memory.yml):

- Valgrind / ASan smoke on Linux
- Memory profiling scripts under `scripts/profile-memory.sh`

## Benchmark verification

`benchmarks/harness/verify.py` and `stability.py` check physics invariants (energy drift, momentum, …) for C++/Rust/Julia/Li kernels.

## Adding a test

1. Add `something.li` under the right suite folder.
2. Add `[[tests]]` block to `manifest.toml`.
3. For `compile_fail`, set `expected_substr` or add `something.exp`.
4. Run `./li-tests/run_all.sh <suite>`.

See also `li-tests/README.md` in the repository.
