#!/usr/bin/env bash
# Phase 8a stub: build all members listed in li.toml [workspace].members
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
WS="${1:-$ROOT/packages/li.toml}"
if [[ ! -f "$WS" ]]; then
  echo "error: workspace file not found: $WS" >&2
  exit 1
fi
members=()
while IFS= read -r name; do
  [[ -n "$name" ]] && members+=("$name")
done < <(grep -oE '"[a-zA-Z0-9_-]+"' "$WS" | tr -d '"' | grep -v '^workspace$' || true)
# drop bare keys that are not package names
filtered=()
for m in "${members[@]}"; do
  [[ "$m" == "members" || "$m" == "path" ]] && continue
  filtered+=("$m")
done
members=("${filtered[@]}")
if [[ ${#members[@]} -eq 0 ]]; then
  echo "workspace: no members (stub ok)"
  exit 0
fi
for m in "${members[@]}"; do
  pkg="$ROOT/packages/$m"
  smoke="$pkg/li-tests/smoke/builds.li"
  if [[ -f "$smoke" ]]; then
    echo "workspace build: $m"
    "$LIC" build "$smoke" -o /dev/null
  fi
done
echo "lic-workspace-build: ok"
