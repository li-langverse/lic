#!/usr/bin/env python3
"""Generate tier2_physics harness dirs for WP3 catalog families (pde/robo/drug/bio/am)."""

from __future__ import annotations

from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
TIER2 = REPO / "benchmarks" / "tier2_physics"

WP3_IDS = (
    "pde_cfl_timestep",
    "pde_heat_implicit_jacobi",
    "robo_multibody_step",
    "robo_ik_jacobian",
    "robo_plan_rrt",
    "robo_plan_prm",
    "robo_traj_opt",
    "drug_litl_stages",
    "drug_docking_score_vina",
    "drug_docking_diffusion",
    "drug_ml_retrain_loop",
    "drug_fep_alchemical",
    "bio_rosetta_energy",
    "bio_rotamer_packing",
    "bio_proteinmpnn",
    "bio_rfdiffusion",
    "am_plane_mesh_intersect",
    "am_polygon_clip",
    "am_slice_layers",
    "am_offset_perimeters",
    "am_infill_grid_lines",
    "am_infill_gyroid",
    "am_support_tree",
    "am_toolpath_arcs",
    "am_thermal_warp",
    "am_export_gcode_3mf",
)

CORES: dict[str, str] = {
    "pde_cfl_timestep": """
enum {{ NX = 64, NY = 64, STEPS = 40000 }};
#define CFL 0.45
#define DX 0.02
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double u[NX][NY], v[NX][NY];
  for (int i = 0; i < NX; ++i) {{
    for (int j = 0; j < NY; ++j) {{
      u[i][j] = 0.2 * sin(0.1 * (double)i) * cos(0.1 * (double)j);
      v[i][j] = 0.15 * cos(0.08 * (double)i) * sin(0.09 * (double)j);
    }}
  }}
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    double maxs = 1e-12;
    for (int i = 0; i < NX; ++i) {{
      for (int j = 0; j < NY; ++j) {{
        const double sp = sqrt(u[i][j] * u[i][j] + v[i][j] * v[i][j]);
        if (sp > maxs) maxs = sp;
      }}
    }}
    const double dt = CFL * DX / maxs;
    acc += dt;
    for (int i = 1; i < NX - 1; ++i) {{
      for (int j = 1; j < NY - 1; ++j) {{
        u[i][j] -= dt * 0.25 * (u[i][j] - u[i - 1][j]);
        v[i][j] -= dt * 0.25 * (v[i][j] - v[i][j - 1]);
      }}
    }}
    (void)s;
  }}
  g_checksum = acc;
}}
""",
    "pde_heat_implicit_jacobi": """
enum {{ NX = 64, NY = 64, STEPS = 12000, JACOBI = 6 }};
#define ALPHA 0.25
#define DX 0.02
#define DT 0.001
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double u[NX][NY], b[NX][NY], x[NX][NY];
  const double r = ALPHA * DT / (DX * DX);
  for (int i = 0; i < NX; ++i) {{
    for (int j = 0; j < NY; ++j) {{
      u[i][j] = sin(0.2 * (double)i) * sin(0.2 * (double)j);
    }}
  }}
  for (int s = 0; s < STEPS; ++s) {{
    for (int i = 0; i < NX; ++i) {{
      for (int j = 0; j < NY; ++j) b[i][j] = u[i][j];
    }}
    for (int j = 0; j < JACOBI; ++j) {{
      for (int i = 1; i < NX - 1; ++i) {{
        for (int k = 1; k < NY - 1; ++k) {{
          x[i][k] = (b[i][k] + r * (u[i + 1][k] + u[i - 1][k] + u[i][k + 1] + u[i][k - 1]))
                    / (1.0 + 4.0 * r);
        }}
      }}
      for (int i = 0; i < NX; ++i) {{
        for (int k = 0; k < NY; ++k) u[i][k] = x[i][k];
      }}
    }}
    (void)s;
  }}
  double acc = 0.0;
  for (int i = 0; i < NX; ++i) {{
    for (int j = 0; j < NY; ++j) acc += u[i][j];
  }}
  g_checksum = acc;
}}
""",
    "robo_multibody_step": """
enum {{ LINKS = 8, STEPS = 6000 }};
#define DT 0.002
#define LEN 0.4
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double th[LINKS], w[LINKS];
  for (int i = 0; i < LINKS; ++i) {{
    th[i] = 0.05 * (double)i;
    w[i] = 0.0;
  }}
  for (int s = 0; s < STEPS; ++s) {{
    double tau = 0.0;
    for (int i = LINKS - 1; i >= 0; --i) {{
      tau += 2.0 * sin(th[i]) - 0.1 * w[i];
      w[i] += tau * DT;
      th[i] += w[i] * DT;
    }}
    (void)s;
  }}
  g_checksum = th[LINKS - 1];
}}
""",
    "robo_ik_jacobian": """
enum {{ DOF = 6, SAMPLES = 20000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double q[DOF];
  for (int i = 0; i < DOF; ++i) q[i] = 0.1 * (double)i;
  double acc = 0.0;
  for (int s = 0; s < SAMPLES; ++s) {{
    double px = 0.0, py = 0.0;
    double c = 1.0;
    for (int i = 0; i < DOF; ++i) {{
      const double l = 0.25;
      const double cq = cos(q[i]);
      const double sq = sin(q[i]);
      px += c * l * cq;
      py += c * l * sq;
      c *= cq;
    }}
    const double eps = 1e-4;
    for (int j = 0; j < DOF; ++j) {{
      double qj = q[j] + eps;
      double px2 = 0.0, py2 = 0.0;
      double c2 = 1.0;
      for (int i = 0; i < DOF; ++i) {{
        const double ang = (i == j) ? qj : q[i];
        const double l = 0.25;
        px2 += c2 * l * cos(ang);
        py2 += c2 * l * sin(ang);
        c2 *= cos(ang);
      }}
      acc += (px2 - px) / eps + (py2 - py) / eps;
    }}
    q[s % DOF] += 1e-3 * sin(0.01 * (double)s);
  }}
  g_checksum = acc;
}}
""",
    "robo_plan_rrt": """
enum {{ NODES = 12000, DIM = 2 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x0[DIM] = {{0.05, 0.05}};
  const double goal[DIM] = {{0.95, 0.95}};
  double acc = 0.0;
  uint32_t seed = 0x9e3779b9u;
  for (int n = 0; n < NODES; ++n) {{
    seed = seed * 1664525u + 1013904223u;
    double q[DIM];
    q[0] = (double)(seed & 0xffff) / 65535.0;
    q[1] = (double)((seed >> 16) & 0xffff) / 65535.0;
    const double dx = q[0] - x0[0];
    const double dy = q[1] - x0[1];
    const double dist = dx * dx + dy * dy;
    if (dist < 0.04) {{
      x0[0] = q[0];
      x0[1] = q[1];
    }}
    acc += dist;
  }}
  const double gx = goal[0] - x0[0];
  const double gy = goal[1] - x0[1];
  g_checksum = acc + gx + gy;
}}
""",
    "robo_plan_prm": """
enum {{ GRID = 48, EDGES = 8000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double occ[GRID][GRID];
  for (int i = 0; i < GRID; ++i) {{
    for (int j = 0; j < GRID; ++j) {{
      const double x = (double)i / (double)GRID;
      const double y = (double)j / (double)GRID;
      occ[i][j] = (x > 0.35 && x < 0.65 && y > 0.2 && y < 0.8) ? 1.0 : 0.0;
    }}
  }}
  double acc = 0.0;
  for (int e = 0; e < EDGES; ++e) {{
    const int i = e % (GRID - 1);
    const int j = (e * 7) % (GRID - 1);
    if (occ[i][j] < 0.5 && occ[i + 1][j] < 0.5) acc += 1.0;
    if (occ[i][j] < 0.5 && occ[i][j + 1] < 0.5) acc += 1.0;
  }}
  g_checksum = acc;
}}
""",
    "robo_traj_opt": """
enum {{ KNOTS = 32, ITERS = 5000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double t[KNOTS];
  for (int i = 0; i < KNOTS; ++i) t[i] = (double)i / (double)(KNOTS - 1);
  for (int it = 0; it < ITERS; ++it) {{
    double cost = 0.0;
    for (int i = 1; i < KNOTS; ++i) {{
      const double v = t[i] - t[i - 1];
      cost += v * v;
    }}
    for (int i = 1; i < KNOTS - 1; ++i) {{
      t[i] -= 0.001 * (2.0 * t[i] - t[i - 1] - t[i + 1]);
    }}
    (void)cost;
  }}
  g_checksum = t[KNOTS - 1];
}}
""",
    "drug_litl_stages": """
enum {{ STAGES = 8, MOLS = 256, STEPS = 4000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double score[MOLS];
  for (int m = 0; m < MOLS; ++m) score[m] = 0.1 * (double)m;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    const int stage = s % STAGES;
    for (int m = 0; m < MOLS; ++m) {{
      score[m] += 0.01 * sin((double)stage * score[m]);
      acc += score[m];
    }}
  }}
  g_checksum = acc;
}}
""",
    "drug_docking_score_vina": """
enum {{ POSES = 5000, ATOMS = 24 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double lig[ATOMS][3];
  for (int a = 0; a < ATOMS; ++a) {{
    lig[a][0] = 0.1 * (double)a;
    lig[a][1] = 0.05 * (double)a;
    lig[a][2] = 0.02 * (double)a;
  }}
  double acc = 0.0;
  for (int p = 0; p < POSES; ++p) {{
    double e = 0.0;
    for (int i = 0; i < ATOMS; ++i) {{
      for (int j = i + 1; j < ATOMS; ++j) {{
        double dx = lig[i][0] - lig[j][0];
        double dy = lig[i][1] - lig[j][1];
        double dz = lig[i][2] - lig[j][2];
        const double r2 = dx * dx + dy * dy + dz * dz + 1e-3;
        e += 1.0 / r2;
      }}
    }}
    acc += e;
    lig[p % ATOMS][0] += 1e-4;
  }}
  g_checksum = acc;
}}
""",
    "drug_docking_diffusion": """
enum {{ STEPS = 20000, DIM = 16 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x[DIM];
  for (int i = 0; i < DIM; ++i) x[i] = 0.01 * (double)i;
  uint32_t seed = 0x12345678u;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    seed = seed * 1664525u + 1013904223u;
    const double noise = ((double)(seed & 0xffff) / 32768.0) - 1.0;
    x[s % DIM] += 0.02 * noise;
    double n2 = 0.0;
    for (int i = 0; i < DIM; ++i) n2 += x[i] * x[i];
    acc += n2;
  }}
  g_checksum = acc;
}}
""",
    "drug_ml_retrain_loop": """
enum {{ FEAT = 64, BATCH = 128, EPOCHS = 800 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double w[FEAT];
  for (int i = 0; i < FEAT; ++i) w[i] = 0.001 * (double)i;
  double acc = 0.0;
  for (int e = 0; e < EPOCHS; ++e) {{
    for (int b = 0; b < BATCH; ++b) {{
      double x[FEAT];
      for (int i = 0; i < FEAT; ++i) x[i] = sin(0.1 * (double)(b + i + e));
      double y = 0.0;
      for (int i = 0; i < FEAT; ++i) y += w[i] * x[i];
      const double err = y - 1.0;
      for (int i = 0; i < FEAT; ++i) w[i] -= 1e-4 * err * x[i];
      acc += err * err;
    }}
  }}
  g_checksum = acc;
}}
""",
    "drug_fep_alchemical": """
enum {{ LAMBDA_STEPS = 32, SAMPLES = 3000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int s = 0; s < SAMPLES; ++s) {{
    for (int l = 0; l < LAMBDA_STEPS; ++l) {{
      const double lam = (double)l / (double)(LAMBDA_STEPS - 1);
      double u = 0.0;
      for (int i = 0; i < 20; ++i) {{
        const double ri = 0.1 * (double)i;
        u += (1.0 - lam) * exp(-ri) + lam * exp(-2.0 * ri);
      }}
      acc += u;
    }}
  }}
  g_checksum = acc;
}}
""",
    "bio_rosetta_energy": """
enum {{ RES = 48, PAIR = 20000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double phi[RES], psi[RES];
  for (int i = 0; i < RES; ++i) {{
    phi[i] = -1.0 + 0.1 * (double)i;
    psi[i] = 1.0 - 0.08 * (double)i;
  }}
  double acc = 0.0;
  for (int p = 0; p < PAIR; ++p) {{
    const int i = p % RES;
    const int j = (p * 5 + 7) % RES;
    const double dphi = phi[i] - phi[j];
    const double dpsi = psi[i] - psi[j];
    acc += dphi * dphi + dpsi * dpsi;
  }}
  g_checksum = acc;
}}
""",
    "bio_rotamer_packing": """
enum {{ SITES = 32, ROT = 3, TRIALS = 15000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  int pick[SITES];
  for (int i = 0; i < SITES; ++i) pick[i] = 0;
  double acc = 0.0;
  for (int t = 0; t < TRIALS; ++t) {{
    const int s = t % SITES;
    pick[s] = (pick[s] + 1) % ROT;
    double e = 0.0;
    for (int i = 0; i < SITES; ++i) {{
      for (int j = i + 1; j < SITES; ++j) {{
        if (pick[i] == pick[j]) e += 1.0;
      }}
    }}
    acc += e;
  }}
  g_checksum = acc;
}}
""",
    "bio_proteinmpnn": """
enum {{ LEN = 64, HID = 128, STEPS = 2500 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double h[HID];
  for (int i = 0; i < HID; ++i) h[i] = 0.0;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    for (int i = 0; i < HID; ++i) h[i] = 0.0;
    for (int p = 0; p < LEN; ++p) {{
      const double x = sin(0.13 * (double)(p + s));
      for (int i = 0; i < HID; ++i) {{
        h[i] += tanh(x + 0.01 * (double)i);
      }}
    }}
    for (int i = 0; i < HID; ++i) acc += h[i];
  }}
  g_checksum = acc;
}}
""",
    "bio_rfdiffusion": """
enum {{ STEPS = 4000, DIM = 32 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x[DIM];
  for (int i = 0; i < DIM; ++i) x[i] = 0.0;
  uint32_t seed = 0xdeadbeefu;
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    seed = seed * 1664525u + 1013904223u;
    const double z = ((double)(seed & 0xffff) / 32768.0) - 1.0;
    for (int i = 0; i < DIM; ++i) {{
      x[i] = 0.98 * x[i] + 0.15 * z;
      acc += x[i] * x[i];
    }}
  }}
  g_checksum = acc;
}}
""",
    "am_plane_mesh_intersect": """
enum {{ TRIS = 2000, PLANES = 200 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int p = 0; p < PLANES; ++p) {{
    const double z = 0.01 * (double)p;
    for (int t = 0; t < TRIS; ++t) {{
      const double z0 = 0.001 * (double)(t % 50);
      const double z1 = 0.001 * (double)((t + 17) % 50);
      const double z2 = 0.001 * (double)((t + 31) % 50);
      const double zm = (z0 + z1 + z2) / 3.0;
      if ((z0 - z) * (z2 - z) <= 0.0) acc += zm;
    }}
  }}
  g_checksum = acc;
}}
""",
    "am_polygon_clip": """
enum {{ VERT = 8, CLIPS = 25000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double px[VERT], py[VERT];
  for (int i = 0; i < VERT; ++i) {{
    const double a = 6.283185307179586 * (double)i / (double)VERT;
    px[i] = cos(a);
    py[i] = sin(a);
  }}
  double acc = 0.0;
  for (int c = 0; c < CLIPS; ++c) {{
    const double x = -0.5 + 0.02 * (double)(c % 50);
    int n = VERT;
    for (int i = 0, j = VERT - 1; i < VERT; j = i++) {{
      const double cross = (x - px[i]) * (py[j] - py[i]) - (py[i] - py[j]) * (px[j] - px[i]);
      if (cross > 0.0) {{
        px[n] = px[i];
        py[n] = py[i];
        ++n;
      }}
    }}
    acc += (double)n;
  }}
  g_checksum = acc;
}}
""",
    "am_slice_layers": """
enum {{ LAYERS = 400, SEGS = 64 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int L = 0; L < LAYERS; ++L) {{
    const double z = 0.05 * (double)L;
    for (int s = 0; s < SEGS; ++s) {{
      const double y0 = sin(0.2 * (double)s);
      const double y1 = sin(0.2 * (double)(s + 1));
      if (y0 <= z && y1 >= z) acc += 1.0;
    }}
  }}
  g_checksum = acc;
}}
""",
    "am_offset_perimeters": """
enum {{ PTS = 2000, OFF = 0.02 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int i = 0; i < PTS; ++i) {{
    const double a = 6.283185307179586 * (double)i / (double)PTS;
    const double nx = cos(a);
    const double ny = sin(a);
    acc += (cos(a + OFF) - nx) * (cos(a + OFF) - nx) + (sin(a + OFF) - ny) * (sin(a + OFF) - ny);
  }}
  g_checksum = acc;
}}
""",
    "am_infill_grid_lines": """
enum {{ LINES = 8000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int i = 0; i < LINES; ++i) {{
    const double t = (double)i / (double)LINES;
    acc += sin(40.0 * t) * cos(30.0 * t);
  }}
  g_checksum = acc;
}}
""",
    "am_infill_gyroid": """
enum {{ SAMPLES = 60000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int i = 0; i < SAMPLES; ++i) {{
    const double x = 0.02 * (double)(i % 100);
    const double y = 0.02 * (double)((i / 100) % 100);
    const double z = 0.02 * (double)(i / 10000);
    acc += sin(x) * cos(y) + sin(y) * cos(z) + sin(z) * cos(x);
  }}
  g_checksum = acc;
}}
""",
    "am_support_tree": """
enum {{ NODES = 5000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x[NODES], y[NODES];
  for (int i = 0; i < NODES; ++i) {{
    x[i] = 0.01 * (double)(i % 70);
    y[i] = 0.01 * (double)((i * 3) % 70);
  }}
  double acc = 0.0;
  for (int i = 1; i < NODES; ++i) {{
    const int p = (i * 7) % i;
    const double dx = x[i] - x[p];
    const double dy = y[i] - y[p];
    acc += sqrt(dx * dx + dy * dy);
  }}
  g_checksum = acc;
}}
""",
    "am_toolpath_arcs": """
enum {{ ARCS = 12000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double acc = 0.0;
  for (int a = 0; a < ARCS; ++a) {{
    const double r = 0.1 + 0.001 * (double)(a % 100);
    const double th0 = 0.01 * (double)a;
    const double th1 = th0 + 0.2;
    acc += r * (th1 - th0) + 0.001 * sin(th0 + th1);
  }}
  g_checksum = acc;
}}
""",
    "am_thermal_warp": """
enum {{ VOX = 48, STEPS = 3000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double t[VOX][VOX][VOX];
  for (int i = 0; i < VOX; ++i) {{
    for (int j = 0; j < VOX; ++j) {{
      for (int k = 0; k < VOX; ++k) t[i][j][k] = 20.0;
    }}
  }}
  double acc = 0.0;
  for (int s = 0; s < STEPS; ++s) {{
    for (int i = 1; i < VOX - 1; ++i) {{
      for (int j = 1; j < VOX - 1; ++j) {{
        for (int k = 1; k < VOX - 1; ++k) {{
          const double lap = t[i + 1][j][k] + t[i - 1][j][k] + t[i][j + 1][k] + t[i][j - 1][k]
                             + t[i][j][k + 1] + t[i][j][k - 1] - 6.0 * t[i][j][k];
          t[i][j][k] += 0.02 * lap;
          acc += t[i][j][k];
        }}
      }}
    }}
  }}
  g_checksum = acc;
}}
""",
    "am_export_gcode_3mf": """
enum {{ MOVES = 25000 }};
static double g_checksum;
__attribute__((noinline)) void {prefix}_kernel(void) {{
  double x = 0.0, y = 0.0, e = 0.0;
  double acc = 0.0;
  for (int m = 0; m < MOVES; ++m) {{
    const double nx = x + 0.01 * sin(0.1 * (double)m);
    const double ny = y + 0.01 * cos(0.1 * (double)m);
    const double de = sqrt((nx - x) * (nx - x) + (ny - y) * (ny - y));
    e += de;
    x = nx;
    y = ny;
    acc += e;
  }}
  g_checksum = acc;
}}
""",
}

