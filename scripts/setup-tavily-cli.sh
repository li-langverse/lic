#!/usr/bin/env bash
# Install Tavily CLI for competitive-intel refresh (requires TAVILY_API_KEY in env).
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v uv >/dev/null 2>&1; then
  echo "==> installing uv"
  curl -fsSL https://astral.sh/uv/install.sh | sh
  # shellcheck source=/dev/null
  [[ -f "${HOME}/.local/bin/env" ]] && source "${HOME}/.local/bin/env"
fi

echo "==> uv tool install tavily-cli"
uv tool install tavily-cli

if [[ -z "${TAVILY_API_KEY:-}" ]]; then
  echo "Set TAVILY_API_KEY in ~/Documents/Cursor/.env (or export) then: source .env" >&2
  exit 1
fi

tvly --status
echo "ok: run ./scripts/fetch-competitive-intel.sh --tavily"
