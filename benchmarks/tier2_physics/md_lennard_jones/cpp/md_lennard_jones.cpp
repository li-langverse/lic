// Lennard-Jones MD reference — params match params.toml
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <string>
#include <vector>

namespace {
constexpr int N = 256;
constexpr int STEPS = 10000;
constexpr double DT = 0.004;
constexpr double RC = 2.5;
constexpr double BOX = 10.0;
constexpr std::uint64_t SEED = 7;

struct Rng {
  std::uint64_t state;
  explicit Rng(std::uint64_t s) : state(s) {}
  double next() {
    state = state * 6364136223846793005ULL + 1ULL;
    return static_cast<double>(state >> 11) / static_cast<double>(1ULL << 53);
  }
};

double mic(double d) {
  const double half = 0.5 * BOX;
  if (d > half) return d - BOX;
  if (d < -half) return d + BOX;
  return d;
}

double wrap_pos(double x) {
  x = std::fmod(x, BOX);
  if (x < 0.0) {
    x += BOX;
  }
  return x;
}

void init_lattice(std::vector<double>& pos, std::vector<double>& vel, Rng& rng) {
  const int cells = static_cast<int>(std::ceil(std::cbrt(static_cast<double>(N))));
  const double spacing = BOX / static_cast<double>(cells);
  int idx = 0;
  for (int ix = 0; ix < cells; ++ix) {
    for (int iy = 0; iy < cells; ++iy) {
      for (int iz = 0; iz < cells; ++iz) {
        if (idx >= N) return;
        pos[idx * 3 + 0] = (static_cast<double>(ix) + 0.5) * spacing;
        pos[idx * 3 + 1] = (static_cast<double>(iy) + 0.5) * spacing;
        pos[idx * 3 + 2] = (static_cast<double>(iz) + 0.5) * spacing;
        vel[idx * 3 + 0] = 0.01 * (rng.next() - 0.5);
        vel[idx * 3 + 1] = 0.01 * (rng.next() - 0.5);
        vel[idx * 3 + 2] = 0.01 * (rng.next() - 0.5);
        ++idx;
      }
    }
  }
}

void compute_forces(const std::vector<double>& pos, std::vector<double>& forces) {
  const double rc2 = RC * RC;
  std::fill(forces.begin(), forces.end(), 0.0);
  for (int i = 0; i < N; ++i) {
    for (int j = i + 1; j < N; ++j) {
      const double dx = mic(pos[j * 3 + 0] - pos[i * 3 + 0]);
      const double dy = mic(pos[j * 3 + 1] - pos[i * 3 + 1]);
      const double dz = mic(pos[j * 3 + 2] - pos[i * 3 + 2]);
      const double r2 = dx * dx + dy * dy + dz * dz;
      if (r2 >= rc2 || r2 < 1e-12) continue;
      const double inv_r2 = 1.0 / r2;
      const double inv_r6 = inv_r2 * inv_r2 * inv_r2;
      const double inv_r12 = inv_r6 * inv_r6;
      const double f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6;
      const double fx = f_scalar * dx;
      const double fy = f_scalar * dy;
      const double fz = f_scalar * dz;
      forces[i * 3 + 0] -= fx;
      forces[i * 3 + 1] -= fy;
      forces[i * 3 + 2] -= fz;
      forces[j * 3 + 0] += fx;
      forces[j * 3 + 1] += fy;
      forces[j * 3 + 2] += fz;
    }
  }
}

double total_energy(const std::vector<double>& pos, const std::vector<double>& vel) {
  const double rc2 = RC * RC;
  double ke = 0.0;
  double pe = 0.0;
  for (int i = 0; i < N; ++i) {
    ke += 0.5 * (vel[i * 3 + 0] * vel[i * 3 + 0] + vel[i * 3 + 1] * vel[i * 3 + 1] +
                 vel[i * 3 + 2] * vel[i * 3 + 2]);
  }
  for (int i = 0; i < N; ++i) {
    for (int j = i + 1; j < N; ++j) {
      const double dx = mic(pos[j * 3 + 0] - pos[i * 3 + 0]);
      const double dy = mic(pos[j * 3 + 1] - pos[i * 3 + 1]);
      const double dz = mic(pos[j * 3 + 2] - pos[i * 3 + 2]);
      const double r2 = dx * dx + dy * dy + dz * dz;
      if (r2 >= rc2 || r2 < 1e-12) continue;
      const double inv_r2 = 1.0 / r2;
      const double inv_r6 = inv_r2 * inv_r2 * inv_r2;
      const double inv_r12 = inv_r6 * inv_r6;
      pe += 4.0 * (inv_r12 - inv_r6);
    }
  }
  return pe + ke;
}

double run_md() {
  Rng rng(SEED);
  std::vector<double> pos(N * 3), vel(N * 3), forces(N * 3);
  init_lattice(pos, vel, rng);
  compute_forces(pos, forces);
  const double e0 = total_energy(pos, vel);
  for (int step = 0; step < STEPS; ++step) {
    for (int i = 0; i < N * 3; ++i) vel[i] += 0.5 * DT * forces[i];
    for (int i = 0; i < N; ++i) {
      pos[i * 3 + 0] = wrap_pos(pos[i * 3 + 0] + DT * vel[i * 3 + 0]);
      pos[i * 3 + 1] = wrap_pos(pos[i * 3 + 1] + DT * vel[i * 3 + 1]);
      pos[i * 3 + 2] = wrap_pos(pos[i * 3 + 2] + DT * vel[i * 3 + 2]);
    }
    compute_forces(pos, forces);
    for (int i = 0; i < N * 3; ++i) vel[i] += 0.5 * DT * forces[i];
  }
  const double e1 = total_energy(pos, vel);
  const double denom = std::max({std::abs(e0), std::abs(e1), 1e-12});
  return std::abs(e1 - e0) / denom;
}
}  // namespace

int main(int argc, char** argv) {
  const double drift = run_md();
  for (int i = 1; i < argc; ++i) {
    if (std::string(argv[i]) == "--verify") {
      std::cout.setf(std::ios::scientific);
      std::cout.precision(8);
      std::cout << drift << '\n';
      break;
    }
  }
  return 0;
}
