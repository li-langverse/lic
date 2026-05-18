#!/usr/bin/env bash
# Ensure every official package under packages/ has .github/workflows/ci.yml.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/scripts/templates/github-repo/ci.yml"
FAIL=0
FIXED=0

if [[ ! -f "$TPL" ]]; then
  echo "error: missing template $TPL" >&2
  exit 1
fi

for pkg in "$ROOT/packages"/*/; do
  [[ -d "$pkg" ]] || continue
  name="$(basename "$pkg")"
  [[ "$name" == "li.toml" ]] && continue
  dest="$pkg/.github/workflows/ci.yml"
  if [[ -f "$dest" ]]; then
    echo "OK   $name ci.yml"
  else
    echo "ADD  $name ci.yml"
    mkdir -p "$(dirname "$dest")"
    cp "$TPL" "$dest"
    FIXED=$((FIXED + 1))
  fi
  if [[ ! -f "$pkg/.github/workflows/ecosystem-upstream.yml" ]]; then
    gh_src="$ROOT/scripts/templates/github-repo/ecosystem-upstream.yml"
    if [[ -f "$gh_src" ]]; then
      mkdir -p "$pkg/.github/workflows"
      cp "$gh_src" "$pkg/.github/workflows/ecosystem-upstream.yml"
      FIXED=$((FIXED + 1))
    fi
  fi
  sec_dest="$pkg/.github/workflows/security-gate.yml"
  sec_tpl="$ROOT/scripts/templates/github-repo/security-gate.yml"
  if [[ -f "$sec_tpl" && ! -f "$sec_dest" ]]; then
    mkdir -p "$(dirname "$sec_dest")"
    cp "$sec_tpl" "$sec_dest"
    echo "ADD  $name security-gate.yml"
    FIXED=$((FIXED + 1))
  fi
done

# Verify
for pkg in "$ROOT/packages"/*/; do
  [[ -d "$pkg" ]] || continue
  name="$(basename "$pkg")"
  if [[ ! -f "$pkg/.github/workflows/ci.yml" ]]; then
    echo "FAIL $name: still missing ci.yml"
    FAIL=1
  fi
done

echo "ensure-package-ci: added=$FIXED"
[[ "$FAIL" -eq 0 ]] || exit 1
