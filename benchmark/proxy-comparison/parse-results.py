#!/usr/bin/env python3
"""Merge benchmark JSONL + resource samples into RESULTS.md and results.csv."""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path


CONCURRENCY = {
    "li-httpd": "2 worker processes, epoll event loop per worker, Li-owned proxy relay",
    "nginx-proxy": "auto worker_processes, epoll per worker, async upstream→client buffers",
    "caddy-proxy": "Go runtime, goroutine-per-connection, reverse_proxy flush",
    "haproxy-proxy": "single process, event-driven (epoll/kqueue), connection-oriented HTTP mode",
}


def load_jsonl(path: Path) -> list[dict]:
    rows = []
    if not path.exists():
        return rows
    for line in path.read_text().splitlines():
        line = line.strip()
        if line:
            rows.append(json.loads(line))
    return rows


def main() -> int:
    out_dir = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    results_path = out_dir / "results.jsonl"
    rows = load_jsonl(results_path)
    if not rows:
        (out_dir / "RESULTS.md").write_text("# Proxy comparison\n\nNo results captured.\n")
        return 1

    # Attach RSS from parallel_18 sampler
    enriched = []
    for r in rows:
        proxy = r["proxy"]
        res_file = out_dir / f"resources-{proxy}.json"
        rss_mb = 0.0
        cpu_max = 0.0
        if res_file.exists():
            res = json.loads(res_file.read_text())
            rss_mb = res.get("rss_mb_max", 0)
            cpu_max = res.get("cpu_pct_max", 0)
        enriched.append({**r, "rss_mb_parallel18": rss_mb, "cpu_pct_max_parallel18": cpu_max})

    csv_path = out_dir / "results.csv"
    fields = [
        "proxy", "workload", "success_rate", "requests", "success",
        "rps", "bps", "latency_p50", "latency_p95", "latency_p99",
        "rss_mb_parallel18", "cpu_pct_max_parallel18",
    ]
    with csv_path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        for r in enriched:
            w.writerow(r)

    meta = {}
    meta_path = out_dir / "meta.json"
    if meta_path.exists():
        meta = json.loads(meta_path.read_text())

    lines = [
        "# Proxy comparison results",
        "",
        f"- **Run**: `{meta.get('timestamp_utc', 'unknown')}`",
        f"- **lic branch**: `{meta.get('lic_git_branch', '?')}` @ `{meta.get('lic_git_sha', '?')}`",
        "- **Backend**: nginx static (GitLab sign_in assets, 18 paths)",
        "- **TLS**: self-signed `gitlab.lilangverse.xyz`, curl `--resolve`",
        "",
        "## Summary table",
        "",
        "| Proxy | Workload | Success rate | p95 latency (s) | RSS MB (parallel 18) | RPS |",
        "|-------|----------|--------------|-----------------|----------------------|-----|",
    ]
    for r in enriched:
        sr = f"{100 * r['success_rate']:.1f}%"
        lines.append(
            f"| {r['proxy']} | {r['workload']} | {sr} "
            f"({r['success']}/{r['requests']}) | {r['latency_p95']:.3f} "
            f"| {r['rss_mb_parallel18']:.1f} | {r['rps']:.1f} |"
        )

    lines.extend(["", "## Concurrency models", ""])
    for proxy, desc in CONCURRENCY.items():
        lines.append(f"- **{proxy}**: {desc}")

    lines.extend(["", "## Raw files", "", f"- `{results_path.name}`", f"- `{csv_path.name}`"])
    (out_dir / "RESULTS.md").write_text("\n".join(lines) + "\n")

    # Copy to benchmark root RESULTS.md (latest)
    root_results = out_dir.parent.parent / "RESULTS.md"
    if out_dir.parent.name == "results":
        root_results.write_text((out_dir / "RESULTS.md").read_text())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
