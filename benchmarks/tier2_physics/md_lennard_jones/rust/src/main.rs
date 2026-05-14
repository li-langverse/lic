//! Lennard-Jones MD reference (velocity Verlet, periodic box).
//! Params match benchmarks/tier2_physics/md_lennard_jones/params.toml.

const N: usize = 256;
const STEPS: usize = 10_000;
const DT: f64 = 0.004;
const RC: f64 = 2.5;
const BOX: f64 = 10.0;
const SEED: u64 = 7;

struct Rng {
    state: u64,
}

impl Rng {
    fn new(seed: u64) -> Self {
        Self { state: seed }
    }

    fn next_f64(&mut self) -> f64 {
        self.state = self.state.wrapping_mul(6364136223846793005).wrapping_add(1);
        ((self.state >> 11) as f64) / ((1u64 << 53) as f64)
    }
}

fn init_lattice(pos: &mut [[f64; 3]], vel: &mut [[f64; 3]], rng: &mut Rng) {
    let cells = (N as f64).cbrt().ceil() as usize;
    let spacing = BOX / cells as f64;
    let mut idx = 0usize;
    for ix in 0..cells {
        for iy in 0..cells {
            for iz in 0..cells {
                if idx >= N {
                    break;
                }
                pos[idx][0] = (ix as f64 + 0.5) * spacing;
                pos[idx][1] = (iy as f64 + 0.5) * spacing;
                pos[idx][2] = (iz as f64 + 0.5) * spacing;
                vel[idx][0] = 0.01 * (rng.next_f64() - 0.5);
                vel[idx][1] = 0.01 * (rng.next_f64() - 0.5);
                vel[idx][2] = 0.01 * (rng.next_f64() - 0.5);
                idx += 1;
            }
        }
    }
}

fn mic(d: f64) -> f64 {
    let half = 0.5 * BOX;
    if d > half {
        d - BOX
    } else if d < -half {
        d + BOX
    } else {
        d
    }
}

fn compute_forces(pos: &[[f64; 3]], forces: &mut [[f64; 3]]) {
    let rc2 = RC * RC;
    for f in forces.iter_mut() {
        *f = [0.0; 3];
    }
    for i in 0..N {
        for j in (i + 1)..N {
            let dx = mic(pos[j][0] - pos[i][0]);
            let dy = mic(pos[j][1] - pos[i][1]);
            let dz = mic(pos[j][2] - pos[i][2]);
            let r2 = dx * dx + dy * dy + dz * dz;
            if r2 >= rc2 || r2 < 1e-12 {
                continue;
            }
            let inv_r2 = 1.0 / r2;
            let inv_r6 = inv_r2 * inv_r2 * inv_r2;
            let inv_r12 = inv_r6 * inv_r6;
            let f_scalar = 48.0 * inv_r12 - 24.0 * inv_r6;
            let fx = f_scalar * dx;
            let fy = f_scalar * dy;
            let fz = f_scalar * dz;
            forces[i][0] -= fx;
            forces[i][1] -= fy;
            forces[i][2] -= fz;
            forces[j][0] += fx;
            forces[j][1] += fy;
            forces[j][2] += fz;
        }
    }
}

fn total_energy(pos: &[[f64; 3]], vel: &[[f64; 3]]) -> f64 {
    let rc2 = RC * RC;
    let mut pe = 0.0;
    let mut ke = 0.0;
    for i in 0..N {
        ke += 0.5 * (vel[i][0] * vel[i][0] + vel[i][1] * vel[i][1] + vel[i][2] * vel[i][2]);
    }
    for i in 0..N {
        for j in (i + 1)..N {
            let dx = mic(pos[j][0] - pos[i][0]);
            let dy = mic(pos[j][1] - pos[i][1]);
            let dz = mic(pos[j][2] - pos[i][2]);
            let r2 = dx * dx + dy * dy + dz * dz;
            if r2 >= rc2 || r2 < 1e-12 {
                continue;
            }
            let inv_r2 = 1.0 / r2;
            let inv_r6 = inv_r2 * inv_r2 * inv_r2;
            let inv_r12 = inv_r6 * inv_r6;
            pe += 4.0 * (inv_r12 - inv_r6);
        }
    }
    pe + ke
}

fn run() -> f64 {
    let mut rng = Rng::new(SEED);
    let mut pos = [[0.0; 3]; N];
    let mut vel = [[0.0; 3]; N];
    let mut forces = [[0.0; 3]; N];

    init_lattice(&mut pos, &mut vel, &mut rng);

    compute_forces(&pos, &mut forces);
    let e0 = total_energy(&pos, &vel);

    for _ in 0..STEPS {
        for i in 0..N {
            vel[i][0] += 0.5 * DT * forces[i][0];
            vel[i][1] += 0.5 * DT * forces[i][1];
            vel[i][2] += 0.5 * DT * forces[i][2];
        }
        for i in 0..N {
            pos[i][0] = (pos[i][0] + DT * vel[i][0]).rem_euclid(BOX);
            pos[i][1] = (pos[i][1] + DT * vel[i][1]).rem_euclid(BOX);
            pos[i][2] = (pos[i][2] + DT * vel[i][2]).rem_euclid(BOX);
        }
        compute_forces(&pos, &mut forces);
        for i in 0..N {
            vel[i][0] += 0.5 * DT * forces[i][0];
            vel[i][1] += 0.5 * DT * forces[i][1];
            vel[i][2] += 0.5 * DT * forces[i][2];
        }
    }

    let e1 = total_energy(&pos, &vel);
    let denom = e0.abs().max(e1.abs()).max(1e-12);
    (e1 - e0).abs() / denom
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let drift = run();
    if args.iter().any(|a| a == "--verify") {
        println!("{:.8e}", drift);
    }
}
