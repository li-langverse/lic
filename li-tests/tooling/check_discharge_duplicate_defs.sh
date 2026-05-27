#!/usr/bin/env bash
# G-lean / codegen↔Lean drift: Discharge.lean must not declare the same def twice.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$ROOT/docs/semantics/Discharge.lean"
mapfile -t names < <(grep -E '^def [A-Za-z0-9_]+' "$FILE" | sed -E 's/^def ([A-Za-z0-9_]+).*/\1/')
declare -A seen=()
dups=()
for n in "${names[@]}"; do
  if [[ -n "${seen[$n]:-}" ]]; then
    dups+=("$n")
  else
    seen[$n]=1
  fi
done
if ((${#dups[@]} > 0)); then
  printf 'check_discharge_duplicate_defs: duplicate def(s) in %s:\n' "$FILE" >&2
  printf '  %s\n' "${dups[@]}" >&2
  exit 1
fi
echo "check_discharge_duplicate_defs: ok (${#names[@]} defs, no duplicates)"
