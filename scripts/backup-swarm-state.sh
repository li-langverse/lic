#!/usr/bin/env bash
# WP-M0: Snapshot swarm/plan-loop state before goal-directed migration.
# Usage:
#   ./scripts/backup-swarm-state.sh
#   BACKUP_ROOT=~/Documents/Cursor/backups ./scripts/backup-swarm-state.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANGVERSE_ROOT="$(cd "$ROOT/.." && pwd)"
AGENTS_ROOT="${LI_CURSOR_AGENTS_ROOT:-$LANGVERSE_ROOT/li-cursor-agents}"
CURSOR_ROOT="${CURSOR_ROOT:-$HOME/Documents/Cursor}"
BACKUP_ROOT="${BACKUP_ROOT:-$CURSOR_ROOT/backups}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DAY="$(date -u +%Y%m%d)"
DEST="${BACKUP_DEST:-$BACKUP_ROOT/swarm-$DAY}"

mkdir -p "$DEST"/{git,systemd,tar}

repo_git_snapshot() {
  local name="$1"
  local dir="$2"
  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "skip: $name ($dir not a git repo)" >&2
    return 0
  fi
  local branch sha dirty
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
  sha="$(git -C "$dir" rev-parse HEAD)"
  if [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]]; then
    dirty=true
  else
    dirty=false
  fi
  {
    echo "branch=$branch"
    echo "sha=$sha"
    echo "dirty=$dirty"
    echo "path=$dir"
  } >"$DEST/git/${name}.txt"
  jq -n \
    --arg name "$name" \
    --arg path "$dir" \
    --arg branch "$branch" \
    --arg sha "$sha" \
    --argjson dirty "$dirty" \
    '{name: $name, path: $path, branch: $branch, sha: $sha, dirty: $dirty}'
}

echo "Backup destination: $DEST"

# --- Git snapshots (lic, li-cursor-agents; benchmarks path within lic) ---
REPOS_JSON='[]'
for name in lic li-cursor-agents; do
  case "$name" in
    lic) dir="$ROOT" ;;
    li-cursor-agents) dir="$AGENTS_ROOT" ;;
  esac
  if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    snap="$(repo_git_snapshot "$name" "$dir")"
    REPOS_JSON="$(jq --argjson snap "$snap" '. + [$snap]' <<<"$REPOS_JSON")"
  fi
done

BENCH_PATH="$ROOT/benchmarks"
if [[ -d "$BENCH_PATH" ]]; then
  REPOS_JSON="$(jq --arg path "$BENCH_PATH" '. + [{name: "benchmarks", path: $path, note: "directory within lic repo; uses lic git snapshot"}]' <<<"$REPOS_JSON")"
fi

# --- Plan-loop and related runtime data (exclude .env) ---
TAR_LIST="$DEST/tar-paths.txt"
: >"$TAR_LIST"
shopt -s nullglob
for d in "$ROOT"/data/*-plan-loop "$ROOT"/data/sim-plan-loop "$ROOT"/data/security-research-loop \
  "$ROOT"/data/goal-directed-agents "$ROOT"/data/swarm-gap-registry; do
  [[ -d "$d" ]] && realpath "$d" >>"$TAR_LIST"
done
shopt -u nullglob

if [[ -d "$AGENTS_ROOT/data/control-plane" ]]; then
  realpath "$AGENTS_ROOT/data/control-plane" >>"$TAR_LIST"
fi

# Optional worktree loop data (sibling repos under li-langverse)
WORKTREE_JSON='[]'
for wt in "$LANGVERSE_ROOT"/lic-worktrees/* "$LANGVERSE_ROOT"/lic-studio-ui; do
  [[ -d "$wt" ]] || continue
  for d in "$wt"/data/*-plan-loop "$wt"/data/*-research-loop "$wt"/data/sim-plan-loop "$wt"/data/security-research-loop; do
    [[ -d "$d" ]] || continue
    realpath "$d" >>"$TAR_LIST"
    WORKTREE_JSON="$(jq --arg path "$d" --arg wt "$wt" '. + [{worktree: $wt, data_dir: $path}]' <<<"$WORKTREE_JSON")"
  done
done

if [[ -s "$TAR_LIST" ]]; then
  # Tar from common parent; exclude secrets
  tar -czf "$DEST/tar/swarm-runtime-data.tar.gz" \
    --exclude='.env' \
    --exclude='*.env' \
    -C / \
    $(sort -u "$TAR_LIST" | while read -r p; do echo "${p#/}"; done)
else
  echo "warning: no runtime data paths found" >&2
  touch "$DEST/tar/swarm-runtime-data.tar.gz"
fi

# --- systemd user units ---
SYSTEMD_JSON='[]'
shopt -s nullglob
for unit in "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"/li-*.service; do
  cp -a "$unit" "$DEST/systemd/"
  SYSTEMD_JSON="$(jq --arg f "$(basename "$unit")" '. + [$f]' <<<"$SYSTEMD_JSON")"
done
shopt -u nullglob

# --- Manifest ---
MANIFEST="$DEST/manifest.json"
jq -n \
  --arg timestamp_utc "$STAMP" \
  --arg backup_dir "$DEST" \
  --arg lic_root "$ROOT" \
  --arg agents_root "$AGENTS_ROOT" \
  --argjson repos "$REPOS_JSON" \
  --argjson systemd_units "$SYSTEMD_JSON" \
  --argjson worktree_data "$WORKTREE_JSON" \
  --arg tar_archive "tar/swarm-runtime-data.tar.gz" \
  '{
    schema: "swarm-backup-v1",
    timestamp_utc: $timestamp_utc,
    backup_dir: $backup_dir,
    lic_root: $lic_root,
    agents_root: $agents_root,
    repos: $repos,
    systemd_units: $systemd_units,
    worktree_data: $worktree_data,
    archives: {
      runtime_data: $tar_archive
    },
    excluded_from_tar: [".env", "*.env"],
    manual_copy: [
      "Copy ~/Documents/Cursor/.env (and any LI_CURSOR_ENV_FILE overrides) by hand; never include in tar."
    ]
  }' >"$MANIFEST"

echo "Wrote $MANIFEST"
echo "Paths archived: $(wc -l <"$TAR_LIST")"
echo "Systemd units: $(jq -r 'length' <<<"$SYSTEMD_JSON")"
