#!/usr/bin/env bash
# One-time / after-reinstall setup to resume the httpd goal-directed plan loop.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANGVERSE="$(cd "$ROOT/.." && pwd)"
CURSOR_ENV="${LI_CURSOR_ENV_FILE:-$HOME/Documents/Cursor/.env}"

echo "==> httpd-plan-setup"
echo "    lic=$ROOT"

# Node (loop scripts expect ~/.local/node/bin first)
if [[ ! -x "${HOME}/.local/node/bin/node" ]]; then
  echo "==> install Node 24 to ~/.local/node (li-cursor-agents requires >=24)"
  NODE_VER=v24.11.0
  ARCH=linux-x64
  TMP="$(mktemp -d)"
  curl -fsSL "https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-${ARCH}.tar.xz" -o "$TMP/node.tar.xz"
  rm -rf "${HOME}/.local/node"
  mkdir -p "${HOME}/.local"
  tar -xJf "$TMP/node.tar.xz" -C "${HOME}/.local"
  mv "${HOME}/.local/node-${NODE_VER}-${ARCH}" "${HOME}/.local/node"
  rm -rf "$TMP"
fi
export PATH="${HOME}/.local/node/bin:${PATH:-/usr/bin:/bin}"

if [[ ! -f "$CURSOR_ENV" ]]; then
  echo "MISSING: $CURSOR_ENV (need CURSOR_API_KEY and GH_TOKEN)" >&2
  exit 1
fi
set -a
# shellcheck source=/dev/null
source "$CURSOR_ENV"
set +a
for v in CURSOR_API_KEY GH_TOKEN; do
  if [[ -z "${!v:-}" ]]; then
    echo "MISSING: $v in $CURSOR_ENV" >&2
    exit 1
  fi
done

export GH_TOKEN="${GH_TOKEN:-}"
if command -v gh >/dev/null 2>&1 && ! gh auth status >/dev/null 2>&1; then
  echo "==> gh auth from GH_TOKEN"
  printf '%s' "$GH_TOKEN" | gh auth login --with-token 2>/dev/null || true
fi

echo "==> git sync"
git -C "$ROOT" fetch origin
git -C "$ROOT" checkout cursor/httpd-plan-continue
git -C "$ROOT" pull --ff-only origin cursor/httpd-plan-continue

AGENTS="${LI_CURSOR_AGENTS_ROOT:-$LANGVERSE/li-cursor-agents}"
BENCH="${BENCHMARKS_ROOT:-$LANGVERSE/benchmarks}"
git -C "$AGENTS" fetch origin
git -C "$AGENTS" checkout feat/goal-directed-sdk-loop
git -C "$AGENTS" pull --ff-only origin feat/goal-directed-sdk-loop || true

if [[ -d "$BENCH/.git" ]]; then
  git -C "$BENCH" fetch origin
  git -C "$BENCH" pull --ff-only 2>/dev/null || true
fi

echo "==> build li-cursor-agents"
(cd "$AGENTS" && npm ci && npm run build)

mkdir -p "$ROOT/data/httpd-plan-loop"
ENV_SNIPPET="$ROOT/data/httpd-plan-loop/env.sh"
cat >"$ENV_SNIPPET" <<EOF
# Source before running httpd-plan-loop:  source data/httpd-plan-loop/env.sh
export PATH="\${HOME}/.local/node/bin:\${PATH}"
export LI_CURSOR_AGENTS_ROOT="$AGENTS"
export BENCHMARKS_ROOT="$BENCH"
export LIC_ROOT="$ROOT"
export HTTPD_PLAN_PR_BRANCH=cursor/httpd-plan-continue
export LI_HTTPD_PLAN_CLOSE_SERVER_MILESTONES=1
export HTTPD_GATES_SKIP_LIC_BUILD=\${HTTPD_GATES_SKIP_LIC_BUILD:-1}
export HTTPD_RUN_BEARER_TEST=\${HTTPD_RUN_BEARER_TEST:-0}
export HTTPD_REFRESH_PAGES=\${HTTPD_REFRESH_PAGES:-1}
export HTTPD_PAGES_SKIP_BENCH=\${HTTPD_PAGES_SKIP_BENCH:-1}
export LI_HTTPD_PLAN_AGENT=\${LI_HTTPD_PLAN_AGENT:-code_implementer}
export LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC=\${LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC:-2700}
export LI_CONTROL_PLANE_STORE=\${LI_CONTROL_PLANE_STORE:-disk}
export HTTPD_PLAN_TZ=\${HTTPD_PLAN_TZ:-Europe/Berlin}
export GH_TOKEN="\${GH_TOKEN:-}"
export CURSOR_API_KEY="\${CURSOR_API_KEY:-}"
if [[ -f "$CURSOR_ENV" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "$CURSOR_ENV"
  set +a
fi
EOF
chmod 644 "$ENV_SNIPPET"

echo "==> reseed state.json from plan YAML"
(cd "$ROOT" && python3 - <<'PY'
import json
from pathlib import Path

plan = Path("docs/superpowers/plans/2026-05-16-li-httpd-plan.md")
completed, pending = [], []
for block in plan.read_text().split("  - id:")[1:]:
    first = block.split("\n", 1)[0].strip()
    tid = first.split()[0] if first else ""
    if "status: completed" in block:
        completed.append(tid)
    elif "status: pending" in block:
        pending.append(tid)
out = Path("data/httpd-plan-loop/state.json")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(
    json.dumps({"completed_ids": completed, "iterations": 0, "history": []}, indent=2) + "\n"
)
print(f"  completed_ids={len(completed)} pending={pending}")
PY
)

cd "$ROOT"
# shellcheck source=/dev/null
source "$ENV_SNIPPET"
echo "==> dry-run (next todo)"
python3 scripts/httpd-plan-loop.py --dry-run 2>&1 | head -20

echo ""
echo "Setup OK. Continue with:"
echo "  cd $ROOT && source data/httpd-plan-loop/env.sh"
echo "  ./scripts/httpd-plan-loop.py --once          # one agent iteration"
echo "  nohup ./scripts/httpd-plan-overnight.sh >> data/httpd-plan-loop/overnight.out 2>&1 &"
