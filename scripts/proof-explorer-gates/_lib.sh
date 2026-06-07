#!/usr/bin/env bash
# Shared helpers for proof-explorer gates (WSL, Git Bash, git worktrees).
set -euo pipefail

pe_resolve_proof_library() {
  local root="$1"
  local candidate=""

  if [[ -n "${PROOF_LIBRARY_ROOT:-}" ]]; then
    candidate="$(cd "$PROOF_LIBRARY_ROOT" 2>/dev/null && pwd || true)"
    if [[ -n "$candidate" && -d "$candidate/data" ]]; then
      echo "$candidate"
      return 0
    fi
  fi

  for candidate in \
    "$root/../proof-library" \
    "${LIC_ROOT:+$LIC_ROOT/../proof-library}" \
    "$root/../../proof-library"; do
    [[ -n "$candidate" ]] || continue
    candidate="$(cd "$candidate" 2>/dev/null && pwd || true)"
    if [[ -n "$candidate" && -d "$candidate/data" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

pe_resolve_lic_main_sha() {
  local root="$1"
  root="$(cd "$root" && pwd)"

  git -C "$root" fetch origin main --quiet 2>/dev/null || true

  if git -C "$root" rev-parse --verify origin/main >/dev/null 2>&1; then
    git -C "$root" rev-parse origin/main
    return 0
  fi
  if git -C "$root" rev-parse --verify main >/dev/null 2>&1; then
    git -C "$root" rev-parse main
    return 0
  fi

  git -C "$root" rev-parse HEAD
}

pe_check_library_lic_commit() {
  local label="$1"
  local library_json="$2"
  local want_sha="$3"

  python3 - "$label" "$library_json" "$want_sha" <<'PY'
import json
import sys
from pathlib import Path

label, path, want = sys.argv[1], Path(sys.argv[2]), sys.argv[3]
lib = json.loads(path.read_text(encoding="utf-8"))
got = lib.get("lic_commit")
if got is None or got == "":
    print(f"{label}: lic_commit missing or null in {path}", file=sys.stderr)
    sys.exit(1)
if not isinstance(got, str):
    print(f"{label}: lic_commit has unexpected type {type(got).__name__}", file=sys.stderr)
    sys.exit(1)
if not got.startswith(want[:8]):
    print(f"{label}: lic_commit={got[:12]} want prefix {want[:12]}", file=sys.stderr)
    sys.exit(1)
print(f"{label}: lic_commit OK ({got[:8]})")
PY
}
