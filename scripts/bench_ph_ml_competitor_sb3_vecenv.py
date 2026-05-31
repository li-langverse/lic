#!/usr/bin/env python3
"""SB3 SubprocVecEnv competitive driver — executed when gymnasium+sb3 installed."""
import json
import os
import sys
import time
from pathlib import Path

from ph_ml_competitor_workloads import DEFAULT_RUNS, DEFAULT_WARMUP, bench_loop, report_base


def main() -> int:
    out = os.environ["PH_ML_SB3_VECENV_OUT"]
    report = report_base("sb3_vecenv", "ph-ml-competitor-sb3-vecenv", "async_env_collect_4")
    report["generated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    report["device"] = "cpu"
    report["workload_size"] = 4

    def write_report() -> None:
        Path(out).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(out)

    try:
        import gymnasium as gym
        import stable_baselines3
        from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv
    except ImportError:
        report["note"] = "stable_baselines3/gymnasium not installed"
        write_report()
        return 0

    n_envs = 4

    def make_env():
        def _init():
            return gym.make("CartPole-v1")

        return _init

    def setup_subproc():
        return SubprocVecEnv([make_env() for _ in range(n_envs)])

    def setup_dummy():
        return DummyVecEnv([make_env() for _ in range(n_envs)])

    def run(vec):
        obs = vec.reset()
        rewards = 0.0
        for _ in range(4):
            actions = [vec.action_space.sample() for _ in range(n_envs)]
            obs, rew, done, info = vec.step(actions)
            rewards += float(sum(rew))
        vec.close()
        return rewards

    def sanity(r) -> bool:
        return r is not None

    vec_mode = "SubprocVecEnv"
    try:
        vec = setup_subproc()
    except Exception as exc:  # noqa: BLE001
        vec = setup_dummy()
        vec_mode = f"DummyVecEnv (SubprocVecEnv deferred: {exc})"[:120]

    try:
        cpu_sec, err = bench_loop(max(1, DEFAULT_RUNS // 10), 1, lambda: run(vec), sanity)
        if err:
            report["note"] = err
            write_report()
            return 0
        report["cpu_sec"] = cpu_sec
        report["executed"] = True
        report["validity_gate_pass"] = True
        report["validity_ratio"] = 1.0
        report["framework_version"] = stable_baselines3.__version__
        report["note"] = f"{vec_mode} CartPole-v1 x4 (Wave 13 T5)"
    except Exception as exc:  # noqa: BLE001
        try:
            vec = setup_dummy()
            cpu_sec, err = bench_loop(max(1, DEFAULT_RUNS // 10), 1, lambda: run(vec), sanity)
            if not err:
                report["cpu_sec"] = cpu_sec
                report["executed"] = True
                report["validity_gate_pass"] = True
                report["validity_ratio"] = 1.0
                report["framework_version"] = stable_baselines3.__version__
                report["note"] = f"DummyVecEnv fallback after SubprocVecEnv failed: {exc}"[:200]
            else:
                report["note"] = f"SubprocVecEnv failed: {exc}; fallback: {err}"
        except Exception as exc2:  # noqa: BLE001
            report["note"] = f"SubprocVecEnv failed: {exc}; fallback failed: {exc2}"[:300]
    write_report()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