PARAMS: dict[str, str] = {
    "pde_cfl_timestep": "nx = 64\nny = 64\nsteps = 40_000\ncfl = 0.45\n",
    "pde_heat_implicit_jacobi": "nx = 64\nny = 64\nsteps = 12_000\njacobi_iters = 6\n",
    "robo_multibody_step": "links = 8\nsteps = 6000\n",
    "robo_ik_jacobian": "dof = 6\nsamples = 20_000\n",
    "robo_plan_rrt": "nodes = 12_000\n",
    "robo_plan_prm": "grid = 48\nedges = 8000\n",
    "robo_traj_opt": "knots = 32\niters = 5000\n",
    "drug_litl_stages": "stages = 8\nmols = 256\n",
    "drug_docking_score_vina": "poses = 5000\natoms = 24\n",
    "drug_docking_diffusion": "steps = 20_000\ndim = 16\n",
    "drug_ml_retrain_loop": "feat = 64\nepochs = 800\n",
    "drug_fep_alchemical": "lambda_steps = 32\nsamples = 3000\n",
    "bio_rosetta_energy": "residues = 48\npairs = 20_000\n",
    "bio_rotamer_packing": "sites = 32\ntrials = 15_000\n",
    "bio_proteinmpnn": "len = 64\nsteps = 2500\n",
    "bio_rfdiffusion": "steps = 4000\ndim = 32\n",
    "am_plane_mesh_intersect": "tris = 2000\nplanes = 200\n",
    "am_polygon_clip": "verts = 8\nclips = 25_000\n",
    "am_slice_layers": "layers = 400\n",
    "am_offset_perimeters": "pts = 2000\n",
    "am_infill_grid_lines": "lines = 8000\n",
    "am_infill_gyroid": "samples = 60_000\n",
    "am_support_tree": "nodes = 5000\n",
    "am_toolpath_arcs": "arcs = 12_000\n",
    "am_thermal_warp": "vox = 48\nsteps = 3000\n",
    "am_export_gcode_3mf": "moves = 25_000\n",
}

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

