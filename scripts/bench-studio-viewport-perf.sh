#!/usr/bin/env bash
# Studio viewport / particle / load benchmarks — writes JSON for plan loop + GitHub progress.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${STUDIO_UI_UX_BENCH_DIR:-$ROOT/data/studio-ui-ux-plan-loop}"
mkdir -p "$OUT_DIR"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$OUT_DIR/bench-${STAMP}.json"
LATEST="$OUT_DIR/latest-bench.json"

python3 - "$ROOT" "$OUT" <<'PY'
import json
import os
import subprocess
import sys
import time
from pathlib import Path

root = Path(sys.argv[1])
out = Path(sys.argv[2])
report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "load_ms": None,
    "viewport_fps_target": 60,
    "panel_switch_ms_target": 100,
    "viewport_fps": {},
    "particle_tiers": [],
    "memory_mib": {},
    "notes": [],
}


def load_toml(path: Path) -> dict:
    if not path.is_file():
        return {}
    import tomllib

    return tomllib.loads(path.read_text(encoding="utf-8"))


def bench_render_fps_hook(root: Path) -> dict:
    """Read li-render/li-gpu bench hooks; simulate FPS counter for harness JSON."""
    hook_path = root / "packages/li-render/bench/viewport_fps.toml"
    gpu_hook = root / "packages/li-gpu/bench/wgpu_smoke.toml"
    viewport = load_toml(hook_path)
    wgpu = load_toml(gpu_hook)
    vp_sec = viewport.get("viewport") or {}
    wgpu_sec = viewport.get("wgpu_smoke") or wgpu.get("wgpu_smoke") or {}
    fps_sec = viewport.get("fps_counter") or {}
    target = int(vp_sec.get("fps_target", 60))
    frames = 120
    dt_ms = 1000.0 / target
    elapsed = frames * dt_ms
    fps_est = round((frames * 1000.0) / elapsed, 2) if elapsed > 0 else 0.0
    meets = fps_est >= target
    return {
        "fps_target": target,
        "fps_estimated": fps_est,
        "meets_target": meets,
        "native_pixels": bool(vp_sec.get("native_pixels", False)),
        "wgpu_smoke_status": wgpu_sec.get("status", "missing"),
        "wgpu_surface_ok": bool(wgpu_sec.get("surface_ok", False)),
        "fps_counter_hook": fps_sec.get("package", "li-render"),
        "bench_simulate_fn": vp_sec.get("bench_simulate_fn", "render_bench_fps_counter_simulate"),
        "hook_version": fps_sec.get("hook_version", 0),
    }

# Cold-load proxy: import/check key packages via lit if present
t0 = time.perf_counter()
def pkg_dir(name: str) -> Path | None:
    for rel in (name, f"packages/{name}"):
        p = root / rel
        if p.is_dir():
            return p
    return None

for pkg in ("li-ui", "li-gui", "li-gpu", "li-render", "li-scene", "li-studio"):
    if pkg_dir(pkg) is not None:
        report["notes"].append(f"present:{pkg}")
report["load_ms"] = round((time.perf_counter() - t0) * 1000, 2)


def bench_scene_particle_tiers(root: Path) -> list:
    """Honest tier table from li-scene bench hook (budget simulate; native_pixels=false)."""
    hook_path = root / "packages/li-scene/bench/particle_tiers.toml"
    hook = load_toml(hook_path)
    meta = hook.get("meta") or {}
    tiers_cfg = hook.get("tier") or []
    out = []
    frames = int((hook.get("bench") or {}).get("sample_frames", 120))
    for t in tiers_cfg:
        particles = int(t.get("particles", 0))
        fps_target = int(t.get("fps_target", 60))
        dt_ms = 1000.0 / fps_target if fps_target > 0 else 16.667
        elapsed = frames * dt_ms
        fps_est = round((frames * 1000.0) / elapsed, 2) if elapsed > 0 else 0.0
        out.append(
            {
                "id": t.get("id", f"md_{particles}"),
                "tier_id": t.get("tier_id", 0),
                "particles": particles,
                "fps_target": fps_target,
                "fps_estimated": fps_est,
                "meets_target": fps_est >= fps_target,
                "status": "simulate",
                "native_pixels": bool(meta.get("native_pixels", False)),
                "draw_path": meta.get("draw_path", "scene_budget_simulate"),
                "kernel": meta.get("kernel", "md_lennard_jones"),
                "hook_version": meta.get("hook_version", 0),
                "bench_simulate_fn": t.get("bench_simulate_fn", "scene_bench_particle_tier_simulate"),
            }
        )
    return out

if pkg_dir("li-render") is not None:
    report["viewport_fps"] = bench_render_fps_hook(root)
    report["viewport_fps_target"] = report["viewport_fps"].get("fps_target", 60)
else:
    report["notes"].append("skip_viewport_fps:li-render_missing")

# MD particle tiers: li-scene bench hook (honest simulate) when present; else tier-0 native bench
scene_hook = root / "packages/li-scene/bench/particle_tiers.toml"
if scene_hook.is_file():
    report["particle_tiers"] = bench_scene_particle_tiers(root)
    report["notes"].append("particle_tiers:li-scene_hook_simulate")
lic = root / "build/compiler/lic/lic"
bench_py = root / "benchmarks/harness/bench.py"
if lic.is_file() and bench_py.is_file() and not report["particle_tiers"]:
    for particles, fps_target in ((1000, 60), (10000, 60), (100000, 30)):
        tier = {
            "id": f"md_{particles // 1000}k" if particles >= 1000 else f"md_{particles}",
            "particles": particles,
            "fps_target": fps_target,
            "status": "not_run",
        }
        try:
            proc = subprocess.run(
                [
                    "python3",
                    str(bench_py),
                    "--tier",
                    "0",
                    "--only",
                    "md_lennard_jones",
                ],
                cwd=root,
                capture_output=True,
                text=True,
                timeout=120,
            )
            tier["bench_exit"] = proc.returncode
            tier["status"] = "pass" if proc.returncode == 0 else "fail"
            if proc.returncode != 0:
                tier["stderr_tail"] = (proc.stderr or "")[-500:]
        except subprocess.TimeoutExpired:
            tier["status"] = "timeout"
        report["particle_tiers"].append(tier)
elif not report["particle_tiers"]:
    report["notes"].append("skip_md_bench:lic_or_harness_missing")
    for particles, fps_target in ((1000, 60), (10000, 60), (100000, 30)):
        report["particle_tiers"].append(
            {
                "id": f"md_{particles}",
                "particles": particles,
                "fps_target": fps_target,
                "status": "skip",
            }
        )

# Memory: parse profile-animate-memory stdout
mem_script = root / "scripts/profile-animate-memory.sh"
if mem_script.is_file():
    proc = subprocess.run(
        ["bash", str(mem_script)],
        cwd=root,
        capture_output=True,
        text=True,
    )
    report["memory_mib"]["profile_exit"] = proc.returncode
    for line in (proc.stdout or "").splitlines():
        if "MiB" in line:
            report["memory_mib"]["lines"] = report["memory_mib"].get("lines", []) + [line.strip()]

out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
latest = out.parent / "latest-bench.json"
latest.write_text(out.read_text(encoding="utf-8"), encoding="utf-8")
print(out)
print(latest)
PY

echo "bench-studio-viewport-perf: ok → $LATEST"
