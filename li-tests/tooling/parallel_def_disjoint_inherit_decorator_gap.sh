#!/usr/bin/env bash
# G-par / G-dec: proc-level @parallel(disjoint=) satisfies nested `parallel for` (E0320)
# but does not apply to @parallel on plain `for` — check_stmt_parallel returns early on Stmt::For
# (policy_module.cpp:171-172). Capture/borrow guards also skip decorated `for`.
# Passes while gaps are open; update when decorator-for inherits proc_disjoint or rejects missing disjoint.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
INHERIT_KW="$ROOT/li-tests/decorators/parallel_def_disjoint_inherit.li"
INHERIT_DEC="$ROOT/li-tests/decorators/parallel_def_disjoint_inherit_decorator_for.li"
MUT_DEC="$ROOT/li-tests/decorators/parallel_def_disjoint_decorator_mut_capture.li"
NO_PROC_PAR="$ROOT/li-tests/decorators/parallel_decorator_on_for_no_disjoint.li"

if ! "$LIC" check "$INHERIT_KW" >/dev/null 2>&1; then
  echo "parallel_def_disjoint_inherit_decorator_gap: parallel_def_disjoint_inherit must pass (proc→parallel for)"
  exit 1
fi

if ! "$LIC" check "$INHERIT_DEC" >/dev/null 2>&1; then
  echo "parallel_def_disjoint_inherit_decorator_gap: proc_disjoint+@parallel for must pass while gap open"
  exit 1
fi

if ! "$LIC" check "$MUT_DEC" >/dev/null 2>&1; then
  echo "parallel_def_disjoint_inherit_decorator_gap: proc_disjoint+decorator mut capture must pass while gap open"
  exit 1
fi

if ! "$LIC" check "$NO_PROC_PAR" >/dev/null 2>&1; then
  echo "parallel_def_disjoint_inherit_decorator_gap: @parallel for without proc disjoint must pass (baseline gap)"
  exit 1
fi

TMP="$(mktemp -t li_no_proc_parfor.XXXXXX.li)"
trap 'rm -f "$TMP"' EXIT
cat >"$TMP" <<'EOF'
@cpu
def no_proc_disjoint_parfor() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var buf: array[8, f64]
  parallel for i in 0..<8
    decreases 8 - i
  =
    buf[i] = 1.0
  return 0
EOF

if "$LIC" check "$TMP" >/dev/null 2>&1; then
  echo "parallel_def_disjoint_inherit_decorator_gap: nested parallel for without proc disjoint must fail E0320"
  exit 1
fi

echo "parallel_def_disjoint_inherit_decorator_gap: ok (documented G-par/G-dec proc inherit asymmetry on decorator-for)"
