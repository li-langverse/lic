#!/usr/bin/env bash
# CVE + malformed-input security gates — same on Linux, macOS, and Windows (Git Bash).
# Sanitizer-only jobs (ASan/UBSan/fuzz) remain OS-specific; see docs/testing/security.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "${LIC:-}" ]]; then
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
  export LIC
fi

if [[ ! -x "$LIC" ]]; then
  echo "ci-security: skip (lic not executable at $LIC)"
  exit 0
fi

echo "==> security corpus (no crash on malformed input)"
chmod +x "$ROOT/li-tests/run_security.sh"
"$ROOT/li-tests/run_security.sh"

echo "==> stdlib_seal (prelude shadow / duplicate top-level)"
"$ROOT/li-tests/run_all.sh" stdlib_seal

echo "==> cve_patterns (CWE weakness class rejections)"
"$ROOT/li-tests/run_all.sh" cve_patterns

echo "==> CVE catalog coverage (all CWE rows in pinned catalog)"
chmod +x "$ROOT/scripts/check-cve-coverage.sh"
"$ROOT/scripts/check-cve-coverage.sh"

echo "==> historic bug registry (Heartbleed, Shellshock, Ariane 5, Firefly OS, …)"
chmod +x "$ROOT/scripts/check-historic-bugs.sh"
"$ROOT/scripts/check-historic-bugs.sh"

echo "==> webserver vulnerability registry (smuggling, SSRF, traversal, …)"
chmod +x "$ROOT/scripts/check-webserver-bugs.sh"
"$ROOT/scripts/check-webserver-bugs.sh"

echo "==> codegen path injection (CWE-78 / CWE-88)"
chmod +x "$ROOT/li-tests/security/codegen_path_injection.sh"
"$ROOT/li-tests/security/codegen_path_injection.sh"

echo "ci-security: ok ($(uname -s 2>/dev/null || echo unknown))"
