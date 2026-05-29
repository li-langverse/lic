#!/usr/bin/env bash
# G-par / G-dec: mut-capture and borrow-in-par policy runs only on Stmt::ParallelFor.
# @parallel(disjoint=...) on plain `for` bypasses check_stmt_parallel_capture / borrow guard.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
MUT_DEC="$ROOT/li-tests/decorators/parallel_decorator_mut_capture_outer.li"
BORROW_DEC="$ROOT/li-tests/decorators/parallel_decorator_borrow_mut_across_iters.li"
MUT_PAR="$ROOT/li-tests/race_shared_memory/mut_capture_no_sync.li"
BORROW_PAR="$ROOT/li-tests/race_shared_memory/borrow_mut_across_iters.li"

if ! "$LIC" check "$MUT_DEC" >/dev/null 2>&1; then
  echo "parallel_decorator_policy_capture_gap: mut decorator-for must pass lic check while gap open"
  exit 1
fi

if ! "$LIC" check "$BORROW_DEC" >/dev/null 2>&1; then
  echo "parallel_decorator_policy_capture_gap: borrow decorator-for must pass lic check while gap open"
  exit 1
fi

if "$LIC" check "$MUT_PAR" >/dev/null 2>&1; then
  echo "parallel_decorator_policy_capture_gap: mut_capture_no_sync must fail (parallel for control)"
  exit 1
fi

if "$LIC" check "$BORROW_PAR" >/dev/null 2>&1; then
  echo "parallel_decorator_policy_capture_gap: borrow_mut_across_iters must fail (parallel for control)"
  exit 1
fi

echo "parallel_decorator_policy_capture_gap: ok (documented G-par/G-dec decorator-for policy bypass)"
