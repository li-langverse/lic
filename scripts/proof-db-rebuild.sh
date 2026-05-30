#!/usr/bin/env bash
# Rebuild proof-db lemma status: lic build, AutoVC open-goal scan, optional lake.
# Appends one JSON object per lemma to proof-db/results/<run-key>.jsonl
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROOF_DB="$ROOT/proof-db"
RESULTS_DIR="$PROOF_DB/results"
CHECK_AUTOVC="$ROOT/scripts/check-autovc-open-goals.sh"
SEMANTICS_DIR="$ROOT/docs/semantics"
NULL_OUT="$(command -v /dev/null >/dev/null 2>&1 && echo /dev/null || echo NUL)"

RUN_LAKE=0
DRY_RUN=0
LIMIT=""

usage() {
  cat <<'EOF'
Usage: ./scripts/proof-db-rebuild.sh [options]

Walk proof-db/**/lemmas/*.li and record verification status per lemma.

Options:
  --lake       Run `lake build` in docs/semantics after each successful strict build
  --dry-run    Print actions without writing JSONL
  --limit N    Process at most N lemma files (debug)
  -h, --help   Show this help

Environment:
  LIC          Path to lic binary (default: scripts/resolve-lic.sh)
  PROOF_DB_RUN_KEY  Override output filename stem (default: lic --version or git SHA)

Output:
  proof-db/results/<run-key>.jsonl  (append mode; one JSON object per line)

Status values:
  proved         lic build ok, zero open AutoVC goals, lake ok when --lake
  open_vc        build ok (or --allow-open-vc) but open Prop goals remain
  compile_fail   lic build failed
  lean_fail      build + closed AutoVC ok, lake build failed (--lake)
  discrepancy    actual status differs from optional <lemma>.expected.json
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lake) RUN_LAKE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "proof-db-rebuild: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

proof_db_run_key() {
  if [[ -n "${PROOF_DB_RUN_KEY:-}" ]]; then
    echo "$PROOF_DB_RUN_KEY"
    return
  fi
  local ver=""
  if ver="$("$LIC" --version 2>/dev/null | head -1)"; then
    ver="${ver// /-}"
    ver="${ver//\//-}"
    echo "$ver"
    return
  fi
  git -C "$ROOT" rev-parse --short HEAD
}

count_autovc_open() {
  local autovc="$1"
  if [[ ! -f "$autovc" ]]; then
    echo 0
    return
  fi
  local open=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^def\ vc_.*decreases.*:\ Nat\ := ]]; then
      local name="${line#def }"
      name="${name%% *}"
      if ! grep -q "theorem ${name}_proved" "$autovc"; then
        open=$((open + 1))
      fi
      continue
    fi
    if [[ "$line" =~ ^def\ vc_.*requires.*:\ Prop\ := ]] && [[ ! "$line" =~ :=\ True$ ]]; then
      continue
    fi
    if [[ "$line" =~ ^def\ vc_.*\ :\ Prop\ :=\ True$ ]]; then
      local name="${line#def }"
      name="${name%% *}"
      if ! grep -q "theorem ${name}_proved" "$autovc"; then
        open=$((open + 1))
      fi
      continue
    fi
    if [[ "$line" =~ ^def\ vc_.*\ :\ Prop\ := ]]; then
      local name="${line#def }"
      name="${name%% *}"
      if ! grep -q "theorem ${name}_proved" "$autovc"; then
        open=$((open + 1))
      fi
    fi
  done < "$autovc"
  echo "$open"
}

lemma_id_from_path() {
  local rel="${1#"$PROOF_DB"/}"
  rel="${rel#/}"
  rel="${rel%.li}"
  if [[ "$rel" == *"/lemmas/"* ]]; then
    rel="$(printf '%s' "$rel" | sed 's|/lemmas/|/|')"
  fi
  echo "$rel"
}

read_expected_status() {
  local lemma_path="$1"
  local expected="${lemma_path%.li}.expected.json"
  if [[ ! -f "$expected" ]]; then
    return 1
  fi
  python3 - "$expected" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
print(data.get("status", ""))
PY
}

append_jsonl() {
  local outfile="$1"
  local lemma_id="$2"
  local status="$3"
  local open_count="$4"
  local notes="$5"
  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local line
  line="$(python3 - "$lemma_id" "$status" "$open_count" "$notes" "$ts" <<'PY'
import json, sys
lemma_id, status, open_count, notes, ts = sys.argv[1:6]
print(json.dumps({
    "lemma_id": lemma_id,
    "status": status,
    "autovc_open_count": int(open_count),
    "notes": notes,
    "recorded_at": ts,
}, separators=(",", ":")))
PY
)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "$line"
    return
  fi
  echo "$line" >>"$outfile"
}

process_lemma() {
  local path="$1"
  local rel="${path#"$ROOT"/}"
  local lemma_id
  lemma_id="$(lemma_id_from_path "$path")"
  local autovc="$ROOT/build/generated/AutoVC.lean"
  local notes=""
  local status=""
  local open_count=0
  local build_log
  build_log="$(mktemp "${TMPDIR:-/tmp}/proof-db-build.XXXXXX")"
  trap 'rm -f "$build_log"' RETURN

  rm -f "$autovc"
  if ! "$LIC" build "$path" -o "$NULL_OUT" >"$build_log" 2>&1; then
    status="compile_fail"
    notes="$(tail -20 "$build_log" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-400)"
    open_count=0
    trap - RETURN
    rm -f "$build_log"
    finalize_record "$lemma_id" "$status" "$open_count" "$notes"
    return
  fi

  if [[ ! -f "$autovc" ]]; then
    status="compile_fail"
    notes="lic build succeeded but missing $autovc"
    open_count=0
    trap - RETURN
    rm -f "$build_log"
    finalize_record "$lemma_id" "$status" "$open_count" "$notes"
    return
  fi

  chmod +x "$CHECK_AUTOVC"
  open_count="$(count_autovc_open "$autovc")"
  if [[ "$open_count" -gt 0 ]]; then
    status="open_vc"
    notes="check-autovc-open-goals would fail ($open_count open)"
  else
    status="proved"
    notes="strict lic build; zero open Prop goals"
    if [[ "$RUN_LAKE" -eq 1 ]]; then
      if command -v lake >/dev/null 2>&1; then
        if ! (cd "$SEMANTICS_DIR" && lake build AutoVC >>"$build_log" 2>&1); then
          status="lean_fail"
          notes="lake build AutoVC failed; see build log tail"
        else
          notes="lic build + closed AutoVC + lake build AutoVC ok"
        fi
      else
        notes="${notes}; lake skipped (not on PATH)"
      fi
    fi
  fi

  trap - RETURN
  rm -f "$build_log"
  finalize_record "$lemma_id" "$status" "$open_count" "$notes"
}

finalize_record() {
  local lemma_id="$1"
  local actual_status="$2"
  local open_count="$3"
  local notes="$4"
  local status="$actual_status"
  local expected=""
  if expected="$(read_expected_status "$CURRENT_LEMMA_PATH" 2>/dev/null)"; then
    if [[ -n "$expected" && "$expected" != "$actual_status" ]]; then
      status="discrepancy"
      notes="expected=${expected}; actual=${actual_status}; ${notes}"
    fi
  fi
  append_jsonl "$OUTFILE" "$lemma_id" "$status" "$open_count" "$notes"
  echo "proof-db-rebuild: $lemma_id -> $status (open=$open_count)"
}

mkdir -p "$RESULTS_DIR"
RUN_KEY="$(proof_db_run_key)"
OUTFILE="$RESULTS_DIR/${RUN_KEY}.jsonl"

LEMMA_FILES=()
while IFS= read -r _line; do
  LEMMA_FILES+=("$_line")
done < <(find "$PROOF_DB" -type f -path '*/lemmas/*.li' | sort)
if [[ ${#LEMMA_FILES[@]} -eq 0 ]]; then
  echo "proof-db-rebuild: no lemmas under $PROOF_DB/**/lemmas/*.li" >&2
  exit 1
fi

count=0
for path in "${LEMMA_FILES[@]}"; do
  CURRENT_LEMMA_PATH="$path"
  process_lemma "$path"
  count=$((count + 1))
  if [[ -n "$LIMIT" && "$count" -ge "$LIMIT" ]]; then
    break
  fi
done

echo "proof-db-rebuild: wrote $count record(s) to ${OUTFILE#$ROOT/}"
