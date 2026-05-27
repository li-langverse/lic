#!/usr/bin/env python3
"""Unit tests for analytical tier-1 oracles and deviation reporting."""

from __future__ import annotations

import math
import sys
import unittest
from pathlib import Path

HARNESS = Path(__file__).resolve().parent
sys.path.insert(0, str(HARNESS))

import reference as ref  # noqa: E402


class ReferenceAnalyticalTest(unittest.TestCase):
    def test_horner_closed_form_matches_iterative_large(self) -> None:
        a = ref.horner_analytical(steps=5_000_000)
        b = ref.horner_iterative(steps=5_000_000)
        self.assertTrue(ref.float_close(a, b, rtol=1e-12, atol=0.0))
        report = ref.deviation_report(b, a, label="iter", reference_kind="analytical")
        self.assertLess(report.ulps, 100.0)

    def test_reduce_sum_analytical_matches_iterative(self) -> None:
        n = 100_000_000
        a = ref.reduce_sum_analytical(n)
        b = ref.reduce_sum_spec(n)
        self.assertTrue(ref.float_close(a, b, rtol=1e-6, atol=1.0))

    def test_horner_tier1_oracle_matches_bench_x(self) -> None:
        case = ref.TIER1_REFERENCE["horner_pure_li"]
        self.assertEqual(case.oracle, "iterative")
        self.assertAlmostEqual(
            case.compute_full(),
            ref.horner_iterative(steps=5_000_000, x=ref.HORNER_BENCH_X),
        )
        self.assertAlmostEqual(
            case.compute_small(),
            ref.horner_analytical(steps=8, x=ref.HORNER_BENCH_X),
        )

    def test_deviation_report_within_1ulp_self(self) -> None:
        x = 1.5
        report = ref.deviation_report(x, x, label="x", reference_kind="analytical")
        self.assertTrue(report.within_machine_epsilon)
        self.assertEqual(report.ulps, 0.0)

    def test_format_deviation_line(self) -> None:
        report = ref.deviation_report(
            1.0,
            1.0 + 2.0 * math.ulp(1.0),
            label="Li",
            reference_kind="analytical",
        )
        line = ref.format_deviation_line(report)
        self.assertIn("within_1ulp=", line)
        self.assertIn("ulps=", line)


if __name__ == "__main__":
    raise SystemExit(unittest.main(verbosity=2))
