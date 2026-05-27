#!/usr/bin/env bash
# Upload gitignored studio-verticals-demo.mp4 to a GitHub Release (not git).
# Auth: gh uses GH_TOKEN or GITHUB_TOKEN when set (Actions: secrets.GITHUB_TOKEN).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MP4="$ROOT/docs/demo/media/studio-verticals-demo.mp4"
TAG="${1:-studio-verticals-demo}"
TITLE="${STUDIO_VERTICALS_RELEASE_TITLE:-Li World Studio — verticals demo}"
NOTES="${STUDIO_VERTICALS_RELEASE_NOTES:-Native-frame vertical tour MP4. Regenerate: docs/demo/media/README.md}"

if [[ ! -f "$MP4" ]]; then
  echo "upload-studio-verticals-demo-release: missing $MP4" >&2
  echo "  Run: LIG_HOST_PRESENT=1 $ROOT/scripts/record-studio-verticals-demo.sh" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "upload-studio-verticals-demo-release: install GitHub CLI (gh)" >&2
  exit 2
fi

if [[ -z "${GH_TOKEN:-}" && -z "${GITHUB_TOKEN:-}" ]]; then
  if ! gh auth status >/dev/null 2>&1; then
    echo "upload-studio-verticals-demo-release: set GH_TOKEN or run gh auth login" >&2
    exit 2
  fi
fi

if ! gh release view "$TAG" >/dev/null 2>&1; then
  echo "upload-studio-verticals-demo-release: creating release $TAG"
  gh release create "$TAG" --title "$TITLE" --notes "$NOTES"
fi

echo "upload-studio-verticals-demo-release: uploading $(du -h "$MP4" | awk '{print $1}') → release $TAG"
gh release upload "$TAG" "$MP4" --clobber
echo "upload-studio-verticals-demo-release: done — gh release view $TAG"
