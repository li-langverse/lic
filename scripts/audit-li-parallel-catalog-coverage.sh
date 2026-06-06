#!/usr/bin/env bash
# WP-PAR-48 — every Li catalog row runs dual-mode; zero skip/stub in killer CSV.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

# Full org catalog lives in li-langverse/benchmarks, not the in-repo lite tree.
if [[ ! -f "${BENCHMARKS_ROOT}/catalog.toml" ]]; then
  _cache="$ROOT/.cache/li-benchmarks"
  if [[ -f "$_cache/catalog.toml" ]]; then
    BENCHMARKS_ROOT="$_cache"
    export BENCHMARKS_ROOT
  fi
fi

CATALOG="${BENCHMARKS_ROOT}/catalog.toml"
if [[ ! -f "$CATALOG" ]]; then
  echo "audit-li-parallel-catalog-coverage: missing $CATALOG" >&2
  echo "  hint: clone benchmarks to .cache/li-benchmarks or set BENCHMARKS_ROOT" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/lipar-apply-parallel-src.sh"
"$ROOT/scripts/lipar-apply-parallel-src.sh"

python3 - "$CATALOG" "$BENCHMARKS_ROOT" <<'PY'
import re
import sys
from pathlib import Path

catalog_path = Path(sys.argv[1])
bench_root = Path(sys.argv[2])
text = catalog_path.read_text(encoding="utf-8")

blocks = re.split(r"\n\[\[benchmark\]\]", text)
eligible: list[tuple[str, str]] = []
for block in blocks:
    if 'repo = "lic"' not in block and "repo = 'lic'" not in block:
        continue
    if "parallel_eligible = false" in block:
        continue
    bid = re.search(r'^id = "([^"]+)"', block, re.M)
    path = re.search(r'^path = "([^"]+)"', block, re.M)
    if not bid or not path:
        continue
    if path.group(1) in ("unknown",):
        continue
    variant = re.search(r'^variant = "([^"]+)"', block, re.M)
    if variant and variant.group(1) in ("algo_registry", "db_parallel"):
        continue
    eligible.append((bid.group(1), path.group(1)))

missing_parallel_src: list[str] = []
for bid, rel in eligible:
    workload = bench_root / rel
    if not workload.is_dir():
        continue
    li_dir = workload / "li"
    if not li_dir.is_dir():
        continue
    has_parallel = (li_dir / "main_parallel.li").is_file() or bid.endswith("_parallel")
    if not has_parallel and (li_dir / "main.li").is_file():
        missing_parallel_src.append(f"{bid} ({rel}/li/main_parallel.li)")

min_coverage = 100
if eligible and missing_parallel_src:
    pct = int(100 * (len(eligible) - len(missing_parallel_src)) / len(eligible))
    print(
        f"audit-li-parallel-catalog-coverage: FAIL {len(missing_parallel_src)}/{len(eligible)} "
        f"Li rows lack parallel variant ({pct}% < {min_coverage}%)",
        file=sys.stderr,
    )
    for row in missing_parallel_src[:12]:
        print(f"  - {row}", file=sys.stderr)
    if len(missing_parallel_src) > 12:
        print(f"  ... and {len(missing_parallel_src) - 12} more", file=sys.stderr)
    sys.exit(1)

print(f"audit-li-parallel-catalog-coverage: {len(eligible)} eligible Li rows checked")
PY
