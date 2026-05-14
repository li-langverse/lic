#!/usr/bin/env python3
"""Generate X-ready benchmark plots from results/latest.csv."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

import pandas as pd

HARNESS = Path(__file__).resolve().parent
REPO = HARNESS.parent.parent
RESULTS = REPO / "benchmarks" / "results"
SHARE = RESULTS / "share"

sys.path.insert(0, str(HARNESS))
from plot_theme import (  # noqa: E402
    LANG_COLORS,
    MUTED,
    PRIMARY,
    TEXT,
    brand_figure,
    save_share,
)


def git_sha() -> str:
    try:
        return (
            subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=REPO)
            .decode()
            .strip()
        )
    except Exception:
        return "unknown"


def load_csv(path: Path) -> pd.DataFrame:
    if not path.exists():
        raise FileNotFoundError(f"missing {path}")
    return pd.read_csv(path)


def load_verify_df() -> pd.DataFrame | None:
    verify_path = RESULTS / "verify.csv"
    if not verify_path.exists():
        return None
    return pd.read_csv(verify_path)


def plot_speed_bars(df: pd.DataFrame, tier: str, out: Path) -> None:
    import matplotlib.pyplot as plt
    import numpy as np

    sub = df[df["benchmark"].str.contains(tier, case=False, na=False)] if tier != "all" else df
    if sub.empty:
        sub = df
    time_df = sub[sub["metric"].isin(["wall_time", "time", "latency"]) | sub["unit"].str.contains("s", na=False)]
    if time_df.empty:
        time_df = sub

    benchmarks = sorted(time_df["benchmark"].unique())
    langs = sorted(time_df["lang"].unique())
    x = np.arange(len(benchmarks))
    width = 0.8 / max(len(langs), 1)

    fig, ax = brand_figure(
        "Benchmark throughput",
        f"Lower is better · tier={tier} · sha={git_sha()}",
    )
    for i, lang in enumerate(langs):
        vals = []
        for b in benchmarks:
            row = time_df[(time_df["benchmark"] == b) & (time_df["lang"] == lang)]
            vals.append(float(row["value"].iloc[0]) if len(row) else 0)
        offset = (i - len(langs) / 2 + 0.5) * width
        ax.bar(
            x + offset,
            vals,
            width * 0.92,
            label=lang,
            color=LANG_COLORS.get(lang, PRIMARY),
            edgecolor="none",
        )
        for xi, v in zip(x + offset, vals):
            if v > 0:
                ax.text(xi, v, f"{v:.2g}", ha="center", va="bottom", fontsize=8, color=MUTED)

    ax.set_xticks(x)
    ax.set_xticklabels(benchmarks, rotation=20, ha="right")
    ax.set_ylabel(time_df["unit"].iloc[0] if len(time_df) else "value")
    ax.legend(loc="upper right", framealpha=0.9)
    ax.grid(axis="y", linestyle="--", linewidth=0.6)
    plt.tight_layout()
    save_share(fig, out)
    plt.close(fig)


def plot_speedup_vs_cpp(df: pd.DataFrame, out: Path) -> None:
    import matplotlib.pyplot as plt
    import numpy as np

    li = df[df["lang"] == "li"].set_index("benchmark")["value"]
    cpp = df[df["lang"] == "cpp"].set_index("benchmark")["value"]
    common = li.index.intersection(cpp.index)
    if len(common) == 0:
        return
    speedup = (cpp[common] / li[common]).sort_values()

    fig, ax = brand_figure("Li vs C++ speedup", "Ratio > 1 means Li is faster")
    colors = [PRIMARY if v >= 1 else "#f85149" for v in speedup.values]
    y = np.arange(len(speedup))
    ax.barh(y, speedup.values, color=colors, edgecolor="none", height=0.65)
    ax.axvline(1.0, color=MUTED, linestyle="--", linewidth=1.2, label="parity")
    ax.set_yticks(y)
    ax.set_yticklabels(speedup.index)
    ax.set_xlabel("× speedup (cpp_time / li_time)")
    ax.legend(loc="lower right")
    ax.grid(axis="x", linestyle="--", linewidth=0.6)
    plt.tight_layout()
    save_share(fig, out)
    plt.close(fig)


def plot_correctness_grid(df: pd.DataFrame, out: Path) -> None:
    import matplotlib.pyplot as plt
    import numpy as np

    if "passed" not in df.columns:
        return
    benches = df["benchmark"].unique()
    langs = sorted(df["lang"].unique())
    grid = np.zeros((len(benches), len(langs)))
    for i, b in enumerate(benches):
        for j, lang in enumerate(langs):
            row = df[(df["benchmark"] == b) & (df["lang"] == lang)]
            grid[i, j] = 1.0 if len(row) and bool(row["passed"].iloc[0]) else 0.0

    fig, ax = brand_figure("Correctness gate", "Green = verify.py pass")
    im = ax.imshow(grid, aspect="auto", cmap="RdYlGn", vmin=0, vmax=1)
    ax.set_xticks(range(len(langs)))
    ax.set_xticklabels(langs)
    ax.set_yticks(range(len(benches)))
    ax.set_yticklabels(benches)
    for i in range(len(benches)):
        for j in range(len(langs)):
            sym = "✓" if grid[i, j] > 0.5 else "✗"
            ax.text(j, i, sym, ha="center", va="center", color=TEXT, fontsize=14)
    fig.colorbar(im, ax=ax, fraction=0.02, pad=0.02)
    plt.tight_layout()
    save_share(fig, out)
    plt.close(fig)


def main() -> int:
    parser = argparse.ArgumentParser(description="Plot benchmark CSV for X")
    parser.add_argument("--csv", type=Path, default=RESULTS / "latest.csv")
    parser.add_argument("--out", type=Path, default=SHARE)
    parser.add_argument("--tier", default="tier2")
    args = parser.parse_args()

    df = load_csv(args.csv)
    args.out.mkdir(parents=True, exist_ok=True)

    plot_speed_bars(df, args.tier, args.out / f"bench_speed_{args.tier}.png")
    plot_speedup_vs_cpp(df, args.out / "speedup_vs_cpp.png")
    verify_df = load_verify_df()
    if verify_df is not None and "passed" in verify_df.columns:
        plot_correctness_grid(verify_df, args.out / "correctness_tier0.png")

    print(f"wrote plots to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
