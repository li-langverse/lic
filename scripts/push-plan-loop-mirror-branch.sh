#!/usr/bin/env bash
# Push one packages/<folder>/ tree from a lic plan-loop branch to an official mirror repo branch.
#
# Usage:
#   ./scripts/push-plan-loop-mirror-branch.sh \
#     --lic-branch cursor/studio-ui-ux-plan-loop \
#     --package li-studio \
#     --mirror-repo studio \
#     --mirror-branch cursor/studio-ui-ux-plan-loop
#
# Options:
#   --dry-run          Print actions only
#   --open-pr          Open gh PR after push (base main)
#   --create-repo      gh repo create if mirror missing (li-gui, etc.)
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ORG="${LI_ORG:-li-langverse}"
LIC_BRANCH=""
PKG=""
MIRROR_REPO=""
MIRROR_BRANCH=""
DRY=0
OPEN_PR=0
CREATE_REPO=0

usage() {
  echo "usage: $0 --lic-branch BR --package PKG --mirror-repo REPO --mirror-branch BRANCH [--dry-run] [--open-pr] [--create-repo]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lic-branch) LIC_BRANCH="$2"; shift 2 ;;
    --package) PKG="$2"; shift 2 ;;
    --mirror-repo) MIRROR_REPO="$2"; shift 2 ;;
    --mirror-branch) MIRROR_BRANCH="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --open-pr) OPEN_PR=1; shift ;;
    --create-repo) CREATE_REPO=1; shift ;;
    -h|--help) usage ;;
    *) echo "unknown: $1" >&2; usage ;;
  esac
done

[[ -n "$LIC_BRANCH" && -n "$PKG" && -n "$MIRROR_REPO" && -n "$MIRROR_BRANCH" ]] || usage

LIC_REF="origin/${LIC_BRANCH#origin/}"
PKG_DIR="$ROOT/packages/$PKG"
REPO_SLUG="${ORG}/${MIRROR_REPO}"

if ! git -C "$ROOT" rev-parse "$LIC_REF" >/dev/null 2>&1; then
  echo "error: missing $LIC_REF (git fetch origin '+refs/heads/cursor/*:refs/remotes/origin/cursor/*')" >&2
  exit 1
fi

if ! git -C "$ROOT" diff --quiet "origin/main" "$LIC_REF" -- "packages/$PKG" 2>/dev/null; then
  :
else
  echo "skip: no diff for packages/$PKG on $LIC_REF vs origin/main"
  exit 0
fi

if [[ "$DRY" -eq 1 ]]; then
  echo "dry-run: $LIC_REF packages/$PKG -> $REPO_SLUG branch $MIRROR_BRANCH"
  exit 0
fi

command -v gh >/dev/null || { echo "gh required" >&2; exit 1; }

if ! gh repo view "$REPO_SLUG" >/dev/null 2>&1; then
  if [[ "$CREATE_REPO" -ne 1 ]]; then
    echo "error: $REPO_SLUG missing; re-run with --create-repo" >&2
    exit 1
  fi
  echo "==> creating $REPO_SLUG"
  gh repo create "$REPO_SLUG" --public --description "Li package mirror ($PKG)" --confirm
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git -C "$ROOT" archive "$LIC_REF" "packages/$PKG" | tar -x -C "$TMP"
if [[ ! -d "$TMP/packages/$PKG" ]]; then
  echo "error: archive missing packages/$PKG" >&2
  exit 1
fi

CLONE="$TMP/clone"
if gh api "repos/${REPO_SLUG}" -q '.size' 2>/dev/null | grep -qv '^0$'; then
  gh repo clone "$REPO_SLUG" "$CLONE" -- --depth 1 -b main 2>/dev/null \
    || gh repo clone "$REPO_SLUG" "$CLONE" -- --depth 1
else
  mkdir -p "$CLONE"
  git -C "$CLONE" init -q -b main
  git -C "$CLONE" remote add origin "https://github.com/${REPO_SLUG}.git"
fi
cd "$CLONE"
git checkout -B "$MIRROR_BRANCH" 2>/dev/null || git checkout -b "$MIRROR_BRANCH"
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude='.git' "$TMP/packages/$PKG/" ./
else
  find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  cp -a "$TMP/packages/$PKG/." ./
fi

git add -A
if git diff --cached --quiet; then
  echo "skip: $REPO_SLUG $MIRROR_BRANCH — already matches packages/$PKG @ $LIC_REF"
  exit 0
fi

git -c user.name="li-langverse-bot" -c user.email="bot@users.noreply.github.com" \
  commit -m "feat(${PKG}): split from lic ${LIC_BRANCH#origin/}

Cherry-pick equivalent: package tree at ${LIC_REF} (monorepo packages/${PKG}/).
Source PR: https://github.com/${ORG}/lic/compare/main...${LIC_BRANCH#origin/}

Co-authored-by: Cursor <cursoragent@cursor.com>"

git push -u origin "$MIRROR_BRANCH"

if [[ "$OPEN_PR" -eq 1 ]]; then
  existing="$(gh pr list --repo "$REPO_SLUG" --head "$MIRROR_BRANCH" --json number -q '.[0].number' 2>/dev/null || true)"
  if [[ -z "$existing" ]]; then
    gh pr create --repo "$REPO_SLUG" \
      --base main \
      --head "$MIRROR_BRANCH" \
      --title "feat(${PKG}): plan-loop split from lic/${LIC_BRANCH#origin/}" \
      --body "$(cat <<EOF
## Summary

Mirror branch for \`packages/${PKG}/\` from [lic \`${LIC_BRANCH#origin/}\`](https://github.com/${ORG}/lic/compare/main...${LIC_BRANCH#origin/}).

Monorepo integration PRs remain on **lic**; this repo gets the publishable package slice only.

## Agent continuation

1. Review package smoke + \`li.toml\` paths (mirror layout = repo root).
2. Merge after lic plan-loop PR strategy is agreed.
3. Re-sync from lic \`main\` after monorepo merge.

## Not changed

- \`lic\` compiler/runtime/benchmarks (stay on lic PRs).
EOF
)"
  else
    echo "PR already open: #$existing"
  fi
fi

echo "ok: $REPO_SLUG @ $MIRROR_BRANCH <= packages/$PKG @ $LIC_REF"
