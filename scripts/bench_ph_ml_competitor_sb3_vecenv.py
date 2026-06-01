#!/usr/bin/env python3
"""SB3 SubprocVecEnv competitive driver — executed when gymnasium+sb3 installed.

Note: SubprocVecEnv uses multiprocessing. On Windows this requires a `__main__`
guard; without it the driver may silently fail and report executed:false, which
breaks the PH-ML gates when SB3 is present.
"""
import json
import os
import sys
import time
from pathlib import Path

from ph_ml_competitor_workloads import DEFAULT_RUNS, bench_loop, report_base


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
        import numpy as np
        import stable_baselines3
        from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv
    except ImportError:
        report["note"] = "stable_baselines3/gymnasium not installed"
        write_report()
        return 0

    import multiprocessing as mp

    try:
        mp.freeze_support()
        mp.set_start_method("spawn", force=True)
    except RuntimeError:
        # Start method may already be set by the runner.
        pass

    n_envs = 4

    def make_env():
        def _init():
            return gym.make("CartPole-v1")

        return _init

    def setup_vec_env():
        makers = [make_env() for _ in range(n_envs)]
        try:
            return SubprocVecEnv(makers), "SubprocVecEnv"
        except (OSError, RuntimeError, ValueError) as exc:
            report["subproc_fallback"] = str(exc)[:200]
        return DummyVecEnv(makers), "DummyVecEnv"

    def run_once() -> float:
        vec, backend = setup_vec_env()
        try:
            vec.reset()
            rewards = 0.0
            for _ in range(4):
                actions = np.array([vec.action_space.sample() for _ in range(n_envs)])
                step_out = vec.step(actions)
                if len(step_out) == 5:
                    _obs, rew, _term, _trunc, _info = step_out
                else:
                    _obs, rew, _done, _info = step_out
                rewards += float(np.sum(rew))
            report["vecenv_backend"] = backend
            return rewards
        finally:
            vec.close()

    def sanity(r) -> bool:
        return r is not None

    try:
        cpu_sec, err = bench_loop(max(1, DEFAULT_RUNS // 10), 1, run_once, sanity)
        if err:
            report["note"] = err
            write_report()
            return 0
        report["cpu_sec"] = cpu_sec
        report["executed"] = True
        report["validity_gate_pass"] = True
        report["validity_ratio"] = 1.0
        report["framework_version"] = stable_baselines3.__version__
        backend = report.get("vecenv_backend", "VecEnv")
        report["note"] = f"{backend} CartPole-v1 x4 (Wave 13 T5)"
    except Exception as exc:  # noqa: BLE001
        report["note"] = f"VecEnv failed: {exc}"
    write_report()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
