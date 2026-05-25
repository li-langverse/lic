# Parser fuzz corpus

Seeds for `parse_fuzz` (libFuzzer). Nightly CI merges new inputs here via `scripts/merge_fuzz_corpus.sh`.

- Top-level files: coverage seeds (may be binary-ish).
- `seed_decorators`, `seed_decorator_stack`, `seed_reserved_typosquat` — `@` stacks and reserved/typosquat `decorator def` parse paths (7d exit gate).
- `regressions/`: minimized crash reproducers from fuzz runs.

Do not commit files larger than 1 MiB.
