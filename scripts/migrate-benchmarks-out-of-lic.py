#!/usr/bin/env python3
"""Point lic scripts at BENCHMARKS_ROOT/harness; remove lic/benchmarks tree."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

LIC = Path(__file__).resolve().parents[1]
BENCH = LIC.parent / "benchmarks"
SOURCE_LINE = '# shellcheck source=lib/benchmarks-env.sh\nsource "$ROOT/scripts/lib/benchmarks-env.sh"\n'

REPLACEMENTS = [
    ('HARNESS="$ROOT/benchmarks/harness"', 'HARNESS="$BENCHMARKS_ROOT/harness"'),
    ('"$ROOT/benchmarks/harness"', '"$HARNESS"'),
    ("'$ROOT/benchmarks/harness'", "'$HARNESS'"),
    ('sys.path.insert(0, "$ROOT/benchmarks/harness")', 'sys.path.insert(0, "$HARNESS")'),
    ('python3 "$ROOT/benchmarks/harness/bench.py"', '"$BENCHMARKS_ROOT/scripts/run-bench.sh"'),
    ('python3 benchmarks/harness/bench.py', '"$BENCHMARKS_ROOT/scripts/run-bench.sh"'),
    ('"$ROOT/benchmarks/results"', '"$BENCHMARKS_RESULTS"'),
    ('"$ROOT/benchmarks/competitive/', '"$BENCHMARKS_COMPETITIVE/'),
    ('mkdir -p "$ROOT/benchmarks/results"', 'mkdir -p "$BENCHMARKS_RESULTS"'),
    ('mkdir -p "$OUT_DIR" "$ROOT/benchmarks/results"', 'mkdir -p "$OUT_DIR" "$BENCHMARKS_RESULTS"'),
    ('[[ -f benchmarks/results/', '[[ -f "$BENCHMARKS_RESULTS/'),
    ('[[ -f benchmarks/competitive/', '[[ -f "$BENCHMARKS_COMPETITIVE/'),
    ('OUT="$ROOT/benchmarks/results/', 'OUT="$BENCHMARKS_RESULTS/'),
    ('REGISTRY="$ROOT/benchmarks/competitive/', 'REGISTRY="$BENCHMARKS_COMPETITIVE/'),
]

SKIP_FILES = {
    "lib/benchmarks-env.sh",
    "bench-via-benchmarks.sh",
    "migrate-benchmarks-out-of-lic.py",
}


def inject_source(text: str) -> str:
    if "benchmarks-env.sh" in text:
        return text
    m = re.search(r'^ROOT="\$\(cd "\$\(dirname "\$0"\)/\.\." && pwd\)"\s*$', text, re.M)
    if not m:
        return text
    insert_at = m.end()
    return text[:insert_at] + "\n" + SOURCE_LINE + text[insert_at:]


def patch_script(path: Path) -> bool:
    rel = path.relative_to(LIC / "scripts").as_posix()
    if rel in SKIP_FILES:
        return False
    text = path.read_text(encoding="utf-8")
    if "benchmarks/harness" not in text and "benchmarks/results" not in text and "benchmarks/competitive" not in text:
        return False
    orig = text
    text = inject_source(text)
    for old, new in REPLACEMENTS:
        text = text.replace(old, new)
    if text == orig:
        return False
    path.write_text(text, encoding="utf-8", newline="\n")
    return True


def main() -> int:
    patched = []
    for path in sorted((LIC / "scripts").rglob("*")):
        if path.suffix not in (".sh", ".py") or not path.is_file():
            continue
        if patch_script(path):
            patched.append(path.relative_to(LIC).as_posix())
    print(f"patched {len(patched)} scripts")
    for p in patched[:30]:
        print(f"  {p}")
    if len(patched) > 30:
        print(f"  ... +{len(patched) - 30} more")

    bench_dir = LIC / "benchmarks"
    readme = bench_dir / "README.md"
    if bench_dir.is_dir():
        shutil.rmtree(bench_dir)
    bench_dir.mkdir()
    readme.write_text(
        """# Benchmarks moved to li-langverse/benchmarks

All harness drivers, workloads, and bench results live in the **benchmarks** repo.

```bash
export BENCHMARKS_ROOT=/path/to/benchmarks   # sibling checkout
export LIC_ROOT=/path/to/lic
"$BENCHMARKS_ROOT/scripts/run-bench.sh" --tier 1
# or from lic:
./scripts/bench-via-benchmarks.sh --tier 1
```

See `../benchmarks/docs/ecosystem/benchmarks-single-repo-layout.md`.
""",
        encoding="utf-8",
    )
    print("replaced lic/benchmarks/ with README.md only")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
