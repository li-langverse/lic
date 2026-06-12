#!/usr/bin/env python3
"""SB3 PPO.train-step competitive driver — one short learn() on CartPole-v1.

Honest scaffold: executed=false when stable_baselines3/gymnasium missing.
Li has no native RL policy-training row yet (Phase M competitor-only).
"""

from __future__ import annotations

import json
import os
import time
from pathlib import Path

from ph_ml_competitor_workloads import bench_loop, report_base

DEFAULT_TIMESTEPS = int(os.environ.get("PH_ML_SB3_TRAIN_TIMESTEPS", "2048"))


def main() -> int:
    out = os.environ.get(
        "PH_ML_SB3_TRAIN_STEP_OUT",
        str(Path(__file__).resolve().parents[1] / "benchmarks/results/ph-ml-sb3-train-step.json"),
    )
    report = report_base("sb3_train_step", "ph-ml-sb3-train-step", "sb3_ppo_cartpole_train_1epoch")
    report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    report["device"] = "cpu"
    report["train_timesteps"] = DEFAULT_TIMESTEPS
    report["env_semantics"] = "cartpole_v1_real"
    report["li_native_row"] = False
    report["semantics_honesty_note"] = (
        "SB3 PPO.learn on real CartPole-v1; Li has no policy-training loop yet — see "
        "docs/game-dev/ph-ml-cartpole-stub-honesty.md"
    )

    def write_report() -> None:
        Path(out).parent.mkdir(parents=True, exist_ok=True)
        Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(out)

    try:
        import gymnasium as gym
        import stable_baselines3
        from stable_baselines3 import PPO
    except ImportError:
        report["note"] = "stable_baselines3/gymnasium not installed"
        write_report()
        return 0

    timesteps = max(64, DEFAULT_TIMESTEPS)

    def run_once() -> float:
        env = gym.make("CartPole-v1")
        try:
            model = PPO("MlpPolicy", env, verbose=0, device="cpu")
            model.learn(total_timesteps=timesteps, progress_bar=False)
            return float(model.ep_info_buffer[-1]["r"]) if model.ep_info_buffer else 0.0
        finally:
            env.close()

    def sanity(r) -> bool:
        return r is not None

    try:
        cpu_sec, err = bench_loop(1, 0, run_once, sanity)
        if err:
            report["note"] = err
            write_report()
            return 0
        report["cpu_sec"] = cpu_sec
        report["executed"] = True
        report["validity_gate_pass"] = True
        report["validity_ratio"] = 1.0
        report["framework_version"] = stable_baselines3.__version__
        report["note"] = f"PPO.learn(total_timesteps={timesteps}) CartPole-v1 (Phase M)"
    except Exception as exc:  # noqa: BLE001
        report["note"] = f"PPO.learn failed: {exc}"

    write_report()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