LI_MAIN = """# {bench_id} — shared C oracle via LI_EXTRA_C (WP3 smoke-scale).

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


def prefix_for(bench_id: str) -> str:
    return "li_" + bench_id


def core_filename(bench_id: str) -> str:
    return bench_id + "_core"


def write_bench(bench_id: str) -> None:
    prefix = prefix_for(bench_id)
    core = core_filename(bench_id)
    root = TIER2 / bench_id
    common = root / "common"
    common.mkdir(parents=True, exist_ok=True)
    (root / "li").mkdir(parents=True, exist_ok=True)
    (root / "cpp").mkdir(parents=True, exist_ok=True)

    body = CORES[bench_id].format(prefix=prefix)
    c_src = (
        f'#include "{core}.h"\n#include <math.h>\n#include <stdint.h>\n#include <stdio.h>\n\n'
        + body
        + f"\ndouble {prefix}_checksum(void) {{ return g_checksum; }}\n"
    )
    (common / f"{core}.c").write_text(c_src, encoding="utf-8")
    (common / f"{core}.h").write_text(HEADER.format(prefix=prefix), encoding="utf-8")
    (root / "cpp" / "main.c").write_text(
        CPP_MAIN.format(core_h=f"{core}.h", prefix=prefix),
        encoding="utf-8",
    )
    (root / "li" / "main.li").write_text(
        LI_MAIN.format(bench_id=bench_id, prefix=prefix),
        encoding="utf-8",
    )
    (root / "params.toml").write_text(
        f"# WP3 harness: {bench_id}\n{PARAMS[bench_id]}",
        encoding="utf-8",
    )


def patch_euler_fluid() -> None:
    root = TIER2 / "euler_fluid_2d"
    if not (root / "li" / "main.li").is_file():
        return
    prefix = "li_euler_fluid_2d"
    core = "euler_fluid_core"
    header = root / "common" / f"{core}.h"
    if not header.is_file():
        header.write_text(HEADER.format(prefix=prefix), encoding="utf-8")
    c_path = root / "common" / f"{core}.c"
    if c_path.is_file() and "li_euler_fluid_2d_checksum" not in c_path.read_text():
        text = c_path.read_text(encoding="utf-8")
        if "#include" not in text.split("\n")[0]:
            text = f'#include "{core}.h"\n' + text
        if "g_li_euler_fluid_checksum" in text and "double li_euler_fluid_2d_checksum" not in text:
            text += f"\ndouble {prefix}_checksum(void) {{ return g_li_euler_fluid_checksum; }}\n"
        c_path.write_text(text, encoding="utf-8")
    (root / "li" / "main.li").write_text(
        LI_MAIN.format(bench_id="euler_fluid_2d", prefix=prefix),
        encoding="utf-8",
    )
    (root / "params.toml").write_text(
        "# WP3 fluid harness: euler_fluid_2d\nn = 64\nsteps = 2000\ndt = 0.001\n",
        encoding="utf-8",
    )


def main() -> None:
    for bench_id in WP3_IDS:
        write_bench(bench_id)
        print(f"wrote {TIER2 / bench_id}")
    patch_euler_fluid()
    print(f"done: {len(WP3_IDS)} harness dirs + euler_fluid_2d patch")


if __name__ == "__main__":
    main()
