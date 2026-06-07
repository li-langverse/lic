#!/usr/bin/env python3
"""Generate tier1_micro harness dirs for catalog num_* + fft_1d_fixed (WP1)."""

from __future__ import annotations

from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
TIER1 = REPO / "benchmarks" / "tier1_micro"

BENCH_IDS = (
    "num_cg",
    "num_cholesky",
    "num_eig_symmetric",
    "num_fft_r2c",
    "num_gmres",
    "num_integ_euler",
    "num_integ_rk4",
    "num_integ_semi_implicit",
    "num_integ_symplectic",
    "num_integ_verlet",
    "num_opt_bfgs",
    "num_opt_line_search",
    "num_quadrature_gauss",
    "num_rng_pcg",
    "num_root_newton",
    "num_sparse_mv",
    "fft_1d_fixed",
)

# C kernel bodies: void <prefix>_kernel(void) { ... g_checksum = ...; }
CORES: dict[str, str] = {
    "num_rng_pcg": """
enum { N = 10000000 };
static uint64_t state = 0x853c49e6748fea9bULL;
static double g_checksum;
static inline uint32_t pcg32(void) {
  const uint64_t old = state;
  state = old * 6364136223846793005ULL + 0xda3e39cb94b95bdbULL;
  const uint32_t xorshifted = (uint32_t)(((old >> 18u) ^ old) >> 27u);
  const uint32_t rot = (uint32_t)(old >> 59u);
  return (xorshifted >> rot) | (xorshifted << ((~rot + 1u) & 31u));
}
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int i = 0; i < N; ++i) {{
    acc += (double)pcg32() * 1e-9;
  }}
  g_checksum = acc;
}}
""",
    "num_quadrature_gauss": """
enum { REPS = 2000000 };
static const double nodes[5] = {-0.906179845938664, -0.538469310105683, 0.0,
                                0.538469310105683, 0.906179845938664};
static const double weights[5] = {0.236926885056189, 0.478628670499366, 0.568888888888889,
                                  0.478628670499366, 0.236926885056189};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {{
    double s = 0.0;
    for (int k = 0; k < 5; ++k) {{
      const double x = 0.5 * (nodes[k] + 1.0);
      s += weights[k] * 0.5 * (x * x + 1.0);
    }}
    acc += s;
  }}
  g_checksum = acc;
}}
""",
    "num_root_newton": """
enum { REPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {{
    double x = 1.0;
    for (int i = 0; i < 12; ++i) {{
      const double fx = x * x - 2.0;
      const double dfx = 2.0 * x;
      x = x - fx / dfx;
    }}
    acc += x;
  }}
  g_checksum = acc;
}}
""",
    "num_sparse_mv": """
enum { N = 256, NNZ_ROW = 7 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x[N], y[N];
  int col[NNZ_ROW];
  double val[NNZ_ROW];
  for (int j = 0; j < NNZ_ROW; ++j) {{
    col[j] = (j * 37) % N;
    val[j] = 0.01 * (double)(j + 1);
  }}
  for (int i = 0; i < N; ++i) x[i] = (double)(i % 17) * 0.001;
  for (int rep = 0; rep < 8000; ++rep) {{
    for (int i = 0; i < N; ++i) {{
      double sum = 0.0;
      for (int k = 0; k < NNZ_ROW; ++k) {{
        const int c = (i + col[k]) % N;
        sum += val[k] * x[c];
      }}
      y[i] = sum;
    }}
    for (int i = 0; i < N; ++i) x[i] = y[i];
  }}
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += x[i];
  g_checksum = acc;
}}
""",
    "num_cg": """
enum { N = 64, ITERS = 120 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x[N], b[N], r[N], p[N], Ap[N];
  for (int i = 0; i < N; ++i) {{
    b[i] = (double)(i + 1);
    x[i] = 0.0;
    r[i] = b[i];
    p[i] = r[i];
  }}
  double rsold = 0.0;
  for (int i = 0; i < N; ++i) rsold += r[i] * r[i];
  for (int it = 0; it < ITERS; ++it) {{
    for (int i = 0; i < N; ++i) {{
      double sum = 0.0;
      for (int j = 0; j < N; ++j) {{
        const double aij = (i == j) ? (double)N + 4.0 : 0.001;
        sum += aij * p[j];
      }}
      Ap[i] = sum;
    }}
    double alpha_den = 0.0;
    for (int i = 0; i < N; ++i) alpha_den += p[i] * Ap[i];
    if (alpha_den <= 0.0) break;
    const double alpha = rsold / alpha_den;
    for (int i = 0; i < N; ++i) x[i] += alpha * p[i];
    double rsnew = 0.0;
    for (int i = 0; i < N; ++i) {{
      r[i] -= alpha * Ap[i];
      rsnew += r[i] * r[i];
    }}
    if (rsold <= 0.0) break;
    const double beta = rsnew / rsold;
    rsold = rsnew;
    for (int i = 0; i < N; ++i) p[i] = r[i] + beta * p[i];
  }}
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += x[i];
  g_checksum = acc;
}}
""",
    "num_gmres": """
enum { N = 48, KRYLOV = 12, OUTER = 20 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x[N], b[N], r[N];
  for (int i = 0; i < N; ++i) {{
    b[i] = (double)(i + 1);
    x[i] = 0.0;
    r[i] = b[i];
  }}
  for (int outer = 0; outer < OUTER; ++outer) {{
    double V[KRYLOV + 1][N];
    double H[KRYLOV + 1][KRYLOV];
    for (int i = 0; i < N; ++i) V[0][i] = r[i];
    double beta = 0.0;
    for (int i = 0; i < N; ++i) beta += V[0][i] * V[0][i];
    beta = sqrt(beta);
    for (int i = 0; i < N; ++i) V[0][i] /= beta;
    for (int j = 0; j < KRYLOV; ++j) {{
      double w[N];
      for (int i = 0; i < N; ++i) {{
        double sum = 0.0;
        for (int k = 0; k < N; ++k) {{
          double aik = (i == k) ? (double)N + 1.0 : 0.005;
          sum += aik * V[j][k];
        }}
        w[i] = sum;
      }}
      for (int i = 0; i <= j; ++i) {{
        H[i][j] = 0.0;
        for (int k = 0; k < N; ++k) H[i][j] += w[k] * V[i][k];
        for (int k = 0; k < N; ++k) w[k] -= H[i][j] * V[i][k];
      }}
      double hn1 = 0.0;
      for (int k = 0; k < N; ++k) hn1 += w[k] * w[k];
      H[j + 1][j] = sqrt(hn1);
      for (int k = 0; k < N; ++k) V[j + 1][k] = w[k] / H[j + 1][j];
    }}
    for (int i = 0; i < N; ++i) x[i] += 0.01 * V[0][i];
    for (int i = 0; i < N; ++i) {{
      double sum = 0.0;
      for (int k = 0; k < N; ++k) {{
        double aik = (i == k) ? (double)N + 1.0 : 0.005;
        sum += aik * x[k];
      }}
      r[i] = b[i] - sum;
    }}
  }}
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += x[i];
  g_checksum = acc;
}}
""",
    "num_cholesky": """
enum { N = 64 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double L[N][N];
  for (int i = 0; i < N; ++i) {{
    for (int j = 0; j < N; ++j) {{
      L[i][j] = (i >= j) ? 0.01 * (double)((i + j) % 11 + 1) : 0.0;
    }}
    L[i][i] += (double)N;
  }}
  for (int rep = 0; rep < 8; ++rep) {{
    for (int i = 0; i < N; ++i) {{
      for (int j = 0; j <= i; ++j) {{
        double sum = L[i][j];
        for (int k = 0; k < j; ++k) sum -= L[i][k] * L[j][k];
        if (i == j) {{
          L[i][j] = sqrt(sum);
        }} else {{
          L[i][j] = sum / L[j][j];
        }}
      }}
    }}
  }}
  double acc = 0.0;
  for (int i = 0; i < N; ++i) acc += L[i][i];
  g_checksum = acc;
}}
""",
    "num_eig_symmetric": """
enum { N = 32, STEPS = 200 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double A[N][N], v[N], w[N];
  for (int i = 0; i < N; ++i) {{
    for (int j = 0; j < N; ++j) {{
      A[i][j] = (i == j) ? (double)(N + i + 1) : 0.02 * (double)((i + j) % 7);
    }}
    v[i] = 1.0 / (double)N;
  }}
  double lambda = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    for (int i = 0; i < N; ++i) {{
      double sum = 0.0;
      for (int j = 0; j < N; ++j) sum += A[i][j] * v[j];
      w[i] = sum;
    }}
    double norm = 0.0;
    for (int i = 0; i < N; ++i) norm += w[i] * w[i];
    norm = sqrt(norm);
    lambda = 0.0;
    for (int i = 0; i < N; ++i) {{
      v[i] = w[i] / norm;
      lambda += v[i] * w[i];
    }}
  }}
  g_checksum = lambda;
}}
""",
    "num_fft_r2c": """
enum { N = 512 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double re[N], im[N], out_re[N];
  for (int k = 0; k < N; ++k) {{
    re[k] = sin(0.013 * (double)k);
    im[k] = 0.0;
  }}
  for (int rep = 0; rep < 4; ++rep) {{
    for (int k = 0; k < N; ++k) {{
      double sum = 0.0;
      for (int n = 0; n < N; ++n) {{
        const double ang = -2.0 * 3.141592653589793 * (double)k * (double)n / (double)N;
        sum += re[n] * cos(ang);
      }}
      out_re[k] = sum;
    }}
    for (int k = 0; k < N; ++k) re[k] = out_re[k];
  }}
  double acc = 0.0;
  for (int k = 0; k < N; ++k) acc += re[k];
  g_checksum = acc;
}}
""",
    "fft_1d_fixed": """
enum { N = 1024 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double re[N], out_re[N];
  for (int n = 0; n < N; ++n) re[n] = cos(0.007 * (double)n) + 0.25 * sin(0.019 * (double)n);
  for (int rep = 0; rep < 2; ++rep) {{
    for (int k = 0; k < N; ++k) {{
      double sum = 0.0;
      for (int n = 0; n < N; ++n) {{
        const double ang = -2.0 * 3.141592653589793 * (double)k * (double)n / (double)N;
        sum += re[n] * cos(ang);
      }}
      out_re[k] = sum;
    }}
    for (int k = 0; k < N; ++k) re[k] = out_re[k];
  }}
  double acc = 0.0;
  for (int k = 0; k < N; ++k) acc += re[k];
  g_checksum = acc;
}}
""",
    "num_integ_euler": """
enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {{
    const double a = -y;
    v += dt * a;
    y += dt * v;
  }}
  g_checksum = y + v;
}}
""",
    "num_integ_rk4": """
enum { STEPS = 200000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  const double dt = 2e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {{
    const double k1y = v;
    const double k1v = -y;
    const double k2y = v + 0.5 * dt * k1v;
    const double k2v = -(y + 0.5 * dt * k1y);
    const double k3y = v + 0.5 * dt * k2v;
    const double k3v = -(y + 0.5 * dt * k2y);
    const double k4y = v + dt * k3v;
    const double k4v = -(y + dt * k3y);
    y += dt * (k1y + 2.0 * k2y + 2.0 * k3y + k4y) / 6.0;
    v += dt * (k1v + 2.0 * k2v + 2.0 * k3v + k4v) / 6.0;
  }}
  g_checksum = y + v;
}}
""",
    "num_integ_verlet": """
enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  double a = -y;
  for (int i = 0; i < STEPS; ++i) {{
    y += dt * v + 0.5 * dt * dt * a;
    const double a_new = -y;
    v += 0.5 * dt * (a + a_new);
    a = a_new;
  }}
  g_checksum = y + v;
}}
""",
    "num_integ_symplectic": """
enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {{
    v += -y * dt;
    y += v * dt;
  }}
  g_checksum = y + v;
}}
""",
    "num_integ_semi_implicit": """
enum { STEPS = 500000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  const double dt = 1e-4;
  double y = 1.0, v = 0.0;
  for (int i = 0; i < STEPS; ++i) {{
    v += -y * dt;
    y += v * dt;
    y /= (1.0 + 0.5 * dt * dt);
  }}
  g_checksum = y + v;
}}
""",
    "num_opt_bfgs": """
enum { REPS = 20000, DIM = 4 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {{
    double x[DIM] = {{0.5, -1.0, 0.25, 0.75}};
    for (int it = 0; it < 12; ++it) {{
      double g[DIM];
      for (int i = 0; i < DIM; ++i) {{
        double gi = 0.0;
        for (int j = 0; j < DIM; ++j) gi += 2.0 * x[j] * (j == i ? 1.0 : 0.1);
        g[i] = gi + 1.0;
      }}
      double step = 0.01;
      for (int i = 0; i < DIM; ++i) x[i] -= step * g[i];
    }}
    for (int i = 0; i < DIM; ++i) acc += x[i];
  }}
  g_checksum = acc;
}}
""",
    "num_opt_line_search": """
enum { REPS = 50000 };
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int r = 0; r < REPS; ++r) {{
    double x = 2.0;
    for (int it = 0; it < 16; ++it) {{
      const double f = (x - 1.0) * (x - 1.0) + 0.1;
      const double df = 2.0 * (x - 1.0);
      double alpha = 1.0;
      for (int ls = 0; ls < 8; ++ls) {{
        const double x_try = x - alpha * df;
        const double f_try = (x_try - 1.0) * (x_try - 1.0) + 0.1;
        if (f_try < f) break;
        alpha *= 0.5;
      }}
      x -= alpha * df;
    }}
    acc += x;
  }}
  g_checksum = acc;
}}
""",
}

