#!/usr/bin/env python3
"""Compare li_serial / li_parallel against all registry bench SOTAs (WP-PAR-40+).

Reads benchmarks/competitive/registry.toml for competitor langs, scans latest.csv
for wall_time rows, and emits JSON + optional markdown summary.

SOTA policy matches org dashboard: best_competitor_lang_excludes_li (li/li_serial/li_parallel).
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

LI_LANGS = frozenset({"li", "li_serial", "li_parallel", "harness"})
DEFAULT_THRESHOLD_VS_CPP = 1.2


def _load_registry(path: Path) -> tuple[list[str], dict[str, str]]:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    langs: set[str] = set()
    notes: dict[str, str] = {}
    for eco in data.get("ecosystem") or []:
        if not isinstance(eco, dict):
            continue
        track = eco.get("track", "")
        lang = eco.get("csv_lang") or ""
        if track in ("bench_tier1", "bench_tier2") and lang and lang not in LI_LANGS:
            langs.add(lang)
            notes[lang] = str(eco.get("id", lang))
    return sorted(langs), notes


def _read_wall_times(path: Path) -> dict[tuple[str, str], float]:
    out: dict[tuple[str, str], float] = {}
    with path.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row.get("metric") != "wall_time":
                continue
            bench = row.get("benchmark") or ""
            lang = row.get("lang") or ""
            if not bench or not lang:
                continue
            try:
                val = float(row["value"])
            except (KeyError, TypeError, ValueError):
                continue
            if val <= 0:
                continue
            out[(bench, lang)] = val
    return out


def _best_sota(
    bench: str, rows: dict[tuple[str, str], float], competitor_langs: list[str]
) -> tuple[str | None, float | None]:
    best_lang: str | None = None
    best_val: float | None = None
    for lang in competitor_langs:
        val = rows.get((bench, lang))
        if val is None:
            continue
        if best_val is None or val < best_val:
            best_lang = lang
            best_val = val
    return best_lang, best_val


def _relative_perf(li_val: float, sota_val: float) -> float:
    """>1.0 means Li is faster than SOTA (lower wall time)."""
    return sota_val / li_val


def _status(relative: float | None, *, threshold: float) -> str:
    if relative is None:
        return "unknown"
    if relative >= 1.0:
        return "beats_sota"
    if relative >= 1.0 / threshold:
        return "within_threshold"
    return "behind"


def build_report(
    *,
    csv_path: Path,
    registry_path: Path,
    threshold_vs_cpp: float,
    ph_ml_path: Path | None,
) -> dict:
    competitor_langs, eco_ids = _load_registry(registry_path)
    rows = _read_wall_times(csv_path)

    benchmarks = sorted({b for (b, _lang) in rows if _lang in LI_LANGS})
    entries: list[dict] = []

    for bench in benchmarks:
        li_serial = rows.get((bench, "li_serial")) or rows.get((bench, "li"))
        li_parallel = rows.get((bench, "li_parallel"))
        if li_serial is None and li_parallel is None:
            continue

        sota_lang, sota_val = _best_sota(bench, rows, competitor_langs)
        competitors: dict[str, float | None] = {
            lang: rows.get((bench, lang)) for lang in competitor_langs
        }

        def _li_block(label: str, val: float | None) -> dict | None:
            if val is None:
                return None
            rel = _relative_perf(val, sota_val) if sota_val else None
            cpp = competitors.get("cpp")
            vs_cpp = (val / cpp) if cpp and cpp > 0 else None
            speedup = (li_serial / val) if li_serial and val > 0 else None
            return {
                "wall_sec": round(val, 6),
                "vs_best_sota": round(rel, 4) if rel is not None else None,
                "ratio_vs_cpp": round(vs_cpp, 4) if vs_cpp is not None else None,
                "speedup_vs_serial": round(speedup, 4) if speedup is not None else None,
                "status": _status(rel, threshold=threshold_vs_cpp),
            }

        entries.append(
            {
                "benchmark": bench,
                "best_sota": {
                    "lang": sota_lang,
                    "ecosystem": eco_ids.get(sota_lang or "", sota_lang),
                    "wall_sec": round(sota_val, 6) if sota_val else None,
                },
                "competitors": {
                    lang: round(v, 6) if v is not None else None
                    for lang, v in competitors.items()
                },
                "li_serial": _li_block("li_serial", li_serial),
                "li_parallel": _li_block("li_parallel", li_parallel),
            }
        )

    summary = {
        "benchmarks_with_li": len(entries),
        "li_parallel_beats_sota": sum(
            1
            for e in entries
            if e.get("li_parallel")
            and e["li_parallel"].get("status") == "beats_sota"
        ),
        "li_parallel_within_threshold": sum(
            1
            for e in entries
            if e.get("li_parallel")
            and e["li_parallel"].get("status") == "within_threshold"
        ),
        "li_parallel_behind": sum(
            1
            for e in entries
            if e.get("li_parallel")
            and e["li_parallel"].get("status") == "behind"
        ),
        "li_serial_beats_sota": sum(
            1
            for e in entries
            if e.get("li_serial") and e["li_serial"].get("status") == "beats_sota"
        ),
    }

    report: dict = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "csv": str(csv_path),
        "registry": str(registry_path),
        "competitor_langs": competitor_langs,
        "threshold_vs_cpp": threshold_vs_cpp,
        "sota_policy": "best_competitor_lang_excludes_li",
        "summary": summary,
        "entries": entries,
    }

    if ph_ml_path and ph_ml_path.is_file():
        report["ph_ml_competitive"] = json.loads(ph_ml_path.read_text(encoding="utf-8"))

    return report


def _markdown(report: dict) -> str:
    s = report["summary"]
    lines = [
        "# li-parallel vs SOTA report",
        "",
        f"Generated: {report['generated_at']}",
        f"CSV: `{report['csv']}`",
        "",
        "## Summary",
        "",
        f"| Metric | Count |",
        f"|--------|------:|",
        f"| Benchmarks with Li rows | {s['benchmarks_with_li']} |",
        f"| **li_parallel** beats best SOTA | {s['li_parallel_beats_sota']} |",
        f"| **li_parallel** within {report['threshold_vs_cpp']}× of SOTA | {s['li_parallel_within_threshold']} |",
        f"| **li_parallel** behind SOTA | {s['li_parallel_behind']} |",
        f"| **li_serial** beats best SOTA | {s['li_serial_beats_sota']} |",
        "",
        "## Per-benchmark (li_parallel vs best competitor)",
        "",
        "| Benchmark | SOTA | SOTA (s) | li_parallel (s) | vs SOTA | vs cpp | speedup | status |",
        "|-----------|------|----------|-----------------|---------|--------|---------|--------|",
    ]
    for e in report["entries"]:
        lp = e.get("li_parallel") or {}
        bs = e.get("best_sota") or {}
        if not lp:
            continue
        lines.append(
            "| {bench} | {slang} | {sval} | {lpval} | {vs} | {vcpp} | {sp} | {st} |".format(
                bench=e["benchmark"],
                slang=bs.get("lang") or "—",
                sval=bs.get("wall_sec") if bs.get("wall_sec") is not None else "—",
                lpval=lp.get("wall_sec", "—"),
                vs=lp.get("vs_best_sota", "—"),
                vcpp=lp.get("ratio_vs_cpp", "—"),
                sp=lp.get("speedup_vs_serial", "—"),
                st=lp.get("status", "—"),
            )
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--csv", type=Path, required=True)
    ap.add_argument("--registry", type=Path, required=True)
    ap.add_argument("--out-json", type=Path, required=True)
    ap.add_argument("--out-md", type=Path, default=None)
    ap.add_argument("--ph-ml", type=Path, default=None)
    ap.add_argument(
        "--threshold-vs-cpp",
        type=float,
        default=float(
            __import__("os").environ.get("LI_LIPAR_MAX_VS_CPP", DEFAULT_THRESHOLD_VS_CPP)
        ),
    )
    args = ap.parse_args()

    if not args.csv.is_file():
        print(f"error: missing CSV {args.csv}", file=sys.stderr)
        return 1
    if not args.registry.is_file():
        print(f"error: missing registry {args.registry}", file=sys.stderr)
        return 1

    report = build_report(
        csv_path=args.csv.resolve(),
        registry_path=args.registry.resolve(),
        threshold_vs_cpp=args.threshold_vs_cpp,
        ph_ml_path=args.ph_ml.resolve() if args.ph_ml else None,
    )
    args.out_json.parent.mkdir(parents=True, exist_ok=True)
    args.out_json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"li_parallel_sota: wrote {args.out_json}")
    print(
        "li_parallel_sota: "
        f"parallel beats={report['summary']['li_parallel_beats_sota']} "
        f"within={report['summary']['li_parallel_within_threshold']} "
        f"behind={report['summary']['li_parallel_behind']}"
    )

    if args.out_md:
        args.out_md.parent.mkdir(parents=True, exist_ok=True)
        args.out_md.write_text(_markdown(report), encoding="utf-8")
        print(f"li_parallel_sota: wrote {args.out_md}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
