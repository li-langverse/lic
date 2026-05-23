# Vertical algorithm catalog (AL-2)

**Status:** Active (2026-05-23) — one kernel section per [verticals.toml](../../benchmarks/competitive/verticals.toml) row.  
**Plan:** [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) AL-2 · Layer B registry AL-1  
**UX intel (Layer C):** [game-dev/competitive-intel/ui-ux-by-dimension.md](../game-dev/competitive-intel/ui-ux-by-dimension.md)

Agents: cite vertical `id` and `workload_class` in PRs. Do **not** claim GROMACS/Gaussian/UE parity without a green bench/oracle row.

| Vertical `id` | `workload_class` | `li_package` | Bench / verify today |
|---------------|------------------|--------------|----------------------|
| `gaming_rigid` | `v0_gaming` | `physics.rigid` | composable `import_physics_rigid_gaming.li` + [world-studio.toml](../../benchmarks/competitive/world-studio.toml) |
| `md_lennard_jones` | `stub` | `sim.scientific` | tier-2 + `md_external_oracle_stub.sh` + [external/README.md](../../benchmarks/tier2_physics/md_lennard_jones/external/README.md) |
| `pde_heat_2d` | `stub` | `sim.scientific` | tier-2 `heat_equation_2d` + `verify.py` |
| `fea_linear_elasticity` | `stub` | `sim.scientific` | none (PH-CAE CAE-1) |
| `cfd_lid_driven_cavity` | `stub` | `sim.scientific` | none (PH-CAE CAE-2) |
| `drug_litl` | `stub` | `sim.drug_design` | composable_only |
| `am_slicer` | `stub` | `sim.additive` | composable_only |
| `scientific_viz` | `stub` | `sim.viz` | composable_only |
| `cinematic_encode` | `stub` | `studio` | none (PH-CIN CIN-2) |
| `cinematic_color_grade` | `stub` | `studio` | composable `import_studio_cinematic_algorithms.li` |
| `cinematic_audio_sync` | `stub` | `studio` | composable `import_studio_cinematic_algorithms.li` |
| `qm_dft` | `stub` | `chem` | external oracle TBD |

Gate: `./scripts/check-vertical-algorithm-catalog.sh` (sync with `verticals.toml`).

---

## gaming_rigid

**Incumbent:** Unreal Engine 5 / Unity / Godot + Jolt/Bullet  
**Kernel / API (compare):** rigid body integrate, collision broadphase  
**`workload_class`:** `v0_gaming` · **`oracle`:** `composable_only` · **`li_package`:** `physics.rigid`

### Kernel families

| Family | Target (incumbent) | Li today | Proof / bench |
|--------|-------------------|----------|---------------|
| Semi-implicit integrate | Bullet/PhysX step | `rigid_integrate_semi_implicit` in `physics.rigid` | composable `li-tests/composable/import_physics_rigid_gaming.li` |
| Collision broadphase | SAP / BVH | `aabb_overlap`, `sphere_sphere_overlap` | composable `import_physics_rigid_gaming.li` (scalar stubs) |
| Constraint solve | joints, contacts | **stub** | none |

### Studio / UX

- Profile: `game` ([world-studio-vision.md](../game-dev/world-studio-vision.md))
- UX: [UX-01](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-01--viewport--3d-navigation), [UX-02](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-02--panel-layout--docking) via `import gui`

### Honesty

[`world-studio.toml`](../../benchmarks/competitive/world-studio.toml) `gaming_rigid` row (`workload_class=v0_gaming`, `oracle=composable_only`) + tier-2 `rigid_body_stack` proxy — **not** full game-engine parity. No UE5 perf claims in CI.

---

## md_lennard_jones

