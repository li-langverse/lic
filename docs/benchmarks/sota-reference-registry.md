# SOTA reference registry (Li implementations)

Li ships solvers in `packages/*`. **Correctness** is checked against C oracles in `lic/benchmarks/tier*/common/*_core.c`. **Performance** is reported via org [benchmarks](https://github.com/li-langverse/benchmarks) ingest.

| Li package / API | Harness id | SOTA / industry reference | Notes |
|----------------|------------|-------------------------|--------|
| `math.numerics` · `three_body_*` | `three_body` | Few-body integrators (symplectic Euler / Yoshida); compare [REBOUND](https://github.com/hannorein/rebound) | Quick: 200k steps, 3 bodies |
| `math.numerics` · `harmonic_chain_*` | `harmonic_oscillator_chain` | Mass–spring chains; MD packages (OpenMM, LAMMPS) | Velocity Verlet + fixed ends |
| `math.numerics` · `heat_1d_*` | `wave_equation_1d` / reactor hooks | Explicit heat/wave CFL; FD textbooks | 1D explicit Laplacian step |
| `math.numerics` · `lj_cluster_energy` | `md_lennard_jones` | [GROMACS](https://www.gromacs.org), [OpenMM](https://openmm.org) LJ | Mini FCC cluster, drift metric |
| `physics.fluids` · SPH / Euler | `sph_dam_break_2d`, `euler_fluid_2d` | [DualSPHysics](https://www.dualsphysics.com), CFD v0 | v0 gaming class in catalog |
| `chem` · `dft_run_lj_reference` | (composable + MD bench) | [ASE](https://wiki.fysik.dtu.dk/ase), [Psi4](https://psicode.org) | LJ surrogate until QM kernel lands |
| `bioeng` · `bioeng_monod_*` | `bioeng` competitive (planned) | Bioprocess Monod kinetics | ODE stability |
| `sim.scientific` · `sim_field_step_li` | `heat_equation_2d` | OpenFOAM-class diffusion (not full NS) | Field chunk → explicit heat |
| `sim.robotics` · `robot_joint_step_li` | (planned) | Pinocchio / Drake joint integration | 1-DOF damped oscillator |
| `sim.automotive` · `bicycle_step_li` | (planned) | Kinematic bicycle model literature | Yaw–speed coupling |
| `sim.drug_design` · `lab_loop_advance_li` | `drug-litl-chem` composable | Lab-in-the-loop QM workflows | Stages + LJ energy hook |

**Rule:** new rows require PR updating this table + `.cursor/rules/li-sota-benchmark-li-only.mdc` compliance.
