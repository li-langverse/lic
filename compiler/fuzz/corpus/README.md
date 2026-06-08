# Parser fuzz corpus

Seeds for `parse_fuzz` (libFuzzer). Nightly CI merges new inputs here via `scripts/merge_fuzz_corpus.sh`.

HTTP parse fuzz (`http_parse_fuzz`) uses `corpus/http/` — see `scripts/http-parse-fuzz-smoke.sh`.

- Top-level files: coverage seeds (may be binary-ish).
- `regressions/`: minimized crash reproducers from fuzz runs.

Do not commit files larger than 1 MiB.
