"""Normative float64 references for tier-1 micro benchmarks.

When a closed-form **analytical** solution exists, it is the primary oracle for
correctness. The iterative loop in ``common/*_core.c`` is still checked to stay
aligned with that oracle (and reported as *implementation drift*).

Verification always prints **absolute error, relative error, ULP distance**, and
whether the result is within **1 ULP** of the reference (machine-epsilon tight).

Python evaluates analytical formulas in float64 unless noted. Optional ``decimal``
checks on small sizes validate the analytical formula itself.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from decimal import Decimal
from typing import Callable, Literal


def format_result(value: float) -> str:
    """Match benchmark ``printf(\"%.17g\\n\", ...)``."""
    if math.isinf(value):
        return "inf" if value > 0 else "-inf"
    if math.isnan(value):
        return "nan"
    return f"{value:.17g}"


def parse_result(text: str) -> float:
    t = text.strip().lower()
    if t == "inf":
        return math.inf
    if t == "-inf":
        return -math.inf
    if t == "nan":
        return math.nan
    return float(text.strip())


def float_close(actual: float, expected: float, *, rtol: float, atol: float = 0.0) -> bool:
    if math.isnan(actual) or math.isnan(expected):
        return False
    if math.isinf(actual) or math.isinf(expected):
        return actual == expected
    scale = max(abs(expected), abs(actual), 1.0)
    return abs(actual - expected) <= atol + rtol * scale


def ulp_distance(actual: float, reference: float) -> float:
    """ULP gap between two float64 values (0 if bitwise equal)."""
    if math.isnan(actual) or math.isnan(reference):
        return math.inf
    if actual == reference:
        return 0.0
    if math.isinf(actual) or math.isinf(reference):
        return math.inf if actual != reference else 0.0
    base = reference
    if base == 0.0:
        base = actual
    step = math.ulp(base)
    if step == 0.0:
        return 0.0
    return abs(actual - reference) / step


@dataclass(frozen=True)
class DeviationReport:
    label: str
    reference_kind: Literal["analytical", "iterative", "spec"]
    actual: float
    reference: float
    abs_error: float
    rel_error: float
    ulps: float
    within_1ulp: bool

    @property
    def within_machine_epsilon(self) -> bool:
        """True when ``actual`` is at most 1 ULP from ``reference`` (float64)."""
        return self.within_1ulp


def deviation_report(
    actual: float,
    reference: float,
    *,
    label: str,
    reference_kind: Literal["analytical", "iterative", "spec"],
) -> DeviationReport:
    abs_err = abs(actual - reference)
    denom = max(abs(reference), 1.0)
    rel_err = abs_err / denom
    ulps = ulp_distance(actual, reference)
    return DeviationReport(
        label=label,
        reference_kind=reference_kind,
        actual=actual,
        reference=reference,
        abs_error=abs_err,
        rel_error=rel_err,
        ulps=ulps,
        within_1ulp=ulps <= 1.0,
    )


def format_deviation_line(report: DeviationReport) -> str:
    eps = "yes" if report.within_machine_epsilon else "no"
    return (
        f"{report.label} vs {report.reference_kind}: "
        f"ref={format_result(report.reference)} actual={format_result(report.actual)} "
        f"abs_err={report.abs_error:.6e} rel_err={report.rel_error:.6e} ulps={report.ulps:.2f} "
        f"within_1ulp={eps}"
    )


def print_deviation_reports(reports: list[DeviationReport], *, bench: str) -> None:
    if not reports:
        return
    print(f"{bench} numeric deviation:")
    for report in reports:
        print(f"  {format_deviation_line(report)}")


# --- analytical closed forms --------------------------------------------------


def horner_analytical(*, steps: int, x: float = 0.999999) -> float:
    """acc after ``steps`` updates ``acc = acc * x + 1`` from ``acc = 0``.

    Closed form: ``(1 - x**steps) / (1 - x)`` for ``x != 1``.
    """
    if steps <= 0:
        return 0.0
    if x == 1.0:
        return float(steps)
    return (1.0 - pow(x, steps)) / (1.0 - x)


def horner_iterative(*, steps: int, x: float = 0.999999) -> float:
    """Sequential float64 loop matching ``horner_core.c``."""
    acc = 0.0
    for _ in range(steps):
        acc = acc * x + 1.0
    return acc


def reduce_sum_analytical(n: int) -> float:
    """``sum_{i=0}^{n-1} (i & 1023) * 1e-6`` — exact period 1024."""
    if n <= 0:
        return 0.0
    period = 1024
    period_sum = 1e-6 * (1023 * 1024 // 2)
    full, rem = divmod(n, period)
    tail = 1e-6 * sum(range(rem))
    return full * period_sum + tail


def horner_analytical_decimal(*, steps: int, x: str = "0.999999") -> Decimal:
    xd = Decimal(x)
    if steps <= 0:
        return Decimal(0)
    if xd == 1:
        return Decimal(steps)
    return (Decimal(1) - xd**steps) / (Decimal(1) - xd)


def _decimal_context() -> None:
    from decimal import getcontext

    getcontext().prec = 50


def dot_spec_decimal(n: int) -> float:
    """High-precision dot spec (validates iterative ``dot_spec_sum`` on small ``n``)."""
    _decimal_context()
    acc = Decimal(0)
    for i in range(n):
        a = Decimal(i & 255) * Decimal("0.001")
        b = Decimal((i * 7) & 255) * Decimal("0.002")
        acc += a * b
    return float(acc)


def matmul_naive_spec_decimal(n: int) -> float:
    _decimal_context()
    a = [[Decimal((i + j) % 17) * Decimal("0.01") for j in range(n)] for i in range(n)]
    b = [[Decimal((i * 3 + j) % 13) * Decimal("0.02") for j in range(n)] for i in range(n)]
    c = [[Decimal(0) for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for k in range(n):
            aik = a[i][k]
            for j in range(n):
                c[i][j] += aik * b[k][j]
    acc = Decimal(0)
    for i in range(n):
        for j in range(n):
            acc += c[i][j]
    return float(acc)


def matmul_blocked_spec_decimal(n: int, *, block: int = 64) -> float:
    _decimal_context()
    a = [[Decimal((i + j) % 17) * Decimal("0.01") for j in range(n)] for i in range(n)]
    b = [[Decimal((i * 3 + j) % 13) * Decimal("0.02") for j in range(n)] for i in range(n)]
    c = [[Decimal(0) for _ in range(n)] for _ in range(n)]
    for ii in range(0, n, block):
        for kk in range(0, n, block):
            for jj in range(0, n, block):
                i_max = min(ii + block, n)
                k_max = min(kk + block, n)
                j_max = min(jj + block, n)
                for i in range(ii, i_max):
                    for k in range(kk, k_max):
                        aik = a[i][k]
                        for j in range(jj, j_max):
                            c[i][j] += aik * b[k][j]
    acc = Decimal(0)
    for i in range(n):
        for j in range(n):
            acc += c[i][j]
    return float(acc)


def primary_analytical_report(reports: list[DeviationReport]) -> DeviationReport | None:
    for report in reports:
        if report.reference_kind == "analytical" and "C-loop vs analytical" not in report.label:
            return report
    return None


def analytical_report_for_label(reports: list[DeviationReport], label: str) -> DeviationReport | None:
    for report in reports:
        if report.label == label and report.reference_kind == "analytical":
            return report
    return None


# --- kernel specs (iterative / C parity) --------------------------------------


def dot_spec_sum(n: int) -> float:
    """``dot_core.c``: fill ``a[i], b[i]`` then sum ``a[i]*b[i]``."""
    a = [float(i & 255) * 0.001 for i in range(n)]
    b = [float((i * 7) & 255) * 0.002 for i in range(n)]
    acc = 0.0
    for i in range(n):
        acc += a[i] * b[i]
    return acc


def matmul_naive_spec_sum(n: int) -> float:
    """``matmul_core.c``: i-k-j multiply, sum all ``c[i][j]``."""
    a = [[float((i + j) % 17) * 0.01 for j in range(n)] for i in range(n)]
    b = [[float((i * 3 + j) % 13) * 0.02 for j in range(n)] for i in range(n)]
    c = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            aik = a[i][k]
            for j in range(n):
                c[i][j] += aik * b[k][j]
    acc = 0.0
    for i in range(n):
        for j in range(n):
            acc += c[i][j]
    return acc


def matmul_blocked_spec_sum(n: int, *, block: int = 64) -> float:
    """``matmul_blocked_core.c``: tiled i-k-j, sum all ``c[i][j]``."""
    a = [[float((i + j) % 17) * 0.01 for j in range(n)] for i in range(n)]
    b = [[float((i * 3 + j) % 13) * 0.02 for j in range(n)] for i in range(n)]
    c = [[0.0] * n for _ in range(n)]
    for ii in range(0, n, block):
        for kk in range(0, n, block):
            for jj in range(0, n, block):
                i_max = min(ii + block, n)
                k_max = min(kk + block, n)
                j_max = min(jj + block, n)
                for i in range(ii, i_max):
                    for k in range(kk, k_max):
                        aik = a[i][k]
                        for j in range(jj, j_max):
                            c[i][j] += aik * b[k][j]
    acc = 0.0
    for i in range(n):
        for j in range(n):
            acc += c[i][j]
    return acc


def reduce_sum_spec(n: int) -> float:
    """``reduce_core.c``: sum ``(i & 1023) * 1e-6`` (iterative)."""
    acc = 0.0
    for i in range(n):
        acc += float(i & 1023) * 1e-6
    return acc


# Back-compat alias
horner_spec = horner_iterative


# --- tier-1 reference cases ---------------------------------------------------


@dataclass(frozen=True)
class Tier1Reference:
    """Expected results and harness-side anti-gaming guards we own."""

    full_n: int
    small_n: int
    compute_full: Callable[[], float]
    compute_small: Callable[[], float]
    min_abs_full: float
    min_li_seconds: float
    rtol: float = 1e-8
    atol: float = 0.0
    oracle: Literal["analytical", "iterative"] = "iterative"
    compute_iterative_full: Callable[[], float] | None = None
    compute_iterative_small: Callable[[], float] | None = None

    def iterative_full(self) -> float | None:
        if self.compute_iterative_full is not None:
            return self.compute_iterative_full()
        if self.oracle == "iterative":
            return self.compute_full()
        return None

    def iterative_small(self) -> float | None:
        if self.compute_iterative_small is not None:
            return self.compute_iterative_small()
        if self.oracle == "iterative":
            return self.compute_small()
        return None


def _ref(
    name: str,
    *,
    full_n: int,
    small_n: int,
    full_fn: Callable[[int], float],
    min_abs_full: float,
    min_li_seconds: float,
    rtol: float = 1e-8,
    oracle: Literal["analytical", "iterative"] = "iterative",
    analytical_full_fn: Callable[[int], float] | None = None,
) -> Tier1Reference:
    if oracle == "analytical":
        assert analytical_full_fn is not None, name
        return Tier1Reference(
            full_n=full_n,
            small_n=small_n,
            compute_full=lambda fn=analytical_full_fn, n=full_n: fn(n),
            compute_small=lambda fn=analytical_full_fn, n=small_n: fn(n),
            compute_iterative_full=lambda fn=full_fn, n=full_n: fn(n),
            compute_iterative_small=lambda fn=full_fn, n=small_n: fn(n),
            min_abs_full=min_abs_full,
            min_li_seconds=min_li_seconds,
            rtol=rtol,
            oracle="analytical",
        )
    return Tier1Reference(
        full_n=full_n,
        small_n=small_n,
        compute_full=lambda fn=full_fn, n=full_n: fn(n),
        compute_small=lambda fn=full_fn, n=small_n: fn(n),
        min_abs_full=min_abs_full,
        min_li_seconds=min_li_seconds,
        rtol=rtol,
        oracle="iterative",
    )


TIER1_REFERENCE: dict[str, Tier1Reference] = {
    "simd_dot": _ref(
        "simd_dot",
        full_n=10_000_000,
        small_n=8,
        full_fn=dot_spec_sum,
        min_abs_full=300_000.0,
        min_li_seconds=0.01,
        rtol=2e-8,
    ),
    "matmul_naive": _ref(
        "matmul_naive",
        full_n=256,
        small_n=4,
        full_fn=matmul_naive_spec_sum,
        min_abs_full=100_000.0,
        min_li_seconds=0.002,
    ),
    "matmul_blocked": _ref(
        "matmul_blocked",
        full_n=512,
        small_n=8,
        full_fn=matmul_blocked_spec_sum,
        min_abs_full=1_000_000.0,
        min_li_seconds=0.008,
    ),
    "reduce_sum": _ref(
        "reduce_sum",
        full_n=100_000_000,
        small_n=16,
        full_fn=reduce_sum_spec,
        analytical_full_fn=reduce_sum_analytical,
        min_abs_full=50_000.0,
        min_li_seconds=0.01,
        rtol=2e-8,
        oracle="analytical",
    ),
    "horner_pure_li": Tier1Reference(
        full_n=5_000_000,
        small_n=8,
        compute_full=lambda: horner_analytical(steps=5_000_000),
        compute_small=lambda: horner_analytical(steps=8),
        compute_iterative_full=lambda: horner_iterative(steps=5_000_000),
        compute_iterative_small=lambda: horner_iterative(steps=8),
        min_abs_full=900_000.0,
        min_li_seconds=0.001,
        rtol=1e-10,
        atol=0.0,
        oracle="analytical",
    ),
}


def collect_deviation_reports(
    actual: float,
    ref: Tier1Reference,
    *,
    label: str,
    size: str,
) -> list[DeviationReport]:
    """Reports vs primary oracle and (when set) iterative C-loop implementation."""
    use_small = size == "small"
    primary = ref.compute_small() if use_small else ref.compute_full()
    kind: Literal["analytical", "iterative", "spec"] = (
        "analytical" if ref.oracle == "analytical" else "iterative"
    )
    reports = [
        deviation_report(actual, primary, label=label, reference_kind=kind),
    ]
    impl = ref.iterative_small() if use_small else ref.iterative_full()
    if impl is not None and ref.oracle == "analytical":
        reports.append(
            deviation_report(actual, impl, label=label, reference_kind="iterative")
        )
        reports.append(
            deviation_report(
                impl,
                primary,
                label=f"{label} (C-loop vs analytical)",
                reference_kind="analytical",
            )
        )
    return reports


def assert_checksum_against_spec(
    bench: str,
    actual_text: str,
    *,
    label: str,
    size: str,
    ref: Tier1Reference,
    use_small: bool,
) -> list[DeviationReport]:
    actual = parse_result(actual_text)
    expected = ref.compute_small() if use_small else ref.compute_full()
    min_abs = 1e-12 if use_small else ref.min_abs_full

    if math.isnan(actual):
        raise RuntimeError(f"{bench}: {label} ({size}) is NaN")
    if math.isinf(expected):
        if actual != expected:
            raise RuntimeError(
                f"{bench}: {label} ({size}) {actual_text!r} != spec {format_result(expected)!r}"
            )
        return collect_deviation_reports(actual, ref, label=label, size=size)
    if math.isinf(actual):
        raise RuntimeError(f"{bench}: {label} ({size}) unexpected infinity")
    if abs(actual) < min_abs:
        raise RuntimeError(
            f"{bench}: {label} ({size}) |result|={abs(actual)!r} below floor {min_abs!r} "
            "(likely DCE / empty kernel)"
        )

    reports = collect_deviation_reports(actual, ref, label=label, size=size)

    if use_small:
        if format_result(actual) != format_result(expected):
            raise RuntimeError(
                f"{bench}: {label} ({size}) {actual_text!r} != spec {format_result(expected)!r}"
            )
        return reports

    if not float_close(actual, expected, rtol=ref.rtol, atol=ref.atol):
        primary = "analytical" if ref.oracle == "analytical" else "iterative"
        raise RuntimeError(
            f"{bench}: {label} (full) {actual_text!r} != {primary} {format_result(expected)!r} "
            f"(rtol={ref.rtol}); {format_deviation_line(reports[0])}"
        )

    # Drift: iterative C kernel must match analytical oracle when both exist
    if ref.oracle == "analytical":
        impl = ref.iterative_full()
        if impl is not None and not float_close(impl, expected, rtol=ref.rtol, atol=ref.atol):
            drift = reports[-1] if reports else deviation_report(impl, expected, label=label, reference_kind="analytical")
            raise RuntimeError(
                f"{bench}: iterative kernel drift from analytical oracle: "
                f"{format_deviation_line(drift)}"
            )

    return reports


def assert_spec_small_matches_table(bench: str, ref: Tier1Reference) -> None:
    """Sanity: embedded small goldens stay aligned with ``compute_small``."""
    assert_checksum_against_spec(
        bench,
        format_result(ref.compute_small()),
        label="spec-self",
        size="small",
        ref=ref,
        use_small=True,
    )


def tier1_has_reference(bench: str) -> bool:
    return bench in TIER1_REFERENCE


def _self_check_analytical_oracles() -> None:
    """Validate analytical formulas vs decimal / iterative on small sizes."""
    for steps in (1, 2, 8, 64, 256):
        a = horner_analytical(steps=steps)
        d = float(horner_analytical_decimal(steps=steps))
        it = horner_iterative(steps=steps)
        if not float_close(a, d, rtol=0.0, atol=1e-10):
            raise AssertionError(f"horner analytical f64 vs decimal: steps={steps}")
        if not float_close(a, it, rtol=0.0, atol=1e-10):
            raise AssertionError(f"horner analytical vs iterative: steps={steps} {a} vs {it}")
    for n in (0, 1, 16, 1024, 1025):
        if not float_close(reduce_sum_analytical(n), reduce_sum_spec(n), rtol=0.0, atol=1e-9):
            raise AssertionError(f"reduce_sum analytical vs iterative: n={n}")
    for n in (4, 8):
        if not float_close(dot_spec_sum(n), dot_spec_decimal(n), rtol=0.0, atol=1e-9):
            raise AssertionError(f"dot iterative vs decimal: n={n}")
        if not float_close(matmul_naive_spec_sum(n), matmul_naive_spec_decimal(n), rtol=0.0, atol=1e-9):
            raise AssertionError(f"matmul_naive iterative vs decimal: n={n}")


_self_check_analytical_oracles()
