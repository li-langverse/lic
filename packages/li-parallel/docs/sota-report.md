# li-parallel vs SOTA report

Generated: 2026-06-08T05:20:08.322451+00:00
CSV: `/mnt/c/Users/Julian/Documents/Programming/li/benchmarks/results/latest.csv`

## Summary

| Metric | Count |
|--------|------:|
| Benchmarks with Li rows | 152 |
| **li_parallel** beats best SOTA | 24 |
| **li_parallel** within 1.2× of SOTA | 118 |
| **li_parallel** behind SOTA | 10 |
| **li_serial** beats best SOTA | 24 |

## Per-benchmark (li_parallel vs best competitor)

| Benchmark | SOTA | SOTA (s) | li_parallel (s) | vs SOTA | vs cpp | speedup | status |
|-----------|------|----------|-----------------|---------|--------|---------|--------|
| advection_diffusion_2d | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_export_gcode_3mf | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_infill_grid_lines | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_infill_gyroid | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_offset_perimeters | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_plane_mesh_intersect | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_polygon_clip | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_slice_layers | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_support_tree | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_thermal_warp | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| am_toolpath_arcs | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| auto_bicycle_model | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| auto_dyn_rk4 | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| auto_sensor_raycast | rust | 0.0814 | 0.0822 | 0.9903 | 0.9762 | 1.0 | within_threshold |
| bio_proteinmpnn | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| bio_rfdiffusion | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| bio_rosetta_energy | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| bio_rotamer_packing | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cfd_fvm_face_flux | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cfd_pimple | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cfd_piso | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cfd_simple | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cfd_turbulence_k_epsilon | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cfd_turbulence_k_omega_sst | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| cloth_swing | rust | 0.0036 | 0.0037 | 0.973 | 1.0 | 1.0 | within_threshold |
| combustion_passive | julia | 0.0033 | 0.0038 | 0.8684 | 1.0857 | 1.0 | within_threshold |
| double_pendulum | rust | 0.3141 | 0.3076 | 1.0211 | 0.9628 | 1.0 | beats_sota |
| drug_docking_diffusion | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| drug_docking_score_vina | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| drug_fep_alchemical | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| drug_litl_stages | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| drug_ml_retrain_loop | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| euler_fluid_2d | rust | 0.0033 | 0.0038 | 0.8684 | 1.0857 | 1.0 | within_threshold |
| fdtd_waveguide_2d | rust | 0.0033 | 0.0037 | 0.8919 | 1.0571 | 1.0 | within_threshold |
| fea_gauss_quadrature | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| fea_linear_elasticity | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| fea_mesh_tri_tet | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| fea_solver_direct | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| fea_solver_iterative | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| fea_stiffness_assembly | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| fft_1d_fixed | rust | 0.0258 | 0.0266 | 0.9699 | 0.9268 | 1.0 | within_threshold |
| harmonic_oscillator_chain | julia | 0.0951 | 0.0962 | 0.9886 | 0.9544 | 1.0 | within_threshold |
| heat_equation_2d | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| horner_pure_li | cpp | 0.0005 | 0.0004 | 1.25 | 0.8 | 1.0 | beats_sota |
| matmul_blocked | julia | 0.0082 | 0.0004 | 20.5 | 0.0471 | 1.0 | beats_sota |
| matmul_naive | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| md_barostat_parrinello_rahman | julia | 2.0918 | 2.1537 | 0.9713 | 0.9867 | 1.0 | within_threshold |
| md_constraints_rattle | rust | 2.0836 | 2.1177 | 0.9839 | 0.9865 | 1.0 | within_threshold |
| md_constraints_shake | julia | 2.1335 | 2.0931 | 1.0193 | 0.9642 | 1.0 | beats_sota |
| md_energy_drift | julia | 2.1032 | 2.0285 | 1.0368 | 0.9208 | 1.0 | beats_sota |
| md_init_fcc_mb | julia | 2.1768 | 2.1506 | 1.0122 | 0.9645 | 1.0 | beats_sota |
| md_integrator_leapfrog | julia | 2.0462 | 2.1372 | 0.9574 | 0.9222 | 1.0 | within_threshold |
| md_integrator_verlet | julia | 2.1148 | 2.0802 | 1.0166 | 0.938 | 1.0 | beats_sota |
| md_lennard_jones | julia | 1.1527 | 1.1833 | 0.9741 | 0.9958 | 1.0 | within_threshold |
| md_lj_cutoff_mic | julia | 1.1527 | 1.1833 | 0.9741 | 0.9958 | 1.0 | within_threshold |
| md_longrange_ewald | rust | 2.0912 | 2.0729 | 1.0088 | 0.9599 | 1.0 | beats_sota |
| md_longrange_pme | rust | 2.1425 | 2.1152 | 1.0129 | 0.9687 | 1.0 | beats_sota |
| md_neighbor_cell_list | julia | 2.1422 | 2.0638 | 1.038 | 0.9621 | 1.0 | beats_sota |
| md_neighbor_verlet_skin | rust | 2.137 | 1.9702 | 1.0847 | 0.8944 | 1.0 | beats_sota |
| md_oracle_external | julia | 2.1929 | 2.0059 | 1.0932 | 0.8844 | 1.0 | beats_sota |
| md_thermostat_berendsen | julia | 2.0605 | 2.1192 | 0.9723 | 1.0131 | 1.0 | within_threshold |
| md_thermostat_nose_hoover | cpp | 2.1232 | 2.1539 | 0.9857 | 1.0145 | 1.0 | within_threshold |
| ml_conv2d_forward | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| ml_mlp_forward | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| ml_mlp_train_step | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| nbody_barnes_hut | julia | 1.1527 | 1.1833 | 0.9741 | 0.9958 | 1.0 | within_threshold |
| nbody_gravity | julia | 1.4375 | 1.4468 | 0.9936 | 0.9646 | 1.0 | within_threshold |
| nbody_pairwise_gravity | julia | 1.1527 | 1.1833 | 0.9741 | 0.9958 | 1.0 | within_threshold |
| num_cg | rust | 0.0085 | 0.0109 | 0.7798 | 1.1848 | 1.0 | behind |
| num_cholesky | rust | 0.0085 | 0.0089 | 0.9551 | 0.9889 | 1.0 | within_threshold |
| num_dot_axpy | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| num_eig_symmetric | rust | 0.0085 | 0.0113 | 0.7522 | 1.2283 | 1.0 | behind |
| num_fft_r2c | rust | 0.0177 | 0.0204 | 0.8676 | 1.0737 | 1.0 | within_threshold |
| num_gmres | cpp | 0.0005 | 0.0005 | 1.0 | 1.0 | 1.0 | beats_sota |
| num_integ_euler | rust | 0.0093 | 0.0121 | 0.7686 | 1.1863 | 1.0 | behind |
| num_integ_rk4 | rust | 0.0094 | 0.0121 | 0.7769 | 1.1863 | 1.0 | behind |
| num_integ_semi_implicit | rust | 0.0093 | 0.0119 | 0.7815 | 1.19 | 1.0 | behind |
| num_integ_symplectic | rust | 0.0093 | 0.0118 | 0.7881 | 1.18 | 1.0 | behind |
| num_integ_verlet | rust | 0.0101 | 0.0129 | 0.7829 | 1.1835 | 1.0 | behind |
| num_matmul_blocked | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| num_matmul_naive | julia | 0.0017 | 0.0018 | 0.9444 | 0.9474 | 1.0 | within_threshold |
| num_opt_bfgs | rust | 0.0085 | 0.0109 | 0.7798 | 1.1978 | 1.0 | behind |
| num_opt_line_search | rust | 0.0107 | 0.0116 | 0.9224 | 0.9915 | 1.0 | within_threshold |
| num_quadrature_gauss | rust | 0.0085 | 0.0103 | 0.8252 | 1.1075 | 1.0 | behind |
| num_rng_pcg | rust | 0.0173 | 0.0205 | 0.8439 | 1.1022 | 1.0 | within_threshold |
| num_root_newton | rust | 0.0085 | 0.0111 | 0.7658 | 1.2198 | 1.0 | behind |
| num_sparse_mv | rust | 0.0143 | 0.0164 | 0.872 | 1.038 | 1.0 | within_threshold |
| orbit_two_body | cpp | 0.0036 | 0.0037 | 0.973 | 1.0278 | 1.0 | within_threshold |
| pde_cfl_timestep | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| pde_heat_explicit_2d | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| pde_heat_implicit_jacobi | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| pde_wave_1d_cfl | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_ase_calculator | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_ccsd | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_grid_becke | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_grid_lebedev | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_hybrid_exchange | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_scf_energy | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_xc_gga | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_xc_lda | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dft_xc_mgga | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_dispersion_d3 | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_ecp | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_eri_density_fitting | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_eri_os | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_eri_screening | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_geom_opt_bfgs | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_geom_opt_internal | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_grad_analytical | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_gto_eval | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_hf_canonical_ortho | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_hf_diis | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_hf_fock_build | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_job_queue_io | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_kinetic_integrals | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_mp2 | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_nuclear_attraction | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_overlap_integrals | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_property_dipole | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_property_freq | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_scf_solver | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_tddft_casida | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_tddft_rpa | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| qm_xtb_gfn | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| ragdoll_chain | rust | 0.0031 | 0.0035 | 0.8857 | 1.0938 | 1.0 | within_threshold |
| reduce_sum | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| rigid_body_stack | rust | 0.0029 | 0.0034 | 0.8529 | 1.1333 | 1.0 | within_threshold |
| rigid_broadphase_bvh | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| rigid_broadphase_sap | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| rigid_constraints | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| rigid_contact_solver | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| rigid_semi_implicit | rust | 0.1062 | 0.1067 | 0.9953 | 0.9417 | 1.0 | within_threshold |
| robo_ik_jacobian | rust | 0.1807 | 0.1817 | 0.9945 | 1.0 | 1.0 | within_threshold |
| robo_multibody_step | rust | 0.1807 | 0.1817 | 0.9945 | 1.0 | 1.0 | within_threshold |
| robo_plan_prm | rust | 0.1807 | 0.1817 | 0.9945 | 1.0 | 1.0 | within_threshold |
| robo_plan_rrt | rust | 0.1807 | 0.1817 | 0.9945 | 1.0 | 1.0 | within_threshold |
| robo_traj_opt | rust | 0.1807 | 0.1817 | 0.9945 | 1.0 | 1.0 | within_threshold |
| schrodinger_1d_barrier | julia | 0.0037 | 0.0039 | 0.9487 | 1.0 | 1.0 | within_threshold |
| simd_dot | julia | 0.0932 | 0.096 | 0.9708 | 0.8233 | 1.0 | within_threshold |
| sph_dam_break_2d | julia | 0.9566 | 0.9576 | 0.999 | 0.9537 | 1.0 | within_threshold |
| three_body | rust | 0.1807 | 0.1817 | 0.9945 | 1.0 | 1.0 | within_threshold |
| three_body_pure | julia | 0.1708 | 0.1705 | 1.0018 | 0.9693 | 1.0 | beats_sota |
| viz_colormap | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| viz_decimate | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| viz_inspector_panels | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| viz_linked_views | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| viz_marching_cubes | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| viz_pipeline_graph | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| viz_resample | julia | 0.4292 | 0.4287 | 1.0012 | 0.9025 | 1.0 | beats_sota |
| wave_equation_1d | cpp | 1.2387 | 1.2046 | 1.0283 | 0.9725 | 1.0 | beats_sota |
| wave_equation_2d | rust | 0.2035 | 0.1977 | 1.0293 | 0.9339 | 1.0 | beats_sota |
| wind_field_bc | rust | 0.0033 | 0.0039 | 0.8462 | 1.1143 | 1.0 | within_threshold |
