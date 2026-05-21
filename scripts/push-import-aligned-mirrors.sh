#!/usr/bin/env bash
# Push World Studio / engine packages to GitHub repos named like imports.
# Usage: ./scripts/push-import-aligned-mirrors.sh [--create] [--dry-run]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CREATE=0
DRY=0
for arg in "$@"; do
  case "$arg" in
    --create) CREATE=1 ;;
    --dry-run) DRY=1 ;;
  esac
done

# Folder names under packages/ after align-package-repo-names.py --apply
PKGS=(
  studio
  studio.ai
  world
  sim
  sim.scientific
  sim.automotive
  sim.robotics
  sim.drug_design
  sim.additive
  render
  ui
  mmo
  store.realtime
  net.httpd
  physics.custom
  physics.runtime
)

for name in "${PKGS[@]}"; do
  if [[ ! -d "$ROOT/packages/$name" ]]; then
    echo "skip (no folder): packages/$name" >&2
    continue
  fi
  echo "=== $name ==="
  extra=()
  [[ "$CREATE" -eq 1 ]] && extra+=(--create)
  [[ "$DRY" -eq 1 ]] && extra+=(--dry-run)
  "$ROOT/scripts/push-official-package-repo.sh" "$name" "${extra[@]}" || true
done

echo "Done. Repos use import paths (studio, studio.ai, …)."
