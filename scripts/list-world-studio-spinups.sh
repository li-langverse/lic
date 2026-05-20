#!/usr/bin/env bash
# List World Studio spin-up templates (human + agent friendly).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOML="$ROOT/deploy/world-studio-spinup/spinup.toml"

echo "World Studio spin-up templates (from spinup.toml):"
echo ""
python3 - <<'PY' "$TOML"
import sys
try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore
path = sys.argv[1]
with open(path, "rb") as f:
    data = tomllib.load(f)
for t in data.get("templates", []):
    tid = t.get("id", "?")
    title = t.get("title", "")
    profile = t.get("profile", "")
    print(f"  {tid:16}  {title}")
    print(f"    profile: {profile}")
    print(f"    scaffold: ./scripts/lis-new-world-studio.sh {tid} DEST")
    print("")
PY
echo "Default: game"
echo "Play mode: ./scripts/lis-new-world-studio.sh play_mode my-project"