**Incumbent:** LAMMPS / GROMACS  
**Kernel / API:** Lennard-Jones cutoff force + energy drift  
**`workload_class`:** `stub` · **`oracle`:** `cpp` (+ external stub plan) · **`li_package`:** `sim.scientific`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| LJ pair force + cutoff | LAMMPS `pair_style lj/cut` | Shared `md_core.c` + Li driver | `benchmarks/tier2_physics/md_lennard_jones/` |
| NVE energy drift | GROMACS validity | Checksum vs native in `verify.py` | tier-2 smoke green |
| External MD oracle | LAMMPS/GROMACS columns | **stub** — `lammps_lj_micro`, `gromacs_lj_micro` | `li-tests/tooling/md_external_oracle_stub.sh` |

### LAMMPS / GROMACS column plan (B0–B2)

| Phase | `csv_lang` | Oracle id | Status |
|-------|------------|-----------|--------|
| B0 | `lammps`, `gromacs` | `lammps_lj_micro`, `gromacs_lj_micro` | **stub** — native drift manifest only |
| B1 | `lammps` | `lammps_lj_micro` | deck matches `md_core.c` IC |
| B2 | `gromacs` | `gromacs_lj_micro` | `gmx mdrun` on pinned release |

Driver doc: [external/README.md](../../benchmarks/tier2_physics/md_lennard_jones/external/README.md) · stub: `run_oracle_stub.sh`.

### References

- Harness: [competitive-engines-plan.md](../benchmarks/competitive-engines-plan.md)
- Registry: [md_oracle.toml](../../benchmarks/competitive/md_oracle.toml)
- Driver: [external/README.md](../../benchmarks/tier2_physics/md_lennard_jones/external/README.md)
- UX: [UX-06](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-06--scientific-visualization)

### Honesty

**No GROMACS/LAMMPS parity claims.** `workload_class=stub` until B1/B2 external validity rows are green.

---

## pde_heat_2d

**Incumbent:** OpenFOAM / PETSc  
**Kernel / API:** explicit heat step, CFL stability  
**`workload_class`:** `stub` · **`oracle`:** `cpp` · **`li_package`:** `sim.scientific`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Explicit 2D heat stencil | FVM explicit step | `heat_equation_2d` Li + C reference | `benchmarks/tier2_physics/heat_equation_2d/` |
| CFL / stability guard | OpenFOAM time controls | documented in params; partial | `verify.py` checksum smoke |

### References

