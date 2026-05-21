#!/usr/bin/env bash
# Bootstrap li-studio-app (Li World Studio product repo) from lic.
# Usage: ./scripts/bootstrap-li-studio-app-repo.sh [DEST]
# See docs/ecosystem/studio-naming.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$ROOT/../studio-app}"

if [[ -e "$DEST" && -n "$(ls -A "$DEST" 2>/dev/null)" ]]; then
  echo "Refusing to overwrite non-empty: $DEST" >&2
  exit 1
fi

mkdir -p "$DEST"/{demo,docs,scripts}

echo "→ $DEST (studio-app — Li World Studio application repo)"

cp -a "$ROOT/deploy/studio-demo/." "$DEST/demo/"

for f in \
  planned-ui-mockups.md \
  demo-showcase.md \
  unified-studio-ux-vision.md \
  product-north-star.md \
  world-studio-vision.md \
  specs/studio-ux-design-system-rfc.md \
  specs/li-canvas-agentic-rfc.md \
  plans/li-native-gui-plan.md
do
  if [[ -f "$ROOT/docs/game-dev/$f" ]]; then
    mkdir -p "$DEST/docs/$(dirname "$f")"
    cp "$ROOT/docs/game-dev/$f" "$DEST/docs/$f"
  fi
done
cp "$ROOT/docs/ecosystem/studio-naming.md" "$DEST/docs/studio-naming.md"
cp "$ROOT/docs/ecosystem/li-studio-repos.md" "$DEST/docs/li-studio-repos.md"

for s in record-studio-demo.sh gen-studio-demo-status.sh open-studio-demo.sh studio-demo-capture.mjs; do
  [[ -f "$ROOT/scripts/$s" ]] && cp "$ROOT/scripts/$s" "$DEST/scripts/"
done
if [[ -d "$ROOT/scripts/studio-demo-pkg" ]]; then
  mkdir -p "$DEST/scripts/studio-demo-pkg"
  cp -a "$ROOT/scripts/studio-demo-pkg/." "$DEST/scripts/studio-demo-pkg/"
fi

for f in "$DEST/scripts/"*.sh "$DEST/scripts/"*.mjs; do
  [[ -f "$f" ]] || continue
  sed -i 's|deploy/studio-demo|demo|g' "$f"
done

cat > "$DEST/README.md" <<'EOF'
# studio-app

**Li World Studio** — the editor application (demo, mockups, native shell). **Not** a lip import.

| Repo kind | Name | This repo? |
|-----------|------|------------|
| Application | **studio-app** | ✅ yes |
| `import studio` | **studio** | ❌ sibling package |
| `import studio.ai` | **studio.ai** | ❌ sibling package |
| `import world` | **world** | ❌ sibling package |

```bash
export LIC_ROOT=../lic
python3 -m http.server 8765 --directory demo
# http://localhost:8765/preview.html
```

See `docs/studio-naming.md`.
EOF

cat > "$DEST/.gitignore" <<'EOF'
demo/videos/frames/
scripts/studio-demo-pkg/node_modules/
EOF

echo "Done: $DEST"
