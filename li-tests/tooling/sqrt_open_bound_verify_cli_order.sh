#!/usr/bin/env bash
# G-vc / G-test-verify: lic verify parses argv[2] as path — flags before file silently
# typecheck an empty module and --strict-lean can false-pass on sqrt_open_bound.
# Passes while the CLI ordering hole is open; update when verify accepts flags before path.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

rm -f "$AUTOVC"

# Control: file before flags — strict-lean must fail on open Float.abs ensures.
if "$LIC" verify "$SAMPLE" --lean --strict-lean >/dev/null 2>&1; then
  echo "sqrt_open_bound_verify_cli_order: expected strict-lean fail (file before flags)"
  exit 1
fi
if ! grep -q 'namespace sqrt_open' "$AUTOVC" 2>/dev/null; then
  echo "sqrt_open_bound_verify_cli_order: expected sqrt_open AutoVC with file-first argv"
  exit 1
fi

rm -f "$AUTOVC"

# Documented hole: flags before file — verify treats --lean as path → procs=0, empty AutoVC.
OUT="$("$LIC" verify --lean --strict-lean "$SAMPLE" 2>&1)" || true
echo "$OUT" | grep -q 'procs=0' || {
  echo "sqrt_open_bound_verify_cli_order: expected procs=0 with flags-before-file argv"
  exit 1
}
if grep -q 'namespace sqrt_open' "$AUTOVC" 2>/dev/null; then
  echo "sqrt_open_bound_verify_cli_order: flags-before-file must not emit sqrt_open VCs yet"
  exit 1
fi
if echo "$OUT" | grep -q 'strict-lean failed'; then
  echo "sqrt_open_bound_verify_cli_order: gap closed — strict-lean now fails with flags-first; update script"
  exit 1
fi

echo "sqrt_open_bound_verify_cli_order: ok (documented G-test-verify CLI ordering hole)"
