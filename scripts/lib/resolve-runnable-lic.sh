#!/usr/bin/env bash
# Pick a lic binary that exists and executes (--version smoke). Prefer native build/ over build-wsl/.
resolve_runnable_lic() {
  local root="${1:-.}"
  local c
  for c in \
    "$root/build/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe" \
    "$root/build-wsl/compiler/lic/lic"; do
    if [[ -x "$c" ]] && "$c" --version >/dev/null 2>&1; then
      echo "$c"
      return 0
    fi
  done
  if [[ -x "$root/scripts/resolve-lic.sh" ]]; then
    c="$("$root/scripts/resolve-lic.sh" 2>/dev/null)" || true
    if [[ -n "$c" && -x "$c" ]] && "$c" --version >/dev/null 2>&1; then
      echo "$c"
      return 0
    fi
  fi
  return 1
}
