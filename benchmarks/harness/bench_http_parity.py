"""Nginx vs li-httpd ratio checks for tier5_http agent-gateway scenarios."""

from __future__ import annotations

import os
from typing import Any


def metric_rows(rows: list[dict[str, object]], *, benchmark: str, lang: str, metric: str) -> list[dict[str, object]]:
    out: list[dict[str, object]] = []
    for row in rows:
        if row.get("benchmark") != benchmark:
            continue
        if row.get("lang") != lang:
            continue
        if row.get("metric") != metric:
            continue
        out.append(row)
    return out


def best_metric(rows: list[dict[str, object]], *, higher_better: bool) -> float | None:
    vals: list[float] = []
    for row in rows:
        try:
            vals.append(float(row["value"]))
        except (TypeError, ValueError, KeyError):
            continue
    if not vals:
        return None
    return max(vals) if higher_better else min(vals)


def scenario_parity_thresholds(
    name: str,
    cfg_by_name: dict[str, dict[str, Any]] | None,
    *,
    rps_min: float,
    p99_max: float,
    ttfb_min: float,
) -> tuple[float, float, float]:
    if not cfg_by_name or name not in cfg_by_name:
        return rps_min, p99_max, ttfb_min
    parity = cfg_by_name[name].get("parity") or {}
    if not isinstance(parity, dict):
        return rps_min, p99_max, ttfb_min
    rps = float(parity.get("rps_ratio_min", rps_min))
    p99 = float(parity.get("p99_ratio_max", p99_max))
    ttfb = float(parity.get("ttfb_ratio_min", ttfb_min))
    return rps, p99, ttfb


def check_parity_ratios(
    rows: list[dict[str, object]],
    scenarios: list[str],
    *,
    rps_min: float | None = None,
    p99_max: float | None = None,
    ttfb_min: float | None = None,
    cfg_by_name: dict[str, dict[str, Any]] | None = None,
) -> tuple[bool, list[str]]:
    """li must meet or beat nginx: RPS ratio >= rps_min, p99 ratio <= p99_max, TTFB ratio >= ttfb_min."""
    default_rps = float(os.environ.get("HTTPD_BENCH_RPS_RATIO_MIN", rps_min if rps_min is not None else "0.95"))
    default_p99 = float(os.environ.get("HTTPD_BENCH_P99_RATIO_MAX", p99_max if p99_max is not None else "2.0"))
    default_ttfb = float(os.environ.get("HTTPD_BENCH_TTFB_RATIO_MIN", ttfb_min if ttfb_min is not None else "0.85"))
    notes: list[str] = []
    ok_all = True
    for name in scenarios:
        parity_meta = (cfg_by_name or {}).get(name, {}).get("parity") if cfg_by_name else None
        if isinstance(parity_meta, dict) and parity_meta.get("verify_only"):
            notes.append(f"{name}: verify-only (skip parity timing)")
            continue
        rps_min_s, p99_max_s, ttfb_min_s = scenario_parity_thresholds(
            name, cfg_by_name, rps_min=default_rps, p99_max=default_p99, ttfb_min=default_ttfb
        )
        nginx_rps = best_metric(
            metric_rows(rows, benchmark=name, lang="nginx", metric="rps"), higher_better=True
        )
        li_rps = best_metric(metric_rows(rows, benchmark=name, lang="li", metric="rps"), higher_better=True)
        if nginx_rps is not None:
            if li_rps is None or li_rps <= 0:
                line = f"{name}: rps li/nginx=0.000 (li={li_rps or 0:.0f} nginx={nginx_rps:.0f})"
                notes.append(line)
                ok_all = False
                notes.append(f"  FAIL rps ratio < {rps_min_s}")
            else:
                ratio = li_rps / nginx_rps
                line = f"{name}: rps li/nginx={ratio:.3f} (li={li_rps:.0f} nginx={nginx_rps:.0f})"
                notes.append(line)
                if ratio < rps_min_s:
                    ok_all = False
                    notes.append(f"  FAIL rps ratio < {rps_min_s}")
        nginx_p99 = best_metric(
            metric_rows(rows, benchmark=name, lang="nginx", metric="p99_latency_ms"),
            higher_better=False,
        )
        li_p99 = best_metric(
            metric_rows(rows, benchmark=name, lang="li", metric="p99_latency_ms"),
            higher_better=False,
        )
        if nginx_p99 and li_p99 and nginx_p99 > 0:
            ratio = li_p99 / nginx_p99
            line = f"{name}: p99 li/nginx={ratio:.3f} (li={li_p99:.2f}ms nginx={nginx_p99:.2f}ms)"
            notes.append(line)
            if ratio > p99_max_s:
                ok_all = False
                notes.append(f"  FAIL p99 ratio > {p99_max_s}")
        nginx_ttfb = best_metric(
            metric_rows(rows, benchmark=name, lang="nginx", metric="ttfb_ms"),
            higher_better=False,
        )
        li_ttfb = best_metric(
            metric_rows(rows, benchmark=name, lang="li", metric="ttfb_ms"),
            higher_better=False,
        )
        if nginx_ttfb and li_ttfb and li_ttfb > 0:
            # Higher ratio = li is closer to nginx speed (li_ms/nginx_ms); want >= ttfb_min.
            ratio = nginx_ttfb / li_ttfb
            line = f"{name}: ttfb li/nginx={ratio:.3f} (li={li_ttfb:.2f}ms nginx={nginx_ttfb:.2f}ms)"
            notes.append(line)
            if ratio < ttfb_min_s:
                ok_all = False
                notes.append(f"  FAIL ttfb ratio < {ttfb_min_s}")
    return ok_all, notes