- UX: [UX-06](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-06--scientific-visualization)
- Additive thermal path reuses heat kernel ([algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §3 AM row)
- Engineering FEA/CFD: [engineering-cae-fundamentals.md](engineering-cae-fundamentals.md) (**PH-CAE**)

### Honesty

PDE smoke proves stencil checksum only — **not** OpenFOAM-scale CFD. FEA/CFD tracked under `fea_linear_elasticity` and `cfd_lid_driven_cavity`.

---

## fea_linear_elasticity

**Incumbent:** CalculiX / ANSYS Mechanical / SimScale  
**Kernel / API:** linear elasticity stiffness assembly + solve  
**`workload_class`:** `stub` · **`oracle`:** `cpp` · **`li_package`:** `sim.scientific`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Stiffness assembly | CalculiX `*STATIC` | **open** — `linalg` explicit small systems | none |
| Linear solve | sparse direct / iterative | **open** | none |
| Post-process stress | field export | **stub** — `sim.viz` | composable_only |

### References

- RFC: [li-sim-cae-rfc.md](../game-dev/specs/li-sim-cae-rfc.md)
- Fundamentals: [engineering-cae-fundamentals.md](engineering-cae-fundamentals.md)
- UX: [UX-06](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-06--scientific-visualization)

### Honesty

**No COMSOL/ANSYS parity claims.** `workload_class=stub` until CAE-1 bench + oracle land.

---

## cfd_lid_driven_cavity

**Incumbent:** OpenFOAM / COMSOL CFD / PETSc  
**Kernel / API:** incompressible Navier-Stokes, lid-driven cavity  
**`workload_class`:** `stub` · **`oracle`:** `cpp` · **`li_package`:** `sim.scientific`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Lid-driven cavity | OpenFOAM `cavity` tutorial | **open** | none |
| Pressure–velocity coupling | SIMPLE / PISO | **open** | none |
| Turbulence (RANS) | k–ε / SST | **stub** — CAE-4 API | none |

### References

- RFC: [li-sim-cae-rfc.md](../game-dev/specs/li-sim-cae-rfc.md)
- Fundamentals: [engineering-cae-fundamentals.md](engineering-cae-fundamentals.md)
- Shared numerics: `pde_heat_2d` explicit stencil discipline only

### Honesty

**No OpenFOAM-scale CFD parity claims.** `workload_class=stub` until CAE-2 bench lands.

---

## drug_litl

**Incumbent:** Roche Lab-in-the-Loop / Recursion LOWE  
**Kernel / API:** stage workflow UI + QM job queue  
**`workload_class`:** `stub` · **`oracle`:** `composable_only` · **`li_package`:** `sim.drug_design`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Stage chrome (hypothesis → clinic) | LITL loop panels | `adaptive_layout_hd()` roles on `li-ui` | composable `import_ui_adaptive_layout.li` |
| QM job queue panel | Schrödinger-class dispatch | **stub** — package composables | none |
| ML retrain loop | Recursion LOWE | **stub** | `bioengineering.toml` composable hooks |

### References

- RFC: [drug-design-lab-loop-rfc.md](../game-dev/specs/drug-design-lab-loop-rfc.md) (when present)
- UX: [UX-07](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-07--drug-discovery-stage-workflow-litl)
- Offline: `competitive-intel/downloads/research-drug-discovery-ui.md`

### Honesty

Workflow **UI patterns only** — no Roche/Schrödinger algorithm parity.

---

## am_slicer

**Incumbent:** PrusaSlicer / Cura / Bambu Studio  
**Kernel / API:** slice → preview → export G-code/3MF  
**`workload_class`:** `stub` · **`oracle`:** `composable_only` · **`li_package`:** `sim.additive`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Mesh slice + layer preview | Prusa plater TAB | **stub** — composable API | none |
| Toolpath / infill | Cura engine | **open** | none |
| Thermal compensation | OpenFOAM-class heat | reuse `pde_heat_2d` tier-2 | `heat_equation_2d` (shared numerics) |
| Export G-code/3MF | ≤3 clicks (PH-UX) | **stub** — `studio.publish` plan | none |

### References

- UX: [UX-08](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-08--am--slicer-workflow), [UX-09](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-09--export--handoff)
- Offline: `competitive-intel/downloads/prusa-ui-overview.html`

### Honesty

No slicer oracle column — interface landed, kernels **stub**.

---

## scientific_viz

**Incumbent:** ParaView / VTK / MATLAB  
**Kernel / API:** pipeline source + display + view properties  
**`workload_class`:** `stub` · **`oracle`:** `composable_only` · **`li_package`:** `sim.viz`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Field → color map | VTK lookup tables | **stub** | tier-2 field data via sim benches only |
| Pipeline browser | ParaView sources/filters | **stub** | none |
| Properties / Display / View | ParaView panel model | `gui` inspector section IDs | `import gui` composable |
| Linked split views | ParaView camera sync | **open** | none |

### References

- UX: [UX-04](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-04--properties--inspector), [UX-06](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-06--scientific-visualization)
- Offline: `competitive-intel/downloads/paraview-properties-panel.html`
- Bench hooks: `md_lennard_jones`, `heat_equation_2d` for field visualization smoke

### Honesty

Inspector layout is **stub**; no VTK render path in `li-ui` yet.

---

## cinematic_encode

**Incumbent:** ffmpeg / DaVinci Resolve export / UE movie render queue  
**Kernel / API:** H.264/MP4 mux presets, deterministic pre-encode frame queue  
**`workload_class`:** `stub` · **`oracle`:** `external_binary` · **`li_package`:** `studio`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Codec preset table | x264 / VP9 / AV1 profiles | `publish_encode_preset_h264` ID stub | composable smoke |
| Container mux | MP4/MKV | **open** — CIN-2 ffmpeg T5 | none |
| Pre-encode frame queue | Deterministic bake from `seq` | **open** — CIN-1 frame hash | none |

### References

- RFC: [li-cinematic-rfc.md](../game-dev/specs/li-cinematic-rfc.md)
- Fundamentals: [cinematic-algorithm-fundamentals.md](cinematic-algorithm-fundamentals.md)
- Timeline: `import seq` — [import_seq_shot_timeline.li](../../li-tests/composable/import_seq_shot_timeline.li)

### Honesty

**No Resolve/UE encode parity.** `workload_class=stub` until CIN-2 ffmpeg oracle lands.

---

## cinematic_color_grade

**Incumbent:** ACES / OCIO / Resolve color science  
**Kernel / API:** 1D LUT + display transfer (Rec.709 segment)  
**`workload_class`:** `stub` · **`oracle`:** `composable_only` · **`li_package`:** `studio`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Display transfer | Rec.709 OETF segment | `publish_color_linear_to_rec709` | composable bounds check |
| 1D LUT | OCIO FileTransform | **open** — CIN-3 | none |
| 3×3 matrix | ACEScg → Rec.709 | **open** — explicit `linalg` | none |

### References

- RFC: [li-cinematic-rfc.md](../game-dev/specs/li-cinematic-rfc.md)
- UX: [UX-05](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-05--timeline--playback) (preview only — not color science)

### Honesty

**No ACES/OCIO production parity.** Per-channel scalar stubs only.

---

## cinematic_audio_sync

**Incumbent:** ffmpeg aresample / Pro Tools pull-up  
**Kernel / API:** sample index from seq timeline time + fps rational  
**`workload_class`:** `stub` · **`oracle`:** `composable_only` · **`li_package`:** `studio`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| Sample index from frame | `frame * sample_rate * fps_den / fps_num` | `publish_audio_sample_index_for_frame` | composable at 24fps |
| Resample / drift guard | ffmpeg aresample | **open** — CIN-4 | none |
| Mux A/V | ffmpeg map | **open** — pairs with `cinematic_encode` | none |

### References

- RFC: [li-cinematic-rfc.md](../game-dev/specs/li-cinematic-rfc.md)
- `seq` clock: `seq_local_time_in_span`, `seq_timeline_contains_time`

### Honesty

**No broadcast audio parity.** Integer rational stub — not floating pull-up tables.

---

## qm_dft

**Incumbent:** Gaussian / ORCA / Psi4  
**Kernel / API:** DFT single-point energy  
**`workload_class`:** `stub` · **`oracle`:** `external_binary` · **`li_package`:** `chem`

### Kernel families

| Family | Target | Li today | Proof / bench |
|--------|--------|----------|---------------|
| DFT SCF energy | Gaussian/ORCA SP | **stub** — composable smoke | no external oracle in CI |
| Basis / functional selection | Psi4 driver API | **open** | trusted FFI plan (T5) |
| Job queue + I/O | HPC chemistry schedulers | **stub** | none |

### References

- UX: [UX-07](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-07--drug-discovery-stage-workflow-litl) (QM panel in LITL chrome)
- Master plan: Wave A before scaling domain chem ([provability-gaps.md](../verification/provability-gaps.md))

### Honesty

**No Gaussian/ORCA parity.** `external_binary` oracle not wired; `workload_class=stub`.

---

## Maintenance

1. Add `[[vertical]]` row to `verticals.toml` first.  
2. Add matching `## <id>` section here (kernel table + honesty).  
3. Run `./scripts/check-vertical-algorithm-catalog.sh`.  
4. Bump `last_reviewed` on quarterly SOTA review ([algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) AL-7).