# Integration family shares template key
for k in ("num_integ_euler", "num_integ_rk4", "num_integ_verlet", "num_integ_symplectic", "num_integ_semi_implicit"):
    if k not in CORES and k.startswith("num_integ_"):
        pass

CPP_MAIN = """#include "../common/{core_h}"
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {{
  {prefix}_kernel();
  const double checksum = {prefix}_checksum();
  if (argc > 1 && strcmp(argv[1], "--verify") == 0) {{
    printf("%.17g\\n", checksum);
    return 0;
  }}
  volatile double sink = checksum;
  (void)sink;
  return 0;
}}
"""

LI_MAIN = """# {bench_id} — shared C oracle via LI_EXTRA_C (smoke-scale).

extern proc {prefix}_kernel()
  requires true
  ensures true

extern proc {prefix}_checksum() -> float
  requires true
  ensures true

extern proc li_rt_volatile_sink_f64(v: float) -> unit
  requires true
  ensures true

def main() raises IO -> int
  requires true
  ensures result == 0
  decreases 0
=
  {prefix}_kernel()
  li_rt_volatile_sink_f64({prefix}_checksum())
  return 0
"""

HEADER = """#pragma once

#ifdef __cplusplus
extern "C" {{
#endif

void {prefix}_kernel(void);
double {prefix}_checksum(void);

#ifdef __cplusplus
}}
#endif
"""

