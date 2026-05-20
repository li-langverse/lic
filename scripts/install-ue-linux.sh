#!/usr/bin/env bash
# Download/install Unreal Engine 5 on Linux via Legendary (Epic OAuth).
# Requires a free Epic account. Set EPIC_AUTH_CODE after browser login, or run interactively.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="${UE_INSTALL_DIR:-$HOME/UnrealEngine}"
LEG="${LEGENDARY:-}"
PATH="$HOME/.local/bin:$PATH"

if [[ -z "$LEG" ]]; then
  for cand in \
    "$(command -v legendary 2>/dev/null || true)" \
    "$HOME/tools/squashfs-root/resources/app.asar.unpacked/build/bin/x64/linux/legendary" \
    "$ROOT/../tools/squashfs-root/resources/app.asar.unpacked/build/bin/x64/linux/legendary"; do
    if [[ -n "$cand" && -x "$cand" ]]; then
      LEG="$cand"
      break
    fi
  done
fi
if [[ -z "$LEG" ]]; then
  pip install -q legendary-gl
  LEG="$HOME/.local/bin/legendary"
fi

echo "== Legendary: $( "$LEG" --version ) =="

if [[ -n "${EPIC_AUTH_CODE:-}" ]]; then
  "$LEG" auth --code "$EPIC_AUTH_CODE" --disable-webview
elif [[ -n "${EPIC_EXCHANGE_TOKEN:-}" ]]; then
  "$LEG" auth --token "$EPIC_EXCHANGE_TOKEN" --disable-webview
elif ! "$LEG" auth 2>/dev/null; then
  AUTH_URL=$(python3 -c "
from legendary.api.egs import EPCAPI
print(EPCAPI().get_auth_url())
")
  echo ""
  echo "Open this URL in a browser (Epic account required), log in, copy the 'code' query param:"
  echo "$AUTH_URL"
  echo ""
  echo "Then:  export EPIC_AUTH_CODE=<code>"
  echo "       $0"
  exit 2
fi

echo "== Listing UE-related Legendary assets =="
"$LEG" list --include-ue 2>&1 | rg -i 'unreal|lyra|engine|UE_' || true

# Prefer official Linux zip name from Epic site (manual) or Lyra sample
UE_APP="${UE_LEGENDARY_APP:-}"
if [[ -z "$UE_APP" ]]; then
  UE_APP=$("$LEG" list --include-ue 2>/dev/null | rg -oi 'unreal[^|]*' | head -1 | tr -d ' ' || true)
fi
if [[ -z "$UE_APP" ]]; then
  echo "No UE app auto-detected. Install Linux zip from https://www.unrealengine.com/linux"
  echo "  extract to $INSTALL_DIR and export UE_ROOT=$INSTALL_DIR"
  exit 3
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
echo "== Installing $UE_APP to $INSTALL_DIR =="
"$LEG" install "$UE_APP" --base-path "$(dirname "$INSTALL_DIR")" --yes

# Find editor binary
for ed in "$INSTALL_DIR"/Engine/Binaries/Linux/UnrealEditor \
          "$INSTALL_DIR"/Linux_*/Engine/Binaries/Linux/UnrealEditor; do
  if [[ -x "$ed" ]]; then
    echo "export UE_ROOT=$(dirname "$(dirname "$(dirname "$(dirname "$ed")")")")"
    echo "Installed: $ed"
    exit 0
  fi
done
echo "Install finished but UnrealEditor not found under $INSTALL_DIR — check Legendary output."
exit 4
