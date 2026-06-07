#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${1:-$ROOT/manifest.toml}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "manifest lint: missing file: $MANIFEST" >&2
  exit 2
fi

fail() {
  echo "manifest lint: $*" >&2
  exit 1
}

block=0
seen_suite=0
seen_file=0
seen_outcome=0
seen_expected_substr=0
have_any=0

flush_block() {
  if ((have_any == 0)); then
    return 0
  fi
  if ((seen_suite == 0 || seen_file == 0 || seen_outcome == 0)); then
    fail "block $block missing required key(s): suite=$seen_suite file=$seen_file outcome=$seen_outcome"
  fi
  seen_suite=0
  seen_file=0
  seen_outcome=0
  seen_expected_substr=0
  have_any=0
}

while IFS= read -r line; do
  if [[ "$line" == "[[tests]]" ]]; then
    flush_block
    block=$((block + 1))
    have_any=1
    continue
  fi
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line//[[:space:]]/}" ]] && continue
  if [[ "$line" =~ ^suite\ =\ \" ]]; then
    ((have_any == 0)) && continue
    ((++seen_suite))
    ((seen_suite > 1)) && fail "block $block duplicate key: suite"
  fi
  if [[ "$line" =~ ^file\ =\ \" ]]; then
    ((have_any == 0)) && continue
    ((++seen_file))
    ((seen_file > 1)) && fail "block $block duplicate key: file"
  fi
  if [[ "$line" =~ ^outcome\ =\ \" ]]; then
    ((have_any == 0)) && continue
    ((++seen_outcome))
    ((seen_outcome > 1)) && fail "block $block duplicate key: outcome"
  fi
  if [[ "$line" =~ ^expected_substr\ =\ \" ]]; then
    ((have_any == 0)) && continue
    ((++seen_expected_substr))
    ((seen_expected_substr > 1)) && fail "block $block duplicate key: expected_substr"
  fi
done <"$MANIFEST"
flush_block

# Self-test: the duplicate fixture must be rejected.
if "$0" "$ROOT/tooling/fixtures/manifest_duplicate_outcome.toml" >/dev/null 2>&1; then
  fail "self-test failed: duplicate-outcome fixture was accepted"
fi

echo "manifest lint ok: $(realpath "$MANIFEST")"

