#!/usr/bin/env bash
# Publish all 12 li-physics-* org mirrors from the lic monorepo.
# Usage: ./scripts/push-physics-mirrors.sh [--create] [--dry-run]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CREATE=0
DRY=0
for arg in "$@"; do
  case "$arg" in
    --create) CREATE=1 ;;
    --dry-run) DRY=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

PKGS=(
  li-physics-core
  li-physics-rigid
  li-physics-runtime
  li-physics-particles
  li-physics-fluids
  li-physics-weather
  li-physics-aero
  li-physics-chem
  li-physics-em
  li-physics-quantum
  li-physics-relativity
  li-physics-hep
)

for pkg in "${PKGS[@]}"; do
  args=()
  [[ "$CREATE" -eq 1 ]] && args+=(--create)
  [[ "$DRY" -eq 1 ]] && args+=(--dry-run)
  echo "==> $pkg"
  "$ROOT/scripts/push-official-package-repo.sh" "$pkg" "${args[@]}"
done

echo "push-physics-mirrors: ok (${#PKGS[@]} packages)"