PARAMS = {
    "num_rng_pcg": "samples = 10_000_000\n",
    "num_quadrature_gauss": "reps = 2_000_000\n",
    "num_root_newton": "reps = 500_000\n",
    "num_sparse_mv": "n = 256\nreps = 8000\n",
    "num_cg": "n = 64\niters = 80\n",
    "num_gmres": "n = 48\n",
    "num_cholesky": "n = 64\n",
    "num_eig_symmetric": "n = 32\n",
    "num_fft_r2c": "n = 512\n",
    "fft_1d_fixed": "n = 1024\n",
    "num_integ_euler": "steps = 500_000\n",
    "num_integ_rk4": "steps = 200_000\n",
    "num_integ_verlet": "steps = 500_000\n",
    "num_integ_symplectic": "steps = 500_000\n",
    "num_integ_semi_implicit": "steps = 500_000\n",
    "num_opt_bfgs": "reps = 20_000\n",
    "num_opt_line_search": "reps = 50_000\n",
}


def prefix_for(bench_id: str) -> str:
    return "li_" + bench_id


def core_filename(bench_id: str) -> str:
    return bench_id + "_core"


def write_bench(bench_id: str) -> None:
    if bench_id not in CORES:
        raise KeyError(bench_id)
    prefix = prefix_for(bench_id)
    core = core_filename(bench_id)
    root = TIER1 / bench_id
    common = root / "common"
    common.mkdir(parents=True, exist_ok=True)
    (root / "li").mkdir(parents=True, exist_ok=True)
    (root / "cpp").mkdir(parents=True, exist_ok=True)

    body = (
        CORES[bench_id]
        .replace("{prefix}", prefix)
        .replace("{{", "{")
        .replace("}}", "}")
    )
    c_src = (
        f'#include "{core}.h"\n#include <math.h>\n#include <stdint.h>\n#include <stdio.h>\n\n'
        + body
        + f"\ndouble {prefix}_checksum(void) {{ return g_checksum; }}\n"
    )
    (common / f"{core}.c").write_text(c_src)
    (common / f"{core}.h").write_text(HEADER.replace("{prefix}", prefix))
    (root / "cpp" / "main.c").write_text(
        CPP_MAIN.replace("{core_h}", f"{core}.h").replace("{prefix}", prefix)
    )
    (root / "li" / "main.li").write_text(
        LI_MAIN.replace("{bench_id}", bench_id).replace("{prefix}", prefix)
    )
    (root / "params.toml").write_text(
        PARAMS.get(bench_id, "# smoke-scale tier1_micro harness\n")
    )


def main() -> None:
    for bench_id in BENCH_IDS:
        write_bench(bench_id)
        print(f"wrote {TIER1 / bench_id}")
    print(f"done: {len(BENCH_IDS)} harness dirs")


if __name__ == "__main__":
    main()
