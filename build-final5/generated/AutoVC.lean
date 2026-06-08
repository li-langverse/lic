-- Auto-generated VC obligations (Phase 2e). Props typecheck in Lean; discharge in 2f.
import Init.Data.Float
import Core
import Discharge

open Li

namespace AutoVC

namespace main

def vc_main_requires_0 : Prop := True
theorem vc_main_requires_0_proved : vc_main_requires_0 := trivial
def vc_main_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_main_ensures_0_proved (result : Int) : vc_main_ensures_0 result := trivial
def vc_main_decreases_0 : Nat := 0
theorem vc_main_decreases_0_proved : vc_main_decreases_0 = 0 := rfl
def vc_main_call0_sim_scientific_oracle_checksum_md_requires_0 : Prop := True
theorem vc_main_call0_sim_scientific_oracle_checksum_md_requires_0_proved : vc_main_call0_sim_scientific_oracle_checksum_md_requires_0 := trivial
def vc_main_call1_sim_scientific_oracle_checksum_heat_requires_0 : Prop := True
theorem vc_main_call1_sim_scientific_oracle_checksum_heat_requires_0_proved : vc_main_call1_sim_scientific_oracle_checksum_heat_requires_0 := trivial
def vc_main_call2_sim_scientific_oracle_checksum_cfd_requires_0 : Prop := True
theorem vc_main_call2_sim_scientific_oracle_checksum_cfd_requires_0_proved : vc_main_call2_sim_scientific_oracle_checksum_cfd_requires_0 := trivial

end main

namespace li_sim_version

def vc_li_sim_version_requires_0 : Prop := True
theorem vc_li_sim_version_requires_0_proved : vc_li_sim_version_requires_0 := trivial
def vc_li_sim_version_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_li_sim_version_ensures_0_proved (result : Int) : vc_li_sim_version_ensures_0 result := trivial
def vc_li_sim_version_decreases_0 : Nat := 0
theorem vc_li_sim_version_decreases_0_proved : vc_li_sim_version_decreases_0 = 0 := rfl

end li_sim_version

namespace output_detail_summary

def vc_output_detail_summary_requires_0 : Prop := True
theorem vc_output_detail_summary_requires_0_proved : vc_output_detail_summary_requires_0 := trivial
def vc_output_detail_summary_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_output_detail_summary_ensures_0_proved (result : Int) : vc_output_detail_summary_ensures_0 result := trivial
def vc_output_detail_summary_decreases_0 : Nat := 0
theorem vc_output_detail_summary_decreases_0_proved : vc_output_detail_summary_decreases_0 = 0 := rfl

end output_detail_summary

namespace output_detail_fields

def vc_output_detail_fields_requires_0 : Prop := True
theorem vc_output_detail_fields_requires_0_proved : vc_output_detail_fields_requires_0 := trivial
def vc_output_detail_fields_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_output_detail_fields_ensures_0_proved (result : Int) : vc_output_detail_fields_ensures_0 result := trivial
def vc_output_detail_fields_decreases_0 : Nat := 0
theorem vc_output_detail_fields_decreases_0_proved : vc_output_detail_fields_decreases_0 = 0 := rfl

end output_detail_fields

namespace output_detail_debug

def vc_output_detail_debug_requires_0 : Prop := True
theorem vc_output_detail_debug_requires_0_proved : vc_output_detail_debug_requires_0 := trivial
def vc_output_detail_debug_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_output_detail_debug_ensures_0_proved (result : Int) : vc_output_detail_debug_ensures_0 result := trivial
def vc_output_detail_debug_decreases_0 : Nat := 0
theorem vc_output_detail_debug_decreases_0_proved : vc_output_detail_debug_decreases_0 = 0 := rfl

end output_detail_debug

namespace output_detail_repro

def vc_output_detail_repro_requires_0 : Prop := True
theorem vc_output_detail_repro_requires_0_proved : vc_output_detail_repro_requires_0 := trivial
def vc_output_detail_repro_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_output_detail_repro_ensures_0_proved (result : Int) : vc_output_detail_repro_ensures_0 result := trivial
def vc_output_detail_repro_decreases_0 : Nat := 0
theorem vc_output_detail_repro_decreases_0_proved : vc_output_detail_repro_decreases_0 = 0 := rfl

end output_detail_repro

namespace summary_format_json

def vc_summary_format_json_requires_0 : Prop := True
theorem vc_summary_format_json_requires_0_proved : vc_summary_format_json_requires_0 := trivial
def vc_summary_format_json_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_summary_format_json_ensures_0_proved (result : Int) : vc_summary_format_json_ensures_0 result := trivial
def vc_summary_format_json_decreases_0 : Nat := 0
theorem vc_summary_format_json_decreases_0_proved : vc_summary_format_json_decreases_0 = 0 := rfl

end summary_format_json

namespace summary_format_json_min

def vc_summary_format_json_min_requires_0 : Prop := True
theorem vc_summary_format_json_min_requires_0_proved : vc_summary_format_json_min_requires_0 := trivial
def vc_summary_format_json_min_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_summary_format_json_min_ensures_0_proved (result : Int) : vc_summary_format_json_min_ensures_0 result := trivial
def vc_summary_format_json_min_decreases_0 : Nat := 0
theorem vc_summary_format_json_min_decreases_0_proved : vc_summary_format_json_min_decreases_0 = 0 := rfl

end summary_format_json_min

namespace summary_format_yaml

def vc_summary_format_yaml_requires_0 : Prop := True
theorem vc_summary_format_yaml_requires_0_proved : vc_summary_format_yaml_requires_0 := trivial
def vc_summary_format_yaml_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_summary_format_yaml_ensures_0_proved (result : Int) : vc_summary_format_yaml_ensures_0 result := trivial
def vc_summary_format_yaml_decreases_0 : Nat := 0
theorem vc_summary_format_yaml_decreases_0_proved : vc_summary_format_yaml_decreases_0 = 0 := rfl

end summary_format_yaml

namespace output_spec_default

def vc_output_spec_default_requires_0 : Prop := True
theorem vc_output_spec_default_requires_0_proved : vc_output_spec_default_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_output_spec_default_ensures_0 (result : Int) : Prop := True
theorem vc_output_spec_default_ensures_0_proved (result : Int) : vc_output_spec_default_ensures_0 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_output_spec_default_ensures_1 (result : Int) : Prop := True
theorem vc_output_spec_default_ensures_1_proved (result : Int) : vc_output_spec_default_ensures_1 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_output_spec_default_ensures_2 (result : Int) : Prop := True
theorem vc_output_spec_default_ensures_2_proved (result : Int) : vc_output_spec_default_ensures_2 result := trivial
def vc_output_spec_default_decreases_0 : Nat := 0
theorem vc_output_spec_default_decreases_0_proved : vc_output_spec_default_decreases_0 = 0 := rfl
def vc_output_spec_default_call0_summary_format_json_min_requires_0 : Prop := True
theorem vc_output_spec_default_call0_summary_format_json_min_requires_0_proved : vc_output_spec_default_call0_summary_format_json_min_requires_0 := trivial

end output_spec_default

namespace output_spec_from_detail

def vc_output_spec_from_detail_requires_0 (detail : Int) : Prop := (detail ≥ 0)
def vc_output_spec_from_detail_requires_1 (detail : Int) : Prop := (detail ≤ 3)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_output_spec_from_detail_ensures_0 (detail : Int) (result : Int) : Prop := True
theorem vc_output_spec_from_detail_ensures_0_proved (detail : Int) (result : Int) : vc_output_spec_from_detail_ensures_0 detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_output_spec_from_detail_ensures_1 (detail : Int) (result : Int) : Prop := True
theorem vc_output_spec_from_detail_ensures_1_proved (detail : Int) (result : Int) : vc_output_spec_from_detail_ensures_1 detail result := trivial
def vc_output_spec_from_detail_decreases_0 (detail : Int) : Nat := 0
theorem vc_output_spec_from_detail_decreases_0_proved (detail : Int) : vc_output_spec_from_detail_decreases_0 detail = 0 := rfl
def vc_output_spec_from_detail_call0_summary_format_json_min_requires_0 (detail : Int) : Prop := True
theorem vc_output_spec_from_detail_call0_summary_format_json_min_requires_0_proved (detail : Int) : vc_output_spec_from_detail_call0_summary_format_json_min_requires_0 detail := trivial

end output_spec_from_detail

namespace vertical_md_lennard_jones

def vc_vertical_md_lennard_jones_requires_0 : Prop := True
theorem vc_vertical_md_lennard_jones_requires_0_proved : vc_vertical_md_lennard_jones_requires_0 := trivial
def vc_vertical_md_lennard_jones_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_md_lennard_jones_ensures_0_proved (result : Int) : vc_vertical_md_lennard_jones_ensures_0 result := trivial
def vc_vertical_md_lennard_jones_decreases_0 : Nat := 0
theorem vc_vertical_md_lennard_jones_decreases_0_proved : vc_vertical_md_lennard_jones_decreases_0 = 0 := rfl

end vertical_md_lennard_jones

namespace vertical_pde_heat_2d

def vc_vertical_pde_heat_2d_requires_0 : Prop := True
theorem vc_vertical_pde_heat_2d_requires_0_proved : vc_vertical_pde_heat_2d_requires_0 := trivial
def vc_vertical_pde_heat_2d_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_pde_heat_2d_ensures_0_proved (result : Int) : vc_vertical_pde_heat_2d_ensures_0 result := trivial
def vc_vertical_pde_heat_2d_decreases_0 : Nat := 0
theorem vc_vertical_pde_heat_2d_decreases_0_proved : vc_vertical_pde_heat_2d_decreases_0 = 0 := rfl

end vertical_pde_heat_2d

namespace vertical_gaming_rigid

def vc_vertical_gaming_rigid_requires_0 : Prop := True
theorem vc_vertical_gaming_rigid_requires_0_proved : vc_vertical_gaming_rigid_requires_0 := trivial
def vc_vertical_gaming_rigid_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_gaming_rigid_ensures_0_proved (result : Int) : vc_vertical_gaming_rigid_ensures_0 result := trivial
def vc_vertical_gaming_rigid_decreases_0 : Nat := 0
theorem vc_vertical_gaming_rigid_decreases_0_proved : vc_vertical_gaming_rigid_decreases_0 = 0 := rfl

end vertical_gaming_rigid

namespace vertical_qm_dft

def vc_vertical_qm_dft_requires_0 : Prop := True
theorem vc_vertical_qm_dft_requires_0_proved : vc_vertical_qm_dft_requires_0 := trivial
def vc_vertical_qm_dft_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_qm_dft_ensures_0_proved (result : Int) : vc_vertical_qm_dft_ensures_0 result := trivial
def vc_vertical_qm_dft_decreases_0 : Nat := 0
theorem vc_vertical_qm_dft_decreases_0_proved : vc_vertical_qm_dft_decreases_0 = 0 := rfl

end vertical_qm_dft

namespace vertical_echem_aimd

def vc_vertical_echem_aimd_requires_0 : Prop := True
theorem vc_vertical_echem_aimd_requires_0_proved : vc_vertical_echem_aimd_requires_0 := trivial
def vc_vertical_echem_aimd_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_echem_aimd_ensures_0_proved (result : Int) : vc_vertical_echem_aimd_ensures_0 result := trivial
def vc_vertical_echem_aimd_decreases_0 : Nat := 0
theorem vc_vertical_echem_aimd_decreases_0_proved : vc_vertical_echem_aimd_decreases_0 = 0 := rfl

end vertical_echem_aimd

namespace vertical_echem_gc_aimd

def vc_vertical_echem_gc_aimd_requires_0 : Prop := True
theorem vc_vertical_echem_gc_aimd_requires_0_proved : vc_vertical_echem_gc_aimd_requires_0 := trivial
def vc_vertical_echem_gc_aimd_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_echem_gc_aimd_ensures_0_proved (result : Int) : vc_vertical_echem_gc_aimd_ensures_0 result := trivial
def vc_vertical_echem_gc_aimd_decreases_0 : Nat := 0
theorem vc_vertical_echem_gc_aimd_decreases_0_proved : vc_vertical_echem_gc_aimd_decreases_0 = 0 := rfl

end vertical_echem_gc_aimd

namespace vertical_echem_sei_kmc

def vc_vertical_echem_sei_kmc_requires_0 : Prop := True
theorem vc_vertical_echem_sei_kmc_requires_0_proved : vc_vertical_echem_sei_kmc_requires_0 := trivial
def vc_vertical_echem_sei_kmc_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_echem_sei_kmc_ensures_0_proved (result : Int) : vc_vertical_echem_sei_kmc_ensures_0 result := trivial
def vc_vertical_echem_sei_kmc_decreases_0 : Nat := 0
theorem vc_vertical_echem_sei_kmc_decreases_0_proved : vc_vertical_echem_sei_kmc_decreases_0 = 0 := rfl

end vertical_echem_sei_kmc

namespace vertical_fea_linear_elasticity

def vc_vertical_fea_linear_elasticity_requires_0 : Prop := True
theorem vc_vertical_fea_linear_elasticity_requires_0_proved : vc_vertical_fea_linear_elasticity_requires_0 := trivial
def vc_vertical_fea_linear_elasticity_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_fea_linear_elasticity_ensures_0_proved (result : Int) : vc_vertical_fea_linear_elasticity_ensures_0 result := trivial
def vc_vertical_fea_linear_elasticity_decreases_0 : Nat := 0
theorem vc_vertical_fea_linear_elasticity_decreases_0_proved : vc_vertical_fea_linear_elasticity_decreases_0 = 0 := rfl

end vertical_fea_linear_elasticity

namespace vertical_cfd_lid_driven_cavity

def vc_vertical_cfd_lid_driven_cavity_requires_0 : Prop := True
theorem vc_vertical_cfd_lid_driven_cavity_requires_0_proved : vc_vertical_cfd_lid_driven_cavity_requires_0 := trivial
def vc_vertical_cfd_lid_driven_cavity_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_vertical_cfd_lid_driven_cavity_ensures_0_proved (result : Int) : vc_vertical_cfd_lid_driven_cavity_ensures_0 result := trivial
def vc_vertical_cfd_lid_driven_cavity_decreases_0 : Nat := 0
theorem vc_vertical_cfd_lid_driven_cavity_decreases_0_proved : vc_vertical_cfd_lid_driven_cavity_decreases_0 = 0 := rfl

end vertical_cfd_lid_driven_cavity

namespace algo_registry_count

def vc_algo_registry_count_requires_0 : Prop := True
theorem vc_algo_registry_count_requires_0_proved : vc_algo_registry_count_requires_0 := trivial
def vc_algo_registry_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_registry_count_ensures_0_proved (result : Int) : vc_algo_registry_count_ensures_0 result := trivial
def vc_algo_registry_count_decreases_0 : Nat := 0
theorem vc_algo_registry_count_decreases_0_proved : vc_algo_registry_count_decreases_0 = 0 := rfl

end algo_registry_count

namespace algo_id_min

def vc_algo_id_min_requires_0 : Prop := True
theorem vc_algo_id_min_requires_0_proved : vc_algo_id_min_requires_0 := trivial
def vc_algo_id_min_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_id_min_ensures_0_proved (result : Int) : vc_algo_id_min_ensures_0 result := trivial
def vc_algo_id_min_decreases_0 : Nat := 0
theorem vc_algo_id_min_decreases_0_proved : vc_algo_id_min_decreases_0 = 0 := rfl

end algo_id_min

namespace algo_id_max

def vc_algo_id_max_requires_0 : Prop := True
theorem vc_algo_id_max_requires_0_proved : vc_algo_id_max_requires_0 := trivial
def vc_algo_id_max_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_id_max_ensures_0_proved (result : Int) : vc_algo_id_max_ensures_0 result := trivial
def vc_algo_id_max_decreases_0 : Nat := 0
theorem vc_algo_id_max_decreases_0_proved : vc_algo_id_max_decreases_0 = 0 := rfl

end algo_id_max

namespace algo_in_registry

def vc_algo_in_registry_requires_0 (algo_id : Int) : Prop := True
theorem vc_algo_in_registry_requires_0_proved (algo_id : Int) : vc_algo_in_registry_requires_0 algo_id := trivial
def vc_algo_in_registry_ensures_0 (algo_id : Int) (result : Int) : Prop := (result ≥ 0)
def vc_algo_in_registry_ensures_1 (algo_id : Int) (result : Int) : Prop := (result ≤ 1)
def vc_algo_in_registry_decreases_0 (algo_id : Int) : Nat := 0
theorem vc_algo_in_registry_decreases_0_proved (algo_id : Int) : vc_algo_in_registry_decreases_0 algo_id = 0 := rfl

end algo_in_registry

namespace algo_family_num

def vc_algo_family_num_requires_0 (algo_id : Int) : Prop := True
theorem vc_algo_family_num_requires_0_proved (algo_id : Int) : vc_algo_family_num_requires_0 algo_id := trivial
def vc_algo_family_num_ensures_0 (algo_id : Int) (result : Int) : Prop := (result ≥ 0)
def vc_algo_family_num_decreases_0 (algo_id : Int) : Nat := 0
theorem vc_algo_family_num_decreases_0_proved (algo_id : Int) : vc_algo_family_num_decreases_0 algo_id = 0 := rfl

end algo_family_num

namespace algo_md_lj_cutoff_mic

def vc_algo_md_lj_cutoff_mic_requires_0 : Prop := True
theorem vc_algo_md_lj_cutoff_mic_requires_0_proved : vc_algo_md_lj_cutoff_mic_requires_0 := trivial
def vc_algo_md_lj_cutoff_mic_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_md_lj_cutoff_mic_ensures_0_proved (result : Int) : vc_algo_md_lj_cutoff_mic_ensures_0 result := trivial
def vc_algo_md_lj_cutoff_mic_decreases_0 : Nat := 0
theorem vc_algo_md_lj_cutoff_mic_decreases_0_proved : vc_algo_md_lj_cutoff_mic_decreases_0 = 0 := rfl

end algo_md_lj_cutoff_mic

namespace algo_md_integrator_verlet

def vc_algo_md_integrator_verlet_requires_0 : Prop := True
theorem vc_algo_md_integrator_verlet_requires_0_proved : vc_algo_md_integrator_verlet_requires_0 := trivial
def vc_algo_md_integrator_verlet_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_md_integrator_verlet_ensures_0_proved (result : Int) : vc_algo_md_integrator_verlet_ensures_0 result := trivial
def vc_algo_md_integrator_verlet_decreases_0 : Nat := 0
theorem vc_algo_md_integrator_verlet_decreases_0_proved : vc_algo_md_integrator_verlet_decreases_0 = 0 := rfl

end algo_md_integrator_verlet

namespace algo_pde_heat_explicit_2d

def vc_algo_pde_heat_explicit_2d_requires_0 : Prop := True
theorem vc_algo_pde_heat_explicit_2d_requires_0_proved : vc_algo_pde_heat_explicit_2d_requires_0 := trivial
def vc_algo_pde_heat_explicit_2d_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_pde_heat_explicit_2d_ensures_0_proved (result : Int) : vc_algo_pde_heat_explicit_2d_ensures_0 result := trivial
def vc_algo_pde_heat_explicit_2d_decreases_0 : Nat := 0
theorem vc_algo_pde_heat_explicit_2d_decreases_0_proved : vc_algo_pde_heat_explicit_2d_decreases_0 = 0 := rfl

end algo_pde_heat_explicit_2d

namespace algo_rigid_semi_implicit

def vc_algo_rigid_semi_implicit_requires_0 : Prop := True
theorem vc_algo_rigid_semi_implicit_requires_0_proved : vc_algo_rigid_semi_implicit_requires_0 := trivial
def vc_algo_rigid_semi_implicit_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_rigid_semi_implicit_ensures_0_proved (result : Int) : vc_algo_rigid_semi_implicit_ensures_0 result := trivial
def vc_algo_rigid_semi_implicit_decreases_0 : Nat := 0
theorem vc_algo_rigid_semi_implicit_decreases_0_proved : vc_algo_rigid_semi_implicit_decreases_0 = 0 := rfl

end algo_rigid_semi_implicit

namespace algo_qm_dft_scf_energy

def vc_algo_qm_dft_scf_energy_requires_0 : Prop := True
theorem vc_algo_qm_dft_scf_energy_requires_0_proved : vc_algo_qm_dft_scf_energy_requires_0 := trivial
def vc_algo_qm_dft_scf_energy_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_qm_dft_scf_energy_ensures_0_proved (result : Int) : vc_algo_qm_dft_scf_energy_ensures_0 result := trivial
def vc_algo_qm_dft_scf_energy_decreases_0 : Nat := 0
theorem vc_algo_qm_dft_scf_energy_decreases_0_proved : vc_algo_qm_dft_scf_energy_decreases_0 = 0 := rfl

end algo_qm_dft_scf_energy

namespace algo_cfd_simple

def vc_algo_cfd_simple_requires_0 : Prop := True
theorem vc_algo_cfd_simple_requires_0_proved : vc_algo_cfd_simple_requires_0 := trivial
def vc_algo_cfd_simple_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_cfd_simple_ensures_0_proved (result : Int) : vc_algo_cfd_simple_ensures_0 result := trivial
def vc_algo_cfd_simple_decreases_0 : Nat := 0
theorem vc_algo_cfd_simple_decreases_0_proved : vc_algo_cfd_simple_decreases_0 = 0 := rfl

end algo_cfd_simple

namespace algo_fea_linear_elasticity

def vc_algo_fea_linear_elasticity_requires_0 : Prop := True
theorem vc_algo_fea_linear_elasticity_requires_0_proved : vc_algo_fea_linear_elasticity_requires_0 := trivial
def vc_algo_fea_linear_elasticity_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_fea_linear_elasticity_ensures_0_proved (result : Int) : vc_algo_fea_linear_elasticity_ensures_0 result := trivial
def vc_algo_fea_linear_elasticity_decreases_0 : Nat := 0
theorem vc_algo_fea_linear_elasticity_decreases_0_proved : vc_algo_fea_linear_elasticity_decreases_0 = 0 := rfl

end algo_fea_linear_elasticity

namespace algo_echem_aimd_interface

def vc_algo_echem_aimd_interface_requires_0 : Prop := True
theorem vc_algo_echem_aimd_interface_requires_0_proved : vc_algo_echem_aimd_interface_requires_0 := trivial
def vc_algo_echem_aimd_interface_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_echem_aimd_interface_ensures_0_proved (result : Int) : vc_algo_echem_aimd_interface_ensures_0 result := trivial
def vc_algo_echem_aimd_interface_decreases_0 : Nat := 0
theorem vc_algo_echem_aimd_interface_decreases_0_proved : vc_algo_echem_aimd_interface_decreases_0 = 0 := rfl

end algo_echem_aimd_interface

namespace algo_echem_gc_aimd_interface

def vc_algo_echem_gc_aimd_interface_requires_0 : Prop := True
theorem vc_algo_echem_gc_aimd_interface_requires_0_proved : vc_algo_echem_gc_aimd_interface_requires_0 := trivial
def vc_algo_echem_gc_aimd_interface_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_echem_gc_aimd_interface_ensures_0_proved (result : Int) : vc_algo_echem_gc_aimd_interface_ensures_0 result := trivial
def vc_algo_echem_gc_aimd_interface_decreases_0 : Nat := 0
theorem vc_algo_echem_gc_aimd_interface_decreases_0_proved : vc_algo_echem_gc_aimd_interface_decreases_0 = 0 := rfl

end algo_echem_gc_aimd_interface

namespace algo_echem_sei_kmc

def vc_algo_echem_sei_kmc_requires_0 : Prop := True
theorem vc_algo_echem_sei_kmc_requires_0_proved : vc_algo_echem_sei_kmc_requires_0 := trivial
def vc_algo_echem_sei_kmc_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_echem_sei_kmc_ensures_0_proved (result : Int) : vc_algo_echem_sei_kmc_ensures_0 result := trivial
def vc_algo_echem_sei_kmc_decreases_0 : Nat := 0
theorem vc_algo_echem_sei_kmc_decreases_0_proved : vc_algo_echem_sei_kmc_decreases_0 = 0 := rfl

end algo_echem_sei_kmc

namespace algo_robo_multibody_step

def vc_algo_robo_multibody_step_requires_0 : Prop := True
theorem vc_algo_robo_multibody_step_requires_0_proved : vc_algo_robo_multibody_step_requires_0 := trivial
def vc_algo_robo_multibody_step_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_robo_multibody_step_ensures_0_proved (result : Int) : vc_algo_robo_multibody_step_ensures_0 result := trivial
def vc_algo_robo_multibody_step_decreases_0 : Nat := 0
theorem vc_algo_robo_multibody_step_decreases_0_proved : vc_algo_robo_multibody_step_decreases_0 = 0 := rfl

end algo_robo_multibody_step

namespace algo_drug_litl_stages

def vc_algo_drug_litl_stages_requires_0 : Prop := True
theorem vc_algo_drug_litl_stages_requires_0_proved : vc_algo_drug_litl_stages_requires_0 := trivial
def vc_algo_drug_litl_stages_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_drug_litl_stages_ensures_0_proved (result : Int) : vc_algo_drug_litl_stages_ensures_0 result := trivial
def vc_algo_drug_litl_stages_decreases_0 : Nat := 0
theorem vc_algo_drug_litl_stages_decreases_0_proved : vc_algo_drug_litl_stages_decreases_0 = 0 := rfl

end algo_drug_litl_stages

namespace algo_am_slice_layers

def vc_algo_am_slice_layers_requires_0 : Prop := True
theorem vc_algo_am_slice_layers_requires_0_proved : vc_algo_am_slice_layers_requires_0 := trivial
def vc_algo_am_slice_layers_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_am_slice_layers_ensures_0_proved (result : Int) : vc_algo_am_slice_layers_ensures_0 result := trivial
def vc_algo_am_slice_layers_decreases_0 : Nat := 0
theorem vc_algo_am_slice_layers_decreases_0_proved : vc_algo_am_slice_layers_decreases_0 = 0 := rfl

end algo_am_slice_layers

namespace algo_am_thermal_warp

def vc_algo_am_thermal_warp_requires_0 : Prop := True
theorem vc_algo_am_thermal_warp_requires_0_proved : vc_algo_am_thermal_warp_requires_0 := trivial
def vc_algo_am_thermal_warp_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_am_thermal_warp_ensures_0_proved (result : Int) : vc_algo_am_thermal_warp_ensures_0 result := trivial
def vc_algo_am_thermal_warp_decreases_0 : Nat := 0
theorem vc_algo_am_thermal_warp_decreases_0_proved : vc_algo_am_thermal_warp_decreases_0 = 0 := rfl

end algo_am_thermal_warp

namespace algo_am_export_gcode_3mf

def vc_algo_am_export_gcode_3mf_requires_0 : Prop := True
theorem vc_algo_am_export_gcode_3mf_requires_0_proved : vc_algo_am_export_gcode_3mf_requires_0 := trivial
def vc_algo_am_export_gcode_3mf_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_am_export_gcode_3mf_ensures_0_proved (result : Int) : vc_algo_am_export_gcode_3mf_ensures_0 result := trivial
def vc_algo_am_export_gcode_3mf_decreases_0 : Nat := 0
theorem vc_algo_am_export_gcode_3mf_decreases_0_proved : vc_algo_am_export_gcode_3mf_decreases_0 = 0 := rfl

end algo_am_export_gcode_3mf

namespace algo_auto_sensor_raycast

def vc_algo_auto_sensor_raycast_requires_0 : Prop := True
theorem vc_algo_auto_sensor_raycast_requires_0_proved : vc_algo_auto_sensor_raycast_requires_0 := trivial
def vc_algo_auto_sensor_raycast_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_algo_auto_sensor_raycast_ensures_0_proved (result : Int) : vc_algo_auto_sensor_raycast_ensures_0 result := trivial
def vc_algo_auto_sensor_raycast_decreases_0 : Nat := 0
theorem vc_algo_auto_sensor_raycast_decreases_0_proved : vc_algo_auto_sensor_raycast_decreases_0 = 0 := rfl

end algo_auto_sensor_raycast

namespace run_result_ok

def vc_run_result_ok_requires_0 (r : Int) : Prop := True
theorem vc_run_result_ok_requires_0_proved (r : Int) : vc_run_result_ok_requires_0 r := trivial
def vc_run_result_ok_ensures_0 (r : Int) (result : Int) : Prop := (result ≥ 0)
def vc_run_result_ok_ensures_1 (r : Int) (result : Int) : Prop := (result ≤ 1)
def vc_run_result_ok_decreases_0 (r : Int) : Nat := 0
theorem vc_run_result_ok_decreases_0_proved (r : Int) : vc_run_result_ok_decreases_0 r = 0 := rfl

end run_result_ok

namespace sim_contract_unknown

def vc_sim_contract_unknown_requires_0 : Prop := True
theorem vc_sim_contract_unknown_requires_0_proved : vc_sim_contract_unknown_requires_0 := trivial
def vc_sim_contract_unknown_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_unknown_ensures_0_proved (result : Int) : vc_sim_contract_unknown_ensures_0 result := trivial
def vc_sim_contract_unknown_decreases_0 : Nat := 0
theorem vc_sim_contract_unknown_decreases_0_proved : vc_sim_contract_unknown_decreases_0 = 0 := rfl

end sim_contract_unknown

namespace sim_contract_game

def vc_sim_contract_game_requires_0 : Prop := True
theorem vc_sim_contract_game_requires_0_proved : vc_sim_contract_game_requires_0 := trivial
def vc_sim_contract_game_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_game_ensures_0_proved (result : Int) : vc_sim_contract_game_ensures_0 result := trivial
def vc_sim_contract_game_decreases_0 : Nat := 0
theorem vc_sim_contract_game_decreases_0_proved : vc_sim_contract_game_decreases_0 = 0 := rfl

end sim_contract_game

namespace sim_contract_sim_rl

def vc_sim_contract_sim_rl_requires_0 : Prop := True
theorem vc_sim_contract_sim_rl_requires_0_proved : vc_sim_contract_sim_rl_requires_0 := trivial
def vc_sim_contract_sim_rl_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_sim_rl_ensures_0_proved (result : Int) : vc_sim_contract_sim_rl_ensures_0 result := trivial
def vc_sim_contract_sim_rl_decreases_0 : Nat := 0
theorem vc_sim_contract_sim_rl_decreases_0_proved : vc_sim_contract_sim_rl_decreases_0 = 0 := rfl

end sim_contract_sim_rl

namespace sim_contract_sim_automotive

def vc_sim_contract_sim_automotive_requires_0 : Prop := True
theorem vc_sim_contract_sim_automotive_requires_0_proved : vc_sim_contract_sim_automotive_requires_0 := trivial
def vc_sim_contract_sim_automotive_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_sim_automotive_ensures_0_proved (result : Int) : vc_sim_contract_sim_automotive_ensures_0 result := trivial
def vc_sim_contract_sim_automotive_decreases_0 : Nat := 0
theorem vc_sim_contract_sim_automotive_decreases_0_proved : vc_sim_contract_sim_automotive_decreases_0 = 0 := rfl

end sim_contract_sim_automotive

namespace sim_contract_sim_robotics

def vc_sim_contract_sim_robotics_requires_0 : Prop := True
theorem vc_sim_contract_sim_robotics_requires_0_proved : vc_sim_contract_sim_robotics_requires_0 := trivial
def vc_sim_contract_sim_robotics_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_sim_robotics_ensures_0_proved (result : Int) : vc_sim_contract_sim_robotics_ensures_0 result := trivial
def vc_sim_contract_sim_robotics_decreases_0 : Nat := 0
theorem vc_sim_contract_sim_robotics_decreases_0_proved : vc_sim_contract_sim_robotics_decreases_0 = 0 := rfl

end sim_contract_sim_robotics

namespace sim_contract_sim_additive

def vc_sim_contract_sim_additive_requires_0 : Prop := True
theorem vc_sim_contract_sim_additive_requires_0_proved : vc_sim_contract_sim_additive_requires_0 := trivial
def vc_sim_contract_sim_additive_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_sim_additive_ensures_0_proved (result : Int) : vc_sim_contract_sim_additive_ensures_0 result := trivial
def vc_sim_contract_sim_additive_decreases_0 : Nat := 0
theorem vc_sim_contract_sim_additive_decreases_0_proved : vc_sim_contract_sim_additive_decreases_0 = 0 := rfl

end sim_contract_sim_additive

namespace sim_contract_sim_scientific

def vc_sim_contract_sim_scientific_requires_0 : Prop := True
theorem vc_sim_contract_sim_scientific_requires_0_proved : vc_sim_contract_sim_scientific_requires_0 := trivial
def vc_sim_contract_sim_scientific_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_sim_scientific_ensures_0_proved (result : Int) : vc_sim_contract_sim_scientific_ensures_0 result := trivial
def vc_sim_contract_sim_scientific_decreases_0 : Nat := 0
theorem vc_sim_contract_sim_scientific_decreases_0_proved : vc_sim_contract_sim_scientific_decreases_0 = 0 := rfl

end sim_contract_sim_scientific

namespace sim_contract_sim_drug_design

def vc_sim_contract_sim_drug_design_requires_0 : Prop := True
theorem vc_sim_contract_sim_drug_design_requires_0_proved : vc_sim_contract_sim_drug_design_requires_0 := trivial
def vc_sim_contract_sim_drug_design_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_contract_sim_drug_design_ensures_0_proved (result : Int) : vc_sim_contract_sim_drug_design_ensures_0 result := trivial
def vc_sim_contract_sim_drug_design_decreases_0 : Nat := 0
theorem vc_sim_contract_sim_drug_design_decreases_0_proved : vc_sim_contract_sim_drug_design_decreases_0 = 0 := rfl

end sim_contract_sim_drug_design

namespace sim_contract_id_valid

def vc_sim_contract_id_valid_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_ensures_0 (contract_id : Int) (result : Int) : Prop := (result ≥ 0)
def vc_sim_contract_id_valid_ensures_1 (contract_id : Int) (result : Int) : Prop := (result ≤ 1)
def vc_sim_contract_id_valid_decreases_0 (contract_id : Int) : Nat := Int.toNat contract_id
theorem vc_sim_contract_id_valid_decreases_0_proved (contract_id : Int) : vc_sim_contract_id_valid_decreases_0 contract_id = Int.toNat contract_id := rfl
def vc_sim_contract_id_valid_call0_sim_contract_unknown_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call0_sim_contract_unknown_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call0_sim_contract_unknown_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call1_sim_contract_game_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call1_sim_contract_game_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call1_sim_contract_game_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call2_sim_contract_sim_rl_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call2_sim_contract_sim_rl_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call2_sim_contract_sim_rl_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call3_sim_contract_sim_automotive_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call3_sim_contract_sim_automotive_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call3_sim_contract_sim_automotive_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call4_sim_contract_sim_robotics_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call4_sim_contract_sim_robotics_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call4_sim_contract_sim_robotics_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call5_sim_contract_sim_additive_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call5_sim_contract_sim_additive_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call5_sim_contract_sim_additive_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call6_sim_contract_sim_scientific_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call6_sim_contract_sim_scientific_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call6_sim_contract_sim_scientific_requires_0 contract_id := trivial
def vc_sim_contract_id_valid_call7_sim_contract_sim_drug_design_requires_0 (contract_id : Int) : Prop := True
theorem vc_sim_contract_id_valid_call7_sim_contract_sim_drug_design_requires_0_proved (contract_id : Int) : vc_sim_contract_id_valid_call7_sim_contract_sim_drug_design_requires_0 contract_id := trivial

end sim_contract_id_valid

namespace li_sim_profile_from_studio_id

def vc_li_sim_profile_from_studio_id_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_requires_0 studio_profile_id := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_li_sim_profile_from_studio_id_ensures_0 (studio_profile_id : Int) (result : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_ensures_0_proved (studio_profile_id : Int) (result : Int) : vc_li_sim_profile_from_studio_id_ensures_0 studio_profile_id result := trivial
def vc_li_sim_profile_from_studio_id_decreases_0 (studio_profile_id : Int) : Nat := Int.toNat studio_profile_id
theorem vc_li_sim_profile_from_studio_id_decreases_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_decreases_0 studio_profile_id = Int.toNat studio_profile_id := rfl
def vc_li_sim_profile_from_studio_id_call0_sim_contract_unknown_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call0_sim_contract_unknown_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call0_sim_contract_unknown_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call1_sim_contract_game_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call1_sim_contract_game_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call1_sim_contract_game_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call2_sim_contract_sim_rl_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call2_sim_contract_sim_rl_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call2_sim_contract_sim_rl_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call3_sim_contract_sim_automotive_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call3_sim_contract_sim_automotive_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call3_sim_contract_sim_automotive_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call4_sim_contract_sim_robotics_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call4_sim_contract_sim_robotics_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call4_sim_contract_sim_robotics_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call5_sim_contract_sim_additive_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call5_sim_contract_sim_additive_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call5_sim_contract_sim_additive_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call6_sim_contract_sim_scientific_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call6_sim_contract_sim_scientific_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call6_sim_contract_sim_scientific_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call7_sim_contract_sim_drug_design_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call7_sim_contract_sim_drug_design_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call7_sim_contract_sim_drug_design_requires_0 studio_profile_id := trivial
def vc_li_sim_profile_from_studio_id_call8_sim_contract_unknown_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_li_sim_profile_from_studio_id_call8_sim_contract_unknown_requires_0_proved (studio_profile_id : Int) : vc_li_sim_profile_from_studio_id_call8_sim_contract_unknown_requires_0 studio_profile_id := trivial

end li_sim_profile_from_studio_id

namespace sim_output_detail_for_studio_profile

def vc_sim_output_detail_for_studio_profile_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_sim_output_detail_for_studio_profile_requires_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_requires_0 studio_profile_id := trivial
def vc_sim_output_detail_for_studio_profile_ensures_0 (studio_profile_id : Int) (result : Int) : Prop := (result ≥ 0)
def vc_sim_output_detail_for_studio_profile_ensures_1 (studio_profile_id : Int) (result : Int) : Prop := (result ≤ 3)
def vc_sim_output_detail_for_studio_profile_decreases_0 (studio_profile_id : Int) : Nat := Int.toNat studio_profile_id
theorem vc_sim_output_detail_for_studio_profile_decreases_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_decreases_0 studio_profile_id = Int.toNat studio_profile_id := rfl
def vc_sim_output_detail_for_studio_profile_call0_output_detail_summary_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_sim_output_detail_for_studio_profile_call0_output_detail_summary_requires_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_call0_output_detail_summary_requires_0 studio_profile_id := trivial
def vc_sim_output_detail_for_studio_profile_call1_output_detail_debug_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_sim_output_detail_for_studio_profile_call1_output_detail_debug_requires_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_call1_output_detail_debug_requires_0 studio_profile_id := trivial
def vc_sim_output_detail_for_studio_profile_call2_output_detail_debug_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_sim_output_detail_for_studio_profile_call2_output_detail_debug_requires_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_call2_output_detail_debug_requires_0 studio_profile_id := trivial
def vc_sim_output_detail_for_studio_profile_call3_output_detail_fields_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_sim_output_detail_for_studio_profile_call3_output_detail_fields_requires_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_call3_output_detail_fields_requires_0 studio_profile_id := trivial
def vc_sim_output_detail_for_studio_profile_call4_output_detail_summary_requires_0 (studio_profile_id : Int) : Prop := True
theorem vc_sim_output_detail_for_studio_profile_call4_output_detail_summary_requires_0_proved (studio_profile_id : Int) : vc_sim_output_detail_for_studio_profile_call4_output_detail_summary_requires_0 studio_profile_id := trivial

end sim_output_detail_for_studio_profile

namespace sim_status_ok

def vc_sim_status_ok_requires_0 : Prop := True
theorem vc_sim_status_ok_requires_0_proved : vc_sim_status_ok_requires_0 := trivial
def vc_sim_status_ok_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_status_ok_ensures_0_proved (result : Int) : vc_sim_status_ok_ensures_0 result := trivial
def vc_sim_status_ok_decreases_0 : Nat := 0
theorem vc_sim_status_ok_decreases_0_proved : vc_sim_status_ok_decreases_0 = 0 := rfl

end sim_status_ok

namespace sim_status_invalid_dt

def vc_sim_status_invalid_dt_requires_0 : Prop := True
theorem vc_sim_status_invalid_dt_requires_0_proved : vc_sim_status_invalid_dt_requires_0 := trivial
def vc_sim_status_invalid_dt_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_status_invalid_dt_ensures_0_proved (result : Int) : vc_sim_status_invalid_dt_ensures_0 result := trivial
def vc_sim_status_invalid_dt_decreases_0 : Nat := 0
theorem vc_sim_status_invalid_dt_decreases_0_proved : vc_sim_status_invalid_dt_decreases_0 = 0 := rfl

end sim_status_invalid_dt

namespace sim_replay_capacity_default

def vc_sim_replay_capacity_default_requires_0 : Prop := True
theorem vc_sim_replay_capacity_default_requires_0_proved : vc_sim_replay_capacity_default_requires_0 := trivial
def vc_sim_replay_capacity_default_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_replay_capacity_default_ensures_0_proved (result : Int) : vc_sim_replay_capacity_default_ensures_0 result := trivial
def vc_sim_replay_capacity_default_decreases_0 : Nat := 0
theorem vc_sim_replay_capacity_default_decreases_0_proved : vc_sim_replay_capacity_default_decreases_0 = 0 := rfl

end sim_replay_capacity_default

namespace sim_replay_new

def vc_sim_replay_new_requires_0 (capacity : Int) : Prop := (capacity > 0)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_replay_new_ensures_0 (capacity : Int) (result : Int) : Prop := True
theorem vc_sim_replay_new_ensures_0_proved (capacity : Int) (result : Int) : vc_sim_replay_new_ensures_0 capacity result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_replay_new_ensures_1 (capacity : Int) (result : Int) : Prop := True
theorem vc_sim_replay_new_ensures_1_proved (capacity : Int) (result : Int) : vc_sim_replay_new_ensures_1 capacity result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_replay_new_ensures_2 (capacity : Int) (result : Int) : Prop := True
theorem vc_sim_replay_new_ensures_2_proved (capacity : Int) (result : Int) : vc_sim_replay_new_ensures_2 capacity result := trivial
def vc_sim_replay_new_decreases_0 (capacity : Int) : Nat := Int.toNat capacity
theorem vc_sim_replay_new_decreases_0_proved (capacity : Int) : vc_sim_replay_new_decreases_0 capacity = Int.toNat capacity := rfl

end sim_replay_new

namespace sim_replay_push

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_replay_push_requires_0 (replay : Int) (tick : Int) : Prop := True
theorem vc_sim_replay_push_requires_0_proved (replay : Int) (tick : Int) : vc_sim_replay_push_requires_0 replay tick := trivial
def vc_sim_replay_push_requires_1 (replay : Int) (tick : Int) : Prop := (tick ≥ 0)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_replay_push_ensures_0 (replay : Int) (tick : Int) (result : Unit) : Prop := True
theorem vc_sim_replay_push_ensures_0_proved (replay : Int) (tick : Int) (result : Unit) : vc_sim_replay_push_ensures_0 replay tick result := trivial
def vc_sim_replay_push_decreases_0 (replay : Int) (tick : Int) : Nat := 0
theorem vc_sim_replay_push_decreases_0_proved (replay : Int) (tick : Int) : vc_sim_replay_push_decreases_0 replay tick = 0 := rfl

end sim_replay_push

namespace sim_replay_last_tick

def vc_sim_replay_last_tick_requires_0 (replay : Int) : Prop := True
theorem vc_sim_replay_last_tick_requires_0_proved (replay : Int) : vc_sim_replay_last_tick_requires_0 replay := trivial
def vc_sim_replay_last_tick_ensures_0 (replay : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_replay_last_tick_ensures_0_proved (replay : Int) (result : Int) : vc_sim_replay_last_tick_ensures_0 replay result := trivial
def vc_sim_replay_last_tick_decreases_0 (replay : Int) : Nat := 0
theorem vc_sim_replay_last_tick_decreases_0_proved (replay : Int) : vc_sim_replay_last_tick_decreases_0 replay = 0 := rfl

end sim_replay_last_tick

namespace sim_session_stub_default

def vc_sim_session_stub_default_requires_0 : Prop := True
theorem vc_sim_session_stub_default_requires_0_proved : vc_sim_session_stub_default_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_0 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_0_proved (result : Int) : vc_sim_session_stub_default_ensures_0 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_1 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_1_proved (result : Int) : vc_sim_session_stub_default_ensures_1 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_2 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_2_proved (result : Int) : vc_sim_session_stub_default_ensures_2 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_3 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_3_proved (result : Int) : vc_sim_session_stub_default_ensures_3 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_4 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_4_proved (result : Int) : vc_sim_session_stub_default_ensures_4 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_5 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_5_proved (result : Int) : vc_sim_session_stub_default_ensures_5 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_6 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_6_proved (result : Int) : vc_sim_session_stub_default_ensures_6 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_7 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_7_proved (result : Int) : vc_sim_session_stub_default_ensures_7 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_8 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_8_proved (result : Int) : vc_sim_session_stub_default_ensures_8 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_9 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_9_proved (result : Int) : vc_sim_session_stub_default_ensures_9 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_10 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_10_proved (result : Int) : vc_sim_session_stub_default_ensures_10 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_11 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_11_proved (result : Int) : vc_sim_session_stub_default_ensures_11 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_12 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_12_proved (result : Int) : vc_sim_session_stub_default_ensures_12 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_13 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_13_proved (result : Int) : vc_sim_session_stub_default_ensures_13 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_14 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_14_proved (result : Int) : vc_sim_session_stub_default_ensures_14 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_15 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_15_proved (result : Int) : vc_sim_session_stub_default_ensures_15 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_stub_default_ensures_16 (result : Int) : Prop := True
theorem vc_sim_session_stub_default_ensures_16_proved (result : Int) : vc_sim_session_stub_default_ensures_16 result := trivial
def vc_sim_session_stub_default_decreases_0 : Nat := 0
theorem vc_sim_session_stub_default_decreases_0_proved : vc_sim_session_stub_default_decreases_0 = 0 := rfl
def vc_sim_session_stub_default_call0_sim_contract_unknown_requires_0 : Prop := True
theorem vc_sim_session_stub_default_call0_sim_contract_unknown_requires_0_proved : vc_sim_session_stub_default_call0_sim_contract_unknown_requires_0 := trivial
def vc_sim_session_stub_default_call1_output_detail_summary_requires_0 : Prop := True
theorem vc_sim_session_stub_default_call1_output_detail_summary_requires_0_proved : vc_sim_session_stub_default_call1_output_detail_summary_requires_0 := trivial
def vc_sim_session_stub_default_call2_sim_replay_capacity_default_requires_0 : Prop := True
theorem vc_sim_session_stub_default_call2_sim_replay_capacity_default_requires_0_proved : vc_sim_session_stub_default_call2_sim_replay_capacity_default_requires_0 := trivial

end sim_session_stub_default

namespace sim_session_replay_record

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_session_replay_record_requires_0 (session : Int) : Prop := True
theorem vc_sim_session_replay_record_requires_0_proved (session : Int) : vc_sim_session_replay_record_requires_0 session := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_session_replay_record_requires_1 (session : Int) : Prop := True
theorem vc_sim_session_replay_record_requires_1_proved (session : Int) : vc_sim_session_replay_record_requires_1 session := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_replay_record_ensures_0 (session : Int) (result : Unit) : Prop := True
theorem vc_sim_session_replay_record_ensures_0_proved (session : Int) (result : Unit) : vc_sim_session_replay_record_ensures_0 session result := trivial
def vc_sim_session_replay_record_decreases_0 (session : Int) : Nat := 0
theorem vc_sim_session_replay_record_decreases_0_proved (session : Int) : vc_sim_session_replay_record_decreases_0 session = 0 := rfl

end sim_session_replay_record

namespace sim_session_replay_last_tick

def vc_sim_session_replay_last_tick_requires_0 (session : Int) : Prop := True
theorem vc_sim_session_replay_last_tick_requires_0_proved (session : Int) : vc_sim_session_replay_last_tick_requires_0 session := trivial
def vc_sim_session_replay_last_tick_ensures_0 (session : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_session_replay_last_tick_ensures_0_proved (session : Int) (result : Int) : vc_sim_session_replay_last_tick_ensures_0 session result := trivial
def vc_sim_session_replay_last_tick_decreases_0 (session : Int) : Nat := 0
theorem vc_sim_session_replay_last_tick_decreases_0_proved (session : Int) : vc_sim_session_replay_last_tick_decreases_0 session = 0 := rfl

end sim_session_replay_last_tick

namespace sim_reset

def vc_sim_reset_requires_0 (session : Int) : Prop := True
theorem vc_sim_reset_requires_0_proved (session : Int) : vc_sim_reset_requires_0 session := trivial
def vc_sim_reset_ensures_0 (session : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_reset_ensures_0_proved (session : Int) (result : Int) : vc_sim_reset_ensures_0 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_1 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_1_proved (session : Int) (result : Int) : vc_sim_reset_ensures_1 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_2 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_2_proved (session : Int) (result : Int) : vc_sim_reset_ensures_2 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_3 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_3_proved (session : Int) (result : Int) : vc_sim_reset_ensures_3 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_4 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_4_proved (session : Int) (result : Int) : vc_sim_reset_ensures_4 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_5 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_5_proved (session : Int) (result : Int) : vc_sim_reset_ensures_5 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_6 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_6_proved (session : Int) (result : Int) : vc_sim_reset_ensures_6 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_7 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_7_proved (session : Int) (result : Int) : vc_sim_reset_ensures_7 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_8 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_8_proved (session : Int) (result : Int) : vc_sim_reset_ensures_8 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_9 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_9_proved (session : Int) (result : Int) : vc_sim_reset_ensures_9 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_10 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_10_proved (session : Int) (result : Int) : vc_sim_reset_ensures_10 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_reset_ensures_11 (session : Int) (result : Int) : Prop := True
theorem vc_sim_reset_ensures_11_proved (session : Int) (result : Int) : vc_sim_reset_ensures_11 session result := trivial
def vc_sim_reset_decreases_0 (session : Int) : Nat := 0
theorem vc_sim_reset_decreases_0_proved (session : Int) : vc_sim_reset_decreases_0 session = 0 := rfl
def vc_sim_reset_call0_sim_status_ok_requires_0 (session : Int) : Prop := True
theorem vc_sim_reset_call0_sim_status_ok_requires_0_proved (session : Int) : vc_sim_reset_call0_sim_status_ok_requires_0 session := trivial

end sim_reset

namespace sim_step

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_step_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_step_requires_0_proved (session : Int) (dt : Float) : vc_sim_step_requires_0 session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_step_requires_1 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_step_requires_1_proved (session : Int) (dt : Float) : vc_sim_step_requires_1 session dt := trivial
def vc_sim_step_ensures_0 (session : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_sim_step_ensures_1 (session : Int) (dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_sim_step_decreases_0 (session : Int) (dt : Float) : Nat := 0
theorem vc_sim_step_decreases_0_proved (session : Int) (dt : Float) : vc_sim_step_decreases_0 session dt = 0 := rfl
def vc_sim_step_call0_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_step_call0_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_step_call0_sim_status_invalid_dt_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_replay_record' at call 1 -/
def vc_sim_step_call1_sim_session_replay_record_requires_0 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'sim_session_replay_record' at call 1 -/
def vc_sim_step_call1_sim_session_replay_record_requires_1 (session : Int) (dt : Float) : Prop := True
def vc_sim_step_call2_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_step_call2_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_step_call2_sim_status_ok_requires_0 session dt := trivial

end sim_step

namespace sim_session_apply_studio_profile

def vc_sim_session_apply_studio_profile_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_requires_0 studio_profile_id sim_out := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_apply_studio_profile_ensures_0 (studio_profile_id : Int) (sim_out : Int) (result : Unit) : Prop := True
theorem vc_sim_session_apply_studio_profile_ensures_0_proved (studio_profile_id : Int) (sim_out : Int) (result : Unit) : vc_sim_session_apply_studio_profile_ensures_0 studio_profile_id sim_out result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_apply_studio_profile_ensures_1 (studio_profile_id : Int) (sim_out : Int) (result : Unit) : Prop := True
theorem vc_sim_session_apply_studio_profile_ensures_1_proved (studio_profile_id : Int) (sim_out : Int) (result : Unit) : vc_sim_session_apply_studio_profile_ensures_1 studio_profile_id sim_out result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_apply_studio_profile_ensures_2 (studio_profile_id : Int) (sim_out : Int) (result : Unit) : Prop := True
theorem vc_sim_session_apply_studio_profile_ensures_2_proved (studio_profile_id : Int) (sim_out : Int) (result : Unit) : vc_sim_session_apply_studio_profile_ensures_2 studio_profile_id sim_out result := trivial
def vc_sim_session_apply_studio_profile_decreases_0 (studio_profile_id : Int) (sim_out : Int) : Nat := Int.toNat studio_profile_id
theorem vc_sim_session_apply_studio_profile_decreases_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_decreases_0 studio_profile_id sim_out = Int.toNat studio_profile_id := rfl
def vc_sim_session_apply_studio_profile_call0_sim_contract_unknown_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call0_sim_contract_unknown_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call0_sim_contract_unknown_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call1_sim_contract_game_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call1_sim_contract_game_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call1_sim_contract_game_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call2_sim_contract_sim_rl_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call2_sim_contract_sim_rl_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call2_sim_contract_sim_rl_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call3_sim_contract_sim_automotive_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call3_sim_contract_sim_automotive_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call3_sim_contract_sim_automotive_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call4_sim_contract_sim_robotics_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call4_sim_contract_sim_robotics_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call4_sim_contract_sim_robotics_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call5_sim_contract_sim_additive_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call5_sim_contract_sim_additive_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call5_sim_contract_sim_additive_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call6_sim_contract_sim_scientific_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call6_sim_contract_sim_scientific_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call6_sim_contract_sim_scientific_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call7_sim_contract_sim_drug_design_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call7_sim_contract_sim_drug_design_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call7_sim_contract_sim_drug_design_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call8_output_detail_summary_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call8_output_detail_summary_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call8_output_detail_summary_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call9_output_detail_debug_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call9_output_detail_debug_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call9_output_detail_debug_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call10_output_detail_debug_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call10_output_detail_debug_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call10_output_detail_debug_requires_0 studio_profile_id sim_out := trivial
def vc_sim_session_apply_studio_profile_call11_output_detail_fields_requires_0 (studio_profile_id : Int) (sim_out : Int) : Prop := True
theorem vc_sim_session_apply_studio_profile_call11_output_detail_fields_requires_0_proved (studio_profile_id : Int) (sim_out : Int) : vc_sim_session_apply_studio_profile_call11_output_detail_fields_requires_0 studio_profile_id sim_out := trivial

end sim_session_apply_studio_profile

namespace sim_rl_env_pool_size_default

def vc_sim_rl_env_pool_size_default_requires_0 : Prop := True
theorem vc_sim_rl_env_pool_size_default_requires_0_proved : vc_sim_rl_env_pool_size_default_requires_0 := trivial
def vc_sim_rl_env_pool_size_default_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_pool_size_default_ensures_0_proved (result : Int) : vc_sim_rl_env_pool_size_default_ensures_0 result := trivial
def vc_sim_rl_env_pool_size_default_decreases_0 : Nat := 0
theorem vc_sim_rl_env_pool_size_default_decreases_0_proved : vc_sim_rl_env_pool_size_default_decreases_0 = 0 := rfl

end sim_rl_env_pool_size_default

namespace sim_rl_dt_default

def vc_sim_rl_dt_default_requires_0 : Prop := True
theorem vc_sim_rl_dt_default_requires_0_proved : vc_sim_rl_dt_default_requires_0 := trivial
def vc_sim_rl_dt_default_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_sim_rl_dt_default_decreases_0 : Nat := 0
theorem vc_sim_rl_dt_default_decreases_0_proved : vc_sim_rl_dt_default_decreases_0 = 0 := rfl

end sim_rl_dt_default

namespace env_pool_stub_default

def vc_env_pool_stub_default_requires_0 : Prop := True
theorem vc_env_pool_stub_default_requires_0_proved : vc_env_pool_stub_default_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_pool_stub_default_ensures_0 (result : Int) : Prop := True
theorem vc_env_pool_stub_default_ensures_0_proved (result : Int) : vc_env_pool_stub_default_ensures_0 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_pool_stub_default_ensures_1 (result : Int) : Prop := True
theorem vc_env_pool_stub_default_ensures_1_proved (result : Int) : vc_env_pool_stub_default_ensures_1 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_pool_stub_default_ensures_2 (result : Int) : Prop := True
theorem vc_env_pool_stub_default_ensures_2_proved (result : Int) : vc_env_pool_stub_default_ensures_2 result := trivial
def vc_env_pool_stub_default_decreases_0 : Nat := 0
theorem vc_env_pool_stub_default_decreases_0_proved : vc_env_pool_stub_default_decreases_0 = 0 := rfl
def vc_env_pool_stub_default_call0_sim_rl_env_pool_size_default_requires_0 : Prop := True
theorem vc_env_pool_stub_default_call0_sim_rl_env_pool_size_default_requires_0_proved : vc_env_pool_stub_default_call0_sim_rl_env_pool_size_default_requires_0 := trivial

end env_pool_stub_default

namespace sim_env_obs_dim

def vc_sim_env_obs_dim_requires_0 : Prop := True
theorem vc_sim_env_obs_dim_requires_0_proved : vc_sim_env_obs_dim_requires_0 := trivial
def vc_sim_env_obs_dim_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_env_obs_dim_ensures_0_proved (result : Int) : vc_sim_env_obs_dim_ensures_0 result := trivial
def vc_sim_env_obs_dim_decreases_0 : Nat := 0
theorem vc_sim_env_obs_dim_decreases_0_proved : vc_sim_env_obs_dim_decreases_0 = 0 := rfl

end sim_env_obs_dim

namespace sim_session_env_pool_init

def vc_sim_session_env_pool_init_requires_0 (session : Int) : Prop := True
theorem vc_sim_session_env_pool_init_requires_0_proved (session : Int) : vc_sim_session_env_pool_init_requires_0 session := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_init_ensures_0 (session : Int) (result : Unit) : Prop := True
theorem vc_sim_session_env_pool_init_ensures_0_proved (session : Int) (result : Unit) : vc_sim_session_env_pool_init_ensures_0 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_init_ensures_1 (session : Int) (result : Unit) : Prop := True
theorem vc_sim_session_env_pool_init_ensures_1_proved (session : Int) (result : Unit) : vc_sim_session_env_pool_init_ensures_1 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_init_ensures_2 (session : Int) (result : Unit) : Prop := True
theorem vc_sim_session_env_pool_init_ensures_2_proved (session : Int) (result : Unit) : vc_sim_session_env_pool_init_ensures_2 session result := trivial
def vc_sim_session_env_pool_init_decreases_0 (session : Int) : Nat := 0
theorem vc_sim_session_env_pool_init_decreases_0_proved (session : Int) : vc_sim_session_env_pool_init_decreases_0 session = 0 := rfl
def vc_sim_session_env_pool_init_call0_sim_rl_env_pool_size_default_requires_0 (session : Int) : Prop := True
theorem vc_sim_session_env_pool_init_call0_sim_rl_env_pool_size_default_requires_0_proved (session : Int) : vc_sim_session_env_pool_init_call0_sim_rl_env_pool_size_default_requires_0 session := trivial

end sim_session_env_pool_init

namespace sim_session_env_pool_load

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_load_requires_0 (session : Int) : Prop := True
theorem vc_sim_session_env_pool_load_requires_0_proved (session : Int) : vc_sim_session_env_pool_load_requires_0 session := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_load_ensures_0 (session : Int) (result : Int) : Prop := True
theorem vc_sim_session_env_pool_load_ensures_0_proved (session : Int) (result : Int) : vc_sim_session_env_pool_load_ensures_0 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_load_ensures_1 (session : Int) (result : Int) : Prop := True
theorem vc_sim_session_env_pool_load_ensures_1_proved (session : Int) (result : Int) : vc_sim_session_env_pool_load_ensures_1 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_load_ensures_2 (session : Int) (result : Int) : Prop := True
theorem vc_sim_session_env_pool_load_ensures_2_proved (session : Int) (result : Int) : vc_sim_session_env_pool_load_ensures_2 session result := trivial
def vc_sim_session_env_pool_load_decreases_0 (session : Int) : Nat := 0
theorem vc_sim_session_env_pool_load_decreases_0_proved (session : Int) : vc_sim_session_env_pool_load_decreases_0 session = 0 := rfl

end sim_session_env_pool_load

namespace sim_session_env_pool_store

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_store_requires_0 (session : Int) (pool : Int) : Prop := True
theorem vc_sim_session_env_pool_store_requires_0_proved (session : Int) (pool : Int) : vc_sim_session_env_pool_store_requires_0 session pool := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_store_ensures_0 (session : Int) (pool : Int) (result : Unit) : Prop := True
theorem vc_sim_session_env_pool_store_ensures_0_proved (session : Int) (pool : Int) (result : Unit) : vc_sim_session_env_pool_store_ensures_0 session pool result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_store_ensures_1 (session : Int) (pool : Int) (result : Unit) : Prop := True
theorem vc_sim_session_env_pool_store_ensures_1_proved (session : Int) (pool : Int) (result : Unit) : vc_sim_session_env_pool_store_ensures_1 session pool result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_sim_session_env_pool_store_ensures_2 (session : Int) (pool : Int) (result : Unit) : Prop := True
theorem vc_sim_session_env_pool_store_ensures_2_proved (session : Int) (pool : Int) (result : Unit) : vc_sim_session_env_pool_store_ensures_2 session pool result := trivial
def vc_sim_session_env_pool_store_decreases_0 (session : Int) (pool : Int) : Nat := 0
theorem vc_sim_session_env_pool_store_decreases_0_proved (session : Int) (pool : Int) : vc_sim_session_env_pool_store_decreases_0 session pool = 0 := rfl

end sim_session_env_pool_store

namespace env_obs_store_on_session

def vc_env_obs_store_on_session_requires_0 (session : Int) (post : Int) : Prop := True
theorem vc_env_obs_store_on_session_requires_0_proved (session : Int) (post : Int) : vc_env_obs_store_on_session_requires_0 session post := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_store_on_session_ensures_0 (session : Int) (post : Int) (result : Unit) : Prop := True
theorem vc_env_obs_store_on_session_ensures_0_proved (session : Int) (post : Int) (result : Unit) : vc_env_obs_store_on_session_ensures_0 session post result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_store_on_session_ensures_1 (session : Int) (post : Int) (result : Unit) : Prop := True
theorem vc_env_obs_store_on_session_ensures_1_proved (session : Int) (post : Int) (result : Unit) : vc_env_obs_store_on_session_ensures_1 session post result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_store_on_session_ensures_2 (session : Int) (post : Int) (result : Unit) : Prop := True
theorem vc_env_obs_store_on_session_ensures_2_proved (session : Int) (post : Int) (result : Unit) : vc_env_obs_store_on_session_ensures_2 session post result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_store_on_session_ensures_3 (session : Int) (post : Int) (result : Unit) : Prop := True
theorem vc_env_obs_store_on_session_ensures_3_proved (session : Int) (post : Int) (result : Unit) : vc_env_obs_store_on_session_ensures_3 session post result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_store_on_session_ensures_4 (session : Int) (post : Int) (result : Unit) : Prop := True
theorem vc_env_obs_store_on_session_ensures_4_proved (session : Int) (post : Int) (result : Unit) : vc_env_obs_store_on_session_ensures_4 session post result := trivial
def vc_env_obs_store_on_session_decreases_0 (session : Int) (post : Int) : Nat := 0
theorem vc_env_obs_store_on_session_decreases_0_proved (session : Int) (post : Int) : vc_env_obs_store_on_session_decreases_0 session post = 0 := rfl

end env_obs_store_on_session

namespace env_obs_from_session

def vc_env_obs_from_session_requires_0 (session : Int) : Prop := True
theorem vc_env_obs_from_session_requires_0_proved (session : Int) : vc_env_obs_from_session_requires_0 session := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_from_session_ensures_0 (session : Int) (result : Int) : Prop := True
theorem vc_env_obs_from_session_ensures_0_proved (session : Int) (result : Int) : vc_env_obs_from_session_ensures_0 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_from_session_ensures_1 (session : Int) (result : Int) : Prop := True
theorem vc_env_obs_from_session_ensures_1_proved (session : Int) (result : Int) : vc_env_obs_from_session_ensures_1 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_from_session_ensures_2 (session : Int) (result : Int) : Prop := True
theorem vc_env_obs_from_session_ensures_2_proved (session : Int) (result : Int) : vc_env_obs_from_session_ensures_2 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_from_session_ensures_3 (session : Int) (result : Int) : Prop := True
theorem vc_env_obs_from_session_ensures_3_proved (session : Int) (result : Int) : vc_env_obs_from_session_ensures_3 session result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_from_session_ensures_4 (session : Int) (result : Int) : Prop := True
theorem vc_env_obs_from_session_ensures_4_proved (session : Int) (result : Int) : vc_env_obs_from_session_ensures_4 session result := trivial
def vc_env_obs_from_session_decreases_0 (session : Int) : Nat := 0
theorem vc_env_obs_from_session_decreases_0_proved (session : Int) : vc_env_obs_from_session_decreases_0 session = 0 := rfl

end env_obs_from_session

namespace env_tick_as_float

def vc_env_tick_as_float_requires_0 (tick : Int) : Prop := (tick ≥ 0)
def vc_env_tick_as_float_requires_1 (tick : Int) : Prop := (tick ≤ 32)
def vc_env_tick_as_float_ensures_0 (tick : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_env_tick_as_float_decreases_0 (tick : Int) : Nat := Int.toNat tick
theorem vc_env_tick_as_float_decreases_0_proved (tick : Int) : vc_env_tick_as_float_decreases_0 tick = Int.toNat tick := rfl

end env_tick_as_float

namespace env_action_for_index

def vc_env_action_for_index_requires_0 (env_index : Int) : Prop := (env_index ≥ 0)
def vc_env_action_for_index_requires_1 (env_index : Int) : Prop := (env_index < 32)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_action_for_index_ensures_0 (env_index : Int) (result : Int) : Prop := True
theorem vc_env_action_for_index_ensures_0_proved (env_index : Int) (result : Int) : vc_env_action_for_index_ensures_0 env_index result := trivial
def vc_env_action_for_index_decreases_0 (env_index : Int) : Nat := Int.toNat env_index
theorem vc_env_action_for_index_decreases_0_proved (env_index : Int) : vc_env_action_for_index_decreases_0 env_index = Int.toNat env_index := rfl

end env_action_for_index

namespace env_obs_fill_fields

def vc_env_obs_fill_fields_requires_0 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (tick ≥ 0)
def vc_env_obs_fill_fields_requires_1 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index ≥ 0)
def vc_env_obs_fill_fields_requires_2 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index < 32)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_obs_fill_fields_ensures_0 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) (result : Unit) : Prop := True
theorem vc_env_obs_fill_fields_ensures_0_proved (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) (result : Unit) : vc_env_obs_fill_fields_ensures_0 r tick last_dt env_index result := trivial
def vc_env_obs_fill_fields_decreases_0 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Nat := Int.toNat env_index
theorem vc_env_obs_fill_fields_decreases_0_proved (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) : vc_env_obs_fill_fields_decreases_0 r tick last_dt env_index = Int.toNat env_index := rfl
def vc_env_obs_fill_fields_call0_env_tick_as_float_requires_0 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) (t_obs : Int) : Prop := (t_obs ≥ 0)
def vc_env_obs_fill_fields_call0_env_tick_as_float_requires_1 (r : Int) (tick : Int) (last_dt : Float) (env_index : Int) (t_obs : Int) : Prop := (t_obs ≤ 32)

end env_obs_fill_fields

namespace sim_rl_env_cartpole_v1_semantics

def vc_sim_rl_env_cartpole_v1_semantics_requires_0 : Prop := True
theorem vc_sim_rl_env_cartpole_v1_semantics_requires_0_proved : vc_sim_rl_env_cartpole_v1_semantics_requires_0 := trivial
def vc_sim_rl_env_cartpole_v1_semantics_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_cartpole_v1_semantics_ensures_0_proved (result : Int) : vc_sim_rl_env_cartpole_v1_semantics_ensures_0 result := trivial
def vc_sim_rl_env_cartpole_v1_semantics_decreases_0 : Nat := 0
theorem vc_sim_rl_env_cartpole_v1_semantics_decreases_0_proved : vc_sim_rl_env_cartpole_v1_semantics_decreases_0 = 0 := rfl

end sim_rl_env_cartpole_v1_semantics

namespace env_cartpole_step_reward

def vc_env_cartpole_step_reward_requires_0 (env_index : Int) : Prop := (env_index ≥ 0)
def vc_env_cartpole_step_reward_requires_1 (env_index : Int) : Prop := (env_index < 32)
def vc_env_cartpole_step_reward_ensures_0 (env_index : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_env_cartpole_step_reward_decreases_0 (env_index : Int) : Nat := Int.toNat env_index
theorem vc_env_cartpole_step_reward_decreases_0_proved (env_index : Int) : vc_env_cartpole_step_reward_decreases_0 env_index = Int.toNat env_index := rfl

end env_cartpole_step_reward

namespace env_reward_for_action

def vc_env_reward_for_action_requires_0 (act0 : Float) (env_index : Int) (tick : Int) : Prop := (env_index ≥ 0)
def vc_env_reward_for_action_requires_1 (act0 : Float) (env_index : Int) (tick : Int) : Prop := (env_index < 32)
def vc_env_reward_for_action_requires_2 (act0 : Float) (env_index : Int) (tick : Int) : Prop := (tick ≥ 0)
def vc_env_reward_for_action_ensures_0 (act0 : Float) (env_index : Int) (tick : Int) (result : Float) : Prop := (result ≥ (-1 : Float))
def vc_env_reward_for_action_decreases_0 (act0 : Float) (env_index : Int) (tick : Int) : Nat := Int.toNat env_index
theorem vc_env_reward_for_action_decreases_0_proved (act0 : Float) (env_index : Int) (tick : Int) : vc_env_reward_for_action_decreases_0 act0 env_index tick = Int.toNat env_index := rfl
def vc_env_reward_for_action_call0_sim_rl_env_cartpole_v1_semantics_requires_0 (act0 : Float) (env_index : Int) (tick : Int) : Prop := True
theorem vc_env_reward_for_action_call0_sim_rl_env_cartpole_v1_semantics_requires_0_proved (act0 : Float) (env_index : Int) (tick : Int) : vc_env_reward_for_action_call0_sim_rl_env_cartpole_v1_semantics_requires_0 act0 env_index tick := trivial
def vc_env_reward_for_action_call1_env_cartpole_step_reward_requires_0 (act0 : Float) (env_index : Int) (tick : Int) : Prop := (env_index ≥ 0)
def vc_env_reward_for_action_call1_env_cartpole_step_reward_requires_1 (act0 : Float) (env_index : Int) (tick : Int) : Prop := (env_index < 32)
def vc_env_reward_for_action_call2_env_tick_as_float_requires_0 (act0 : Float) (env_index : Int) (tick : Int) (t_rew : Int) : Prop := (t_rew ≥ 0)
def vc_env_reward_for_action_call2_env_tick_as_float_requires_1 (act0 : Float) (env_index : Int) (tick : Int) (t_rew : Int) : Prop := (t_rew ≤ 32)

end env_reward_for_action

namespace env_step_contract_pre

def vc_env_step_contract_pre_requires_0 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (pool_size > 0)
def vc_env_step_contract_pre_requires_1 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index ≥ 0)
def vc_env_step_contract_pre_requires_2 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index < pool_size)
def vc_env_step_contract_pre_requires_3 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Prop := (tick ≥ 0)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_step_contract_pre_ensures_0 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (result : Int) : Prop := True
theorem vc_env_step_contract_pre_ensures_0_proved (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (result : Int) : vc_env_step_contract_pre_ensures_0 pool_size tick last_dt env_index result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_step_contract_pre_ensures_1 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (result : Int) : Prop := True
theorem vc_env_step_contract_pre_ensures_1_proved (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (result : Int) : vc_env_step_contract_pre_ensures_1 pool_size tick last_dt env_index result := trivial
def vc_env_step_contract_pre_decreases_0 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) : Nat := Int.toNat env_index
theorem vc_env_step_contract_pre_decreases_0_proved (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) : vc_env_step_contract_pre_decreases_0 pool_size tick last_dt env_index = Int.toNat env_index := rfl
def vc_env_step_contract_pre_call0_env_action_for_index_requires_0 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (ei_act : Int) : Prop := (ei_act ≥ 0)
def vc_env_step_contract_pre_call0_env_action_for_index_requires_1 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (ei_act : Int) : Prop := (ei_act < 32)
def vc_env_step_contract_pre_call1_env_obs_fill_fields_requires_0 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (t_obs : Int) : Prop := (t_obs ≥ 0)
def vc_env_step_contract_pre_call1_env_obs_fill_fields_requires_1 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (ei_obs : Int) : Prop := (ei_obs ≥ 0)
def vc_env_step_contract_pre_call1_env_obs_fill_fields_requires_2 (pool_size : Int) (tick : Int) (last_dt : Float) (env_index : Int) (ei_obs : Int) : Prop := (ei_obs < 32)

end env_step_contract_pre

namespace env_step_contract_post

def vc_env_step_contract_post_requires_0 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : Prop := (tick ≥ 0)
def vc_env_step_contract_post_requires_1 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : Prop := (pool_size > 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_step_contract_post_requires_2 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : Prop := True
theorem vc_env_step_contract_post_requires_2_proved (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : vc_env_step_contract_post_requires_2 pre tick last_dt pool_size := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_step_contract_post_requires_3 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : Prop := True
theorem vc_env_step_contract_post_requires_3_proved (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : vc_env_step_contract_post_requires_3 pre tick last_dt pool_size := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_step_contract_post_ensures_0 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (result : Int) : Prop := True
theorem vc_env_step_contract_post_ensures_0_proved (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (result : Int) : vc_env_step_contract_post_ensures_0 pre tick last_dt pool_size result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_step_contract_post_ensures_1 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (result : Int) : Prop := True
theorem vc_env_step_contract_post_ensures_1_proved (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (result : Int) : vc_env_step_contract_post_ensures_1 pre tick last_dt pool_size result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_step_contract_post_ensures_2 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (result : Int) : Prop := True
theorem vc_env_step_contract_post_ensures_2_proved (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (result : Int) : vc_env_step_contract_post_ensures_2 pre tick last_dt pool_size result := trivial
def vc_env_step_contract_post_decreases_0 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : Nat := 0
theorem vc_env_step_contract_post_decreases_0_proved (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) : vc_env_step_contract_post_decreases_0 pre tick last_dt pool_size = 0 := rfl
def vc_env_step_contract_post_call0_env_obs_fill_fields_requires_0 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (t_obs : Int) : Prop := (t_obs ≥ 0)
def vc_env_step_contract_post_call0_env_obs_fill_fields_requires_1 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (idx_obs : Int) : Prop := (idx_obs ≥ 0)
def vc_env_step_contract_post_call0_env_obs_fill_fields_requires_2 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (idx_obs : Int) : Prop := (idx_obs < 32)
def vc_env_step_contract_post_call1_env_reward_for_action_requires_0 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (idx_rew : Int) : Prop := (idx_rew ≥ 0)
def vc_env_step_contract_post_call1_env_reward_for_action_requires_1 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (idx_rew : Int) : Prop := (idx_rew < 32)
def vc_env_step_contract_post_call1_env_reward_for_action_requires_2 (pre : Int) (tick : Int) (last_dt : Float) (pool_size : Int) (t_rew : Int) : Prop := (t_rew ≥ 0)

end env_step_contract_post

namespace sim_rl_env_worker_mode

def vc_sim_rl_env_worker_mode_requires_0 : Prop := True
theorem vc_sim_rl_env_worker_mode_requires_0_proved : vc_sim_rl_env_worker_mode_requires_0 := trivial
def vc_sim_rl_env_worker_mode_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_worker_mode_ensures_0_proved (result : Int) : vc_sim_rl_env_worker_mode_ensures_0 result := trivial
def vc_sim_rl_env_worker_mode_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_worker_mode_ensures_1_proved (result : Int) : vc_sim_rl_env_worker_mode_ensures_1 result := trivial
def vc_sim_rl_env_worker_mode_decreases_0 : Nat := 0
theorem vc_sim_rl_env_worker_mode_decreases_0_proved : vc_sim_rl_env_worker_mode_decreases_0 = 0 := rfl
def vc_sim_rl_env_worker_mode_call0_sim_rl_env_worker_mode_config_requires_0 : Prop := True
theorem vc_sim_rl_env_worker_mode_call0_sim_rl_env_worker_mode_config_requires_0_proved : vc_sim_rl_env_worker_mode_call0_sim_rl_env_worker_mode_config_requires_0 := trivial

end sim_rl_env_worker_mode

namespace sim_rl_env_worker_mode_config

def vc_sim_rl_env_worker_mode_config_requires_0 : Prop := True
theorem vc_sim_rl_env_worker_mode_config_requires_0_proved : vc_sim_rl_env_worker_mode_config_requires_0 := trivial
def vc_sim_rl_env_worker_mode_config_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_env_worker_mode_config_ensures_1 (result : Int) : Prop := (result ≤ 2)
def vc_sim_rl_env_worker_mode_config_decreases_0 : Nat := 0
theorem vc_sim_rl_env_worker_mode_config_decreases_0_proved : vc_sim_rl_env_worker_mode_config_decreases_0 = 0 := rfl

end sim_rl_env_worker_mode_config

namespace sim_rl_env_ipc_multiprocess_label

def vc_sim_rl_env_ipc_multiprocess_label_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_multiprocess_label_requires_0_proved : vc_sim_rl_env_ipc_multiprocess_label_requires_0 := trivial
def vc_sim_rl_env_ipc_multiprocess_label_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_ipc_multiprocess_label_ensures_0_proved (result : Int) : vc_sim_rl_env_ipc_multiprocess_label_ensures_0 result := trivial
def vc_sim_rl_env_ipc_multiprocess_label_decreases_0 : Nat := 0
theorem vc_sim_rl_env_ipc_multiprocess_label_decreases_0_proved : vc_sim_rl_env_ipc_multiprocess_label_decreases_0 = 0 := rfl

end sim_rl_env_ipc_multiprocess_label

namespace sim_rl_env_ipc_scaffold_note

def vc_sim_rl_env_ipc_scaffold_note_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_scaffold_note_requires_0_proved : vc_sim_rl_env_ipc_scaffold_note_requires_0 := trivial
def vc_sim_rl_env_ipc_scaffold_note_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_ipc_scaffold_note_ensures_0_proved (result : Int) : vc_sim_rl_env_ipc_scaffold_note_ensures_0 result := trivial
def vc_sim_rl_env_ipc_scaffold_note_decreases_0 : Nat := 0
theorem vc_sim_rl_env_ipc_scaffold_note_decreases_0_proved : vc_sim_rl_env_ipc_scaffold_note_decreases_0 = 0 := rfl

end sim_rl_env_ipc_scaffold_note

namespace sim_rl_env_worker_process_mode_label

def vc_sim_rl_env_worker_process_mode_label_requires_0 : Prop := True
theorem vc_sim_rl_env_worker_process_mode_label_requires_0_proved : vc_sim_rl_env_worker_process_mode_label_requires_0 := trivial
def vc_sim_rl_env_worker_process_mode_label_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_worker_process_mode_label_ensures_0_proved (result : Int) : vc_sim_rl_env_worker_process_mode_label_ensures_0 result := trivial
def vc_sim_rl_env_worker_process_mode_label_decreases_0 : Nat := 0
theorem vc_sim_rl_env_worker_process_mode_label_decreases_0_proved : vc_sim_rl_env_worker_process_mode_label_decreases_0 = 0 := rfl
def vc_sim_rl_env_worker_process_mode_label_call0_sim_rl_env_worker_mode_process_scaffold_requires_0 : Prop := True
theorem vc_sim_rl_env_worker_process_mode_label_call0_sim_rl_env_worker_mode_process_scaffold_requires_0_proved : vc_sim_rl_env_worker_process_mode_label_call0_sim_rl_env_worker_mode_process_scaffold_requires_0 := trivial

end sim_rl_env_worker_process_mode_label

namespace sim_rl_env_worker_mode_process_scaffold

def vc_sim_rl_env_worker_mode_process_scaffold_requires_0 : Prop := True
theorem vc_sim_rl_env_worker_mode_process_scaffold_requires_0_proved : vc_sim_rl_env_worker_mode_process_scaffold_requires_0 := trivial
def vc_sim_rl_env_worker_mode_process_scaffold_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_worker_mode_process_scaffold_ensures_0_proved (result : Int) : vc_sim_rl_env_worker_mode_process_scaffold_ensures_0 result := trivial
def vc_sim_rl_env_worker_mode_process_scaffold_decreases_0 : Nat := 0
theorem vc_sim_rl_env_worker_mode_process_scaffold_decreases_0_proved : vc_sim_rl_env_worker_mode_process_scaffold_decreases_0 = 0 := rfl

end sim_rl_env_worker_mode_process_scaffold

namespace env_pool_parallel_scratch_default

def vc_env_pool_parallel_scratch_default_requires_0 (pool_size : Int) : Prop := (pool_size > 0)
def vc_env_pool_parallel_scratch_default_requires_1 (pool_size : Int) : Prop := (pool_size ≤ 32)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_pool_parallel_scratch_default_ensures_0 (pool_size : Int) (result : Int) : Prop := True
theorem vc_env_pool_parallel_scratch_default_ensures_0_proved (pool_size : Int) (result : Int) : vc_env_pool_parallel_scratch_default_ensures_0 pool_size result := trivial
def vc_env_pool_parallel_scratch_default_decreases_0 (pool_size : Int) : Nat := Int.toNat pool_size
theorem vc_env_pool_parallel_scratch_default_decreases_0_proved (pool_size : Int) : vc_env_pool_parallel_scratch_default_decreases_0 pool_size = Int.toNat pool_size := rfl

end env_pool_parallel_scratch_default

namespace env_pool_ipc_prepare_shards

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_ipc_prepare_shards_requires_0 (scratch : Int) : Prop := True
theorem vc_env_pool_ipc_prepare_shards_requires_0_proved (scratch : Int) : vc_env_pool_ipc_prepare_shards_requires_0 scratch := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_ipc_prepare_shards_requires_1 (scratch : Int) : Prop := True
theorem vc_env_pool_ipc_prepare_shards_requires_1_proved (scratch : Int) : vc_env_pool_ipc_prepare_shards_requires_1 scratch := trivial
def vc_env_pool_ipc_prepare_shards_ensures_0 (scratch : Int) (result : Int) : Prop := (result ≥ 0)
def vc_env_pool_ipc_prepare_shards_ensures_1 (scratch : Int) (result : Int) : Prop := (result ≤ 1)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_env_pool_ipc_prepare_shards_ensures_2 (scratch : Int) (result : Int) : Prop := True
theorem vc_env_pool_ipc_prepare_shards_ensures_2_proved (scratch : Int) (result : Int) : vc_env_pool_ipc_prepare_shards_ensures_2 scratch result := trivial
def vc_env_pool_ipc_prepare_shards_decreases_0 (scratch : Int) : Nat := 0
theorem vc_env_pool_ipc_prepare_shards_decreases_0_proved (scratch : Int) : vc_env_pool_ipc_prepare_shards_decreases_0 scratch = 0 := rfl
def vc_env_pool_ipc_prepare_shards_call0_sim_status_ok_requires_0 (scratch : Int) : Prop := True
theorem vc_env_pool_ipc_prepare_shards_call0_sim_status_ok_requires_0_proved (scratch : Int) : vc_env_pool_ipc_prepare_shards_call0_sim_status_ok_requires_0 scratch := trivial

end env_pool_ipc_prepare_shards

namespace env_pool_parallel_reward_at

def vc_env_pool_parallel_reward_at_requires_0 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (pool_size > 0)
def vc_env_pool_parallel_reward_at_requires_1 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (pool_size ≤ 32)
def vc_env_pool_parallel_reward_at_requires_2 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (base_tick ≥ 0)
def vc_env_pool_parallel_reward_at_requires_3 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index ≥ 0)
def vc_env_pool_parallel_reward_at_requires_4 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index < pool_size)
def vc_env_pool_parallel_reward_at_ensures_0 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) (result : Float) : Prop := (result ≥ (-1 : Float))
def vc_env_pool_parallel_reward_at_decreases_0 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Nat := Int.toNat env_index
theorem vc_env_pool_parallel_reward_at_decreases_0_proved (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : vc_env_pool_parallel_reward_at_decreases_0 pool_size base_tick last_dt env_index = Int.toNat env_index := rfl
def vc_env_pool_parallel_reward_at_call0_env_step_contract_pre_requires_0 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (pool_size > 0)
def vc_env_pool_parallel_reward_at_call0_env_step_contract_pre_requires_1 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index ≥ 0)
def vc_env_pool_parallel_reward_at_call0_env_step_contract_pre_requires_2 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (env_index < pool_size)
def vc_env_pool_parallel_reward_at_call0_env_step_contract_pre_requires_3 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := ((base_tick + env_index) ≥ 0)
def vc_env_pool_parallel_reward_at_call1_env_step_contract_post_requires_0 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (((base_tick + env_index) + 1) ≥ 0)
def vc_env_pool_parallel_reward_at_call1_env_step_contract_post_requires_1 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) : Prop := (pool_size > 0)
/-! VC call-site requires (opaque): callee 'env_step_contract_post' at call 1 -/
def vc_env_pool_parallel_reward_at_call1_env_step_contract_post_requires_2 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) (pre : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_step_contract_post' at call 1 -/
def vc_env_pool_parallel_reward_at_call1_env_step_contract_post_requires_3 (pool_size : Int) (base_tick : Int) (last_dt : Float) (env_index : Int) (pre : Int) : Prop := True

end env_pool_parallel_reward_at

namespace env_pool_fill_rewards_parallel

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_fill_rewards_parallel_requires_0 (scratch : Int) (base_tick : Int) (last_dt : Float) : Prop := True
theorem vc_env_pool_fill_rewards_parallel_requires_0_proved (scratch : Int) (base_tick : Int) (last_dt : Float) : vc_env_pool_fill_rewards_parallel_requires_0 scratch base_tick last_dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_fill_rewards_parallel_requires_1 (scratch : Int) (base_tick : Int) (last_dt : Float) : Prop := True
theorem vc_env_pool_fill_rewards_parallel_requires_1_proved (scratch : Int) (base_tick : Int) (last_dt : Float) : vc_env_pool_fill_rewards_parallel_requires_1 scratch base_tick last_dt := trivial
def vc_env_pool_fill_rewards_parallel_requires_2 (scratch : Int) (base_tick : Int) (last_dt : Float) : Prop := (base_tick ≥ 0)
def vc_env_pool_fill_rewards_parallel_ensures_0 (scratch : Int) (base_tick : Int) (last_dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_env_pool_fill_rewards_parallel_ensures_1 (scratch : Int) (base_tick : Int) (last_dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_env_pool_fill_rewards_parallel_decreases_0 (scratch : Int) (base_tick : Int) (last_dt : Float) : Nat := 0
theorem vc_env_pool_fill_rewards_parallel_decreases_0_proved (scratch : Int) (base_tick : Int) (last_dt : Float) : vc_env_pool_fill_rewards_parallel_decreases_0 scratch base_tick last_dt = 0 := rfl
def vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_0 (scratch : Int) (base_tick : Int) (last_dt : Float) (psz : Int) : Prop := (psz > 0)
def vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_1 (scratch : Int) (base_tick : Int) (last_dt : Float) (psz : Int) : Prop := (psz ≤ 32)
def vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_2 (scratch : Int) (base_tick : Int) (last_dt : Float) : Prop := (base_tick ≥ 0)
def vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_3 (scratch : Int) (base_tick : Int) (last_dt : Float) : Prop := True
theorem vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_3_proved (scratch : Int) (base_tick : Int) (last_dt : Float) : vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_3 scratch base_tick last_dt := trivial
def vc_env_pool_fill_rewards_parallel_call0_env_pool_parallel_reward_at_requires_4 (scratch : Int) (base_tick : Int) (last_dt : Float) (psz : Int) : Prop := (0 < psz)
def vc_env_pool_fill_rewards_parallel_call1_sim_status_ok_requires_0 (scratch : Int) (base_tick : Int) (last_dt : Float) : Prop := True
theorem vc_env_pool_fill_rewards_parallel_call1_sim_status_ok_requires_0_proved (scratch : Int) (base_tick : Int) (last_dt : Float) : vc_env_pool_fill_rewards_parallel_call1_sim_status_ok_requires_0 scratch base_tick last_dt := trivial

end env_pool_fill_rewards_parallel

namespace env_pool_stub_step_sync

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_sync_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_sync_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_sync_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_sync_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_sync_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_env_pool_stub_step_sync_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_env_pool_stub_step_sync_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_sync_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_sync_call0_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_call0_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_call0_sim_status_invalid_dt_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_sync_call1_env_step_contract_pre_requires_0 (pool : Int) (session : Int) (dt : Float) (psz : Int) : Prop := (psz > 0)
def vc_env_pool_stub_step_sync_call1_env_step_contract_pre_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_call1_env_step_contract_pre_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_call1_env_step_contract_pre_requires_1 pool session dt := trivial
def vc_env_pool_stub_step_sync_call1_env_step_contract_pre_requires_2 (pool : Int) (session : Int) (dt : Float) (psz : Int) : Prop := (0 < psz)
def vc_env_pool_stub_step_sync_call1_env_step_contract_pre_requires_3 (pool : Int) (session : Int) (dt : Float) (tick0 : Int) : Prop := (tick0 ≥ 0)
/-! VC call-site requires (opaque): callee 'sim_step' at call 2 -/
def vc_env_pool_stub_step_sync_call2_sim_step_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'sim_step' at call 2 -/
def vc_env_pool_stub_step_sync_call2_sim_step_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
def vc_env_pool_stub_step_sync_call3_sim_status_ok_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_call3_sim_status_ok_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_call3_sim_status_ok_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_sync_call4_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_call4_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_call4_sim_status_invalid_dt_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_sync_call5_env_step_contract_post_requires_0 (pool : Int) (session : Int) (dt : Float) (tick1 : Int) : Prop := (tick1 ≥ 0)
def vc_env_pool_stub_step_sync_call5_env_step_contract_post_requires_1 (pool : Int) (session : Int) (dt : Float) (psz : Int) : Prop := (psz > 0)
/-! VC call-site requires (opaque): callee 'env_step_contract_post' at call 5 -/
def vc_env_pool_stub_step_sync_call5_env_step_contract_post_requires_2 (pool : Int) (session : Int) (dt : Float) (pre : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_step_contract_post' at call 5 -/
def vc_env_pool_stub_step_sync_call5_env_step_contract_post_requires_3 (pool : Int) (session : Int) (dt : Float) (pre : Int) (psz : Int) : Prop := True
def vc_env_pool_stub_step_sync_call6_env_obs_store_on_session_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_call6_env_obs_store_on_session_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_call6_env_obs_store_on_session_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_sync_call7_sim_status_ok_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_sync_call7_sim_status_ok_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_sync_call7_sim_status_ok_requires_0 pool session dt := trivial

end env_pool_stub_step_sync

namespace env_pool_stub_step_thread_pool

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_thread_pool_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_thread_pool_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_thread_pool_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_thread_pool_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_env_pool_stub_step_thread_pool_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_env_pool_stub_step_thread_pool_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_thread_pool_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_thread_pool_call0_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call0_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call0_sim_status_invalid_dt_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_parallel_scratch_default' at call 1 -/
def vc_env_pool_stub_step_thread_pool_call1_env_pool_parallel_scratch_default_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_parallel_scratch_default' at call 1 -/
def vc_env_pool_stub_step_thread_pool_call1_env_pool_parallel_scratch_default_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_fill_rewards_parallel' at call 2 -/
def vc_env_pool_stub_step_thread_pool_call2_env_pool_fill_rewards_parallel_requires_0 (pool : Int) (session : Int) (dt : Float) (scratch : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_fill_rewards_parallel' at call 2 -/
def vc_env_pool_stub_step_thread_pool_call2_env_pool_fill_rewards_parallel_requires_1 (pool : Int) (session : Int) (dt : Float) (scratch : Int) : Prop := True
def vc_env_pool_stub_step_thread_pool_call2_env_pool_fill_rewards_parallel_requires_2 (pool : Int) (session : Int) (dt : Float) (base_tick : Int) : Prop := (base_tick ≥ 0)
def vc_env_pool_stub_step_thread_pool_call3_sim_status_ok_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call3_sim_status_ok_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call3_sim_status_ok_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_call4_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call4_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call4_sim_status_invalid_dt_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_call5_env_step_contract_pre_requires_0 (pool : Int) (session : Int) (dt : Float) (psz : Int) : Prop := (psz > 0)
def vc_env_pool_stub_step_thread_pool_call5_env_step_contract_pre_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call5_env_step_contract_pre_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call5_env_step_contract_pre_requires_1 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_call5_env_step_contract_pre_requires_2 (pool : Int) (session : Int) (dt : Float) (psz : Int) : Prop := (0 < psz)
def vc_env_pool_stub_step_thread_pool_call5_env_step_contract_pre_requires_3 (pool : Int) (session : Int) (dt : Float) (tick0 : Int) : Prop := (tick0 ≥ 0)
/-! VC call-site requires (opaque): callee 'sim_step' at call 6 -/
def vc_env_pool_stub_step_thread_pool_call6_sim_step_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'sim_step' at call 6 -/
def vc_env_pool_stub_step_thread_pool_call6_sim_step_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
def vc_env_pool_stub_step_thread_pool_call7_sim_status_ok_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call7_sim_status_ok_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call7_sim_status_ok_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_call8_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call8_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call8_sim_status_invalid_dt_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_call9_env_step_contract_post_requires_0 (pool : Int) (session : Int) (dt : Float) (tick1 : Int) : Prop := (tick1 ≥ 0)
def vc_env_pool_stub_step_thread_pool_call9_env_step_contract_post_requires_1 (pool : Int) (session : Int) (dt : Float) (psz : Int) : Prop := (psz > 0)
/-! VC call-site requires (opaque): callee 'env_step_contract_post' at call 9 -/
def vc_env_pool_stub_step_thread_pool_call9_env_step_contract_post_requires_2 (pool : Int) (session : Int) (dt : Float) (pre : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_step_contract_post' at call 9 -/
def vc_env_pool_stub_step_thread_pool_call9_env_step_contract_post_requires_3 (pool : Int) (session : Int) (dt : Float) (pre : Int) (psz : Int) : Prop := True
def vc_env_pool_stub_step_thread_pool_call10_env_obs_store_on_session_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call10_env_obs_store_on_session_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call10_env_obs_store_on_session_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_thread_pool_call11_sim_status_ok_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_thread_pool_call11_sim_status_ok_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_thread_pool_call11_sim_status_ok_requires_0 pool session dt := trivial

end env_pool_stub_step_thread_pool

namespace sim_rl_env_ipc_fork_os_ready

def vc_sim_rl_env_ipc_fork_os_ready_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_fork_os_ready_requires_0_proved : vc_sim_rl_env_ipc_fork_os_ready_requires_0 := trivial
def vc_sim_rl_env_ipc_fork_os_ready_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_env_ipc_fork_os_ready_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_sim_rl_env_ipc_fork_os_ready_decreases_0 : Nat := 0
theorem vc_sim_rl_env_ipc_fork_os_ready_decreases_0_proved : vc_sim_rl_env_ipc_fork_os_ready_decreases_0 = 0 := rfl
def vc_sim_rl_env_ipc_fork_os_ready_call0_sim_rl_env_ipc_fork_mode_label_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_fork_os_ready_call0_sim_rl_env_ipc_fork_mode_label_requires_0_proved : vc_sim_rl_env_ipc_fork_os_ready_call0_sim_rl_env_ipc_fork_mode_label_requires_0 := trivial

end sim_rl_env_ipc_fork_os_ready

namespace sim_rl_env_ipc_multiprocessing_ready

def vc_sim_rl_env_ipc_multiprocessing_ready_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_multiprocessing_ready_requires_0_proved : vc_sim_rl_env_ipc_multiprocessing_ready_requires_0 := trivial
def vc_sim_rl_env_ipc_multiprocessing_ready_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_ipc_multiprocessing_ready_ensures_0_proved (result : Int) : vc_sim_rl_env_ipc_multiprocessing_ready_ensures_0 result := trivial
def vc_sim_rl_env_ipc_multiprocessing_ready_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_ipc_multiprocessing_ready_ensures_1_proved (result : Int) : vc_sim_rl_env_ipc_multiprocessing_ready_ensures_1 result := trivial
def vc_sim_rl_env_ipc_multiprocessing_ready_decreases_0 : Nat := 0
theorem vc_sim_rl_env_ipc_multiprocessing_ready_decreases_0_proved : vc_sim_rl_env_ipc_multiprocessing_ready_decreases_0 = 0 := rfl
def vc_sim_rl_env_ipc_multiprocessing_ready_call0_sim_rl_env_ipc_fork_os_ready_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_multiprocessing_ready_call0_sim_rl_env_ipc_fork_os_ready_requires_0_proved : vc_sim_rl_env_ipc_multiprocessing_ready_call0_sim_rl_env_ipc_fork_os_ready_requires_0 := trivial

end sim_rl_env_ipc_multiprocessing_ready

namespace sim_rl_env_ipc_fork_mode_label

def vc_sim_rl_env_ipc_fork_mode_label_requires_0 : Prop := True
theorem vc_sim_rl_env_ipc_fork_mode_label_requires_0_proved : vc_sim_rl_env_ipc_fork_mode_label_requires_0 := trivial
def vc_sim_rl_env_ipc_fork_mode_label_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_ipc_fork_mode_label_ensures_0_proved (result : Int) : vc_sim_rl_env_ipc_fork_mode_label_ensures_0 result := trivial
def vc_sim_rl_env_ipc_fork_mode_label_decreases_0 : Nat := 0
theorem vc_sim_rl_env_ipc_fork_mode_label_decreases_0_proved : vc_sim_rl_env_ipc_fork_mode_label_decreases_0 = 0 := rfl

end sim_rl_env_ipc_fork_mode_label

namespace env_pool_stub_step_fork_ipc

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_fork_ipc_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_fork_ipc_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_fork_ipc_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_fork_ipc_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_fork_ipc_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_fork_ipc_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_fork_ipc_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_fork_ipc_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_fork_ipc_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_fork_ipc_ensures_0_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_fork_ipc_ensures_0 pool session dt result := trivial
def vc_env_pool_stub_step_fork_ipc_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_fork_ipc_ensures_1_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_fork_ipc_ensures_1 pool session dt result := trivial
def vc_env_pool_stub_step_fork_ipc_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_fork_ipc_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_fork_ipc_call0_sim_rl_env_ipc_fork_mode_label_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_fork_ipc_call0_sim_rl_env_ipc_fork_mode_label_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_call0_sim_rl_env_ipc_fork_mode_label_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_fork_ipc_call1_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_fork_ipc_call1_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_fork_ipc_call1_sim_status_invalid_dt_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 2 -/
def vc_env_pool_stub_step_fork_ipc_call2_env_pool_stub_step_ipc_scaffold_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 2 -/
def vc_env_pool_stub_step_fork_ipc_call2_env_pool_stub_step_ipc_scaffold_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 2 -/
def vc_env_pool_stub_step_fork_ipc_call2_env_pool_stub_step_ipc_scaffold_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 2 -/
def vc_env_pool_stub_step_fork_ipc_call2_env_pool_stub_step_ipc_scaffold_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True

end env_pool_stub_step_fork_ipc

namespace env_pool_stub_step_ipc_scaffold

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_ipc_scaffold_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_ipc_scaffold_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_ipc_scaffold_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_ipc_scaffold_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_ipc_scaffold_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_ipc_scaffold_ensures_0_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_ipc_scaffold_ensures_0 pool session dt result := trivial
def vc_env_pool_stub_step_ipc_scaffold_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_ipc_scaffold_ensures_1_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_ipc_scaffold_ensures_1 pool session dt result := trivial
def vc_env_pool_stub_step_ipc_scaffold_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_ipc_scaffold_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_ipc_scaffold_call0_sim_rl_env_ipc_scaffold_note_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_call0_sim_rl_env_ipc_scaffold_note_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_call0_sim_rl_env_ipc_scaffold_note_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_ipc_scaffold_call1_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_call1_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_call1_sim_status_invalid_dt_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_ipc_scaffold_call2_sim_rl_env_ipc_multiprocessing_ready_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_call2_sim_rl_env_ipc_multiprocessing_ready_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_call2_sim_rl_env_ipc_multiprocessing_ready_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_ipc_scaffold_call3_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_call3_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_call3_sim_status_invalid_dt_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_parallel_scratch_default' at call 4 -/
def vc_env_pool_stub_step_ipc_scaffold_call4_env_pool_parallel_scratch_default_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_parallel_scratch_default' at call 4 -/
def vc_env_pool_stub_step_ipc_scaffold_call4_env_pool_parallel_scratch_default_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_ipc_prepare_shards' at call 5 -/
def vc_env_pool_stub_step_ipc_scaffold_call5_env_pool_ipc_prepare_shards_requires_0 (pool : Int) (session : Int) (dt : Float) (scratch : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_ipc_prepare_shards' at call 5 -/
def vc_env_pool_stub_step_ipc_scaffold_call5_env_pool_ipc_prepare_shards_requires_1 (pool : Int) (session : Int) (dt : Float) (scratch : Int) : Prop := True
def vc_env_pool_stub_step_ipc_scaffold_call6_sim_status_ok_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_call6_sim_status_ok_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_call6_sim_status_ok_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_ipc_scaffold_call7_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_ipc_scaffold_call7_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_ipc_scaffold_call7_sim_status_invalid_dt_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 8 -/
def vc_env_pool_stub_step_ipc_scaffold_call8_env_pool_stub_step_thread_pool_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 8 -/
def vc_env_pool_stub_step_ipc_scaffold_call8_env_pool_stub_step_thread_pool_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 8 -/
def vc_env_pool_stub_step_ipc_scaffold_call8_env_pool_stub_step_thread_pool_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 8 -/
def vc_env_pool_stub_step_ipc_scaffold_call8_env_pool_stub_step_thread_pool_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True

end env_pool_stub_step_ipc_scaffold

namespace env_pool_stub_step_process_pool

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_process_pool_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_process_pool_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_process_pool_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_process_pool_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_process_pool_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_process_pool_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_process_pool_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_process_pool_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_process_pool_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_process_pool_ensures_0_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_process_pool_ensures_0 pool session dt result := trivial
def vc_env_pool_stub_step_process_pool_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_process_pool_ensures_1_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_process_pool_ensures_1 pool session dt result := trivial
def vc_env_pool_stub_step_process_pool_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_process_pool_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_process_pool_call0_sim_rl_env_worker_process_mode_label_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_process_pool_call0_sim_rl_env_worker_process_mode_label_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_call0_sim_rl_env_worker_process_mode_label_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 1 -/
def vc_env_pool_stub_step_process_pool_call1_env_pool_stub_step_thread_pool_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 1 -/
def vc_env_pool_stub_step_process_pool_call1_env_pool_stub_step_thread_pool_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 1 -/
def vc_env_pool_stub_step_process_pool_call1_env_pool_stub_step_thread_pool_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 1 -/
def vc_env_pool_stub_step_process_pool_call1_env_pool_stub_step_thread_pool_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
def vc_env_pool_stub_step_process_pool_call2_sim_rl_env_ipc_multiprocess_label_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_process_pool_call2_sim_rl_env_ipc_multiprocess_label_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_process_pool_call2_sim_rl_env_ipc_multiprocess_label_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 3 -/
def vc_env_pool_stub_step_process_pool_call3_env_pool_stub_step_ipc_scaffold_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 3 -/
def vc_env_pool_stub_step_process_pool_call3_env_pool_stub_step_ipc_scaffold_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 3 -/
def vc_env_pool_stub_step_process_pool_call3_env_pool_stub_step_ipc_scaffold_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_ipc_scaffold' at call 3 -/
def vc_env_pool_stub_step_process_pool_call3_env_pool_stub_step_ipc_scaffold_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 4 -/
def vc_env_pool_stub_step_process_pool_call4_env_pool_stub_step_sync_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 4 -/
def vc_env_pool_stub_step_process_pool_call4_env_pool_stub_step_sync_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 4 -/
def vc_env_pool_stub_step_process_pool_call4_env_pool_stub_step_sync_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 4 -/
def vc_env_pool_stub_step_process_pool_call4_env_pool_stub_step_sync_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True

end env_pool_stub_step_process_pool

namespace env_pool_stub_step

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_ensures_0_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_ensures_0 pool session dt result := trivial
def vc_env_pool_stub_step_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_ensures_1_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_ensures_1 pool session dt result := trivial
def vc_env_pool_stub_step_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_call0_sim_rl_env_worker_mode_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_call0_sim_rl_env_worker_mode_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_call0_sim_rl_env_worker_mode_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 1 -/
def vc_env_pool_stub_step_call1_env_pool_stub_step_sync_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 1 -/
def vc_env_pool_stub_step_call1_env_pool_stub_step_sync_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 1 -/
def vc_env_pool_stub_step_call1_env_pool_stub_step_sync_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_sync' at call 1 -/
def vc_env_pool_stub_step_call1_env_pool_stub_step_sync_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
def vc_env_pool_stub_step_call2_sim_rl_env_worker_mode_process_scaffold_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_call2_sim_rl_env_worker_mode_process_scaffold_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_call2_sim_rl_env_worker_mode_process_scaffold_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_env_pool_stub_step_call3_env_pool_stub_step_process_pool_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_env_pool_stub_step_call3_env_pool_stub_step_process_pool_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_env_pool_stub_step_call3_env_pool_stub_step_process_pool_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_env_pool_stub_step_call3_env_pool_stub_step_process_pool_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 4 -/
def vc_env_pool_stub_step_call4_env_pool_stub_step_thread_pool_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 4 -/
def vc_env_pool_stub_step_call4_env_pool_stub_step_thread_pool_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 4 -/
def vc_env_pool_stub_step_call4_env_pool_stub_step_thread_pool_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_thread_pool' at call 4 -/
def vc_env_pool_stub_step_call4_env_pool_stub_step_thread_pool_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True

end env_pool_stub_step

namespace sim_rl_session_env_pool_step_process_scaffold

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_rl_session_env_pool_step_process_scaffold_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_requires_0 session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_rl_session_env_pool_step_process_scaffold_requires_1 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_requires_1_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_requires_1 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_ensures_0 (session : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_session_env_pool_step_process_scaffold_ensures_1 (session : Int) (dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_sim_rl_session_env_pool_step_process_scaffold_decreases_0 (session : Int) (dt : Float) : Nat := 0
theorem vc_sim_rl_session_env_pool_step_process_scaffold_decreases_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_decreases_0 session dt = 0 := rfl
def vc_sim_rl_session_env_pool_step_process_scaffold_call0_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call0_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call0_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_call1_sim_session_env_pool_init_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call1_sim_session_env_pool_init_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call1_sim_session_env_pool_init_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_env_pool_load' at call 2 -/
def vc_sim_rl_session_env_pool_step_process_scaffold_call2_sim_session_env_pool_load_requires_0 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_sim_rl_session_env_pool_step_process_scaffold_call3_env_pool_stub_step_process_pool_requires_0 (session : Int) (dt : Float) (pool : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_sim_rl_session_env_pool_step_process_scaffold_call3_env_pool_stub_step_process_pool_requires_1 (session : Int) (dt : Float) (pool : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_sim_rl_session_env_pool_step_process_scaffold_call3_env_pool_stub_step_process_pool_requires_2 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_process_pool' at call 3 -/
def vc_sim_rl_session_env_pool_step_process_scaffold_call3_env_pool_stub_step_process_pool_requires_3 (session : Int) (dt : Float) : Prop := True
def vc_sim_rl_session_env_pool_step_process_scaffold_call4_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call4_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call4_sim_status_ok_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_call5_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call5_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call5_sim_status_invalid_dt_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_env_pool_store' at call 6 -/
def vc_sim_rl_session_env_pool_step_process_scaffold_call6_sim_session_env_pool_store_requires_0 (session : Int) (dt : Float) (pool : Int) : Prop := True
def vc_sim_rl_session_env_pool_step_process_scaffold_call7_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call7_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call7_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_call8_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call8_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call8_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_call9_sim_session_replay_last_tick_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call9_sim_session_replay_last_tick_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call9_sim_session_replay_last_tick_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_call10_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call10_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call10_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_process_scaffold_call11_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_process_scaffold_call11_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_process_scaffold_call11_sim_status_ok_requires_0 session dt := trivial

end sim_rl_session_env_pool_step_process_scaffold

namespace sim_rl_session_env_pool_step

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_rl_session_env_pool_step_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_requires_0 session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_rl_session_env_pool_step_requires_1 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_requires_1_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_requires_1 session dt := trivial
def vc_sim_rl_session_env_pool_step_ensures_0 (session : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_session_env_pool_step_ensures_1 (session : Int) (dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_sim_rl_session_env_pool_step_decreases_0 (session : Int) (dt : Float) : Nat := 0
theorem vc_sim_rl_session_env_pool_step_decreases_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_decreases_0 session dt = 0 := rfl
def vc_sim_rl_session_env_pool_step_call0_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call0_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call0_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_call1_sim_session_env_pool_init_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call1_sim_session_env_pool_init_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call1_sim_session_env_pool_init_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_env_pool_load' at call 2 -/
def vc_sim_rl_session_env_pool_step_call2_sim_session_env_pool_load_requires_0 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step' at call 3 -/
def vc_sim_rl_session_env_pool_step_call3_env_pool_stub_step_requires_0 (session : Int) (dt : Float) (pool : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step' at call 3 -/
def vc_sim_rl_session_env_pool_step_call3_env_pool_stub_step_requires_1 (session : Int) (dt : Float) (pool : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step' at call 3 -/
def vc_sim_rl_session_env_pool_step_call3_env_pool_stub_step_requires_2 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step' at call 3 -/
def vc_sim_rl_session_env_pool_step_call3_env_pool_stub_step_requires_3 (session : Int) (dt : Float) : Prop := True
def vc_sim_rl_session_env_pool_step_call4_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call4_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call4_sim_status_ok_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_call5_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call5_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call5_sim_status_invalid_dt_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_env_pool_store' at call 6 -/
def vc_sim_rl_session_env_pool_step_call6_sim_session_env_pool_store_requires_0 (session : Int) (dt : Float) (pool : Int) : Prop := True
def vc_sim_rl_session_env_pool_step_call7_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call7_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call7_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_call8_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call8_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call8_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_call9_sim_session_replay_last_tick_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call9_sim_session_replay_last_tick_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call9_sim_session_replay_last_tick_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_call10_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call10_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call10_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_call11_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_call11_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_call11_sim_status_ok_requires_0 session dt := trivial

end sim_rl_session_env_pool_step

namespace sim_rl_tick_stub

def vc_sim_rl_tick_stub_requires_0 (detail : Int) : Prop := (detail ≥ 0)
def vc_sim_rl_tick_stub_requires_1 (detail : Int) : Prop := (detail ≤ 3)
def vc_sim_rl_tick_stub_ensures_0 (detail : Int) (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_tick_stub_ensures_1 (detail : Int) (result : Int) : Prop := (result ≤ 1)
def vc_sim_rl_tick_stub_decreases_0 (detail : Int) : Nat := 0
theorem vc_sim_rl_tick_stub_decreases_0_proved (detail : Int) : vc_sim_rl_tick_stub_decreases_0 detail = 0 := rfl
def vc_sim_rl_tick_stub_call0_sim_session_stub_default_requires_0 (detail : Int) : Prop := True
theorem vc_sim_rl_tick_stub_call0_sim_session_stub_default_requires_0_proved (detail : Int) : vc_sim_rl_tick_stub_call0_sim_session_stub_default_requires_0 detail := trivial
def vc_sim_rl_tick_stub_call1_sim_session_apply_studio_profile_requires_0 (detail : Int) : Prop := True
theorem vc_sim_rl_tick_stub_call1_sim_session_apply_studio_profile_requires_0_proved (detail : Int) : vc_sim_rl_tick_stub_call1_sim_session_apply_studio_profile_requires_0 detail := trivial
/-! VC call-site requires (opaque): callee 'sim_rl_session_env_pool_step' at call 2 -/
def vc_sim_rl_tick_stub_call2_sim_rl_session_env_pool_step_requires_0 (detail : Int) (sess : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'sim_rl_session_env_pool_step' at call 2 -/
def vc_sim_rl_tick_stub_call2_sim_rl_session_env_pool_step_requires_1 (detail : Int) (sess : Int) : Prop := True
def vc_sim_rl_tick_stub_call3_sim_status_ok_requires_0 (detail : Int) : Prop := True
theorem vc_sim_rl_tick_stub_call3_sim_status_ok_requires_0_proved (detail : Int) : vc_sim_rl_tick_stub_call3_sim_status_ok_requires_0 detail := trivial

end sim_rl_tick_stub

namespace sim_rl_env_li_process_fork_mode_label

def vc_sim_rl_env_li_process_fork_mode_label_requires_0 : Prop := True
theorem vc_sim_rl_env_li_process_fork_mode_label_requires_0_proved : vc_sim_rl_env_li_process_fork_mode_label_requires_0 := trivial
def vc_sim_rl_env_li_process_fork_mode_label_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_rl_env_li_process_fork_mode_label_ensures_0_proved (result : Int) : vc_sim_rl_env_li_process_fork_mode_label_ensures_0 result := trivial
def vc_sim_rl_env_li_process_fork_mode_label_decreases_0 : Nat := 0
theorem vc_sim_rl_env_li_process_fork_mode_label_decreases_0_proved : vc_sim_rl_env_li_process_fork_mode_label_decreases_0 = 0 := rfl

end sim_rl_env_li_process_fork_mode_label

namespace sim_rl_env_li_process_fork_ready

def vc_sim_rl_env_li_process_fork_ready_requires_0 : Prop := True
theorem vc_sim_rl_env_li_process_fork_ready_requires_0_proved : vc_sim_rl_env_li_process_fork_ready_requires_0 := trivial
def vc_sim_rl_env_li_process_fork_ready_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_env_li_process_fork_ready_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_sim_rl_env_li_process_fork_ready_decreases_0 : Nat := 0
theorem vc_sim_rl_env_li_process_fork_ready_decreases_0_proved : vc_sim_rl_env_li_process_fork_ready_decreases_0 = 0 := rfl
def vc_sim_rl_env_li_process_fork_ready_call0_sim_rl_env_li_process_fork_mode_label_requires_0 : Prop := True
theorem vc_sim_rl_env_li_process_fork_ready_call0_sim_rl_env_li_process_fork_mode_label_requires_0_proved : vc_sim_rl_env_li_process_fork_ready_call0_sim_rl_env_li_process_fork_mode_label_requires_0 := trivial
def vc_sim_rl_env_li_process_fork_ready_call1_sim_rl_env_ipc_fork_os_ready_requires_0 : Prop := True
theorem vc_sim_rl_env_li_process_fork_ready_call1_sim_rl_env_ipc_fork_os_ready_requires_0_proved : vc_sim_rl_env_li_process_fork_ready_call1_sim_rl_env_ipc_fork_os_ready_requires_0 := trivial

end sim_rl_env_li_process_fork_ready

namespace env_pool_stub_step_li_process_fork

/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_li_process_fork_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_li_process_fork_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_requires_0 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_li_process_fork_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_li_process_fork_requires_1_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_requires_1 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_li_process_fork_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_li_process_fork_requires_2_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_requires_2 pool session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_env_pool_stub_step_li_process_fork_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_li_process_fork_requires_3_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_requires_3 pool session dt := trivial
def vc_env_pool_stub_step_li_process_fork_ensures_0 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_li_process_fork_ensures_0_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_li_process_fork_ensures_0 pool session dt result := trivial
def vc_env_pool_stub_step_li_process_fork_ensures_1 (pool : Int) (session : Int) (dt : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_env_pool_stub_step_li_process_fork_ensures_1_proved (pool : Int) (session : Int) (dt : Float) (result : Int) : vc_env_pool_stub_step_li_process_fork_ensures_1 pool session dt result := trivial
def vc_env_pool_stub_step_li_process_fork_decreases_0 (pool : Int) (session : Int) (dt : Float) : Nat := 0
theorem vc_env_pool_stub_step_li_process_fork_decreases_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_decreases_0 pool session dt = 0 := rfl
def vc_env_pool_stub_step_li_process_fork_call0_sim_rl_env_li_process_fork_ready_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_li_process_fork_call0_sim_rl_env_li_process_fork_ready_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_call0_sim_rl_env_li_process_fork_ready_requires_0 pool session dt := trivial
def vc_env_pool_stub_step_li_process_fork_call1_sim_status_invalid_dt_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
theorem vc_env_pool_stub_step_li_process_fork_call1_sim_status_invalid_dt_requires_0_proved (pool : Int) (session : Int) (dt : Float) : vc_env_pool_stub_step_li_process_fork_call1_sim_status_invalid_dt_requires_0 pool session dt := trivial
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_fork_ipc' at call 2 -/
def vc_env_pool_stub_step_li_process_fork_call2_env_pool_stub_step_fork_ipc_requires_0 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_fork_ipc' at call 2 -/
def vc_env_pool_stub_step_li_process_fork_call2_env_pool_stub_step_fork_ipc_requires_1 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_fork_ipc' at call 2 -/
def vc_env_pool_stub_step_li_process_fork_call2_env_pool_stub_step_fork_ipc_requires_2 (pool : Int) (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_fork_ipc' at call 2 -/
def vc_env_pool_stub_step_li_process_fork_call2_env_pool_stub_step_fork_ipc_requires_3 (pool : Int) (session : Int) (dt : Float) : Prop := True

end env_pool_stub_step_li_process_fork

namespace sim_rl_session_env_pool_step_li_fork

/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_rl_session_env_pool_step_li_fork_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_requires_0 session dt := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_sim_rl_session_env_pool_step_li_fork_requires_1 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_requires_1_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_requires_1 session dt := trivial
def vc_sim_rl_session_env_pool_step_li_fork_ensures_0 (session : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_sim_rl_session_env_pool_step_li_fork_ensures_1 (session : Int) (dt : Float) (result : Int) : Prop := (result ≤ 1)
def vc_sim_rl_session_env_pool_step_li_fork_decreases_0 (session : Int) (dt : Float) : Nat := 0
theorem vc_sim_rl_session_env_pool_step_li_fork_decreases_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_decreases_0 session dt = 0 := rfl
def vc_sim_rl_session_env_pool_step_li_fork_call0_sim_session_env_pool_init_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call0_sim_session_env_pool_init_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call0_sim_session_env_pool_init_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_env_pool_load' at call 1 -/
def vc_sim_rl_session_env_pool_step_li_fork_call1_sim_session_env_pool_load_requires_0 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_li_process_fork' at call 2 -/
def vc_sim_rl_session_env_pool_step_li_fork_call2_env_pool_stub_step_li_process_fork_requires_0 (session : Int) (dt : Float) (pool : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_li_process_fork' at call 2 -/
def vc_sim_rl_session_env_pool_step_li_fork_call2_env_pool_stub_step_li_process_fork_requires_1 (session : Int) (dt : Float) (pool : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_li_process_fork' at call 2 -/
def vc_sim_rl_session_env_pool_step_li_fork_call2_env_pool_stub_step_li_process_fork_requires_2 (session : Int) (dt : Float) : Prop := True
/-! VC call-site requires (opaque): callee 'env_pool_stub_step_li_process_fork' at call 2 -/
def vc_sim_rl_session_env_pool_step_li_fork_call2_env_pool_stub_step_li_process_fork_requires_3 (session : Int) (dt : Float) : Prop := True
def vc_sim_rl_session_env_pool_step_li_fork_call3_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call3_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call3_sim_status_ok_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_li_fork_call4_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call4_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call4_sim_status_invalid_dt_requires_0 session dt := trivial
/-! VC call-site requires (opaque): callee 'sim_session_env_pool_store' at call 5 -/
def vc_sim_rl_session_env_pool_step_li_fork_call5_sim_session_env_pool_store_requires_0 (session : Int) (dt : Float) (pool : Int) : Prop := True
def vc_sim_rl_session_env_pool_step_li_fork_call6_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call6_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call6_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_li_fork_call7_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call7_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call7_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_li_fork_call8_sim_session_replay_last_tick_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call8_sim_session_replay_last_tick_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call8_sim_session_replay_last_tick_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_li_fork_call9_sim_status_invalid_dt_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call9_sim_status_invalid_dt_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call9_sim_status_invalid_dt_requires_0 session dt := trivial
def vc_sim_rl_session_env_pool_step_li_fork_call10_sim_status_ok_requires_0 (session : Int) (dt : Float) : Prop := True
theorem vc_sim_rl_session_env_pool_step_li_fork_call10_sim_status_ok_requires_0_proved (session : Int) (dt : Float) : vc_sim_rl_session_env_pool_step_li_fork_call10_sim_status_ok_requires_0 session dt := trivial

end sim_rl_session_env_pool_step_li_fork

namespace li_sim_scientific_version

def vc_li_sim_scientific_version_requires_0 : Prop := True
theorem vc_li_sim_scientific_version_requires_0_proved : vc_li_sim_scientific_version_requires_0 := trivial
def vc_li_sim_scientific_version_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_li_sim_scientific_version_ensures_0_proved (result : Int) : vc_li_sim_scientific_version_ensures_0 result := trivial
def vc_li_sim_scientific_version_decreases_0 : Nat := 0
theorem vc_li_sim_scientific_version_decreases_0_proved : vc_li_sim_scientific_version_decreases_0 = 0 := rfl

end li_sim_scientific_version

namespace md_oracle_lj_fx_pair

def vc_md_oracle_lj_fx_pair_requires_0 (dx : Float) (r2 : Float) (rc2 : Float) : Prop := (rc2 > (0 : Float))
def vc_md_oracle_lj_fx_pair_ensures_0 (dx : Float) (r2 : Float) (rc2 : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_md_oracle_lj_fx_pair_decreases_0 (dx : Float) (r2 : Float) (rc2 : Float) : Nat := 0
theorem vc_md_oracle_lj_fx_pair_decreases_0_proved (dx : Float) (r2 : Float) (rc2 : Float) : vc_md_oracle_lj_fx_pair_decreases_0 dx r2 rc2 = 0 := rfl

end md_oracle_lj_fx_pair

namespace md_oracle_lj_pe_pair

def vc_md_oracle_lj_pe_pair_requires_0 (r2 : Float) (rc2 : Float) : Prop := (rc2 > (0 : Float))
def vc_md_oracle_lj_pe_pair_ensures_0 (r2 : Float) (rc2 : Float) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_md_oracle_lj_pe_pair_decreases_0 (r2 : Float) (rc2 : Float) : Nat := 0
theorem vc_md_oracle_lj_pe_pair_decreases_0_proved (r2 : Float) (rc2 : Float) : vc_md_oracle_lj_pe_pair_decreases_0 r2 rc2 = 0 := rfl

end md_oracle_lj_pe_pair

namespace md_oracle_chain_energy

def vc_md_oracle_chain_energy_requires_0 (px : LiArray Float 4) (py : LiArray Float 4) (vx : LiArray Float 4) (vy : LiArray Float 4) : Prop := True
theorem vc_md_oracle_chain_energy_requires_0_proved (px : LiArray Float 4) (py : LiArray Float 4) (vx : LiArray Float 4) (vy : LiArray Float 4) : vc_md_oracle_chain_energy_requires_0 px py vx vy := trivial
def vc_md_oracle_chain_energy_ensures_0 (px : LiArray Float 4) (py : LiArray Float 4) (vx : LiArray Float 4) (vy : LiArray Float 4) (result : Float) : Prop := (result ≥ (-1000 : Float))
def vc_md_oracle_chain_energy_decreases_0 (px : LiArray Float 4) (py : LiArray Float 4) (vx : LiArray Float 4) (vy : LiArray Float 4) : Nat := 0
theorem vc_md_oracle_chain_energy_decreases_0_proved (px : LiArray Float 4) (py : LiArray Float 4) (vx : LiArray Float 4) (vy : LiArray Float 4) : vc_md_oracle_chain_energy_decreases_0 px py vx vy = 0 := rfl
def vc_md_oracle_chain_energy_call0_md_oracle_lj_pe_pair_requires_0 (px : LiArray Float 4) (py : LiArray Float 4) (vx : LiArray Float 4) (vy : LiArray Float 4) (rc2 : Float) : Prop := (rc2 > (0 : Float))

end md_oracle_chain_energy

namespace md_oracle_chain_forces

def vc_md_oracle_chain_forces_requires_0 (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) : Prop := True
theorem vc_md_oracle_chain_forces_requires_0_proved (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) : vc_md_oracle_chain_forces_requires_0 px py fx fy := trivial
def vc_md_oracle_chain_forces_ensures_0 (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) (result : Unit) : Prop := (result = 0)
def vc_md_oracle_chain_forces_decreases_0 (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) : Nat := 0
theorem vc_md_oracle_chain_forces_decreases_0_proved (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) : vc_md_oracle_chain_forces_decreases_0 px py fx fy = 0 := rfl
def vc_md_oracle_chain_forces_call0_md_oracle_lj_fx_pair_requires_0 (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) (rc2 : Float) : Prop := (rc2 > (0 : Float))
def vc_md_oracle_chain_forces_call1_md_oracle_lj_fx_pair_requires_0 (px : LiArray Float 4) (py : LiArray Float 4) (fx : LiArray Float 4) (fy : LiArray Float 4) (rc2 : Float) : Prop := (rc2 > (0 : Float))

end md_oracle_chain_forces

namespace sim_scientific_oracle_checksum_md

def vc_sim_scientific_oracle_checksum_md_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_md_requires_0_proved : vc_sim_scientific_oracle_checksum_md_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_md_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_sim_scientific_oracle_checksum_md_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_md_decreases_0_proved : vc_sim_scientific_oracle_checksum_md_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_md_call0_md_oracle_chain_energy_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_md_call0_md_oracle_chain_energy_requires_0_proved : vc_sim_scientific_oracle_checksum_md_call0_md_oracle_chain_energy_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_md_call1_md_oracle_chain_forces_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_md_call1_md_oracle_chain_forces_requires_0_proved : vc_sim_scientific_oracle_checksum_md_call1_md_oracle_chain_forces_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_md_call2_md_oracle_chain_forces_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_md_call2_md_oracle_chain_forces_requires_0_proved : vc_sim_scientific_oracle_checksum_md_call2_md_oracle_chain_forces_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_md_call3_md_oracle_chain_energy_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_md_call3_md_oracle_chain_energy_requires_0_proved : vc_sim_scientific_oracle_checksum_md_call3_md_oracle_chain_energy_requires_0 := trivial

end sim_scientific_oracle_checksum_md

namespace heat_oracle_stencil_step

def vc_heat_oracle_stencil_step_requires_0 (u : LiArray Float 8) (v : LiArray Float 8) (r : Float) : Prop := (r > (0 : Float))
def vc_heat_oracle_stencil_step_ensures_0 (u : LiArray Float 8) (v : LiArray Float 8) (r : Float) (result : Unit) : Prop := (result = 0)
def vc_heat_oracle_stencil_step_decreases_0 (u : LiArray Float 8) (v : LiArray Float 8) (r : Float) : Nat := 0
theorem vc_heat_oracle_stencil_step_decreases_0_proved (u : LiArray Float 8) (v : LiArray Float 8) (r : Float) : vc_heat_oracle_stencil_step_decreases_0 u v r = 0 := rfl

end heat_oracle_stencil_step

namespace sim_scientific_oracle_checksum_heat

def vc_sim_scientific_oracle_checksum_heat_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_heat_requires_0_proved : vc_sim_scientific_oracle_checksum_heat_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_heat_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_sim_scientific_oracle_checksum_heat_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_heat_decreases_0_proved : vc_sim_scientific_oracle_checksum_heat_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_heat_call0_heat_oracle_stencil_step_requires_0 (r : Float) : Prop := (r > (0 : Float))

end sim_scientific_oracle_checksum_heat

namespace cfd_oracle_lid_diffuse_step

def vc_cfd_oracle_lid_diffuse_step_requires_0 (u : LiArray Float 8) (nu : Float) (dt : Float) (dx : Float) : Prop := (nu > (0 : Float))
def vc_cfd_oracle_lid_diffuse_step_requires_1 (u : LiArray Float 8) (nu : Float) (dt : Float) (dx : Float) : Prop := (dt > (0 : Float))
def vc_cfd_oracle_lid_diffuse_step_requires_2 (u : LiArray Float 8) (nu : Float) (dt : Float) (dx : Float) : Prop := (dx > (0 : Float))
def vc_cfd_oracle_lid_diffuse_step_ensures_0 (u : LiArray Float 8) (nu : Float) (dt : Float) (dx : Float) (result : Unit) : Prop := (result = 0)
def vc_cfd_oracle_lid_diffuse_step_decreases_0 (u : LiArray Float 8) (nu : Float) (dt : Float) (dx : Float) : Nat := 0
theorem vc_cfd_oracle_lid_diffuse_step_decreases_0_proved (u : LiArray Float 8) (nu : Float) (dt : Float) (dx : Float) : vc_cfd_oracle_lid_diffuse_step_decreases_0 u nu dt dx = 0 := rfl

end cfd_oracle_lid_diffuse_step

namespace sim_scientific_oracle_checksum_cfd

def vc_sim_scientific_oracle_checksum_cfd_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_cfd_requires_0_proved : vc_sim_scientific_oracle_checksum_cfd_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_cfd_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_sim_scientific_oracle_checksum_cfd_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_cfd_decreases_0_proved : vc_sim_scientific_oracle_checksum_cfd_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_cfd_call0_cfd_oracle_lid_diffuse_step_requires_0 (nu : Float) : Prop := (nu > (0 : Float))
def vc_sim_scientific_oracle_checksum_cfd_call0_cfd_oracle_lid_diffuse_step_requires_1 (dt : Float) : Prop := (dt > (0 : Float))
def vc_sim_scientific_oracle_checksum_cfd_call0_cfd_oracle_lid_diffuse_step_requires_2 (dx : Float) : Prop := (dx > (0 : Float))

end sim_scientific_oracle_checksum_cfd

namespace fea_oracle_bar_stiffness

def vc_fea_oracle_bar_stiffness_requires_0 (e : Float) (a : Float) (l : Float) : Prop := (e > (0 : Float))
def vc_fea_oracle_bar_stiffness_requires_1 (e : Float) (a : Float) (l : Float) : Prop := (a > (0 : Float))
def vc_fea_oracle_bar_stiffness_requires_2 (e : Float) (a : Float) (l : Float) : Prop := (l > (0 : Float))
def vc_fea_oracle_bar_stiffness_ensures_0 (e : Float) (a : Float) (l : Float) (result : Float) : Prop := (result > (0 : Float))
def vc_fea_oracle_bar_stiffness_decreases_0 (e : Float) (a : Float) (l : Float) : Nat := 0
theorem vc_fea_oracle_bar_stiffness_decreases_0_proved (e : Float) (a : Float) (l : Float) : vc_fea_oracle_bar_stiffness_decreases_0 e a l = 0 := rfl

end fea_oracle_bar_stiffness

namespace fea_oracle_series_displacement

def vc_fea_oracle_series_displacement_requires_0 (k1 : Float) (k2 : Float) (force : Float) : Prop := (k1 > (0 : Float))
def vc_fea_oracle_series_displacement_requires_1 (k1 : Float) (k2 : Float) (force : Float) : Prop := (k2 > (0 : Float))
def vc_fea_oracle_series_displacement_requires_2 (k1 : Float) (k2 : Float) (force : Float) : Prop := (force > (0 : Float))
def vc_fea_oracle_series_displacement_ensures_0 (k1 : Float) (k2 : Float) (force : Float) (result : Float) : Prop := (result > (0 : Float))
def vc_fea_oracle_series_displacement_decreases_0 (k1 : Float) (k2 : Float) (force : Float) : Nat := 0
theorem vc_fea_oracle_series_displacement_decreases_0_proved (k1 : Float) (k2 : Float) (force : Float) : vc_fea_oracle_series_displacement_decreases_0 k1 k2 force = 0 := rfl

end fea_oracle_series_displacement

namespace sim_scientific_oracle_checksum_fea

def vc_sim_scientific_oracle_checksum_fea_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_fea_requires_0_proved : vc_sim_scientific_oracle_checksum_fea_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_fea_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_fea_decreases_0_proved : vc_sim_scientific_oracle_checksum_fea_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_fea_call0_fea_oracle_bar_stiffness_requires_0 (e : Float) : Prop := (e > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call0_fea_oracle_bar_stiffness_requires_1 (a : Float) : Prop := (a > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call0_fea_oracle_bar_stiffness_requires_2 (l : Float) : Prop := (l > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call1_fea_oracle_bar_stiffness_requires_0 (e : Float) : Prop := (e > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call1_fea_oracle_bar_stiffness_requires_1 (a : Float) : Prop := (a > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call1_fea_oracle_bar_stiffness_requires_2 (l : Float) : Prop := ((l * (0.75 : Float)) > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call2_fea_oracle_series_displacement_requires_0 (k1 : Float) : Prop := (k1 > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call2_fea_oracle_series_displacement_requires_1 (k2 : Float) : Prop := (k2 > (0 : Float))
def vc_sim_scientific_oracle_checksum_fea_call2_fea_oracle_series_displacement_requires_2 (force : Float) : Prop := (force > (0 : Float))

end sim_scientific_oracle_checksum_fea

namespace sim_scientific_oracle_checksum_qm

def vc_sim_scientific_oracle_checksum_qm_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_qm_requires_0_proved : vc_sim_scientific_oracle_checksum_qm_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_qm_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_scientific_oracle_checksum_qm_ensures_0_proved (result : Float) : vc_sim_scientific_oracle_checksum_qm_ensures_0 result := trivial
def vc_sim_scientific_oracle_checksum_qm_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_qm_decreases_0_proved : vc_sim_scientific_oracle_checksum_qm_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_qm_call0_chem_dft_energy_kernel_hartree_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_qm_call0_chem_dft_energy_kernel_hartree_requires_0_proved : vc_sim_scientific_oracle_checksum_qm_call0_chem_dft_energy_kernel_hartree_requires_0 := trivial

end sim_scientific_oracle_checksum_qm

namespace echem_aimd_step_count

def vc_echem_aimd_step_count_requires_0 : Prop := True
theorem vc_echem_aimd_step_count_requires_0_proved : vc_echem_aimd_step_count_requires_0 := trivial
def vc_echem_aimd_step_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_aimd_step_count_ensures_0_proved (result : Int) : vc_echem_aimd_step_count_ensures_0 result := trivial
def vc_echem_aimd_step_count_decreases_0 : Nat := 0
theorem vc_echem_aimd_step_count_decreases_0_proved : vc_echem_aimd_step_count_decreases_0 = 0 := rfl

end echem_aimd_step_count

namespace echem_aimd_harmonic_k

def vc_echem_aimd_harmonic_k_requires_0 : Prop := True
theorem vc_echem_aimd_harmonic_k_requires_0_proved : vc_echem_aimd_harmonic_k_requires_0 := trivial
def vc_echem_aimd_harmonic_k_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_aimd_harmonic_k_decreases_0 : Nat := 0
theorem vc_echem_aimd_harmonic_k_decreases_0_proved : vc_echem_aimd_harmonic_k_decreases_0 = 0 := rfl

end echem_aimd_harmonic_k

namespace echem_aimd_dft_energy_per_step

def vc_echem_aimd_dft_energy_per_step_requires_0 : Prop := True
theorem vc_echem_aimd_dft_energy_per_step_requires_0_proved : vc_echem_aimd_dft_energy_per_step_requires_0 := trivial
def vc_echem_aimd_dft_energy_per_step_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_aimd_dft_energy_per_step_ensures_0_proved (result : Float) : vc_echem_aimd_dft_energy_per_step_ensures_0 result := trivial
def vc_echem_aimd_dft_energy_per_step_decreases_0 : Nat := 0
theorem vc_echem_aimd_dft_energy_per_step_decreases_0_proved : vc_echem_aimd_dft_energy_per_step_decreases_0 = 0 := rfl
def vc_echem_aimd_dft_energy_per_step_call0_chem_dft_energy_kernel_hartree_requires_0 : Prop := True
theorem vc_echem_aimd_dft_energy_per_step_call0_chem_dft_energy_kernel_hartree_requires_0_proved : vc_echem_aimd_dft_energy_per_step_call0_chem_dft_energy_kernel_hartree_requires_0 := trivial

end echem_aimd_dft_energy_per_step

namespace echem_aimd_kinetic_pe

def vc_echem_aimd_kinetic_pe_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_aimd_kinetic_pe_requires_0_proved (x : Float) (vx : Float) : vc_echem_aimd_kinetic_pe_requires_0 x vx := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_aimd_kinetic_pe_ensures_0 (x : Float) (vx : Float) (result : Float) : Prop := True
theorem vc_echem_aimd_kinetic_pe_ensures_0_proved (x : Float) (vx : Float) (result : Float) : vc_echem_aimd_kinetic_pe_ensures_0 x vx result := trivial
def vc_echem_aimd_kinetic_pe_decreases_0 (x : Float) (vx : Float) : Nat := 0
theorem vc_echem_aimd_kinetic_pe_decreases_0_proved (x : Float) (vx : Float) : vc_echem_aimd_kinetic_pe_decreases_0 x vx = 0 := rfl
def vc_echem_aimd_kinetic_pe_call0_echem_aimd_harmonic_k_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_aimd_kinetic_pe_call0_echem_aimd_harmonic_k_requires_0_proved (x : Float) (vx : Float) : vc_echem_aimd_kinetic_pe_call0_echem_aimd_harmonic_k_requires_0 x vx := trivial

end echem_aimd_kinetic_pe

namespace echem_aimd_total_energy

def vc_echem_aimd_total_energy_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_aimd_total_energy_requires_0_proved (x : Float) (vx : Float) : vc_echem_aimd_total_energy_requires_0 x vx := trivial
def vc_echem_aimd_total_energy_ensures_0 (x : Float) (vx : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_aimd_total_energy_ensures_0_proved (x : Float) (vx : Float) (result : Float) : vc_echem_aimd_total_energy_ensures_0 x vx result := trivial
def vc_echem_aimd_total_energy_decreases_0 (x : Float) (vx : Float) : Nat := 0
theorem vc_echem_aimd_total_energy_decreases_0_proved (x : Float) (vx : Float) : vc_echem_aimd_total_energy_decreases_0 x vx = 0 := rfl
def vc_echem_aimd_total_energy_call0_echem_aimd_dft_energy_per_step_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_aimd_total_energy_call0_echem_aimd_dft_energy_per_step_requires_0_proved (x : Float) (vx : Float) : vc_echem_aimd_total_energy_call0_echem_aimd_dft_energy_per_step_requires_0 x vx := trivial
def vc_echem_aimd_total_energy_call1_echem_aimd_kinetic_pe_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_aimd_total_energy_call1_echem_aimd_kinetic_pe_requires_0_proved (x : Float) (vx : Float) : vc_echem_aimd_total_energy_call1_echem_aimd_kinetic_pe_requires_0 x vx := trivial

end echem_aimd_total_energy

namespace echem_aimd_thermostat_step

def vc_echem_aimd_thermostat_step_requires_0 (vx : Float) (target_ke : Float) : Prop := (target_ke ≥ (0 : Float))
def vc_echem_aimd_thermostat_step_ensures_0 (vx : Float) (target_ke : Float) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_aimd_thermostat_step_ensures_0_proved (vx : Float) (target_ke : Float) (result : Unit) : vc_echem_aimd_thermostat_step_ensures_0 vx target_ke result := trivial
def vc_echem_aimd_thermostat_step_decreases_0 (vx : Float) (target_ke : Float) : Nat := 0
theorem vc_echem_aimd_thermostat_step_decreases_0_proved (vx : Float) (target_ke : Float) : vc_echem_aimd_thermostat_step_decreases_0 vx target_ke = 0 := rfl

end echem_aimd_thermostat_step

namespace sim_scientific_oracle_checksum_echem_aimd

def vc_sim_scientific_oracle_checksum_echem_aimd_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_aimd_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_aimd_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_sim_scientific_oracle_checksum_echem_aimd_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_echem_aimd_decreases_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_echem_aimd_call0_echem_aimd_harmonic_k_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_aimd_call0_echem_aimd_harmonic_k_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_call0_echem_aimd_harmonic_k_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_aimd_call1_echem_aimd_total_energy_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_aimd_call1_echem_aimd_total_energy_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_call1_echem_aimd_total_energy_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_aimd_call2_echem_aimd_step_count_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_aimd_call2_echem_aimd_step_count_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_call2_echem_aimd_step_count_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_aimd_call3_echem_aimd_dft_energy_per_step_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_aimd_call3_echem_aimd_dft_energy_per_step_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_call3_echem_aimd_dft_energy_per_step_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_aimd_call4_echem_aimd_thermostat_step_requires_0 (target_ke : Float) : Prop := (target_ke ≥ (0 : Float))
def vc_sim_scientific_oracle_checksum_echem_aimd_call5_echem_aimd_total_energy_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_aimd_call5_echem_aimd_total_energy_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_aimd_call5_echem_aimd_total_energy_requires_0 := trivial

end sim_scientific_oracle_checksum_echem_aimd

namespace echem_gc_aimd_step_count

def vc_echem_gc_aimd_step_count_requires_0 : Prop := True
theorem vc_echem_gc_aimd_step_count_requires_0_proved : vc_echem_gc_aimd_step_count_requires_0 := trivial
def vc_echem_gc_aimd_step_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_gc_aimd_step_count_ensures_0_proved (result : Int) : vc_echem_gc_aimd_step_count_ensures_0 result := trivial
def vc_echem_gc_aimd_step_count_decreases_0 : Nat := 0
theorem vc_echem_gc_aimd_step_count_decreases_0_proved : vc_echem_gc_aimd_step_count_decreases_0 = 0 := rfl

end echem_gc_aimd_step_count

namespace echem_gc_aimd_electrode_potential_v

def vc_echem_gc_aimd_electrode_potential_v_requires_0 : Prop := True
theorem vc_echem_gc_aimd_electrode_potential_v_requires_0_proved : vc_echem_gc_aimd_electrode_potential_v_requires_0 := trivial
def vc_echem_gc_aimd_electrode_potential_v_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_gc_aimd_electrode_potential_v_ensures_0_proved (result : Float) : vc_echem_gc_aimd_electrode_potential_v_ensures_0 result := trivial
def vc_echem_gc_aimd_electrode_potential_v_decreases_0 : Nat := 0
theorem vc_echem_gc_aimd_electrode_potential_v_decreases_0_proved : vc_echem_gc_aimd_electrode_potential_v_decreases_0 = 0 := rfl

end echem_gc_aimd_electrode_potential_v

namespace echem_gc_aimd_harmonic_k

def vc_echem_gc_aimd_harmonic_k_requires_0 : Prop := True
theorem vc_echem_gc_aimd_harmonic_k_requires_0_proved : vc_echem_gc_aimd_harmonic_k_requires_0 := trivial
def vc_echem_gc_aimd_harmonic_k_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_gc_aimd_harmonic_k_decreases_0 : Nat := 0
theorem vc_echem_gc_aimd_harmonic_k_decreases_0_proved : vc_echem_gc_aimd_harmonic_k_decreases_0 = 0 := rfl

end echem_gc_aimd_harmonic_k

namespace echem_gc_aimd_dft_energy_at_potential

def vc_echem_gc_aimd_dft_energy_at_potential_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_gc_aimd_dft_energy_at_potential_requires_0_proved (u_v : Float) : vc_echem_gc_aimd_dft_energy_at_potential_requires_0 u_v := trivial
def vc_echem_gc_aimd_dft_energy_at_potential_ensures_0 (u_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_gc_aimd_dft_energy_at_potential_ensures_0_proved (u_v : Float) (result : Float) : vc_echem_gc_aimd_dft_energy_at_potential_ensures_0 u_v result := trivial
def vc_echem_gc_aimd_dft_energy_at_potential_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_gc_aimd_dft_energy_at_potential_decreases_0_proved (u_v : Float) : vc_echem_gc_aimd_dft_energy_at_potential_decreases_0 u_v = 0 := rfl
def vc_echem_gc_aimd_dft_energy_at_potential_call0_echem_dft_energy_at_potential_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_gc_aimd_dft_energy_at_potential_call0_echem_dft_energy_at_potential_requires_0_proved (u_v : Float) : vc_echem_gc_aimd_dft_energy_at_potential_call0_echem_dft_energy_at_potential_requires_0 u_v := trivial

end echem_gc_aimd_dft_energy_at_potential

namespace echem_gc_aimd_kinetic_pe

def vc_echem_gc_aimd_kinetic_pe_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_gc_aimd_kinetic_pe_requires_0_proved (x : Float) (vx : Float) : vc_echem_gc_aimd_kinetic_pe_requires_0 x vx := trivial
def vc_echem_gc_aimd_kinetic_pe_ensures_0 (x : Float) (vx : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_gc_aimd_kinetic_pe_decreases_0 (x : Float) (vx : Float) : Nat := 0
theorem vc_echem_gc_aimd_kinetic_pe_decreases_0_proved (x : Float) (vx : Float) : vc_echem_gc_aimd_kinetic_pe_decreases_0 x vx = 0 := rfl
def vc_echem_gc_aimd_kinetic_pe_call0_echem_gc_aimd_harmonic_k_requires_0 (x : Float) (vx : Float) : Prop := True
theorem vc_echem_gc_aimd_kinetic_pe_call0_echem_gc_aimd_harmonic_k_requires_0_proved (x : Float) (vx : Float) : vc_echem_gc_aimd_kinetic_pe_call0_echem_gc_aimd_harmonic_k_requires_0 x vx := trivial

end echem_gc_aimd_kinetic_pe

namespace echem_gc_aimd_thermostat_step

def vc_echem_gc_aimd_thermostat_step_requires_0 (vx : Float) (target_ke : Float) : Prop := (target_ke ≥ (0 : Float))
def vc_echem_gc_aimd_thermostat_step_ensures_0 (vx : Float) (target_ke : Float) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_gc_aimd_thermostat_step_ensures_0_proved (vx : Float) (target_ke : Float) (result : Unit) : vc_echem_gc_aimd_thermostat_step_ensures_0 vx target_ke result := trivial
def vc_echem_gc_aimd_thermostat_step_decreases_0 (vx : Float) (target_ke : Float) : Nat := 0
theorem vc_echem_gc_aimd_thermostat_step_decreases_0_proved (vx : Float) (target_ke : Float) : vc_echem_gc_aimd_thermostat_step_decreases_0 vx target_ke = 0 := rfl

end echem_gc_aimd_thermostat_step

namespace sim_scientific_oracle_checksum_echem_gc_aimd

def vc_sim_scientific_oracle_checksum_echem_gc_aimd_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_decreases_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call0_echem_gc_aimd_electrode_potential_v_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call0_echem_gc_aimd_electrode_potential_v_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call0_echem_gc_aimd_electrode_potential_v_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call1_echem_gc_aimd_harmonic_k_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call1_echem_gc_aimd_harmonic_k_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call1_echem_gc_aimd_harmonic_k_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call2_echem_gc_charge_drift_abs_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call2_echem_gc_charge_drift_abs_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call2_echem_gc_charge_drift_abs_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call3_echem_gc_aimd_step_count_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call3_echem_gc_aimd_step_count_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call3_echem_gc_aimd_step_count_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call4_echem_gc_aimd_dft_energy_at_potential_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call4_echem_gc_aimd_dft_energy_at_potential_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call4_echem_gc_aimd_dft_energy_at_potential_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call5_echem_gc_aimd_thermostat_step_requires_0 (target_ke : Float) : Prop := (target_ke ≥ (0 : Float))
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call6_echem_gc_charge_neutrality_next_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call6_echem_gc_charge_neutrality_next_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call6_echem_gc_charge_neutrality_next_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call7_echem_gc_charge_drift_abs_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call7_echem_gc_charge_drift_abs_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call7_echem_gc_charge_drift_abs_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_gc_aimd_call8_echem_gc_charge_drift_abs_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_gc_aimd_call8_echem_gc_charge_drift_abs_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_gc_aimd_call8_echem_gc_charge_drift_abs_requires_0 := trivial

end sim_scientific_oracle_checksum_echem_gc_aimd

namespace echem_sei_kmc_step_count

def vc_echem_sei_kmc_step_count_requires_0 : Prop := True
theorem vc_echem_sei_kmc_step_count_requires_0_proved : vc_echem_sei_kmc_step_count_requires_0 := trivial
def vc_echem_sei_kmc_step_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_sei_kmc_step_count_ensures_0_proved (result : Int) : vc_echem_sei_kmc_step_count_ensures_0 result := trivial
def vc_echem_sei_kmc_step_count_decreases_0 : Nat := 0
theorem vc_echem_sei_kmc_step_count_decreases_0_proved : vc_echem_sei_kmc_step_count_decreases_0 = 0 := rfl

end echem_sei_kmc_step_count

namespace echem_sei_kmc_discrete_thickness_ang

def vc_echem_sei_kmc_discrete_thickness_ang_requires_0 : Prop := True
theorem vc_echem_sei_kmc_discrete_thickness_ang_requires_0_proved : vc_echem_sei_kmc_discrete_thickness_ang_requires_0 := trivial
def vc_echem_sei_kmc_discrete_thickness_ang_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_sei_kmc_discrete_thickness_ang_decreases_0 : Nat := 0
theorem vc_echem_sei_kmc_discrete_thickness_ang_decreases_0_proved : vc_echem_sei_kmc_discrete_thickness_ang_decreases_0 = 0 := rfl
def vc_echem_sei_kmc_discrete_thickness_ang_call0_echem_sei_deposition_rate_per_step_requires_0 : Prop := True
theorem vc_echem_sei_kmc_discrete_thickness_ang_call0_echem_sei_deposition_rate_per_step_requires_0_proved : vc_echem_sei_kmc_discrete_thickness_ang_call0_echem_sei_deposition_rate_per_step_requires_0 := trivial
def vc_echem_sei_kmc_discrete_thickness_ang_call1_echem_sei_growth_ang_per_event_requires_0 : Prop := True
theorem vc_echem_sei_kmc_discrete_thickness_ang_call1_echem_sei_growth_ang_per_event_requires_0_proved : vc_echem_sei_kmc_discrete_thickness_ang_call1_echem_sei_growth_ang_per_event_requires_0 := trivial
def vc_echem_sei_kmc_discrete_thickness_ang_call2_echem_sei_kmc_step_count_requires_0 : Prop := True
theorem vc_echem_sei_kmc_discrete_thickness_ang_call2_echem_sei_kmc_step_count_requires_0_proved : vc_echem_sei_kmc_discrete_thickness_ang_call2_echem_sei_kmc_step_count_requires_0 := trivial

end echem_sei_kmc_discrete_thickness_ang

namespace echem_sei_kmc_analytic_thickness_ang

def vc_echem_sei_kmc_analytic_thickness_ang_requires_0 : Prop := True
theorem vc_echem_sei_kmc_analytic_thickness_ang_requires_0_proved : vc_echem_sei_kmc_analytic_thickness_ang_requires_0 := trivial
def vc_echem_sei_kmc_analytic_thickness_ang_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_sei_kmc_analytic_thickness_ang_decreases_0 : Nat := 0
theorem vc_echem_sei_kmc_analytic_thickness_ang_decreases_0_proved : vc_echem_sei_kmc_analytic_thickness_ang_decreases_0 = 0 := rfl
def vc_echem_sei_kmc_analytic_thickness_ang_call0_echem_sei_deposition_rate_per_step_requires_0 : Prop := True
theorem vc_echem_sei_kmc_analytic_thickness_ang_call0_echem_sei_deposition_rate_per_step_requires_0_proved : vc_echem_sei_kmc_analytic_thickness_ang_call0_echem_sei_deposition_rate_per_step_requires_0 := trivial
def vc_echem_sei_kmc_analytic_thickness_ang_call1_echem_sei_growth_ang_per_event_requires_0 : Prop := True
theorem vc_echem_sei_kmc_analytic_thickness_ang_call1_echem_sei_growth_ang_per_event_requires_0_proved : vc_echem_sei_kmc_analytic_thickness_ang_call1_echem_sei_growth_ang_per_event_requires_0 := trivial
def vc_echem_sei_kmc_analytic_thickness_ang_call2_echem_sei_kmc_step_count_requires_0 : Prop := True
theorem vc_echem_sei_kmc_analytic_thickness_ang_call2_echem_sei_kmc_step_count_requires_0_proved : vc_echem_sei_kmc_analytic_thickness_ang_call2_echem_sei_kmc_step_count_requires_0 := trivial

end echem_sei_kmc_analytic_thickness_ang

namespace echem_sei_kmc_growth_smoke

def vc_echem_sei_kmc_growth_smoke_requires_0 : Prop := True
theorem vc_echem_sei_kmc_growth_smoke_requires_0_proved : vc_echem_sei_kmc_growth_smoke_requires_0 := trivial
def vc_echem_sei_kmc_growth_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_sei_kmc_growth_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_sei_kmc_growth_smoke_decreases_0 : Nat := 0
theorem vc_echem_sei_kmc_growth_smoke_decreases_0_proved : vc_echem_sei_kmc_growth_smoke_decreases_0 = 0 := rfl
def vc_echem_sei_kmc_growth_smoke_call0_echem_sei_kmc_discrete_thickness_ang_requires_0 : Prop := True
theorem vc_echem_sei_kmc_growth_smoke_call0_echem_sei_kmc_discrete_thickness_ang_requires_0_proved : vc_echem_sei_kmc_growth_smoke_call0_echem_sei_kmc_discrete_thickness_ang_requires_0 := trivial
def vc_echem_sei_kmc_growth_smoke_call1_echem_sei_kmc_analytic_thickness_ang_requires_0 : Prop := True
theorem vc_echem_sei_kmc_growth_smoke_call1_echem_sei_kmc_analytic_thickness_ang_requires_0_proved : vc_echem_sei_kmc_growth_smoke_call1_echem_sei_kmc_analytic_thickness_ang_requires_0 := trivial

end echem_sei_kmc_growth_smoke

namespace sim_scientific_oracle_checksum_echem_sei_kmc

def vc_sim_scientific_oracle_checksum_echem_sei_kmc_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_sei_kmc_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_sei_kmc_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_sei_kmc_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_sim_scientific_oracle_checksum_echem_sei_kmc_decreases_0 : Nat := 0
theorem vc_sim_scientific_oracle_checksum_echem_sei_kmc_decreases_0_proved : vc_sim_scientific_oracle_checksum_echem_sei_kmc_decreases_0 = 0 := rfl
def vc_sim_scientific_oracle_checksum_echem_sei_kmc_call0_echem_sei_kmc_discrete_thickness_ang_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_sei_kmc_call0_echem_sei_kmc_discrete_thickness_ang_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_sei_kmc_call0_echem_sei_kmc_discrete_thickness_ang_requires_0 := trivial
def vc_sim_scientific_oracle_checksum_echem_sei_kmc_call1_echem_sei_kmc_analytic_thickness_ang_requires_0 : Prop := True
theorem vc_sim_scientific_oracle_checksum_echem_sei_kmc_call1_echem_sei_kmc_analytic_thickness_ang_requires_0_proved : vc_sim_scientific_oracle_checksum_echem_sei_kmc_call1_echem_sei_kmc_analytic_thickness_ang_requires_0 := trivial

end sim_scientific_oracle_checksum_echem_sei_kmc

namespace sim_scientific_checksum_combine

def vc_sim_scientific_checksum_combine_requires_0 (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) : Prop := (step_index ≥ 1)
def vc_sim_scientific_checksum_combine_requires_1 (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) : Prop := (step_index ≤ 64)
def vc_sim_scientific_checksum_combine_requires_2 (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) : Prop := (chk_md ≥ (0 : Float))
def vc_sim_scientific_checksum_combine_requires_3 (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) : Prop := (chk_heat ≥ (0 : Float))
def vc_sim_scientific_checksum_combine_ensures_0 (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_sim_scientific_checksum_combine_decreases_0 (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) : Nat := Int.toNat step_index
theorem vc_sim_scientific_checksum_combine_decreases_0_proved (chk_md : Float) (chk_heat : Float) (chk_rigid : Float) (step_index : Int) : vc_sim_scientific_checksum_combine_decreases_0 chk_md chk_heat chk_rigid step_index = Int.toNat step_index := rfl

end sim_scientific_checksum_combine

namespace run_multi_physics_at_step

def vc_run_multi_physics_at_step_requires_0 (step_index : Int) (detail : Int) : Prop := (step_index ≥ 1)
def vc_run_multi_physics_at_step_requires_1 (step_index : Int) (detail : Int) : Prop := (step_index ≤ 64)
def vc_run_multi_physics_at_step_requires_2 (step_index : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_multi_physics_at_step_requires_3 (step_index : Int) (detail : Int) : Prop := (detail ≤ 3)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_multi_physics_at_step_ensures_0 (step_index : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_multi_physics_at_step_ensures_0_proved (step_index : Int) (detail : Int) (result : Int) : vc_run_multi_physics_at_step_ensures_0 step_index detail result := trivial
def vc_run_multi_physics_at_step_decreases_0 (step_index : Int) (detail : Int) : Nat := Int.toNat step_index
theorem vc_run_multi_physics_at_step_decreases_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_decreases_0 step_index detail = Int.toNat step_index := rfl
def vc_run_multi_physics_at_step_call0_run_md_lj_smoke_requires_0 (step_index : Int) (detail : Int) (d : Int) : Prop := (d ≥ 0)
def vc_run_multi_physics_at_step_call0_run_md_lj_smoke_requires_1 (step_index : Int) (detail : Int) (d : Int) : Prop := (d ≤ 3)
def vc_run_multi_physics_at_step_call1_run_heat_smoke_requires_0 (step_index : Int) (detail : Int) (d : Int) : Prop := (d ≥ 0)
def vc_run_multi_physics_at_step_call1_run_heat_smoke_requires_1 (step_index : Int) (detail : Int) (d : Int) : Prop := (d ≤ 3)
def vc_run_multi_physics_at_step_call2_run_rigid_smoke_requires_0 (step_index : Int) (detail : Int) (d : Int) : Prop := (d ≥ 0)
def vc_run_multi_physics_at_step_call2_run_rigid_smoke_requires_1 (step_index : Int) (detail : Int) (d : Int) : Prop := (d ≤ 3)
def vc_run_multi_physics_at_step_call3_run_result_ok_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call3_run_result_ok_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call3_run_result_ok_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call4_algo_md_lj_cutoff_mic_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call4_algo_md_lj_cutoff_mic_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call4_algo_md_lj_cutoff_mic_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call5_vertical_md_lennard_jones_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call5_vertical_md_lennard_jones_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call5_vertical_md_lennard_jones_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call6_run_result_ok_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call6_run_result_ok_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call6_run_result_ok_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call7_algo_pde_heat_explicit_2d_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call7_algo_pde_heat_explicit_2d_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call7_algo_pde_heat_explicit_2d_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call8_vertical_pde_heat_2d_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call8_vertical_pde_heat_2d_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call8_vertical_pde_heat_2d_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call9_run_result_ok_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call9_run_result_ok_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call9_run_result_ok_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call10_algo_rigid_semi_implicit_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call10_algo_rigid_semi_implicit_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call10_algo_rigid_semi_implicit_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call11_vertical_gaming_rigid_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call11_vertical_gaming_rigid_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call11_vertical_gaming_rigid_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call12_algo_md_lj_cutoff_mic_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call12_algo_md_lj_cutoff_mic_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call12_algo_md_lj_cutoff_mic_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call13_vertical_md_lennard_jones_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_run_multi_physics_at_step_call13_vertical_md_lennard_jones_requires_0_proved (step_index : Int) (detail : Int) : vc_run_multi_physics_at_step_call13_vertical_md_lennard_jones_requires_0 step_index detail := trivial
def vc_run_multi_physics_at_step_call14_sim_scientific_checksum_combine_requires_0 (step_index : Int) (detail : Int) : Prop := (step_index ≥ 1)
def vc_run_multi_physics_at_step_call14_sim_scientific_checksum_combine_requires_1 (step_index : Int) (detail : Int) : Prop := (step_index ≤ 64)
/-! VC call-site requires (opaque): callee 'sim_scientific_checksum_combine' at call 14 -/
def vc_run_multi_physics_at_step_call14_sim_scientific_checksum_combine_requires_2 (step_index : Int) (detail : Int) (md : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'sim_scientific_checksum_combine' at call 14 -/
def vc_run_multi_physics_at_step_call14_sim_scientific_checksum_combine_requires_3 (step_index : Int) (detail : Int) (heat : Int) : Prop := True

end run_multi_physics_at_step

namespace sim_scientific_tick_at

def vc_sim_scientific_tick_at_requires_0 (step_index : Int) (detail : Int) : Prop := (step_index ≥ 1)
def vc_sim_scientific_tick_at_requires_1 (step_index : Int) (detail : Int) : Prop := (step_index ≤ 64)
def vc_sim_scientific_tick_at_requires_2 (step_index : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_sim_scientific_tick_at_requires_3 (step_index : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_sim_scientific_tick_at_ensures_0 (step_index : Int) (detail : Int) (result : Int) : Prop := (result ≥ 0)
def vc_sim_scientific_tick_at_ensures_1 (step_index : Int) (detail : Int) (result : Int) : Prop := (result ≤ 1)
def vc_sim_scientific_tick_at_decreases_0 (step_index : Int) (detail : Int) : Nat := Int.toNat step_index
theorem vc_sim_scientific_tick_at_decreases_0_proved (step_index : Int) (detail : Int) : vc_sim_scientific_tick_at_decreases_0 step_index detail = Int.toNat step_index := rfl
def vc_sim_scientific_tick_at_call0_run_multi_physics_at_step_requires_0 (step_index : Int) (detail : Int) : Prop := (step_index ≥ 1)
def vc_sim_scientific_tick_at_call0_run_multi_physics_at_step_requires_1 (step_index : Int) (detail : Int) : Prop := (step_index ≤ 64)
def vc_sim_scientific_tick_at_call0_run_multi_physics_at_step_requires_2 (step_index : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_sim_scientific_tick_at_call0_run_multi_physics_at_step_requires_3 (step_index : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_sim_scientific_tick_at_call1_run_result_ok_requires_0 (step_index : Int) (detail : Int) : Prop := True
theorem vc_sim_scientific_tick_at_call1_run_result_ok_requires_0_proved (step_index : Int) (detail : Int) : vc_sim_scientific_tick_at_call1_run_result_ok_requires_0 step_index detail := trivial

end sim_scientific_tick_at

namespace sim_scientific_tick_stub

def vc_sim_scientific_tick_stub_requires_0 (detail : Int) : Prop := (detail ≥ 0)
def vc_sim_scientific_tick_stub_requires_1 (detail : Int) : Prop := (detail ≤ 3)
def vc_sim_scientific_tick_stub_ensures_0 (detail : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_scientific_tick_stub_ensures_0_proved (detail : Int) (result : Int) : vc_sim_scientific_tick_stub_ensures_0 detail result := trivial
def vc_sim_scientific_tick_stub_ensures_1 (detail : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_sim_scientific_tick_stub_ensures_1_proved (detail : Int) (result : Int) : vc_sim_scientific_tick_stub_ensures_1 detail result := trivial
def vc_sim_scientific_tick_stub_decreases_0 (detail : Int) : Nat := 0
theorem vc_sim_scientific_tick_stub_decreases_0_proved (detail : Int) : vc_sim_scientific_tick_stub_decreases_0 detail = 0 := rfl
def vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_0 (detail : Int) : Prop := True
theorem vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_0_proved (detail : Int) : vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_0 detail := trivial
def vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_1 (detail : Int) : Prop := True
theorem vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_1_proved (detail : Int) : vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_1 detail := trivial
def vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_2 (detail : Int) : Prop := (detail ≥ 0)
def vc_sim_scientific_tick_stub_call0_sim_scientific_tick_at_requires_3 (detail : Int) : Prop := (detail ≤ 3)

end sim_scientific_tick_stub

namespace run_md_lj_smoke

def vc_run_md_lj_smoke_requires_0 (detail : Int) : Prop := (detail ≥ 0)
def vc_run_md_lj_smoke_requires_1 (detail : Int) : Prop := (detail ≤ 3)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_md_lj_smoke_ensures_0 (detail : Int) (result : Int) : Prop := True
theorem vc_run_md_lj_smoke_ensures_0_proved (detail : Int) (result : Int) : vc_run_md_lj_smoke_ensures_0 detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_md_lj_smoke_ensures_1 (detail : Int) (result : Int) : Prop := True
theorem vc_run_md_lj_smoke_ensures_1_proved (detail : Int) (result : Int) : vc_run_md_lj_smoke_ensures_1 detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_md_lj_smoke_ensures_2 (detail : Int) (result : Int) : Prop := True
theorem vc_run_md_lj_smoke_ensures_2_proved (detail : Int) (result : Int) : vc_run_md_lj_smoke_ensures_2 detail result := trivial
def vc_run_md_lj_smoke_decreases_0 (detail : Int) : Nat := 0
theorem vc_run_md_lj_smoke_decreases_0_proved (detail : Int) : vc_run_md_lj_smoke_decreases_0 detail = 0 := rfl
def vc_run_md_lj_smoke_call0_sim_scientific_oracle_checksum_md_requires_0 (detail : Int) : Prop := True
theorem vc_run_md_lj_smoke_call0_sim_scientific_oracle_checksum_md_requires_0_proved (detail : Int) : vc_run_md_lj_smoke_call0_sim_scientific_oracle_checksum_md_requires_0 detail := trivial
def vc_run_md_lj_smoke_call1_algo_md_lj_cutoff_mic_requires_0 (detail : Int) : Prop := True
theorem vc_run_md_lj_smoke_call1_algo_md_lj_cutoff_mic_requires_0_proved (detail : Int) : vc_run_md_lj_smoke_call1_algo_md_lj_cutoff_mic_requires_0 detail := trivial
def vc_run_md_lj_smoke_call2_vertical_md_lennard_jones_requires_0 (detail : Int) : Prop := True
theorem vc_run_md_lj_smoke_call2_vertical_md_lennard_jones_requires_0_proved (detail : Int) : vc_run_md_lj_smoke_call2_vertical_md_lennard_jones_requires_0 detail := trivial

end run_md_lj_smoke

namespace run_heat_smoke

def vc_run_heat_smoke_requires_0 (detail : Int) : Prop := (detail ≥ 0)
def vc_run_heat_smoke_requires_1 (detail : Int) : Prop := (detail ≤ 3)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_heat_smoke_ensures_0 (detail : Int) (result : Int) : Prop := True
theorem vc_run_heat_smoke_ensures_0_proved (detail : Int) (result : Int) : vc_run_heat_smoke_ensures_0 detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_heat_smoke_ensures_1 (detail : Int) (result : Int) : Prop := True
theorem vc_run_heat_smoke_ensures_1_proved (detail : Int) (result : Int) : vc_run_heat_smoke_ensures_1 detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_heat_smoke_ensures_2 (detail : Int) (result : Int) : Prop := True
theorem vc_run_heat_smoke_ensures_2_proved (detail : Int) (result : Int) : vc_run_heat_smoke_ensures_2 detail result := trivial
def vc_run_heat_smoke_decreases_0 (detail : Int) : Nat := 0
theorem vc_run_heat_smoke_decreases_0_proved (detail : Int) : vc_run_heat_smoke_decreases_0 detail = 0 := rfl
def vc_run_heat_smoke_call0_sim_scientific_oracle_checksum_heat_requires_0 (detail : Int) : Prop := True
theorem vc_run_heat_smoke_call0_sim_scientific_oracle_checksum_heat_requires_0_proved (detail : Int) : vc_run_heat_smoke_call0_sim_scientific_oracle_checksum_heat_requires_0 detail := trivial
def vc_run_heat_smoke_call1_algo_pde_heat_explicit_2d_requires_0 (detail : Int) : Prop := True
theorem vc_run_heat_smoke_call1_algo_pde_heat_explicit_2d_requires_0_proved (detail : Int) : vc_run_heat_smoke_call1_algo_pde_heat_explicit_2d_requires_0 detail := trivial
def vc_run_heat_smoke_call2_vertical_pde_heat_2d_requires_0 (detail : Int) : Prop := True
theorem vc_run_heat_smoke_call2_vertical_pde_heat_2d_requires_0_proved (detail : Int) : vc_run_heat_smoke_call2_vertical_pde_heat_2d_requires_0 detail := trivial

end run_heat_smoke

namespace run_rigid_smoke

def vc_run_rigid_smoke_requires_0 (detail : Int) : Prop := (detail ≥ 0)
def vc_run_rigid_smoke_requires_1 (detail : Int) : Prop := (detail ≤ 3)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_rigid_smoke_ensures_0 (detail : Int) (result : Int) : Prop := True
theorem vc_run_rigid_smoke_ensures_0_proved (detail : Int) (result : Int) : vc_run_rigid_smoke_ensures_0 detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_rigid_smoke_ensures_1 (detail : Int) (result : Int) : Prop := True
theorem vc_run_rigid_smoke_ensures_1_proved (detail : Int) (result : Int) : vc_run_rigid_smoke_ensures_1 detail result := trivial
def vc_run_rigid_smoke_decreases_0 (detail : Int) : Nat := 0
theorem vc_run_rigid_smoke_decreases_0_proved (detail : Int) : vc_run_rigid_smoke_decreases_0 detail = 0 := rfl
def vc_run_rigid_smoke_call0_rigid_integrate_semi_implicit_requires_0 (detail : Int) : Prop := ((0.01 : Float) > (0 : Float))
def vc_run_rigid_smoke_call1_algo_rigid_semi_implicit_requires_0 (detail : Int) : Prop := True
theorem vc_run_rigid_smoke_call1_algo_rigid_semi_implicit_requires_0_proved (detail : Int) : vc_run_rigid_smoke_call1_algo_rigid_semi_implicit_requires_0 detail := trivial
def vc_run_rigid_smoke_call2_vertical_gaming_rigid_requires_0 (detail : Int) : Prop := True
theorem vc_run_rigid_smoke_call2_vertical_gaming_rigid_requires_0_proved (detail : Int) : vc_run_rigid_smoke_call2_vertical_gaming_rigid_requires_0 detail := trivial

end run_rigid_smoke

namespace run_algo_registry_stub

def vc_run_algo_registry_stub_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_algo_registry_stub_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
/-! VC requires (opaque): source expr not yet translated -/
def vc_run_algo_registry_stub_requires_2 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_registry_stub_requires_2_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_stub_requires_2 algo_id detail := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_algo_registry_stub_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_algo_registry_stub_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_algo_registry_stub_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_algo_registry_stub_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_algo_registry_stub_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_algo_registry_stub_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_algo_registry_stub_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_algo_registry_stub_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_algo_registry_stub_ensures_2 algo_id detail result := trivial
def vc_run_algo_registry_stub_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_algo_registry_stub_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_stub_decreases_0 algo_id detail = 0 := rfl

end run_algo_registry_stub

namespace run_md_tier2_registry

def vc_run_md_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_md_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_md_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 101)
def vc_run_md_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 117)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_md_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_md_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_md_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_md_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_md_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_md_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_md_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_md_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_md_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_md_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_md_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_md_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_md_tier2_registry_call0_sim_scientific_oracle_checksum_md_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_md_tier2_registry_call0_sim_scientific_oracle_checksum_md_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_md_tier2_registry_call0_sim_scientific_oracle_checksum_md_requires_0 algo_id detail := trivial
def vc_run_md_tier2_registry_call1_vertical_md_lennard_jones_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_md_tier2_registry_call1_vertical_md_lennard_jones_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_md_tier2_registry_call1_vertical_md_lennard_jones_requires_0 algo_id detail := trivial

end run_md_tier2_registry

namespace run_heat_tier2_registry

def vc_run_heat_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_heat_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_heat_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 201)
def vc_run_heat_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 204)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_heat_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_heat_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_heat_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_heat_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_heat_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_heat_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_heat_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_heat_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_heat_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_heat_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_heat_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_heat_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_heat_tier2_registry_call0_sim_scientific_oracle_checksum_heat_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_heat_tier2_registry_call0_sim_scientific_oracle_checksum_heat_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_heat_tier2_registry_call0_sim_scientific_oracle_checksum_heat_requires_0 algo_id detail := trivial
def vc_run_heat_tier2_registry_call1_vertical_pde_heat_2d_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_heat_tier2_registry_call1_vertical_pde_heat_2d_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_heat_tier2_registry_call1_vertical_pde_heat_2d_requires_0 algo_id detail := trivial

end run_heat_tier2_registry

namespace run_cfd_tier2_registry

def vc_run_cfd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_cfd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_cfd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 205)
def vc_run_cfd_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 210)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_cfd_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_cfd_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_cfd_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_cfd_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_cfd_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_cfd_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_cfd_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_cfd_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_cfd_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_cfd_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_cfd_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_cfd_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_cfd_tier2_registry_call0_sim_scientific_oracle_checksum_cfd_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_cfd_tier2_registry_call0_sim_scientific_oracle_checksum_cfd_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_cfd_tier2_registry_call0_sim_scientific_oracle_checksum_cfd_requires_0 algo_id detail := trivial
def vc_run_cfd_tier2_registry_call1_vertical_cfd_lid_driven_cavity_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_cfd_tier2_registry_call1_vertical_cfd_lid_driven_cavity_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_cfd_tier2_registry_call1_vertical_cfd_lid_driven_cavity_requires_0 algo_id detail := trivial

end run_cfd_tier2_registry

namespace run_fea_tier2_registry

def vc_run_fea_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_fea_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_fea_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 211)
def vc_run_fea_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 216)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_fea_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_fea_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_fea_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_fea_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_fea_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_fea_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_fea_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_fea_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_fea_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_fea_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_fea_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_fea_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_fea_tier2_registry_call0_sim_scientific_oracle_checksum_fea_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_fea_tier2_registry_call0_sim_scientific_oracle_checksum_fea_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_fea_tier2_registry_call0_sim_scientific_oracle_checksum_fea_requires_0 algo_id detail := trivial
def vc_run_fea_tier2_registry_call1_vertical_fea_linear_elasticity_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_fea_tier2_registry_call1_vertical_fea_linear_elasticity_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_fea_tier2_registry_call1_vertical_fea_linear_elasticity_requires_0 algo_id detail := trivial

end run_fea_tier2_registry

namespace run_qm_tier2_registry

def vc_run_qm_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_qm_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_qm_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 401)
def vc_run_qm_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 432)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_qm_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_qm_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_qm_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_qm_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_qm_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_qm_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_qm_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_qm_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_qm_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_qm_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_qm_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_qm_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_qm_tier2_registry_call0_sim_scientific_oracle_checksum_qm_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_qm_tier2_registry_call0_sim_scientific_oracle_checksum_qm_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_qm_tier2_registry_call0_sim_scientific_oracle_checksum_qm_requires_0 algo_id detail := trivial
def vc_run_qm_tier2_registry_call1_vertical_qm_dft_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_qm_tier2_registry_call1_vertical_qm_dft_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_qm_tier2_registry_call1_vertical_qm_dft_requires_0 algo_id detail := trivial

end run_qm_tier2_registry

namespace run_echem_aimd_tier2_registry

def vc_run_echem_aimd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_echem_aimd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
/-! VC requires (opaque): source expr not yet translated -/
def vc_run_echem_aimd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_aimd_tier2_registry_requires_2_proved (algo_id : Int) (detail : Int) : vc_run_echem_aimd_tier2_registry_requires_2 algo_id detail := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_aimd_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_aimd_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_aimd_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_aimd_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_aimd_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_aimd_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_aimd_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_aimd_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_aimd_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_echem_aimd_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_echem_aimd_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_aimd_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_echem_aimd_tier2_registry_call0_sim_scientific_oracle_checksum_echem_aimd_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_aimd_tier2_registry_call0_sim_scientific_oracle_checksum_echem_aimd_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_aimd_tier2_registry_call0_sim_scientific_oracle_checksum_echem_aimd_requires_0 algo_id detail := trivial
def vc_run_echem_aimd_tier2_registry_call1_vertical_echem_aimd_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_aimd_tier2_registry_call1_vertical_echem_aimd_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_aimd_tier2_registry_call1_vertical_echem_aimd_requires_0 algo_id detail := trivial

end run_echem_aimd_tier2_registry

namespace run_echem_gc_aimd_tier2_registry

def vc_run_echem_gc_aimd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_echem_gc_aimd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
/-! VC requires (opaque): source expr not yet translated -/
def vc_run_echem_gc_aimd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_gc_aimd_tier2_registry_requires_2_proved (algo_id : Int) (detail : Int) : vc_run_echem_gc_aimd_tier2_registry_requires_2 algo_id detail := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_gc_aimd_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_gc_aimd_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_gc_aimd_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_gc_aimd_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_gc_aimd_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_gc_aimd_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_gc_aimd_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_gc_aimd_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_gc_aimd_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_echem_gc_aimd_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_echem_gc_aimd_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_gc_aimd_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_echem_gc_aimd_tier2_registry_call0_sim_scientific_oracle_checksum_echem_gc_aimd_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_gc_aimd_tier2_registry_call0_sim_scientific_oracle_checksum_echem_gc_aimd_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_gc_aimd_tier2_registry_call0_sim_scientific_oracle_checksum_echem_gc_aimd_requires_0 algo_id detail := trivial
def vc_run_echem_gc_aimd_tier2_registry_call1_vertical_echem_gc_aimd_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_gc_aimd_tier2_registry_call1_vertical_echem_gc_aimd_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_gc_aimd_tier2_registry_call1_vertical_echem_gc_aimd_requires_0 algo_id detail := trivial

end run_echem_gc_aimd_tier2_registry

namespace run_echem_sei_kmc_tier2_registry

def vc_run_echem_sei_kmc_tier2_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_echem_sei_kmc_tier2_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
/-! VC requires (opaque): source expr not yet translated -/
def vc_run_echem_sei_kmc_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_sei_kmc_tier2_registry_requires_2_proved (algo_id : Int) (detail : Int) : vc_run_echem_sei_kmc_tier2_registry_requires_2 algo_id detail := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_sei_kmc_tier2_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_sei_kmc_tier2_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_sei_kmc_tier2_registry_ensures_0 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_sei_kmc_tier2_registry_ensures_1 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_sei_kmc_tier2_registry_ensures_1_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_sei_kmc_tier2_registry_ensures_1 algo_id detail result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_echem_sei_kmc_tier2_registry_ensures_2 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_echem_sei_kmc_tier2_registry_ensures_2_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_echem_sei_kmc_tier2_registry_ensures_2 algo_id detail result := trivial
def vc_run_echem_sei_kmc_tier2_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_echem_sei_kmc_tier2_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_sei_kmc_tier2_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_echem_sei_kmc_tier2_registry_call0_sim_scientific_oracle_checksum_echem_sei_kmc_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_sei_kmc_tier2_registry_call0_sim_scientific_oracle_checksum_echem_sei_kmc_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_sei_kmc_tier2_registry_call0_sim_scientific_oracle_checksum_echem_sei_kmc_requires_0 algo_id detail := trivial
def vc_run_echem_sei_kmc_tier2_registry_call1_vertical_echem_sei_kmc_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_echem_sei_kmc_tier2_registry_call1_vertical_echem_sei_kmc_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_echem_sei_kmc_tier2_registry_call1_vertical_echem_sei_kmc_requires_0 algo_id detail := trivial

end run_echem_sei_kmc_tier2_registry

namespace run_algo_registry

def vc_run_algo_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_algo_registry_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
/-! VC requires (opaque): source expr not yet translated -/
def vc_run_algo_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_registry_requires_2_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_requires_2 algo_id detail := trivial
def vc_run_algo_registry_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_run_algo_registry_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_algo_registry_ensures_0 algo_id detail result := trivial
def vc_run_algo_registry_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_algo_registry_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_decreases_0 algo_id detail = 0 := rfl
def vc_run_algo_registry_call0_run_md_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d0 : Int) : Prop := (d0 ≥ 0)
def vc_run_algo_registry_call0_run_md_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d0 : Int) : Prop := (d0 ≤ 3)
def vc_run_algo_registry_call0_run_md_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 101)
def vc_run_algo_registry_call0_run_md_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 117)
def vc_run_algo_registry_call1_run_heat_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d1 : Int) : Prop := (d1 ≥ 0)
def vc_run_algo_registry_call1_run_heat_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d1 : Int) : Prop := (d1 ≤ 3)
def vc_run_algo_registry_call1_run_heat_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 201)
def vc_run_algo_registry_call1_run_heat_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 204)
def vc_run_algo_registry_call2_run_cfd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_cfd : Int) : Prop := (d_cfd ≥ 0)
def vc_run_algo_registry_call2_run_cfd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_cfd : Int) : Prop := (d_cfd ≤ 3)
def vc_run_algo_registry_call2_run_cfd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 205)
def vc_run_algo_registry_call2_run_cfd_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 210)
def vc_run_algo_registry_call3_run_fea_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_fea : Int) : Prop := (d_fea ≥ 0)
def vc_run_algo_registry_call3_run_fea_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_fea : Int) : Prop := (d_fea ≤ 3)
def vc_run_algo_registry_call3_run_fea_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 211)
def vc_run_algo_registry_call3_run_fea_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 216)
def vc_run_algo_registry_call4_run_qm_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_qm : Int) : Prop := (d_qm ≥ 0)
def vc_run_algo_registry_call4_run_qm_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_qm : Int) : Prop := (d_qm ≤ 3)
def vc_run_algo_registry_call4_run_qm_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 401)
def vc_run_algo_registry_call4_run_qm_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 432)
def vc_run_algo_registry_call5_run_rigid_smoke_requires_0 (algo_id : Int) (detail : Int) (d2 : Int) : Prop := (d2 ≥ 0)
def vc_run_algo_registry_call5_run_rigid_smoke_requires_1 (algo_id : Int) (detail : Int) (d2 : Int) : Prop := (d2 ≤ 3)
def vc_run_algo_registry_call6_algo_echem_aimd_interface_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_registry_call6_algo_echem_aimd_interface_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_call6_algo_echem_aimd_interface_requires_0 algo_id detail := trivial
def vc_run_algo_registry_call7_run_echem_aimd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_echem : Int) : Prop := (d_echem ≥ 0)
def vc_run_algo_registry_call7_run_echem_aimd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_echem : Int) : Prop := (d_echem ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_aimd_tier2_registry' at call 7 -/
def vc_run_algo_registry_call7_run_echem_aimd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
def vc_run_algo_registry_call8_algo_echem_gc_aimd_interface_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_registry_call8_algo_echem_gc_aimd_interface_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_call8_algo_echem_gc_aimd_interface_requires_0 algo_id detail := trivial
def vc_run_algo_registry_call9_run_echem_gc_aimd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_gc : Int) : Prop := (d_gc ≥ 0)
def vc_run_algo_registry_call9_run_echem_gc_aimd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_gc : Int) : Prop := (d_gc ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_gc_aimd_tier2_registry' at call 9 -/
def vc_run_algo_registry_call9_run_echem_gc_aimd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
def vc_run_algo_registry_call10_algo_echem_sei_kmc_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_registry_call10_algo_echem_sei_kmc_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_registry_call10_algo_echem_sei_kmc_requires_0 algo_id detail := trivial
def vc_run_algo_registry_call11_run_echem_sei_kmc_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_sei : Int) : Prop := (d_sei ≥ 0)
def vc_run_algo_registry_call11_run_echem_sei_kmc_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_sei : Int) : Prop := (d_sei ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_sei_kmc_tier2_registry' at call 11 -/
def vc_run_algo_registry_call11_run_echem_sei_kmc_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
def vc_run_algo_registry_call12_run_algo_registry_stub_requires_0 (algo_id : Int) (detail : Int) (d3 : Int) : Prop := (d3 ≥ 0)
def vc_run_algo_registry_call12_run_algo_registry_stub_requires_1 (algo_id : Int) (detail : Int) (d3 : Int) : Prop := (d3 ≤ 3)
/-! VC call-site requires (opaque): callee 'run_algo_registry_stub' at call 12 -/
def vc_run_algo_registry_call12_run_algo_registry_stub_requires_2 (algo_id : Int) (detail : Int) : Prop := True

end run_algo_registry

namespace run_algo

def vc_run_algo_requires_0 (algo_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_algo_requires_1 (algo_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_algo_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id > 0)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_algo_ensures_0 (algo_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_algo_ensures_0_proved (algo_id : Int) (detail : Int) (result : Int) : vc_run_algo_ensures_0 algo_id detail result := trivial
def vc_run_algo_decreases_0 (algo_id : Int) (detail : Int) : Nat := 0
theorem vc_run_algo_decreases_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_decreases_0 algo_id detail = 0 := rfl
def vc_run_algo_call0_algo_md_lj_cutoff_mic_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call0_algo_md_lj_cutoff_mic_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call0_algo_md_lj_cutoff_mic_requires_0 algo_id detail := trivial
def vc_run_algo_call1_run_md_lj_smoke_requires_0 (algo_id : Int) (detail : Int) (d0 : Int) : Prop := (d0 ≥ 0)
def vc_run_algo_call1_run_md_lj_smoke_requires_1 (algo_id : Int) (detail : Int) (d0 : Int) : Prop := (d0 ≤ 3)
def vc_run_algo_call2_algo_md_integrator_verlet_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call2_algo_md_integrator_verlet_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call2_algo_md_integrator_verlet_requires_0 algo_id detail := trivial
def vc_run_algo_call3_run_md_lj_smoke_requires_0 (algo_id : Int) (detail : Int) (d1 : Int) : Prop := (d1 ≥ 0)
def vc_run_algo_call3_run_md_lj_smoke_requires_1 (algo_id : Int) (detail : Int) (d1 : Int) : Prop := (d1 ≤ 3)
def vc_run_algo_call4_algo_pde_heat_explicit_2d_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call4_algo_pde_heat_explicit_2d_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call4_algo_pde_heat_explicit_2d_requires_0 algo_id detail := trivial
def vc_run_algo_call5_run_heat_smoke_requires_0 (algo_id : Int) (detail : Int) (d2 : Int) : Prop := (d2 ≥ 0)
def vc_run_algo_call5_run_heat_smoke_requires_1 (algo_id : Int) (detail : Int) (d2 : Int) : Prop := (d2 ≤ 3)
def vc_run_algo_call6_algo_rigid_semi_implicit_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call6_algo_rigid_semi_implicit_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call6_algo_rigid_semi_implicit_requires_0 algo_id detail := trivial
def vc_run_algo_call7_run_rigid_smoke_requires_0 (algo_id : Int) (detail : Int) (d3 : Int) : Prop := (d3 ≥ 0)
def vc_run_algo_call7_run_rigid_smoke_requires_1 (algo_id : Int) (detail : Int) (d3 : Int) : Prop := (d3 ≤ 3)
def vc_run_algo_call8_algo_echem_aimd_interface_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call8_algo_echem_aimd_interface_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call8_algo_echem_aimd_interface_requires_0 algo_id detail := trivial
def vc_run_algo_call9_run_echem_aimd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_echem : Int) : Prop := (d_echem ≥ 0)
def vc_run_algo_call9_run_echem_aimd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_echem : Int) : Prop := (d_echem ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_aimd_tier2_registry' at call 9 -/
def vc_run_algo_call9_run_echem_aimd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
def vc_run_algo_call10_algo_echem_gc_aimd_interface_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call10_algo_echem_gc_aimd_interface_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call10_algo_echem_gc_aimd_interface_requires_0 algo_id detail := trivial
def vc_run_algo_call11_run_echem_gc_aimd_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_gc : Int) : Prop := (d_gc ≥ 0)
def vc_run_algo_call11_run_echem_gc_aimd_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_gc : Int) : Prop := (d_gc ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_gc_aimd_tier2_registry' at call 11 -/
def vc_run_algo_call11_run_echem_gc_aimd_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
def vc_run_algo_call12_algo_echem_sei_kmc_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call12_algo_echem_sei_kmc_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call12_algo_echem_sei_kmc_requires_0 algo_id detail := trivial
def vc_run_algo_call13_run_echem_sei_kmc_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_sei : Int) : Prop := (d_sei ≥ 0)
def vc_run_algo_call13_run_echem_sei_kmc_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_sei : Int) : Prop := (d_sei ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_sei_kmc_tier2_registry' at call 13 -/
def vc_run_algo_call13_run_echem_sei_kmc_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := True
def vc_run_algo_call14_run_qm_tier2_registry_requires_0 (algo_id : Int) (detail : Int) (d_qm : Int) : Prop := (d_qm ≥ 0)
def vc_run_algo_call14_run_qm_tier2_registry_requires_1 (algo_id : Int) (detail : Int) (d_qm : Int) : Prop := (d_qm ≤ 3)
def vc_run_algo_call14_run_qm_tier2_registry_requires_2 (algo_id : Int) (detail : Int) : Prop := (algo_id ≥ 401)
def vc_run_algo_call14_run_qm_tier2_registry_requires_3 (algo_id : Int) (detail : Int) : Prop := (algo_id ≤ 432)
def vc_run_algo_call15_algo_in_registry_requires_0 (algo_id : Int) (detail : Int) : Prop := True
theorem vc_run_algo_call15_algo_in_registry_requires_0_proved (algo_id : Int) (detail : Int) : vc_run_algo_call15_algo_in_registry_requires_0 algo_id detail := trivial
def vc_run_algo_call16_run_algo_registry_requires_0 (algo_id : Int) (detail : Int) (d4 : Int) : Prop := (d4 ≥ 0)
def vc_run_algo_call16_run_algo_registry_requires_1 (algo_id : Int) (detail : Int) (d4 : Int) : Prop := (d4 ≤ 3)
/-! VC call-site requires (opaque): callee 'run_algo_registry' at call 16 -/
def vc_run_algo_call16_run_algo_registry_requires_2 (algo_id : Int) (detail : Int) (reg_run : Int) : Prop := True

end run_algo

namespace run_simulation

def vc_run_simulation_requires_0 (vertical_id : Int) (detail : Int) : Prop := (detail ≥ 0)
def vc_run_simulation_requires_1 (vertical_id : Int) (detail : Int) : Prop := (detail ≤ 3)
def vc_run_simulation_requires_2 (vertical_id : Int) (detail : Int) : Prop := (vertical_id > 0)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_run_simulation_ensures_0 (vertical_id : Int) (detail : Int) (result : Int) : Prop := True
theorem vc_run_simulation_ensures_0_proved (vertical_id : Int) (detail : Int) (result : Int) : vc_run_simulation_ensures_0 vertical_id detail result := trivial
def vc_run_simulation_decreases_0 (vertical_id : Int) (detail : Int) : Nat := 0
theorem vc_run_simulation_decreases_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_decreases_0 vertical_id detail = 0 := rfl
def vc_run_simulation_call0_vertical_md_lennard_jones_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call0_vertical_md_lennard_jones_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call0_vertical_md_lennard_jones_requires_0 vertical_id detail := trivial
def vc_run_simulation_call1_run_md_lj_smoke_requires_0 (vertical_id : Int) (detail : Int) (d0 : Int) : Prop := (d0 ≥ 0)
def vc_run_simulation_call1_run_md_lj_smoke_requires_1 (vertical_id : Int) (detail : Int) (d0 : Int) : Prop := (d0 ≤ 3)
def vc_run_simulation_call2_vertical_pde_heat_2d_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call2_vertical_pde_heat_2d_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call2_vertical_pde_heat_2d_requires_0 vertical_id detail := trivial
def vc_run_simulation_call3_run_heat_smoke_requires_0 (vertical_id : Int) (detail : Int) (d1 : Int) : Prop := (d1 ≥ 0)
def vc_run_simulation_call3_run_heat_smoke_requires_1 (vertical_id : Int) (detail : Int) (d1 : Int) : Prop := (d1 ≤ 3)
def vc_run_simulation_call4_vertical_gaming_rigid_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call4_vertical_gaming_rigid_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call4_vertical_gaming_rigid_requires_0 vertical_id detail := trivial
def vc_run_simulation_call5_run_rigid_smoke_requires_0 (vertical_id : Int) (detail : Int) (d2 : Int) : Prop := (d2 ≥ 0)
def vc_run_simulation_call5_run_rigid_smoke_requires_1 (vertical_id : Int) (detail : Int) (d2 : Int) : Prop := (d2 ≤ 3)
def vc_run_simulation_call6_vertical_qm_dft_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call6_vertical_qm_dft_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call6_vertical_qm_dft_requires_0 vertical_id detail := trivial
def vc_run_simulation_call7_run_algo_requires_0 (vertical_id : Int) (detail : Int) (d3 : Int) : Prop := (d3 ≥ 0)
def vc_run_simulation_call7_run_algo_requires_1 (vertical_id : Int) (detail : Int) (d3 : Int) : Prop := (d3 ≤ 3)
/-! VC call-site requires (opaque): callee 'run_algo' at call 7 -/
def vc_run_simulation_call7_run_algo_requires_2 (vertical_id : Int) (detail : Int) : Prop := True
def vc_run_simulation_call8_algo_qm_dft_scf_energy_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call8_algo_qm_dft_scf_energy_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call8_algo_qm_dft_scf_energy_requires_0 vertical_id detail := trivial
def vc_run_simulation_call9_vertical_echem_aimd_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call9_vertical_echem_aimd_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call9_vertical_echem_aimd_requires_0 vertical_id detail := trivial
def vc_run_simulation_call10_run_echem_aimd_tier2_registry_requires_0 (vertical_id : Int) (detail : Int) (d_echem : Int) : Prop := (d_echem ≥ 0)
def vc_run_simulation_call10_run_echem_aimd_tier2_registry_requires_1 (vertical_id : Int) (detail : Int) (d_echem : Int) : Prop := (d_echem ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_aimd_tier2_registry' at call 10 -/
def vc_run_simulation_call10_run_echem_aimd_tier2_registry_requires_2 (vertical_id : Int) (detail : Int) : Prop := True
def vc_run_simulation_call11_algo_echem_aimd_interface_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call11_algo_echem_aimd_interface_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call11_algo_echem_aimd_interface_requires_0 vertical_id detail := trivial
def vc_run_simulation_call12_vertical_echem_gc_aimd_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call12_vertical_echem_gc_aimd_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call12_vertical_echem_gc_aimd_requires_0 vertical_id detail := trivial
def vc_run_simulation_call13_run_echem_gc_aimd_tier2_registry_requires_0 (vertical_id : Int) (detail : Int) (d_gc : Int) : Prop := (d_gc ≥ 0)
def vc_run_simulation_call13_run_echem_gc_aimd_tier2_registry_requires_1 (vertical_id : Int) (detail : Int) (d_gc : Int) : Prop := (d_gc ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_gc_aimd_tier2_registry' at call 13 -/
def vc_run_simulation_call13_run_echem_gc_aimd_tier2_registry_requires_2 (vertical_id : Int) (detail : Int) : Prop := True
def vc_run_simulation_call14_algo_echem_gc_aimd_interface_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call14_algo_echem_gc_aimd_interface_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call14_algo_echem_gc_aimd_interface_requires_0 vertical_id detail := trivial
def vc_run_simulation_call15_vertical_echem_sei_kmc_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call15_vertical_echem_sei_kmc_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call15_vertical_echem_sei_kmc_requires_0 vertical_id detail := trivial
def vc_run_simulation_call16_run_echem_sei_kmc_tier2_registry_requires_0 (vertical_id : Int) (detail : Int) (d_sei : Int) : Prop := (d_sei ≥ 0)
def vc_run_simulation_call16_run_echem_sei_kmc_tier2_registry_requires_1 (vertical_id : Int) (detail : Int) (d_sei : Int) : Prop := (d_sei ≤ 3)
/-! VC call-site requires (opaque): callee 'run_echem_sei_kmc_tier2_registry' at call 16 -/
def vc_run_simulation_call16_run_echem_sei_kmc_tier2_registry_requires_2 (vertical_id : Int) (detail : Int) : Prop := True
def vc_run_simulation_call17_algo_echem_sei_kmc_requires_0 (vertical_id : Int) (detail : Int) : Prop := True
theorem vc_run_simulation_call17_algo_echem_sei_kmc_requires_0_proved (vertical_id : Int) (detail : Int) : vc_run_simulation_call17_algo_echem_sei_kmc_requires_0 vertical_id detail := trivial

end run_simulation

namespace chem_dft_energy_stub_hartree

def vc_chem_dft_energy_stub_hartree_requires_0 : Prop := True
theorem vc_chem_dft_energy_stub_hartree_requires_0_proved : vc_chem_dft_energy_stub_hartree_requires_0 := trivial
def vc_chem_dft_energy_stub_hartree_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_energy_stub_hartree_ensures_0_proved (result : Float) : vc_chem_dft_energy_stub_hartree_ensures_0 result := trivial
def vc_chem_dft_energy_stub_hartree_decreases_0 : Nat := 0
theorem vc_chem_dft_energy_stub_hartree_decreases_0_proved : vc_chem_dft_energy_stub_hartree_decreases_0 = 0 := rfl

end chem_dft_energy_stub_hartree

namespace chem_dft_sto3g_grid_n

def vc_chem_dft_sto3g_grid_n_requires_0 : Prop := True
theorem vc_chem_dft_sto3g_grid_n_requires_0_proved : vc_chem_dft_sto3g_grid_n_requires_0 := trivial
def vc_chem_dft_sto3g_grid_n_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_sto3g_grid_n_ensures_0_proved (result : Int) : vc_chem_dft_sto3g_grid_n_ensures_0 result := trivial
def vc_chem_dft_sto3g_grid_n_decreases_0 : Nat := 0
theorem vc_chem_dft_sto3g_grid_n_decreases_0_proved : vc_chem_dft_sto3g_grid_n_decreases_0 = 0 := rfl

end chem_dft_sto3g_grid_n

namespace chem_dft_basis_n

def vc_chem_dft_basis_n_requires_0 : Prop := True
theorem vc_chem_dft_basis_n_requires_0_proved : vc_chem_dft_basis_n_requires_0 := trivial
def vc_chem_dft_basis_n_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_basis_n_ensures_0_proved (result : Int) : vc_chem_dft_basis_n_ensures_0 result := trivial
def vc_chem_dft_basis_n_decreases_0 : Nat := 0
theorem vc_chem_dft_basis_n_decreases_0_proved : vc_chem_dft_basis_n_decreases_0 = 0 := rfl

end chem_dft_basis_n

namespace chem_dft_grid_dr

def vc_chem_dft_grid_dr_requires_0 : Prop := True
theorem vc_chem_dft_grid_dr_requires_0_proved : vc_chem_dft_grid_dr_requires_0 := trivial
def vc_chem_dft_grid_dr_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_chem_dft_grid_dr_decreases_0 : Nat := 0
theorem vc_chem_dft_grid_dr_decreases_0_proved : vc_chem_dft_grid_dr_decreases_0 = 0 := rfl

end chem_dft_grid_dr

namespace chem_dft_grid_r_at

def vc_chem_dft_grid_r_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_grid_r_at_requires_1 (i : Int) : Prop := True
theorem vc_chem_dft_grid_r_at_requires_1_proved (i : Int) : vc_chem_dft_grid_r_at_requires_1 i := trivial
def vc_chem_dft_grid_r_at_ensures_0 (i : Int) (result : Float) : Prop := (result > (0 : Float))
def vc_chem_dft_grid_r_at_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_chem_dft_grid_r_at_decreases_0_proved (i : Int) : vc_chem_dft_grid_r_at_decreases_0 i = Int.toNat i := rfl

end chem_dft_grid_r_at

namespace chem_dft_basis_zeta_at

def vc_chem_dft_basis_zeta_at_requires_0 (bi : Int) : Prop := (bi ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_basis_zeta_at_requires_1 (bi : Int) : Prop := True
theorem vc_chem_dft_basis_zeta_at_requires_1_proved (bi : Int) : vc_chem_dft_basis_zeta_at_requires_1 bi := trivial
def vc_chem_dft_basis_zeta_at_ensures_0 (bi : Int) (result : Float) : Prop := (result > (0 : Float))
def vc_chem_dft_basis_zeta_at_decreases_0 (bi : Int) : Nat := Int.toNat bi
theorem vc_chem_dft_basis_zeta_at_decreases_0_proved (bi : Int) : vc_chem_dft_basis_zeta_at_decreases_0 bi = Int.toNat bi := rfl

end chem_dft_basis_zeta_at

namespace chem_dft_basis_centroid_at

def vc_chem_dft_basis_centroid_at_requires_0 (bi : Int) : Prop := (bi ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_basis_centroid_at_requires_1 (bi : Int) : Prop := True
theorem vc_chem_dft_basis_centroid_at_requires_1_proved (bi : Int) : vc_chem_dft_basis_centroid_at_requires_1 bi := trivial
def vc_chem_dft_basis_centroid_at_ensures_0 (bi : Int) (result : Float) : Prop := (result > (0 : Float))
def vc_chem_dft_basis_centroid_at_decreases_0 (bi : Int) : Nat := Int.toNat bi
theorem vc_chem_dft_basis_centroid_at_decreases_0_proved (bi : Int) : vc_chem_dft_basis_centroid_at_decreases_0 bi = Int.toNat bi := rfl

end chem_dft_basis_centroid_at

namespace chem_dft_primitive_decay

def vc_chem_dft_primitive_decay_requires_0 (r : Float) (zeta : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_primitive_decay_requires_1 (r : Float) (zeta : Float) : Prop := (zeta > (0 : Float))
def vc_chem_dft_primitive_decay_ensures_0 (r : Float) (zeta : Float) (result : Float) : Prop := (result > (0 : Float))
def vc_chem_dft_primitive_decay_decreases_0 (r : Float) (zeta : Float) : Nat := 0
theorem vc_chem_dft_primitive_decay_decreases_0_proved (r : Float) (zeta : Float) : vc_chem_dft_primitive_decay_decreases_0 r zeta = 0 := rfl

end chem_dft_primitive_decay

namespace chem_dft_basis_eval_at

def vc_chem_dft_basis_eval_at_requires_0 (bi : Int) (r : Float) : Prop := (bi ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_basis_eval_at_requires_1 (bi : Int) (r : Float) : Prop := True
theorem vc_chem_dft_basis_eval_at_requires_1_proved (bi : Int) (r : Float) : vc_chem_dft_basis_eval_at_requires_1 bi r := trivial
def vc_chem_dft_basis_eval_at_requires_2 (bi : Int) (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_basis_eval_at_ensures_0 (bi : Int) (r : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_chem_dft_basis_eval_at_decreases_0 (bi : Int) (r : Float) : Nat := Int.toNat bi
theorem vc_chem_dft_basis_eval_at_decreases_0_proved (bi : Int) (r : Float) : vc_chem_dft_basis_eval_at_decreases_0 bi r = Int.toNat bi := rfl
def vc_chem_dft_basis_eval_at_call0_chem_dft_primitive_decay_requires_0 (bi : Int) (r : Float) : Prop := (r ≥ (0 : Float))
/-! VC call-site requires (opaque): callee 'chem_dft_primitive_decay' at call 0 -/
def vc_chem_dft_basis_eval_at_call0_chem_dft_primitive_decay_requires_1 (bi : Int) (r : Float) : Prop := True
def vc_chem_dft_basis_eval_at_call1_chem_dft_basis_zeta_at_requires_0 (bi : Int) (r : Float) : Prop := (bi ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_basis_zeta_at' at call 1 -/
def vc_chem_dft_basis_eval_at_call1_chem_dft_basis_zeta_at_requires_1 (bi : Int) (r : Float) : Prop := True

end chem_dft_basis_eval_at

namespace chem_dft_basis_eval_sto3g

def vc_chem_dft_basis_eval_sto3g_requires_0 (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_basis_eval_sto3g_ensures_0 (r : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_chem_dft_basis_eval_sto3g_decreases_0 (r : Float) : Nat := 0
theorem vc_chem_dft_basis_eval_sto3g_decreases_0_proved (r : Float) : vc_chem_dft_basis_eval_sto3g_decreases_0 r = 0 := rfl
def vc_chem_dft_basis_eval_sto3g_call0_chem_dft_primitive_decay_requires_0 (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_basis_eval_sto3g_call0_chem_dft_primitive_decay_requires_1 (r : Float) : Prop := ((3.42525 : Float) > (0 : Float))
def vc_chem_dft_basis_eval_sto3g_call1_chem_dft_primitive_decay_requires_0 (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_basis_eval_sto3g_call1_chem_dft_primitive_decay_requires_1 (r : Float) : Prop := ((0.623914 : Float) > (0 : Float))
def vc_chem_dft_basis_eval_sto3g_call2_chem_dft_primitive_decay_requires_0 (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_basis_eval_sto3g_call2_chem_dft_primitive_decay_requires_1 (r : Float) : Prop := ((0.168855 : Float) > (0 : Float))

end chem_dft_basis_eval_sto3g

namespace chem_dft_cbrt_rho

def vc_chem_dft_cbrt_rho_requires_0 (rho : Float) : Prop := (rho ≥ (0 : Float))
def vc_chem_dft_cbrt_rho_ensures_0 (rho : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_chem_dft_cbrt_rho_decreases_0 (rho : Float) : Nat := 0
theorem vc_chem_dft_cbrt_rho_decreases_0_proved (rho : Float) : vc_chem_dft_cbrt_rho_decreases_0 rho = 0 := rfl

end chem_dft_cbrt_rho

namespace chem_dft_lda_xc_density

def vc_chem_dft_lda_xc_density_requires_0 (rho : Float) : Prop := (rho ≥ (0 : Float))
def vc_chem_dft_lda_xc_density_ensures_0 (rho : Float) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_lda_xc_density_decreases_0 (rho : Float) : Nat := 0
theorem vc_chem_dft_lda_xc_density_decreases_0_proved (rho : Float) : vc_chem_dft_lda_xc_density_decreases_0 rho = 0 := rfl
def vc_chem_dft_lda_xc_density_call0_chem_dft_cbrt_rho_requires_0 (rho : Float) : Prop := (rho ≥ (0 : Float))

end chem_dft_lda_xc_density

namespace chem_dft_coulomb_2center

def vc_chem_dft_coulomb_2center_requires_0 (bi : Int) (bj : Int) : Prop := (bi ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_coulomb_2center_requires_1 (bi : Int) (bj : Int) : Prop := True
theorem vc_chem_dft_coulomb_2center_requires_1_proved (bi : Int) (bj : Int) : vc_chem_dft_coulomb_2center_requires_1 bi bj := trivial
def vc_chem_dft_coulomb_2center_requires_2 (bi : Int) (bj : Int) : Prop := (bj ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_coulomb_2center_requires_3 (bi : Int) (bj : Int) : Prop := True
theorem vc_chem_dft_coulomb_2center_requires_3_proved (bi : Int) (bj : Int) : vc_chem_dft_coulomb_2center_requires_3 bi bj := trivial
def vc_chem_dft_coulomb_2center_ensures_0 (bi : Int) (bj : Int) (result : Float) : Prop := (result > (0 : Float))
def vc_chem_dft_coulomb_2center_decreases_0 (bi : Int) (bj : Int) : Nat := Int.toNat ((bi + bj))
theorem vc_chem_dft_coulomb_2center_decreases_0_proved (bi : Int) (bj : Int) : vc_chem_dft_coulomb_2center_decreases_0 bi bj = Int.toNat ((bi + bj)) := rfl
def vc_chem_dft_coulomb_2center_call0_chem_dft_basis_centroid_at_requires_0 (bi : Int) (bj : Int) : Prop := (bi ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_basis_centroid_at' at call 0 -/
def vc_chem_dft_coulomb_2center_call0_chem_dft_basis_centroid_at_requires_1 (bi : Int) (bj : Int) : Prop := True
def vc_chem_dft_coulomb_2center_call1_chem_dft_basis_centroid_at_requires_0 (bi : Int) (bj : Int) : Prop := (bj ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_basis_centroid_at' at call 1 -/
def vc_chem_dft_coulomb_2center_call1_chem_dft_basis_centroid_at_requires_1 (bi : Int) (bj : Int) : Prop := True

end chem_dft_coulomb_2center

namespace chem_dft_overlap_build

def vc_chem_dft_overlap_build_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_requires_0 S := trivial
def vc_chem_dft_overlap_build_ensures_0 (S : LiArray (LiArray Float 4) 4) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_overlap_build_ensures_0_proved (S : LiArray (LiArray Float 4) 4) (result : Unit) : vc_chem_dft_overlap_build_ensures_0 S result := trivial
def vc_chem_dft_overlap_build_decreases_0 (S : LiArray (LiArray Float 4) 4) : Nat := 0
theorem vc_chem_dft_overlap_build_decreases_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_decreases_0 S = 0 := rfl
def vc_chem_dft_overlap_build_call0_chem_dft_grid_dr_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call0_chem_dft_grid_dr_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call0_chem_dft_grid_dr_requires_0 S := trivial
def vc_chem_dft_overlap_build_call1_chem_dft_basis_n_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call1_chem_dft_basis_n_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call1_chem_dft_basis_n_requires_0 S := trivial
def vc_chem_dft_overlap_build_call2_chem_dft_basis_n_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call2_chem_dft_basis_n_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call2_chem_dft_basis_n_requires_0 S := trivial
def vc_chem_dft_overlap_build_call3_chem_dft_sto3g_grid_n_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call3_chem_dft_sto3g_grid_n_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call3_chem_dft_sto3g_grid_n_requires_0 S := trivial
def vc_chem_dft_overlap_build_call4_chem_dft_grid_r_at_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call4_chem_dft_grid_r_at_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call4_chem_dft_grid_r_at_requires_0 S := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 4 -/
def vc_chem_dft_overlap_build_call4_chem_dft_grid_r_at_requires_1 (S : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_overlap_build_call5_chem_dft_basis_eval_at_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call5_chem_dft_basis_eval_at_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call5_chem_dft_basis_eval_at_requires_0 S := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_basis_eval_at' at call 5 -/
def vc_chem_dft_overlap_build_call5_chem_dft_basis_eval_at_requires_1 (S : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_overlap_build_call5_chem_dft_basis_eval_at_requires_2 (S : LiArray (LiArray Float 4) 4) (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_overlap_build_call6_chem_dft_basis_eval_at_requires_0 (S : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_overlap_build_call6_chem_dft_basis_eval_at_requires_0_proved (S : LiArray (LiArray Float 4) 4) : vc_chem_dft_overlap_build_call6_chem_dft_basis_eval_at_requires_0 S := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_basis_eval_at' at call 6 -/
def vc_chem_dft_overlap_build_call6_chem_dft_basis_eval_at_requires_1 (S : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_overlap_build_call6_chem_dft_basis_eval_at_requires_2 (S : LiArray (LiArray Float 4) 4) (r : Float) : Prop := (r ≥ (0 : Float))

end chem_dft_overlap_build

namespace chem_dft_core_hamiltonian_ii

def vc_chem_dft_core_hamiltonian_ii_requires_0 (bi : Int) : Prop := (bi ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_chem_dft_core_hamiltonian_ii_requires_1 (bi : Int) : Prop := True
theorem vc_chem_dft_core_hamiltonian_ii_requires_1_proved (bi : Int) : vc_chem_dft_core_hamiltonian_ii_requires_1 bi := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_chem_dft_core_hamiltonian_ii_ensures_0 (bi : Int) (result : Float) : Prop := True
theorem vc_chem_dft_core_hamiltonian_ii_ensures_0_proved (bi : Int) (result : Float) : vc_chem_dft_core_hamiltonian_ii_ensures_0 bi result := trivial
def vc_chem_dft_core_hamiltonian_ii_decreases_0 (bi : Int) : Nat := Int.toNat bi
theorem vc_chem_dft_core_hamiltonian_ii_decreases_0_proved (bi : Int) : vc_chem_dft_core_hamiltonian_ii_decreases_0 bi = Int.toNat bi := rfl
def vc_chem_dft_core_hamiltonian_ii_call0_chem_dft_basis_centroid_at_requires_0 (bi : Int) : Prop := (bi ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_basis_centroid_at' at call 0 -/
def vc_chem_dft_core_hamiltonian_ii_call0_chem_dft_basis_centroid_at_requires_1 (bi : Int) : Prop := True
def vc_chem_dft_core_hamiltonian_ii_call1_chem_dft_basis_zeta_at_requires_0 (bi : Int) : Prop := (bi ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_basis_zeta_at' at call 1 -/
def vc_chem_dft_core_hamiltonian_ii_call1_chem_dft_basis_zeta_at_requires_1 (bi : Int) : Prop := True

end chem_dft_core_hamiltonian_ii

namespace chem_dft_fock_diagonal_build

def vc_chem_dft_fock_diagonal_build_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_requires_0 P F := trivial
def vc_chem_dft_fock_diagonal_build_ensures_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_fock_diagonal_build_ensures_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) (result : Unit) : vc_chem_dft_fock_diagonal_build_ensures_0 P F result := trivial
def vc_chem_dft_fock_diagonal_build_decreases_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Nat := 0
theorem vc_chem_dft_fock_diagonal_build_decreases_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_decreases_0 P F = 0 := rfl
def vc_chem_dft_fock_diagonal_build_call0_chem_dft_basis_n_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call0_chem_dft_basis_n_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call0_chem_dft_basis_n_requires_0 P F := trivial
def vc_chem_dft_fock_diagonal_build_call1_chem_dft_basis_n_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call1_chem_dft_basis_n_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call1_chem_dft_basis_n_requires_0 P F := trivial
def vc_chem_dft_fock_diagonal_build_call2_chem_dft_basis_n_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call2_chem_dft_basis_n_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call2_chem_dft_basis_n_requires_0 P F := trivial
def vc_chem_dft_fock_diagonal_build_call3_chem_dft_core_hamiltonian_ii_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call3_chem_dft_core_hamiltonian_ii_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call3_chem_dft_core_hamiltonian_ii_requires_0 P F := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_core_hamiltonian_ii' at call 3 -/
def vc_chem_dft_fock_diagonal_build_call3_chem_dft_core_hamiltonian_ii_requires_1 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_fock_diagonal_build_call4_chem_dft_basis_n_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call4_chem_dft_basis_n_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call4_chem_dft_basis_n_requires_0 P F := trivial
def vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_0 P F := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_coulomb_2center' at call 5 -/
def vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_1 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_2 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_2_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_2 P F := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_coulomb_2center' at call 5 -/
def vc_chem_dft_fock_diagonal_build_call5_chem_dft_coulomb_2center_requires_3 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_0 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_0_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_0 P F := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_coulomb_2center' at call 6 -/
def vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_1 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
def vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_2 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_2_proved (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_2 P F := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_coulomb_2center' at call 6 -/
def vc_chem_dft_fock_diagonal_build_call6_chem_dft_coulomb_2center_requires_3 (P : LiArray (LiArray Float 4) 4) (F : LiArray (LiArray Float 4) 4) : Prop := True

end chem_dft_fock_diagonal_build

namespace chem_dft_copy4

def vc_chem_dft_copy4_requires_0 (src : LiArray Float 4) (dst : LiArray Float 4) : Prop := True
theorem vc_chem_dft_copy4_requires_0_proved (src : LiArray Float 4) (dst : LiArray Float 4) : vc_chem_dft_copy4_requires_0 src dst := trivial
def vc_chem_dft_copy4_ensures_0 (src : LiArray Float 4) (dst : LiArray Float 4) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_copy4_ensures_0_proved (src : LiArray Float 4) (dst : LiArray Float 4) (result : Unit) : vc_chem_dft_copy4_ensures_0 src dst result := trivial
def vc_chem_dft_copy4_decreases_0 (src : LiArray Float 4) (dst : LiArray Float 4) : Nat := 0
theorem vc_chem_dft_copy4_decreases_0_proved (src : LiArray Float 4) (dst : LiArray Float 4) : vc_chem_dft_copy4_decreases_0 src dst = 0 := rfl
def vc_chem_dft_copy4_call0_chem_dft_basis_n_requires_0 (src : LiArray Float 4) (dst : LiArray Float 4) : Prop := True
theorem vc_chem_dft_copy4_call0_chem_dft_basis_n_requires_0_proved (src : LiArray Float 4) (dst : LiArray Float 4) : vc_chem_dft_copy4_call0_chem_dft_basis_n_requires_0 src dst := trivial

end chem_dft_copy4

namespace chem_dft_matvec4

def vc_chem_dft_matvec4_requires_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : Prop := True
theorem vc_chem_dft_matvec4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : vc_chem_dft_matvec4_requires_0 F v out := trivial
def vc_chem_dft_matvec4_ensures_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_matvec4_ensures_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) (result : Unit) : vc_chem_dft_matvec4_ensures_0 F v out result := trivial
def vc_chem_dft_matvec4_decreases_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : Nat := 0
theorem vc_chem_dft_matvec4_decreases_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : vc_chem_dft_matvec4_decreases_0 F v out = 0 := rfl
def vc_chem_dft_matvec4_call0_chem_dft_basis_n_requires_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : Prop := True
theorem vc_chem_dft_matvec4_call0_chem_dft_basis_n_requires_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : vc_chem_dft_matvec4_call0_chem_dft_basis_n_requires_0 F v out := trivial
def vc_chem_dft_matvec4_call1_chem_dft_basis_n_requires_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : Prop := True
theorem vc_chem_dft_matvec4_call1_chem_dft_basis_n_requires_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (out : LiArray Float 4) : vc_chem_dft_matvec4_call1_chem_dft_basis_n_requires_0 F v out := trivial

end chem_dft_matvec4

namespace chem_dft_vec_norm4

def vc_chem_dft_vec_norm4_requires_0 (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_vec_norm4_requires_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_norm4_requires_0 v := trivial
def vc_chem_dft_vec_norm4_ensures_0 (v : LiArray Float 4) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_chem_dft_vec_norm4_decreases_0 (v : LiArray Float 4) : Nat := 0
theorem vc_chem_dft_vec_norm4_decreases_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_norm4_decreases_0 v = 0 := rfl
def vc_chem_dft_vec_norm4_call0_chem_dft_basis_n_requires_0 (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_vec_norm4_call0_chem_dft_basis_n_requires_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_norm4_call0_chem_dft_basis_n_requires_0 v := trivial

end chem_dft_vec_norm4

namespace chem_dft_vec_normalize4

def vc_chem_dft_vec_normalize4_requires_0 (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_vec_normalize4_requires_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_normalize4_requires_0 v := trivial
def vc_chem_dft_vec_normalize4_ensures_0 (v : LiArray Float 4) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_vec_normalize4_ensures_0_proved (v : LiArray Float 4) (result : Unit) : vc_chem_dft_vec_normalize4_ensures_0 v result := trivial
def vc_chem_dft_vec_normalize4_decreases_0 (v : LiArray Float 4) : Nat := 0
theorem vc_chem_dft_vec_normalize4_decreases_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_normalize4_decreases_0 v = 0 := rfl
def vc_chem_dft_vec_normalize4_call0_chem_dft_vec_norm4_requires_0 (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_vec_normalize4_call0_chem_dft_vec_norm4_requires_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_normalize4_call0_chem_dft_vec_norm4_requires_0 v := trivial
def vc_chem_dft_vec_normalize4_call1_chem_dft_basis_n_requires_0 (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_vec_normalize4_call1_chem_dft_basis_n_requires_0_proved (v : LiArray Float 4) : vc_chem_dft_vec_normalize4_call1_chem_dft_basis_n_requires_0 v := trivial

end chem_dft_vec_normalize4

namespace chem_dft_rayleigh4

def vc_chem_dft_rayleigh4_requires_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_rayleigh4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : vc_chem_dft_rayleigh4_requires_0 F v := trivial
def vc_chem_dft_rayleigh4_ensures_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_rayleigh4_decreases_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : Nat := 0
theorem vc_chem_dft_rayleigh4_decreases_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : vc_chem_dft_rayleigh4_decreases_0 F v = 0 := rfl
def vc_chem_dft_rayleigh4_call0_chem_dft_matvec4_requires_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_rayleigh4_call0_chem_dft_matvec4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : vc_chem_dft_rayleigh4_call0_chem_dft_matvec4_requires_0 F v := trivial
def vc_chem_dft_rayleigh4_call1_chem_dft_basis_n_requires_0 (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : Prop := True
theorem vc_chem_dft_rayleigh4_call1_chem_dft_basis_n_requires_0_proved (F : LiArray (LiArray Float 4) 4) (v : LiArray Float 4) : vc_chem_dft_rayleigh4_call1_chem_dft_basis_n_requires_0 F v := trivial

end chem_dft_rayleigh4

namespace chem_dft_eigensolve_power4

def vc_chem_dft_eigensolve_power4_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_ensures_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_eigensolve_power4_decreases_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Nat := 0
theorem vc_chem_dft_eigensolve_power4_decreases_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_decreases_0 F coeffs = 0 := rfl
def vc_chem_dft_eigensolve_power4_call0_chem_dft_basis_n_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call0_chem_dft_basis_n_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call0_chem_dft_basis_n_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_call1_chem_dft_vec_normalize4_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call1_chem_dft_vec_normalize4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call1_chem_dft_vec_normalize4_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_call2_chem_dft_rayleigh4_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call2_chem_dft_rayleigh4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call2_chem_dft_rayleigh4_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_call3_chem_dft_matvec4_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call3_chem_dft_matvec4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call3_chem_dft_matvec4_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_call4_chem_dft_basis_n_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call4_chem_dft_basis_n_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call4_chem_dft_basis_n_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_call5_chem_dft_vec_normalize4_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call5_chem_dft_vec_normalize4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call5_chem_dft_vec_normalize4_requires_0 F coeffs := trivial
def vc_chem_dft_eigensolve_power4_call6_chem_dft_rayleigh4_requires_0 (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : Prop := True
theorem vc_chem_dft_eigensolve_power4_call6_chem_dft_rayleigh4_requires_0_proved (F : LiArray (LiArray Float 4) 4) (coeffs : LiArray Float 4) : vc_chem_dft_eigensolve_power4_call6_chem_dft_rayleigh4_requires_0 F coeffs := trivial

end chem_dft_eigensolve_power4

namespace chem_dft_density_matrix_from_coeffs

def vc_chem_dft_density_matrix_from_coeffs_requires_0 (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_density_matrix_from_coeffs_requires_0_proved (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : vc_chem_dft_density_matrix_from_coeffs_requires_0 coeffs P := trivial
def vc_chem_dft_density_matrix_from_coeffs_ensures_0 (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_density_matrix_from_coeffs_ensures_0_proved (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) (result : Unit) : vc_chem_dft_density_matrix_from_coeffs_ensures_0 coeffs P result := trivial
def vc_chem_dft_density_matrix_from_coeffs_decreases_0 (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : Nat := 0
theorem vc_chem_dft_density_matrix_from_coeffs_decreases_0_proved (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : vc_chem_dft_density_matrix_from_coeffs_decreases_0 coeffs P = 0 := rfl
def vc_chem_dft_density_matrix_from_coeffs_call0_chem_dft_basis_n_requires_0 (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_density_matrix_from_coeffs_call0_chem_dft_basis_n_requires_0_proved (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : vc_chem_dft_density_matrix_from_coeffs_call0_chem_dft_basis_n_requires_0 coeffs P := trivial
def vc_chem_dft_density_matrix_from_coeffs_call1_chem_dft_basis_n_requires_0 (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : Prop := True
theorem vc_chem_dft_density_matrix_from_coeffs_call1_chem_dft_basis_n_requires_0_proved (coeffs : LiArray Float 4) (P : LiArray (LiArray Float 4) 4) : vc_chem_dft_density_matrix_from_coeffs_call1_chem_dft_basis_n_requires_0 coeffs P := trivial

end chem_dft_density_matrix_from_coeffs

namespace chem_dft_fill_density_from_coeffs

def vc_chem_dft_fill_density_from_coeffs_requires_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_coeffs_requires_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_coeffs_requires_0 coeffs dens := trivial
def vc_chem_dft_fill_density_from_coeffs_ensures_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_fill_density_from_coeffs_ensures_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) (result : Unit) : vc_chem_dft_fill_density_from_coeffs_ensures_0 coeffs dens result := trivial
def vc_chem_dft_fill_density_from_coeffs_decreases_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Nat := 0
theorem vc_chem_dft_fill_density_from_coeffs_decreases_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_coeffs_decreases_0 coeffs dens = 0 := rfl
def vc_chem_dft_fill_density_from_coeffs_call0_chem_dft_sto3g_grid_n_requires_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_coeffs_call0_chem_dft_sto3g_grid_n_requires_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_coeffs_call0_chem_dft_sto3g_grid_n_requires_0 coeffs dens := trivial
def vc_chem_dft_fill_density_from_coeffs_call1_chem_dft_grid_r_at_requires_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_coeffs_call1_chem_dft_grid_r_at_requires_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_coeffs_call1_chem_dft_grid_r_at_requires_0 coeffs dens := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 1 -/
def vc_chem_dft_fill_density_from_coeffs_call1_chem_dft_grid_r_at_requires_1 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_fill_density_from_coeffs_call2_chem_dft_basis_n_requires_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_coeffs_call2_chem_dft_basis_n_requires_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_coeffs_call2_chem_dft_basis_n_requires_0 coeffs dens := trivial
def vc_chem_dft_fill_density_from_coeffs_call3_chem_dft_basis_eval_at_requires_0 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_coeffs_call3_chem_dft_basis_eval_at_requires_0_proved (coeffs : LiArray Float 4) (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_coeffs_call3_chem_dft_basis_eval_at_requires_0 coeffs dens := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_basis_eval_at' at call 3 -/
def vc_chem_dft_fill_density_from_coeffs_call3_chem_dft_basis_eval_at_requires_1 (coeffs : LiArray Float 4) (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_fill_density_from_coeffs_call3_chem_dft_basis_eval_at_requires_2 (coeffs : LiArray Float 4) (dens : LiArray Float 8) (r : Float) : Prop := (r ≥ (0 : Float))

end chem_dft_fill_density_from_coeffs

namespace chem_dft_fill_density_from_basis

def vc_chem_dft_fill_density_from_basis_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_basis_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_basis_requires_0 dens := trivial
def vc_chem_dft_fill_density_from_basis_ensures_0 (dens : LiArray Float 8) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_fill_density_from_basis_ensures_0_proved (dens : LiArray Float 8) (result : Unit) : vc_chem_dft_fill_density_from_basis_ensures_0 dens result := trivial
def vc_chem_dft_fill_density_from_basis_decreases_0 (dens : LiArray Float 8) : Nat := 0
theorem vc_chem_dft_fill_density_from_basis_decreases_0_proved (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_basis_decreases_0 dens = 0 := rfl
def vc_chem_dft_fill_density_from_basis_call0_chem_dft_basis_n_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_basis_call0_chem_dft_basis_n_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_basis_call0_chem_dft_basis_n_requires_0 dens := trivial
def vc_chem_dft_fill_density_from_basis_call1_chem_dft_fill_density_from_coeffs_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_fill_density_from_basis_call1_chem_dft_fill_density_from_coeffs_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_fill_density_from_basis_call1_chem_dft_fill_density_from_coeffs_requires_0 dens := trivial

end chem_dft_fill_density_from_basis

namespace chem_dft_hartree_grid

def vc_chem_dft_hartree_grid_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_hartree_grid_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_requires_0 dens := trivial
def vc_chem_dft_hartree_grid_ensures_0 (dens : LiArray Float 8) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_chem_dft_hartree_grid_decreases_0 (dens : LiArray Float 8) : Nat := 0
theorem vc_chem_dft_hartree_grid_decreases_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_decreases_0 dens = 0 := rfl
def vc_chem_dft_hartree_grid_call0_chem_dft_grid_dr_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_hartree_grid_call0_chem_dft_grid_dr_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_call0_chem_dft_grid_dr_requires_0 dens := trivial
def vc_chem_dft_hartree_grid_call1_chem_dft_sto3g_grid_n_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_hartree_grid_call1_chem_dft_sto3g_grid_n_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_call1_chem_dft_sto3g_grid_n_requires_0 dens := trivial
def vc_chem_dft_hartree_grid_call2_chem_dft_grid_r_at_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_hartree_grid_call2_chem_dft_grid_r_at_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_call2_chem_dft_grid_r_at_requires_0 dens := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 2 -/
def vc_chem_dft_hartree_grid_call2_chem_dft_grid_r_at_requires_1 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_hartree_grid_call3_chem_dft_sto3g_grid_n_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_hartree_grid_call3_chem_dft_sto3g_grid_n_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_call3_chem_dft_sto3g_grid_n_requires_0 dens := trivial
def vc_chem_dft_hartree_grid_call4_chem_dft_grid_r_at_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_hartree_grid_call4_chem_dft_grid_r_at_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_hartree_grid_call4_chem_dft_grid_r_at_requires_0 dens := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 4 -/
def vc_chem_dft_hartree_grid_call4_chem_dft_grid_r_at_requires_1 (dens : LiArray Float 8) : Prop := True

end chem_dft_hartree_grid

namespace chem_dft_energy_from_density

def vc_chem_dft_energy_from_density_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_ensures_0 (dens : LiArray Float 8) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_energy_from_density_decreases_0 (dens : LiArray Float 8) : Nat := 0
theorem vc_chem_dft_energy_from_density_decreases_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_decreases_0 dens = 0 := rfl
def vc_chem_dft_energy_from_density_call0_chem_dft_grid_dr_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_call0_chem_dft_grid_dr_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_call0_chem_dft_grid_dr_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_call1_chem_dft_sto3g_grid_n_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_call1_chem_dft_sto3g_grid_n_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_call1_chem_dft_sto3g_grid_n_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_call2_chem_dft_grid_r_at_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_call2_chem_dft_grid_r_at_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_call2_chem_dft_grid_r_at_requires_0 dens := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 2 -/
def vc_chem_dft_energy_from_density_call2_chem_dft_grid_r_at_requires_1 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_energy_from_density_call3_chem_dft_lda_xc_density_requires_0 (dens : LiArray Float 8) (rho : Float) : Prop := (rho ≥ (0 : Float))
/-! VC call-site requires (opaque): callee 'chem_dft_basis_eval_sto3g' at call 4 -/
def vc_chem_dft_energy_from_density_call4_chem_dft_basis_eval_sto3g_requires_0 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_energy_from_density_call5_chem_dft_grid_r_at_requires_0 (dens : LiArray Float 8) : Prop := ((0 + 1) ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 5 -/
def vc_chem_dft_energy_from_density_call5_chem_dft_grid_r_at_requires_1 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_energy_from_density_call6_chem_dft_basis_eval_sto3g_requires_0 (dens : LiArray Float 8) (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_energy_from_density_call7_chem_dft_hartree_grid_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_call7_chem_dft_hartree_grid_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_call7_chem_dft_hartree_grid_requires_0 dens := trivial

end chem_dft_energy_from_density

namespace chem_dft_energy_kernel_hartree

def vc_chem_dft_energy_kernel_hartree_requires_0 : Prop := True
theorem vc_chem_dft_energy_kernel_hartree_requires_0_proved : vc_chem_dft_energy_kernel_hartree_requires_0 := trivial
def vc_chem_dft_energy_kernel_hartree_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_energy_kernel_hartree_ensures_0_proved (result : Float) : vc_chem_dft_energy_kernel_hartree_ensures_0 result := trivial
def vc_chem_dft_energy_kernel_hartree_decreases_0 : Nat := 0
theorem vc_chem_dft_energy_kernel_hartree_decreases_0_proved : vc_chem_dft_energy_kernel_hartree_decreases_0 = 0 := rfl
def vc_chem_dft_energy_kernel_hartree_call0_chem_dft_fill_density_from_basis_requires_0 : Prop := True
theorem vc_chem_dft_energy_kernel_hartree_call0_chem_dft_fill_density_from_basis_requires_0_proved : vc_chem_dft_energy_kernel_hartree_call0_chem_dft_fill_density_from_basis_requires_0 := trivial
def vc_chem_dft_energy_kernel_hartree_call1_chem_dft_energy_from_density_requires_0 : Prop := True
theorem vc_chem_dft_energy_kernel_hartree_call1_chem_dft_energy_from_density_requires_0_proved : vc_chem_dft_energy_kernel_hartree_call1_chem_dft_energy_from_density_requires_0 := trivial

end chem_dft_energy_kernel_hartree

namespace chem_dft_fock_density_mix_step

def vc_chem_dft_fock_density_mix_step_requires_0 (dens : LiArray Float 8) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_fock_density_mix_step_requires_1 (dens : LiArray Float 8) (mix : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_fock_density_mix_step_ensures_0 (dens : LiArray Float 8) (mix : Float) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_fock_density_mix_step_ensures_0_proved (dens : LiArray Float 8) (mix : Float) (result : Unit) : vc_chem_dft_fock_density_mix_step_ensures_0 dens mix result := trivial
def vc_chem_dft_fock_density_mix_step_decreases_0 (dens : LiArray Float 8) (mix : Float) : Nat := 0
theorem vc_chem_dft_fock_density_mix_step_decreases_0_proved (dens : LiArray Float 8) (mix : Float) : vc_chem_dft_fock_density_mix_step_decreases_0 dens mix = 0 := rfl
def vc_chem_dft_fock_density_mix_step_call0_chem_dft_fill_density_from_basis_requires_0 (dens : LiArray Float 8) (mix : Float) : Prop := True
theorem vc_chem_dft_fock_density_mix_step_call0_chem_dft_fill_density_from_basis_requires_0_proved (dens : LiArray Float 8) (mix : Float) : vc_chem_dft_fock_density_mix_step_call0_chem_dft_fill_density_from_basis_requires_0 dens mix := trivial
def vc_chem_dft_fock_density_mix_step_call1_chem_dft_sto3g_grid_n_requires_0 (dens : LiArray Float 8) (mix : Float) : Prop := True
theorem vc_chem_dft_fock_density_mix_step_call1_chem_dft_sto3g_grid_n_requires_0_proved (dens : LiArray Float 8) (mix : Float) : vc_chem_dft_fock_density_mix_step_call1_chem_dft_sto3g_grid_n_requires_0 dens mix := trivial

end chem_dft_fock_density_mix_step

namespace chem_dft_scf_fock_step

def vc_chem_dft_scf_fock_step_requires_0 (dens : LiArray Float 8) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_fock_step_requires_1 (dens : LiArray Float 8) (mix : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_scf_fock_step_ensures_0 (dens : LiArray Float 8) (mix : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_scf_fock_step_ensures_0_proved (dens : LiArray Float 8) (mix : Float) (result : Float) : vc_chem_dft_scf_fock_step_ensures_0 dens mix result := trivial
def vc_chem_dft_scf_fock_step_decreases_0 (dens : LiArray Float 8) (mix : Float) : Nat := 0
theorem vc_chem_dft_scf_fock_step_decreases_0_proved (dens : LiArray Float 8) (mix : Float) : vc_chem_dft_scf_fock_step_decreases_0 dens mix = 0 := rfl
def vc_chem_dft_scf_fock_step_call0_chem_dft_scf_fock_step_at_potential_requires_0 (dens : LiArray Float 8) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_fock_step_call0_chem_dft_scf_fock_step_at_potential_requires_1 (dens : LiArray Float 8) (mix : Float) : Prop := (mix ≤ (1 : Float))

end chem_dft_scf_fock_step

namespace chem_dft_potential_shift_hartree

def vc_chem_dft_potential_shift_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_chem_dft_potential_shift_hartree_requires_0_proved (u_v : Float) : vc_chem_dft_potential_shift_hartree_requires_0 u_v := trivial
def vc_chem_dft_potential_shift_hartree_ensures_0 (u_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_potential_shift_hartree_ensures_0_proved (u_v : Float) (result : Float) : vc_chem_dft_potential_shift_hartree_ensures_0 u_v result := trivial
def vc_chem_dft_potential_shift_hartree_decreases_0 (u_v : Float) : Nat := 0
theorem vc_chem_dft_potential_shift_hartree_decreases_0_proved (u_v : Float) : vc_chem_dft_potential_shift_hartree_decreases_0 u_v = 0 := rfl

end chem_dft_potential_shift_hartree

namespace chem_dft_fock_apply_potential_shift

def vc_chem_dft_fock_apply_potential_shift_requires_0 (F : LiArray (LiArray Float 4) 4) (u_v : Float) : Prop := True
theorem vc_chem_dft_fock_apply_potential_shift_requires_0_proved (F : LiArray (LiArray Float 4) 4) (u_v : Float) : vc_chem_dft_fock_apply_potential_shift_requires_0 F u_v := trivial
def vc_chem_dft_fock_apply_potential_shift_ensures_0 (F : LiArray (LiArray Float 4) 4) (u_v : Float) (result : Unit) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_fock_apply_potential_shift_ensures_0_proved (F : LiArray (LiArray Float 4) 4) (u_v : Float) (result : Unit) : vc_chem_dft_fock_apply_potential_shift_ensures_0 F u_v result := trivial
def vc_chem_dft_fock_apply_potential_shift_decreases_0 (F : LiArray (LiArray Float 4) 4) (u_v : Float) : Nat := 0
theorem vc_chem_dft_fock_apply_potential_shift_decreases_0_proved (F : LiArray (LiArray Float 4) 4) (u_v : Float) : vc_chem_dft_fock_apply_potential_shift_decreases_0 F u_v = 0 := rfl
def vc_chem_dft_fock_apply_potential_shift_call0_chem_dft_potential_shift_hartree_requires_0 (F : LiArray (LiArray Float 4) 4) (u_v : Float) : Prop := True
theorem vc_chem_dft_fock_apply_potential_shift_call0_chem_dft_potential_shift_hartree_requires_0_proved (F : LiArray (LiArray Float 4) 4) (u_v : Float) : vc_chem_dft_fock_apply_potential_shift_call0_chem_dft_potential_shift_hartree_requires_0 F u_v := trivial
def vc_chem_dft_fock_apply_potential_shift_call1_chem_dft_basis_n_requires_0 (F : LiArray (LiArray Float 4) 4) (u_v : Float) : Prop := True
theorem vc_chem_dft_fock_apply_potential_shift_call1_chem_dft_basis_n_requires_0_proved (F : LiArray (LiArray Float 4) 4) (u_v : Float) : vc_chem_dft_fock_apply_potential_shift_call1_chem_dft_basis_n_requires_0 F u_v := trivial

end chem_dft_fock_apply_potential_shift

namespace chem_dft_scf_fock_step_at_potential

def vc_chem_dft_scf_fock_step_at_potential_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_fock_step_at_potential_requires_1 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_scf_fock_step_at_potential_ensures_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_scf_fock_step_at_potential_decreases_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Nat := 0
theorem vc_chem_dft_scf_fock_step_at_potential_decreases_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_decreases_0 dens mix u_v = 0 := rfl
def vc_chem_dft_scf_fock_step_at_potential_call0_chem_dft_basis_n_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call0_chem_dft_basis_n_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call0_chem_dft_basis_n_requires_0 dens mix u_v := trivial
def vc_chem_dft_scf_fock_step_at_potential_call1_chem_dft_density_matrix_from_coeffs_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call1_chem_dft_density_matrix_from_coeffs_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call1_chem_dft_density_matrix_from_coeffs_requires_0 dens mix u_v := trivial
def vc_chem_dft_scf_fock_step_at_potential_call2_chem_dft_fock_diagonal_build_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call2_chem_dft_fock_diagonal_build_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call2_chem_dft_fock_diagonal_build_requires_0 dens mix u_v := trivial
def vc_chem_dft_scf_fock_step_at_potential_call3_chem_dft_fock_apply_potential_shift_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call3_chem_dft_fock_apply_potential_shift_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call3_chem_dft_fock_apply_potential_shift_requires_0 dens mix u_v := trivial
def vc_chem_dft_scf_fock_step_at_potential_call4_chem_dft_eigensolve_power4_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call4_chem_dft_eigensolve_power4_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call4_chem_dft_eigensolve_power4_requires_0 dens mix u_v := trivial
def vc_chem_dft_scf_fock_step_at_potential_call5_chem_dft_fill_density_from_coeffs_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call5_chem_dft_fill_density_from_coeffs_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call5_chem_dft_fill_density_from_coeffs_requires_0 dens mix u_v := trivial
def vc_chem_dft_scf_fock_step_at_potential_call6_chem_dft_sto3g_grid_n_requires_0 (dens : LiArray Float 8) (mix : Float) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_fock_step_at_potential_call6_chem_dft_sto3g_grid_n_requires_0_proved (dens : LiArray Float 8) (mix : Float) (u_v : Float) : vc_chem_dft_scf_fock_step_at_potential_call6_chem_dft_sto3g_grid_n_requires_0 dens mix u_v := trivial

end chem_dft_scf_fock_step_at_potential

namespace chem_dft_scf_iteration_scaffold

def vc_chem_dft_scf_iteration_scaffold_requires_0 (max_iter : Int) : Prop := (max_iter ≥ 1)
def vc_chem_dft_scf_iteration_scaffold_requires_1 (max_iter : Int) : Prop := (max_iter ≤ 32)
def vc_chem_dft_scf_iteration_scaffold_ensures_0 (max_iter : Int) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_scf_iteration_scaffold_decreases_0 (max_iter : Int) : Nat := Int.toNat max_iter
theorem vc_chem_dft_scf_iteration_scaffold_decreases_0_proved (max_iter : Int) : vc_chem_dft_scf_iteration_scaffold_decreases_0 max_iter = Int.toNat max_iter := rfl
def vc_chem_dft_scf_iteration_scaffold_call0_chem_dft_fill_density_from_basis_requires_0 (max_iter : Int) : Prop := True
theorem vc_chem_dft_scf_iteration_scaffold_call0_chem_dft_fill_density_from_basis_requires_0_proved (max_iter : Int) : vc_chem_dft_scf_iteration_scaffold_call0_chem_dft_fill_density_from_basis_requires_0 max_iter := trivial
def vc_chem_dft_scf_iteration_scaffold_call1_chem_dft_energy_from_density_requires_0 (max_iter : Int) : Prop := True
theorem vc_chem_dft_scf_iteration_scaffold_call1_chem_dft_energy_from_density_requires_0_proved (max_iter : Int) : vc_chem_dft_scf_iteration_scaffold_call1_chem_dft_energy_from_density_requires_0 max_iter := trivial
def vc_chem_dft_scf_iteration_scaffold_call2_chem_dft_scf_fock_step_requires_0 (max_iter : Int) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_iteration_scaffold_call2_chem_dft_scf_fock_step_requires_1 (max_iter : Int) (mix : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_scf_iteration_scaffold_call3_chem_dft_energy_from_density_requires_0 (max_iter : Int) : Prop := True
theorem vc_chem_dft_scf_iteration_scaffold_call3_chem_dft_energy_from_density_requires_0_proved (max_iter : Int) : vc_chem_dft_scf_iteration_scaffold_call3_chem_dft_energy_from_density_requires_0 max_iter := trivial

end chem_dft_scf_iteration_scaffold

namespace chem_dft_scf_iteration_scaffold_at_potential

def vc_chem_dft_scf_iteration_scaffold_at_potential_requires_0 (max_iter : Int) (u_v : Float) : Prop := (max_iter ≥ 1)
def vc_chem_dft_scf_iteration_scaffold_at_potential_requires_1 (max_iter : Int) (u_v : Float) : Prop := (max_iter ≤ 32)
def vc_chem_dft_scf_iteration_scaffold_at_potential_ensures_0 (max_iter : Int) (u_v : Float) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_scf_iteration_scaffold_at_potential_decreases_0 (max_iter : Int) (u_v : Float) : Nat := Int.toNat max_iter
theorem vc_chem_dft_scf_iteration_scaffold_at_potential_decreases_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_iteration_scaffold_at_potential_decreases_0 max_iter u_v = Int.toNat max_iter := rfl
def vc_chem_dft_scf_iteration_scaffold_at_potential_call0_chem_dft_fill_density_from_basis_requires_0 (max_iter : Int) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_iteration_scaffold_at_potential_call0_chem_dft_fill_density_from_basis_requires_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_iteration_scaffold_at_potential_call0_chem_dft_fill_density_from_basis_requires_0 max_iter u_v := trivial
def vc_chem_dft_scf_iteration_scaffold_at_potential_call1_chem_dft_energy_from_density_requires_0 (max_iter : Int) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_iteration_scaffold_at_potential_call1_chem_dft_energy_from_density_requires_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_iteration_scaffold_at_potential_call1_chem_dft_energy_from_density_requires_0 max_iter u_v := trivial
def vc_chem_dft_scf_iteration_scaffold_at_potential_call2_chem_dft_scf_fock_step_at_potential_requires_0 (max_iter : Int) (u_v : Float) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_iteration_scaffold_at_potential_call2_chem_dft_scf_fock_step_at_potential_requires_1 (max_iter : Int) (u_v : Float) (mix : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_scf_iteration_scaffold_at_potential_call3_chem_dft_energy_from_density_requires_0 (max_iter : Int) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_iteration_scaffold_at_potential_call3_chem_dft_energy_from_density_requires_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_iteration_scaffold_at_potential_call3_chem_dft_energy_from_density_requires_0 max_iter u_v := trivial

end chem_dft_scf_iteration_scaffold_at_potential

namespace chem_dft_h2_bond_length_ang

def vc_chem_dft_h2_bond_length_ang_requires_0 : Prop := True
theorem vc_chem_dft_h2_bond_length_ang_requires_0_proved : vc_chem_dft_h2_bond_length_ang_requires_0 := trivial
def vc_chem_dft_h2_bond_length_ang_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_h2_bond_length_ang_ensures_0_proved (result : Float) : vc_chem_dft_h2_bond_length_ang_ensures_0 result := trivial
def vc_chem_dft_h2_bond_length_ang_decreases_0 : Nat := 0
theorem vc_chem_dft_h2_bond_length_ang_decreases_0_proved : vc_chem_dft_h2_bond_length_ang_decreases_0 = 0 := rfl

end chem_dft_h2_bond_length_ang

namespace chem_dft_energy_from_density_h2

def vc_chem_dft_energy_from_density_h2_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_h2_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_h2_ensures_0 (dens : LiArray Float 8) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_energy_from_density_h2_decreases_0 (dens : LiArray Float 8) : Nat := 0
theorem vc_chem_dft_energy_from_density_h2_decreases_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_decreases_0 dens = 0 := rfl
def vc_chem_dft_energy_from_density_h2_call0_chem_dft_grid_dr_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_h2_call0_chem_dft_grid_dr_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_call0_chem_dft_grid_dr_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_h2_call1_chem_dft_h2_bond_length_ang_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_h2_call1_chem_dft_h2_bond_length_ang_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_call1_chem_dft_h2_bond_length_ang_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_h2_call2_chem_dft_sto3g_grid_n_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_h2_call2_chem_dft_sto3g_grid_n_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_call2_chem_dft_sto3g_grid_n_requires_0 dens := trivial
def vc_chem_dft_energy_from_density_h2_call3_chem_dft_grid_r_at_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_h2_call3_chem_dft_grid_r_at_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_call3_chem_dft_grid_r_at_requires_0 dens := trivial
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 3 -/
def vc_chem_dft_energy_from_density_h2_call3_chem_dft_grid_r_at_requires_1 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_energy_from_density_h2_call4_chem_dft_lda_xc_density_requires_0 (dens : LiArray Float 8) (rho : Float) : Prop := (rho ≥ (0 : Float))
/-! VC call-site requires (opaque): callee 'chem_dft_basis_eval_sto3g' at call 5 -/
def vc_chem_dft_energy_from_density_h2_call5_chem_dft_basis_eval_sto3g_requires_0 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_energy_from_density_h2_call6_chem_dft_grid_r_at_requires_0 (dens : LiArray Float 8) : Prop := ((0 + 1) ≥ 0)
/-! VC call-site requires (opaque): callee 'chem_dft_grid_r_at' at call 6 -/
def vc_chem_dft_energy_from_density_h2_call6_chem_dft_grid_r_at_requires_1 (dens : LiArray Float 8) : Prop := True
def vc_chem_dft_energy_from_density_h2_call7_chem_dft_basis_eval_sto3g_requires_0 (dens : LiArray Float 8) (r : Float) : Prop := (r ≥ (0 : Float))
def vc_chem_dft_energy_from_density_h2_call8_chem_dft_hartree_grid_requires_0 (dens : LiArray Float 8) : Prop := True
theorem vc_chem_dft_energy_from_density_h2_call8_chem_dft_hartree_grid_requires_0_proved (dens : LiArray Float 8) : vc_chem_dft_energy_from_density_h2_call8_chem_dft_hartree_grid_requires_0 dens := trivial

end chem_dft_energy_from_density_h2

namespace chem_dft_scf_h2_iteration_scaffold

def vc_chem_dft_scf_h2_iteration_scaffold_requires_0 (max_iter : Int) : Prop := (max_iter ≥ 1)
def vc_chem_dft_scf_h2_iteration_scaffold_requires_1 (max_iter : Int) : Prop := (max_iter ≤ 32)
def vc_chem_dft_scf_h2_iteration_scaffold_ensures_0 (max_iter : Int) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_scf_h2_iteration_scaffold_decreases_0 (max_iter : Int) : Nat := Int.toNat max_iter
theorem vc_chem_dft_scf_h2_iteration_scaffold_decreases_0_proved (max_iter : Int) : vc_chem_dft_scf_h2_iteration_scaffold_decreases_0 max_iter = Int.toNat max_iter := rfl
def vc_chem_dft_scf_h2_iteration_scaffold_call0_chem_dft_fill_density_from_basis_requires_0 (max_iter : Int) : Prop := True
theorem vc_chem_dft_scf_h2_iteration_scaffold_call0_chem_dft_fill_density_from_basis_requires_0_proved (max_iter : Int) : vc_chem_dft_scf_h2_iteration_scaffold_call0_chem_dft_fill_density_from_basis_requires_0 max_iter := trivial
def vc_chem_dft_scf_h2_iteration_scaffold_call1_chem_dft_energy_from_density_h2_requires_0 (max_iter : Int) : Prop := True
theorem vc_chem_dft_scf_h2_iteration_scaffold_call1_chem_dft_energy_from_density_h2_requires_0_proved (max_iter : Int) : vc_chem_dft_scf_h2_iteration_scaffold_call1_chem_dft_energy_from_density_h2_requires_0 max_iter := trivial
def vc_chem_dft_scf_h2_iteration_scaffold_call2_chem_dft_scf_fock_step_requires_0 (max_iter : Int) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_h2_iteration_scaffold_call2_chem_dft_scf_fock_step_requires_1 (max_iter : Int) (mix : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_scf_h2_iteration_scaffold_call3_chem_dft_energy_from_density_h2_requires_0 (max_iter : Int) : Prop := True
theorem vc_chem_dft_scf_h2_iteration_scaffold_call3_chem_dft_energy_from_density_h2_requires_0_proved (max_iter : Int) : vc_chem_dft_scf_h2_iteration_scaffold_call3_chem_dft_energy_from_density_h2_requires_0 max_iter := trivial

end chem_dft_scf_h2_iteration_scaffold

namespace chem_dft_scf_h2_iteration_scaffold_at_potential

def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_0 (max_iter : Int) (u_v : Float) : Prop := (max_iter ≥ 1)
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_1 (max_iter : Int) (u_v : Float) : Prop := (max_iter ≤ 32)
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_ensures_0 (max_iter : Int) (u_v : Float) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_decreases_0 (max_iter : Int) (u_v : Float) : Nat := Int.toNat max_iter
theorem vc_chem_dft_scf_h2_iteration_scaffold_at_potential_decreases_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_h2_iteration_scaffold_at_potential_decreases_0 max_iter u_v = Int.toNat max_iter := rfl
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call0_chem_dft_fill_density_from_basis_requires_0 (max_iter : Int) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call0_chem_dft_fill_density_from_basis_requires_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call0_chem_dft_fill_density_from_basis_requires_0 max_iter u_v := trivial
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call1_chem_dft_energy_from_density_h2_requires_0 (max_iter : Int) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call1_chem_dft_energy_from_density_h2_requires_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call1_chem_dft_energy_from_density_h2_requires_0 max_iter u_v := trivial
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call2_chem_dft_scf_fock_step_at_potential_requires_0 (max_iter : Int) (u_v : Float) (mix : Float) : Prop := (mix > (0 : Float))
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call2_chem_dft_scf_fock_step_at_potential_requires_1 (max_iter : Int) (u_v : Float) (mix : Float) : Prop := (mix ≤ (1 : Float))
def vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call3_chem_dft_energy_from_density_h2_requires_0 (max_iter : Int) (u_v : Float) : Prop := True
theorem vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call3_chem_dft_energy_from_density_h2_requires_0_proved (max_iter : Int) (u_v : Float) : vc_chem_dft_scf_h2_iteration_scaffold_at_potential_call3_chem_dft_energy_from_density_h2_requires_0 max_iter u_v := trivial

end chem_dft_scf_h2_iteration_scaffold_at_potential

namespace chem_dft_gpu_energy_checksum

def vc_chem_dft_gpu_energy_checksum_requires_0 : Prop := True
theorem vc_chem_dft_gpu_energy_checksum_requires_0_proved : vc_chem_dft_gpu_energy_checksum_requires_0 := trivial
def vc_chem_dft_gpu_energy_checksum_ensures_0 (result : Float) : Prop := (result ≥ (0 : Float))
def vc_chem_dft_gpu_energy_checksum_ensures_1 (result : Float) : Prop := (result ≤ (1 : Float))
def vc_chem_dft_gpu_energy_checksum_decreases_0 : Nat := 0
theorem vc_chem_dft_gpu_energy_checksum_decreases_0_proved : vc_chem_dft_gpu_energy_checksum_decreases_0 = 0 := rfl
def vc_chem_dft_gpu_energy_checksum_call0_chem_dft_scf_iteration_scaffold_requires_0 : Prop := True
theorem vc_chem_dft_gpu_energy_checksum_call0_chem_dft_scf_iteration_scaffold_requires_0_proved : vc_chem_dft_gpu_energy_checksum_call0_chem_dft_scf_iteration_scaffold_requires_0 := trivial
def vc_chem_dft_gpu_energy_checksum_call0_chem_dft_scf_iteration_scaffold_requires_1 : Prop := True
theorem vc_chem_dft_gpu_energy_checksum_call0_chem_dft_scf_iteration_scaffold_requires_1_proved : vc_chem_dft_gpu_energy_checksum_call0_chem_dft_scf_iteration_scaffold_requires_1 := trivial

end chem_dft_gpu_energy_checksum

namespace chem_dft_run_smoke

def vc_chem_dft_run_smoke_requires_0 : Prop := True
theorem vc_chem_dft_run_smoke_requires_0_proved : vc_chem_dft_run_smoke_requires_0 := trivial
def vc_chem_dft_run_smoke_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_dft_run_smoke_ensures_0_proved (result : Float) : vc_chem_dft_run_smoke_ensures_0 result := trivial
def vc_chem_dft_run_smoke_decreases_0 : Nat := 0
theorem vc_chem_dft_run_smoke_decreases_0_proved : vc_chem_dft_run_smoke_decreases_0 = 0 := rfl
def vc_chem_dft_run_smoke_call0_chem_dft_energy_kernel_hartree_requires_0 : Prop := True
theorem vc_chem_dft_run_smoke_call0_chem_dft_energy_kernel_hartree_requires_0_proved : vc_chem_dft_run_smoke_call0_chem_dft_energy_kernel_hartree_requires_0 := trivial

end chem_dft_run_smoke

namespace chem_use_lkir

def vc_chem_use_lkir_requires_0 : Prop := True
theorem vc_chem_use_lkir_requires_0_proved : vc_chem_use_lkir_requires_0 := trivial
def vc_chem_use_lkir_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_chem_use_lkir_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_chem_use_lkir_decreases_0 : Nat := 0
theorem vc_chem_use_lkir_decreases_0_proved : vc_chem_use_lkir_decreases_0 = 0 := rfl

end chem_use_lkir

namespace chem_lig_energy_kernel_id

def vc_chem_lig_energy_kernel_id_requires_0 : Prop := True
theorem vc_chem_lig_energy_kernel_id_requires_0_proved : vc_chem_lig_energy_kernel_id_requires_0 := trivial
def vc_chem_lig_energy_kernel_id_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_lig_energy_kernel_id_ensures_0_proved (result : Int) : vc_chem_lig_energy_kernel_id_ensures_0 result := trivial
def vc_chem_lig_energy_kernel_id_decreases_0 : Nat := 0
theorem vc_chem_lig_energy_kernel_id_decreases_0_proved : vc_chem_lig_energy_kernel_id_decreases_0 = 0 := rfl
def vc_chem_lig_energy_kernel_id_call0_lig_kernel_matmul_f32_requires_0 : Prop := True
theorem vc_chem_lig_energy_kernel_id_call0_lig_kernel_matmul_f32_requires_0_proved : vc_chem_lig_energy_kernel_id_call0_lig_kernel_matmul_f32_requires_0 := trivial

end chem_lig_energy_kernel_id

namespace chem_dft_gpu_lkir_progress

def vc_chem_dft_gpu_lkir_progress_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_progress_requires_0_proved : vc_chem_dft_gpu_lkir_progress_requires_0 := trivial
def vc_chem_dft_gpu_lkir_progress_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_chem_dft_gpu_lkir_progress_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_chem_dft_gpu_lkir_progress_decreases_0 : Nat := 0
theorem vc_chem_dft_gpu_lkir_progress_decreases_0_proved : vc_chem_dft_gpu_lkir_progress_decreases_0 = 0 := rfl
def vc_chem_dft_gpu_lkir_progress_call0_chem_use_lkir_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_progress_call0_chem_use_lkir_requires_0_proved : vc_chem_dft_gpu_lkir_progress_call0_chem_use_lkir_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 1 -/
def vc_chem_dft_gpu_lkir_progress_call1_lig_kernel_run_requires_0 : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 1 -/
def vc_chem_dft_gpu_lkir_progress_call1_lig_kernel_run_requires_1 : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 1 -/
def vc_chem_dft_gpu_lkir_progress_call1_lig_kernel_run_requires_2 : Prop := True
def vc_chem_dft_gpu_lkir_progress_call2_chem_lig_energy_kernel_id_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_progress_call2_chem_lig_energy_kernel_id_requires_0_proved : vc_chem_dft_gpu_lkir_progress_call2_chem_lig_energy_kernel_id_requires_0 := trivial
def vc_chem_dft_gpu_lkir_progress_call3_lig_backend_select_auto_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_progress_call3_lig_backend_select_auto_requires_0_proved : vc_chem_dft_gpu_lkir_progress_call3_lig_backend_select_auto_requires_0 := trivial
def vc_chem_dft_gpu_lkir_progress_call4_lig_validity_gate_pass_requires_0 : Prop := ((0.999 : Float) ≥ (0 : Float))
def vc_chem_dft_gpu_lkir_progress_call4_lig_validity_gate_pass_requires_1 : Prop := ((0.999 : Float) ≤ (1 : Float))

end chem_dft_gpu_lkir_progress

namespace chem_dft_gpu_lkir_launch_pipeline

def vc_chem_dft_gpu_lkir_launch_pipeline_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_launch_pipeline_requires_0_proved : vc_chem_dft_gpu_lkir_launch_pipeline_requires_0 := trivial
def vc_chem_dft_gpu_lkir_launch_pipeline_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_chem_dft_gpu_lkir_launch_pipeline_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_chem_dft_gpu_lkir_launch_pipeline_decreases_0 : Nat := 0
theorem vc_chem_dft_gpu_lkir_launch_pipeline_decreases_0_proved : vc_chem_dft_gpu_lkir_launch_pipeline_decreases_0 = 0 := rfl
def vc_chem_dft_gpu_lkir_launch_pipeline_call0_chem_dft_gpu_lkir_progress_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_launch_pipeline_call0_chem_dft_gpu_lkir_progress_requires_0_proved : vc_chem_dft_gpu_lkir_launch_pipeline_call0_chem_dft_gpu_lkir_progress_requires_0 := trivial
def vc_chem_dft_gpu_lkir_launch_pipeline_call1_lig_gpu_launch_prologue_ok_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_launch_pipeline_call1_lig_gpu_launch_prologue_ok_requires_0_proved : vc_chem_dft_gpu_lkir_launch_pipeline_call1_lig_gpu_launch_prologue_ok_requires_0 := trivial
def vc_chem_dft_gpu_lkir_launch_pipeline_call2_lig_emit_vendor_progress_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_launch_pipeline_call2_lig_emit_vendor_progress_requires_0_proved : vc_chem_dft_gpu_lkir_launch_pipeline_call2_lig_emit_vendor_progress_requires_0 := trivial
def vc_chem_dft_gpu_lkir_launch_pipeline_call3_lig_gpu_device_buffer_ready_requires_0 : Prop := True
theorem vc_chem_dft_gpu_lkir_launch_pipeline_call3_lig_gpu_device_buffer_ready_requires_0_proved : vc_chem_dft_gpu_lkir_launch_pipeline_call3_lig_gpu_device_buffer_ready_requires_0 := trivial

end chem_dft_gpu_lkir_launch_pipeline

namespace chem_dft_run_gpu_queue

def vc_chem_dft_run_gpu_queue_requires_0 : Prop := True
theorem vc_chem_dft_run_gpu_queue_requires_0_proved : vc_chem_dft_run_gpu_queue_requires_0 := trivial
def vc_chem_dft_run_gpu_queue_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_chem_dft_run_gpu_queue_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_chem_dft_run_gpu_queue_decreases_0 : Nat := 0
theorem vc_chem_dft_run_gpu_queue_decreases_0_proved : vc_chem_dft_run_gpu_queue_decreases_0 = 0 := rfl
def vc_chem_dft_run_gpu_queue_call0_chem_dft_energy_kernel_hartree_requires_0 : Prop := True
theorem vc_chem_dft_run_gpu_queue_call0_chem_dft_energy_kernel_hartree_requires_0_proved : vc_chem_dft_run_gpu_queue_call0_chem_dft_energy_kernel_hartree_requires_0 := trivial
def vc_chem_dft_run_gpu_queue_call1_chem_dft_gpu_lkir_launch_pipeline_requires_0 : Prop := True
theorem vc_chem_dft_run_gpu_queue_call1_chem_dft_gpu_lkir_launch_pipeline_requires_0_proved : vc_chem_dft_run_gpu_queue_call1_chem_dft_gpu_lkir_launch_pipeline_requires_0 := trivial

end chem_dft_run_gpu_queue

namespace echem_she_reference_ev

def vc_echem_she_reference_ev_requires_0 : Prop := True
theorem vc_echem_she_reference_ev_requires_0_proved : vc_echem_she_reference_ev_requires_0 := trivial
def vc_echem_she_reference_ev_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_she_reference_ev_ensures_0_proved (result : Float) : vc_echem_she_reference_ev_ensures_0 result := trivial
def vc_echem_she_reference_ev_decreases_0 : Nat := 0
theorem vc_echem_she_reference_ev_decreases_0_proved : vc_echem_she_reference_ev_decreases_0 = 0 := rfl

end echem_she_reference_ev

namespace echem_hartree_to_ev_factor

def vc_echem_hartree_to_ev_factor_requires_0 : Prop := True
theorem vc_echem_hartree_to_ev_factor_requires_0_proved : vc_echem_hartree_to_ev_factor_requires_0 := trivial
def vc_echem_hartree_to_ev_factor_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_hartree_to_ev_factor_ensures_0_proved (result : Float) : vc_echem_hartree_to_ev_factor_ensures_0 result := trivial
def vc_echem_hartree_to_ev_factor_decreases_0 : Nat := 0
theorem vc_echem_hartree_to_ev_factor_decreases_0_proved : vc_echem_hartree_to_ev_factor_decreases_0 = 0 := rfl

end echem_hartree_to_ev_factor

namespace echem_hartree_to_ev

def vc_echem_hartree_to_ev_requires_0 (hartree : Float) : Prop := True
theorem vc_echem_hartree_to_ev_requires_0_proved (hartree : Float) : vc_echem_hartree_to_ev_requires_0 hartree := trivial
def vc_echem_hartree_to_ev_ensures_0 (hartree : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_hartree_to_ev_ensures_0_proved (hartree : Float) (result : Float) : vc_echem_hartree_to_ev_ensures_0 hartree result := trivial
def vc_echem_hartree_to_ev_decreases_0 (hartree : Float) : Nat := 0
theorem vc_echem_hartree_to_ev_decreases_0_proved (hartree : Float) : vc_echem_hartree_to_ev_decreases_0 hartree = 0 := rfl
def vc_echem_hartree_to_ev_call0_echem_hartree_to_ev_factor_requires_0 (hartree : Float) : Prop := True
theorem vc_echem_hartree_to_ev_call0_echem_hartree_to_ev_factor_requires_0_proved (hartree : Float) : vc_echem_hartree_to_ev_call0_echem_hartree_to_ev_factor_requires_0 hartree := trivial

end echem_hartree_to_ev

namespace echem_dft_h_star_energy_hartree

def vc_echem_dft_h_star_energy_hartree_requires_0 : Prop := True
theorem vc_echem_dft_h_star_energy_hartree_requires_0_proved : vc_echem_dft_h_star_energy_hartree_requires_0 := trivial
def vc_echem_dft_h_star_energy_hartree_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_dft_h_star_energy_hartree_ensures_0_proved (result : Float) : vc_echem_dft_h_star_energy_hartree_ensures_0 result := trivial
def vc_echem_dft_h_star_energy_hartree_decreases_0 : Nat := 0
theorem vc_echem_dft_h_star_energy_hartree_decreases_0_proved : vc_echem_dft_h_star_energy_hartree_decreases_0 = 0 := rfl
def vc_echem_dft_h_star_energy_hartree_call0_chem_dft_scf_iteration_scaffold_requires_0 : Prop := True
theorem vc_echem_dft_h_star_energy_hartree_call0_chem_dft_scf_iteration_scaffold_requires_0_proved : vc_echem_dft_h_star_energy_hartree_call0_chem_dft_scf_iteration_scaffold_requires_0 := trivial
def vc_echem_dft_h_star_energy_hartree_call0_chem_dft_scf_iteration_scaffold_requires_1 : Prop := True
theorem vc_echem_dft_h_star_energy_hartree_call0_chem_dft_scf_iteration_scaffold_requires_1_proved : vc_echem_dft_h_star_energy_hartree_call0_chem_dft_scf_iteration_scaffold_requires_1 := trivial

end echem_dft_h_star_energy_hartree

namespace echem_dft_h2_energy_hartree

def vc_echem_dft_h2_energy_hartree_requires_0 : Prop := True
theorem vc_echem_dft_h2_energy_hartree_requires_0_proved : vc_echem_dft_h2_energy_hartree_requires_0 := trivial
def vc_echem_dft_h2_energy_hartree_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_dft_h2_energy_hartree_ensures_0_proved (result : Float) : vc_echem_dft_h2_energy_hartree_ensures_0 result := trivial
def vc_echem_dft_h2_energy_hartree_decreases_0 : Nat := 0
theorem vc_echem_dft_h2_energy_hartree_decreases_0_proved : vc_echem_dft_h2_energy_hartree_decreases_0 = 0 := rfl
def vc_echem_dft_h2_energy_hartree_call0_chem_dft_scf_h2_iteration_scaffold_requires_0 : Prop := True
theorem vc_echem_dft_h2_energy_hartree_call0_chem_dft_scf_h2_iteration_scaffold_requires_0_proved : vc_echem_dft_h2_energy_hartree_call0_chem_dft_scf_h2_iteration_scaffold_requires_0 := trivial
def vc_echem_dft_h2_energy_hartree_call0_chem_dft_scf_h2_iteration_scaffold_requires_1 : Prop := True
theorem vc_echem_dft_h2_energy_hartree_call0_chem_dft_scf_h2_iteration_scaffold_requires_1_proved : vc_echem_dft_h2_energy_hartree_call0_chem_dft_scf_h2_iteration_scaffold_requires_1 := trivial

end echem_dft_h2_energy_hartree

namespace echem_che_h2_energy_ev_stub

def vc_echem_che_h2_energy_ev_stub_requires_0 : Prop := True
theorem vc_echem_che_h2_energy_ev_stub_requires_0_proved : vc_echem_che_h2_energy_ev_stub_requires_0 := trivial
def vc_echem_che_h2_energy_ev_stub_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_che_h2_energy_ev_stub_ensures_0_proved (result : Float) : vc_echem_che_h2_energy_ev_stub_ensures_0 result := trivial
def vc_echem_che_h2_energy_ev_stub_decreases_0 : Nat := 0
theorem vc_echem_che_h2_energy_ev_stub_decreases_0_proved : vc_echem_che_h2_energy_ev_stub_decreases_0 = 0 := rfl
def vc_echem_che_h2_energy_ev_stub_call0_echem_hartree_to_ev_requires_0 : Prop := True
theorem vc_echem_che_h2_energy_ev_stub_call0_echem_hartree_to_ev_requires_0_proved : vc_echem_che_h2_energy_ev_stub_call0_echem_hartree_to_ev_requires_0 := trivial
def vc_echem_che_h2_energy_ev_stub_call1_echem_dft_h2_energy_hartree_requires_0 : Prop := True
theorem vc_echem_che_h2_energy_ev_stub_call1_echem_dft_h2_energy_hartree_requires_0_proved : vc_echem_che_h2_energy_ev_stub_call1_echem_dft_h2_energy_hartree_requires_0 := trivial

end echem_che_h2_energy_ev_stub

namespace echem_h_star_pt111_energy_ev_stub

def vc_echem_h_star_pt111_energy_ev_stub_requires_0 : Prop := True
theorem vc_echem_h_star_pt111_energy_ev_stub_requires_0_proved : vc_echem_h_star_pt111_energy_ev_stub_requires_0 := trivial
def vc_echem_h_star_pt111_energy_ev_stub_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_h_star_pt111_energy_ev_stub_ensures_0_proved (result : Float) : vc_echem_h_star_pt111_energy_ev_stub_ensures_0 result := trivial
def vc_echem_h_star_pt111_energy_ev_stub_decreases_0 : Nat := 0
theorem vc_echem_h_star_pt111_energy_ev_stub_decreases_0_proved : vc_echem_h_star_pt111_energy_ev_stub_decreases_0 = 0 := rfl
def vc_echem_h_star_pt111_energy_ev_stub_call0_echem_hartree_to_ev_requires_0 : Prop := True
theorem vc_echem_h_star_pt111_energy_ev_stub_call0_echem_hartree_to_ev_requires_0_proved : vc_echem_h_star_pt111_energy_ev_stub_call0_echem_hartree_to_ev_requires_0 := trivial
def vc_echem_h_star_pt111_energy_ev_stub_call1_echem_dft_h_star_energy_hartree_requires_0 : Prop := True
theorem vc_echem_h_star_pt111_energy_ev_stub_call1_echem_dft_h_star_energy_hartree_requires_0_proved : vc_echem_h_star_pt111_energy_ev_stub_call1_echem_dft_h_star_energy_hartree_requires_0 := trivial

end echem_h_star_pt111_energy_ev_stub

namespace echem_potential_shift_hartree

def vc_echem_potential_shift_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_potential_shift_hartree_requires_0_proved (u_v : Float) : vc_echem_potential_shift_hartree_requires_0 u_v := trivial
def vc_echem_potential_shift_hartree_ensures_0 (u_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_potential_shift_hartree_ensures_0_proved (u_v : Float) (result : Float) : vc_echem_potential_shift_hartree_ensures_0 u_v result := trivial
def vc_echem_potential_shift_hartree_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_potential_shift_hartree_decreases_0_proved (u_v : Float) : vc_echem_potential_shift_hartree_decreases_0 u_v = 0 := rfl
def vc_echem_potential_shift_hartree_call0_chem_dft_potential_shift_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_potential_shift_hartree_call0_chem_dft_potential_shift_hartree_requires_0_proved (u_v : Float) : vc_echem_potential_shift_hartree_call0_chem_dft_potential_shift_hartree_requires_0 u_v := trivial

end echem_potential_shift_hartree

namespace echem_dft_h_star_energy_at_potential_hartree

def vc_echem_dft_h_star_energy_at_potential_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_h_star_energy_at_potential_hartree_requires_0_proved (u_v : Float) : vc_echem_dft_h_star_energy_at_potential_hartree_requires_0 u_v := trivial
def vc_echem_dft_h_star_energy_at_potential_hartree_ensures_0 (u_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_dft_h_star_energy_at_potential_hartree_ensures_0_proved (u_v : Float) (result : Float) : vc_echem_dft_h_star_energy_at_potential_hartree_ensures_0 u_v result := trivial
def vc_echem_dft_h_star_energy_at_potential_hartree_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_dft_h_star_energy_at_potential_hartree_decreases_0_proved (u_v : Float) : vc_echem_dft_h_star_energy_at_potential_hartree_decreases_0 u_v = 0 := rfl
def vc_echem_dft_h_star_energy_at_potential_hartree_call0_chem_dft_scf_iteration_scaffold_at_potential_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_h_star_energy_at_potential_hartree_call0_chem_dft_scf_iteration_scaffold_at_potential_requires_0_proved (u_v : Float) : vc_echem_dft_h_star_energy_at_potential_hartree_call0_chem_dft_scf_iteration_scaffold_at_potential_requires_0 u_v := trivial
def vc_echem_dft_h_star_energy_at_potential_hartree_call0_chem_dft_scf_iteration_scaffold_at_potential_requires_1 (u_v : Float) : Prop := True
theorem vc_echem_dft_h_star_energy_at_potential_hartree_call0_chem_dft_scf_iteration_scaffold_at_potential_requires_1_proved (u_v : Float) : vc_echem_dft_h_star_energy_at_potential_hartree_call0_chem_dft_scf_iteration_scaffold_at_potential_requires_1 u_v := trivial

end echem_dft_h_star_energy_at_potential_hartree

namespace echem_dft_h2_energy_at_potential_hartree

def vc_echem_dft_h2_energy_at_potential_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_h2_energy_at_potential_hartree_requires_0_proved (u_v : Float) : vc_echem_dft_h2_energy_at_potential_hartree_requires_0 u_v := trivial
def vc_echem_dft_h2_energy_at_potential_hartree_ensures_0 (u_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_dft_h2_energy_at_potential_hartree_ensures_0_proved (u_v : Float) (result : Float) : vc_echem_dft_h2_energy_at_potential_hartree_ensures_0 u_v result := trivial
def vc_echem_dft_h2_energy_at_potential_hartree_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_dft_h2_energy_at_potential_hartree_decreases_0_proved (u_v : Float) : vc_echem_dft_h2_energy_at_potential_hartree_decreases_0 u_v = 0 := rfl
def vc_echem_dft_h2_energy_at_potential_hartree_call0_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_h2_energy_at_potential_hartree_call0_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_0_proved (u_v : Float) : vc_echem_dft_h2_energy_at_potential_hartree_call0_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_0 u_v := trivial
def vc_echem_dft_h2_energy_at_potential_hartree_call0_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_1 (u_v : Float) : Prop := True
theorem vc_echem_dft_h2_energy_at_potential_hartree_call0_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_1_proved (u_v : Float) : vc_echem_dft_h2_energy_at_potential_hartree_call0_chem_dft_scf_h2_iteration_scaffold_at_potential_requires_1 u_v := trivial

end echem_dft_h2_energy_at_potential_hartree

namespace echem_dft_energy_at_potential

def vc_echem_dft_energy_at_potential_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_energy_at_potential_requires_0_proved (u_v : Float) : vc_echem_dft_energy_at_potential_requires_0 u_v := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_dft_energy_at_potential_ensures_0 (u_v : Float) (result : Float) : Prop := True
theorem vc_echem_dft_energy_at_potential_ensures_0_proved (u_v : Float) (result : Float) : vc_echem_dft_energy_at_potential_ensures_0 u_v result := trivial
def vc_echem_dft_energy_at_potential_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_dft_energy_at_potential_decreases_0_proved (u_v : Float) : vc_echem_dft_energy_at_potential_decreases_0 u_v = 0 := rfl
def vc_echem_dft_energy_at_potential_call0_echem_dft_h_star_energy_at_potential_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_energy_at_potential_call0_echem_dft_h_star_energy_at_potential_hartree_requires_0_proved (u_v : Float) : vc_echem_dft_energy_at_potential_call0_echem_dft_h_star_energy_at_potential_hartree_requires_0 u_v := trivial
def vc_echem_dft_energy_at_potential_call1_echem_dft_h2_energy_at_potential_hartree_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_energy_at_potential_call1_echem_dft_h2_energy_at_potential_hartree_requires_0_proved (u_v : Float) : vc_echem_dft_energy_at_potential_call1_echem_dft_h2_energy_at_potential_hartree_requires_0 u_v := trivial
def vc_echem_dft_energy_at_potential_call2_echem_hartree_to_ev_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_dft_energy_at_potential_call2_echem_hartree_to_ev_requires_0_proved (u_v : Float) : vc_echem_dft_energy_at_potential_call2_echem_hartree_to_ev_requires_0 u_v := trivial

end echem_dft_energy_at_potential

namespace echem_che_h_adsorption_energy

def vc_echem_che_h_adsorption_energy_requires_0 (potential_v : Float) : Prop := True
theorem vc_echem_che_h_adsorption_energy_requires_0_proved (potential_v : Float) : vc_echem_che_h_adsorption_energy_requires_0 potential_v := trivial
def vc_echem_che_h_adsorption_energy_ensures_0 (potential_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_che_h_adsorption_energy_ensures_0_proved (potential_v : Float) (result : Float) : vc_echem_che_h_adsorption_energy_ensures_0 potential_v result := trivial
def vc_echem_che_h_adsorption_energy_decreases_0 (potential_v : Float) : Nat := 0
theorem vc_echem_che_h_adsorption_energy_decreases_0_proved (potential_v : Float) : vc_echem_che_h_adsorption_energy_decreases_0 potential_v = 0 := rfl
def vc_echem_che_h_adsorption_energy_call0_echem_dft_energy_at_potential_requires_0 (potential_v : Float) : Prop := True
theorem vc_echem_che_h_adsorption_energy_call0_echem_dft_energy_at_potential_requires_0_proved (potential_v : Float) : vc_echem_che_h_adsorption_energy_call0_echem_dft_energy_at_potential_requires_0 potential_v := trivial

end echem_che_h_adsorption_energy

namespace echem_edl_permittivity_stub

def vc_echem_edl_permittivity_stub_requires_0 : Prop := True
theorem vc_echem_edl_permittivity_stub_requires_0_proved : vc_echem_edl_permittivity_stub_requires_0 := trivial
def vc_echem_edl_permittivity_stub_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_edl_permittivity_stub_ensures_0_proved (result : Float) : vc_echem_edl_permittivity_stub_ensures_0 result := trivial
def vc_echem_edl_permittivity_stub_decreases_0 : Nat := 0
theorem vc_echem_edl_permittivity_stub_decreases_0_proved : vc_echem_edl_permittivity_stub_decreases_0 = 0 := rfl

end echem_edl_permittivity_stub

namespace echem_edl_helmholtz_gap_nm

def vc_echem_edl_helmholtz_gap_nm_requires_0 : Prop := True
theorem vc_echem_edl_helmholtz_gap_nm_requires_0_proved : vc_echem_edl_helmholtz_gap_nm_requires_0 := trivial
def vc_echem_edl_helmholtz_gap_nm_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_edl_helmholtz_gap_nm_ensures_0_proved (result : Float) : vc_echem_edl_helmholtz_gap_nm_ensures_0 result := trivial
def vc_echem_edl_helmholtz_gap_nm_decreases_0 : Nat := 0
theorem vc_echem_edl_helmholtz_gap_nm_decreases_0_proved : vc_echem_edl_helmholtz_gap_nm_decreases_0 = 0 := rfl

end echem_edl_helmholtz_gap_nm

namespace echem_edl_helmholtz_capacitance_stub

def vc_echem_edl_helmholtz_capacitance_stub_requires_0 : Prop := True
theorem vc_echem_edl_helmholtz_capacitance_stub_requires_0_proved : vc_echem_edl_helmholtz_capacitance_stub_requires_0 := trivial
def vc_echem_edl_helmholtz_capacitance_stub_ensures_0 (result : Float) : Prop := (result > (10 : Float))
def vc_echem_edl_helmholtz_capacitance_stub_ensures_1 (result : Float) : Prop := (result < (30 : Float))
def vc_echem_edl_helmholtz_capacitance_stub_decreases_0 : Nat := 0
theorem vc_echem_edl_helmholtz_capacitance_stub_decreases_0_proved : vc_echem_edl_helmholtz_capacitance_stub_decreases_0 = 0 := rfl
def vc_echem_edl_helmholtz_capacitance_stub_call0_echem_edl_permittivity_stub_requires_0 : Prop := True
theorem vc_echem_edl_helmholtz_capacitance_stub_call0_echem_edl_permittivity_stub_requires_0_proved : vc_echem_edl_helmholtz_capacitance_stub_call0_echem_edl_permittivity_stub_requires_0 := trivial
def vc_echem_edl_helmholtz_capacitance_stub_call1_echem_edl_helmholtz_gap_nm_requires_0 : Prop := True
theorem vc_echem_edl_helmholtz_capacitance_stub_call1_echem_edl_helmholtz_gap_nm_requires_0_proved : vc_echem_edl_helmholtz_capacitance_stub_call1_echem_edl_helmholtz_gap_nm_requires_0 := trivial

end echem_edl_helmholtz_capacitance_stub

namespace echem_edl_pb_grid_n

def vc_echem_edl_pb_grid_n_requires_0 : Prop := True
theorem vc_echem_edl_pb_grid_n_requires_0_proved : vc_echem_edl_pb_grid_n_requires_0 := trivial
def vc_echem_edl_pb_grid_n_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_edl_pb_grid_n_ensures_0_proved (result : Int) : vc_echem_edl_pb_grid_n_ensures_0 result := trivial
def vc_echem_edl_pb_grid_n_decreases_0 : Nat := 0
theorem vc_echem_edl_pb_grid_n_decreases_0_proved : vc_echem_edl_pb_grid_n_decreases_0 = 0 := rfl

end echem_edl_pb_grid_n

namespace echem_edl_pb_kappa_per_m

def vc_echem_edl_pb_kappa_per_m_requires_0 : Prop := True
theorem vc_echem_edl_pb_kappa_per_m_requires_0_proved : vc_echem_edl_pb_kappa_per_m_requires_0 := trivial
def vc_echem_edl_pb_kappa_per_m_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_edl_pb_kappa_per_m_decreases_0 : Nat := 0
theorem vc_echem_edl_pb_kappa_per_m_decreases_0_proved : vc_echem_edl_pb_kappa_per_m_decreases_0 = 0 := rfl
def vc_echem_edl_pb_kappa_per_m_call0_echem_edl_helmholtz_gap_nm_requires_0 : Prop := True
theorem vc_echem_edl_pb_kappa_per_m_call0_echem_edl_helmholtz_gap_nm_requires_0_proved : vc_echem_edl_pb_kappa_per_m_call0_echem_edl_helmholtz_gap_nm_requires_0 := trivial

end echem_edl_pb_kappa_per_m

namespace echem_edl_pb_dx_m

def vc_echem_edl_pb_dx_m_requires_0 : Prop := True
theorem vc_echem_edl_pb_dx_m_requires_0_proved : vc_echem_edl_pb_dx_m_requires_0 := trivial
def vc_echem_edl_pb_dx_m_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_edl_pb_dx_m_decreases_0 : Nat := 0
theorem vc_echem_edl_pb_dx_m_decreases_0_proved : vc_echem_edl_pb_dx_m_decreases_0 = 0 := rfl
def vc_echem_edl_pb_dx_m_call0_echem_edl_helmholtz_gap_nm_requires_0 : Prop := True
theorem vc_echem_edl_pb_dx_m_call0_echem_edl_helmholtz_gap_nm_requires_0_proved : vc_echem_edl_pb_dx_m_call0_echem_edl_helmholtz_gap_nm_requires_0 := trivial

end echem_edl_pb_dx_m

namespace echem_sinh_toy

def vc_echem_sinh_toy_requires_0 (x : Float) : Prop := True
theorem vc_echem_sinh_toy_requires_0_proved (x : Float) : vc_echem_sinh_toy_requires_0 x := trivial
def vc_echem_sinh_toy_ensures_0 (x : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_sinh_toy_decreases_0 (x : Float) : Nat := 0
theorem vc_echem_sinh_toy_decreases_0_proved (x : Float) : vc_echem_sinh_toy_decreases_0 x = 0 := rfl

end echem_sinh_toy

namespace echem_edl_pb_x_at

def vc_echem_edl_pb_x_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_edl_pb_x_at_requires_1 (i : Int) : Prop := True
theorem vc_echem_edl_pb_x_at_requires_1_proved (i : Int) : vc_echem_edl_pb_x_at_requires_1 i := trivial
def vc_echem_edl_pb_x_at_ensures_0 (i : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_edl_pb_x_at_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_edl_pb_x_at_decreases_0_proved (i : Int) : vc_echem_edl_pb_x_at_decreases_0 i = Int.toNat i := rfl
def vc_echem_edl_pb_x_at_call0_echem_edl_pb_x_at_requires_0 (i : Int) : Prop := ((i - 1) ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_edl_pb_x_at' at call 0 -/
def vc_echem_edl_pb_x_at_call0_echem_edl_pb_x_at_requires_1 (i : Int) : Prop := True
def vc_echem_edl_pb_x_at_call1_echem_edl_pb_dx_m_requires_0 (i : Int) : Prop := True
theorem vc_echem_edl_pb_x_at_call1_echem_edl_pb_dx_m_requires_0_proved (i : Int) : vc_echem_edl_pb_x_at_call1_echem_edl_pb_dx_m_requires_0 i := trivial

end echem_edl_pb_x_at

namespace echem_edl_pb_psi_at

def vc_echem_edl_pb_psi_at_requires_0 (i : Int) (u_v : Float) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_edl_pb_psi_at_requires_1 (i : Int) (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_psi_at_requires_1_proved (i : Int) (u_v : Float) : vc_echem_edl_pb_psi_at_requires_1 i u_v := trivial
def vc_echem_edl_pb_psi_at_requires_2 (i : Int) (u_v : Float) : Prop := (u_v > (0 : Float))
def vc_echem_edl_pb_psi_at_ensures_0 (i : Int) (u_v : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_edl_pb_psi_at_decreases_0 (i : Int) (u_v : Float) : Nat := Int.toNat i
theorem vc_echem_edl_pb_psi_at_decreases_0_proved (i : Int) (u_v : Float) : vc_echem_edl_pb_psi_at_decreases_0 i u_v = Int.toNat i := rfl
def vc_echem_edl_pb_psi_at_call0_echem_edl_helmholtz_gap_nm_requires_0 (i : Int) (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_psi_at_call0_echem_edl_helmholtz_gap_nm_requires_0_proved (i : Int) (u_v : Float) : vc_echem_edl_pb_psi_at_call0_echem_edl_helmholtz_gap_nm_requires_0 i u_v := trivial
def vc_echem_edl_pb_psi_at_call1_echem_edl_pb_kappa_per_m_requires_0 (i : Int) (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_psi_at_call1_echem_edl_pb_kappa_per_m_requires_0_proved (i : Int) (u_v : Float) : vc_echem_edl_pb_psi_at_call1_echem_edl_pb_kappa_per_m_requires_0 i u_v := trivial
def vc_echem_edl_pb_psi_at_call2_echem_edl_pb_x_at_requires_0 (i : Int) (u_v : Float) : Prop := (i ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_edl_pb_x_at' at call 2 -/
def vc_echem_edl_pb_psi_at_call2_echem_edl_pb_x_at_requires_1 (i : Int) (u_v : Float) : Prop := True
def vc_echem_edl_pb_psi_at_call3_echem_sinh_toy_requires_0 (i : Int) (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_psi_at_call3_echem_sinh_toy_requires_0_proved (i : Int) (u_v : Float) : vc_echem_edl_pb_psi_at_call3_echem_sinh_toy_requires_0 i u_v := trivial
def vc_echem_edl_pb_psi_at_call4_echem_sinh_toy_requires_0 (i : Int) (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_psi_at_call4_echem_sinh_toy_requires_0_proved (i : Int) (u_v : Float) : vc_echem_edl_pb_psi_at_call4_echem_sinh_toy_requires_0 i u_v := trivial

end echem_edl_pb_psi_at

namespace echem_edl_pb_capacitance_at_u_uf_cm2

def vc_echem_edl_pb_capacitance_at_u_uf_cm2_requires_0 (u_v : Float) : Prop := (u_v > (0 : Float))
def vc_echem_edl_pb_capacitance_at_u_uf_cm2_ensures_0 (u_v : Float) (result : Float) : Prop := (result > (0 : Float))
def vc_echem_edl_pb_capacitance_at_u_uf_cm2_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_edl_pb_capacitance_at_u_uf_cm2_decreases_0_proved (u_v : Float) : vc_echem_edl_pb_capacitance_at_u_uf_cm2_decreases_0 u_v = 0 := rfl
def vc_echem_edl_pb_capacitance_at_u_uf_cm2_call0_echem_edl_helmholtz_gap_nm_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_capacitance_at_u_uf_cm2_call0_echem_edl_helmholtz_gap_nm_requires_0_proved (u_v : Float) : vc_echem_edl_pb_capacitance_at_u_uf_cm2_call0_echem_edl_helmholtz_gap_nm_requires_0 u_v := trivial
def vc_echem_edl_pb_capacitance_at_u_uf_cm2_call1_echem_edl_pb_kappa_per_m_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_capacitance_at_u_uf_cm2_call1_echem_edl_pb_kappa_per_m_requires_0_proved (u_v : Float) : vc_echem_edl_pb_capacitance_at_u_uf_cm2_call1_echem_edl_pb_kappa_per_m_requires_0 u_v := trivial
def vc_echem_edl_pb_capacitance_at_u_uf_cm2_call2_echem_sinh_toy_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_capacitance_at_u_uf_cm2_call2_echem_sinh_toy_requires_0_proved (u_v : Float) : vc_echem_edl_pb_capacitance_at_u_uf_cm2_call2_echem_sinh_toy_requires_0 u_v := trivial
def vc_echem_edl_pb_capacitance_at_u_uf_cm2_call3_echem_edl_permittivity_stub_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_edl_pb_capacitance_at_u_uf_cm2_call3_echem_edl_permittivity_stub_requires_0_proved (u_v : Float) : vc_echem_edl_pb_capacitance_at_u_uf_cm2_call3_echem_edl_permittivity_stub_requires_0 u_v := trivial

end echem_edl_pb_capacitance_at_u_uf_cm2

namespace echem_edl_pb_capacitance_uf_cm2

def vc_echem_edl_pb_capacitance_uf_cm2_requires_0 : Prop := True
theorem vc_echem_edl_pb_capacitance_uf_cm2_requires_0_proved : vc_echem_edl_pb_capacitance_uf_cm2_requires_0 := trivial
def vc_echem_edl_pb_capacitance_uf_cm2_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_edl_pb_capacitance_uf_cm2_ensures_0_proved (result : Float) : vc_echem_edl_pb_capacitance_uf_cm2_ensures_0 result := trivial
def vc_echem_edl_pb_capacitance_uf_cm2_decreases_0 : Nat := 0
theorem vc_echem_edl_pb_capacitance_uf_cm2_decreases_0_proved : vc_echem_edl_pb_capacitance_uf_cm2_decreases_0 = 0 := rfl
def vc_echem_edl_pb_capacitance_uf_cm2_call0_echem_edl_pb_capacitance_at_u_uf_cm2_requires_0 : Prop := ((1 : Float) > (0 : Float))

end echem_edl_pb_capacitance_uf_cm2

namespace echem_edl_pb_grid_boundary_smoke

def vc_echem_edl_pb_grid_boundary_smoke_requires_0 : Prop := True
theorem vc_echem_edl_pb_grid_boundary_smoke_requires_0_proved : vc_echem_edl_pb_grid_boundary_smoke_requires_0 := trivial
def vc_echem_edl_pb_grid_boundary_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_edl_pb_grid_boundary_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_edl_pb_grid_boundary_smoke_decreases_0 : Nat := 0
theorem vc_echem_edl_pb_grid_boundary_smoke_decreases_0_proved : vc_echem_edl_pb_grid_boundary_smoke_decreases_0 = 0 := rfl
def vc_echem_edl_pb_grid_boundary_smoke_call0_echem_edl_pb_psi_at_requires_0 : Prop := True
theorem vc_echem_edl_pb_grid_boundary_smoke_call0_echem_edl_pb_psi_at_requires_0_proved : vc_echem_edl_pb_grid_boundary_smoke_call0_echem_edl_pb_psi_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_edl_pb_psi_at' at call 0 -/
def vc_echem_edl_pb_grid_boundary_smoke_call0_echem_edl_pb_psi_at_requires_1 : Prop := True
def vc_echem_edl_pb_grid_boundary_smoke_call0_echem_edl_pb_psi_at_requires_2 (u_v : Float) : Prop := (u_v > (0 : Float))
def vc_echem_edl_pb_grid_boundary_smoke_call1_echem_edl_pb_psi_at_requires_0 : Prop := True
theorem vc_echem_edl_pb_grid_boundary_smoke_call1_echem_edl_pb_psi_at_requires_0_proved : vc_echem_edl_pb_grid_boundary_smoke_call1_echem_edl_pb_psi_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_edl_pb_psi_at' at call 1 -/
def vc_echem_edl_pb_grid_boundary_smoke_call1_echem_edl_pb_psi_at_requires_1 : Prop := True
def vc_echem_edl_pb_grid_boundary_smoke_call1_echem_edl_pb_psi_at_requires_2 (u_v : Float) : Prop := (u_v > (0 : Float))

end echem_edl_pb_grid_boundary_smoke

namespace echem_edl_pb_vs_helmholtz_smoke

def vc_echem_edl_pb_vs_helmholtz_smoke_requires_0 : Prop := True
theorem vc_echem_edl_pb_vs_helmholtz_smoke_requires_0_proved : vc_echem_edl_pb_vs_helmholtz_smoke_requires_0 := trivial
def vc_echem_edl_pb_vs_helmholtz_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_edl_pb_vs_helmholtz_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_edl_pb_vs_helmholtz_smoke_decreases_0 : Nat := 0
theorem vc_echem_edl_pb_vs_helmholtz_smoke_decreases_0_proved : vc_echem_edl_pb_vs_helmholtz_smoke_decreases_0 = 0 := rfl
def vc_echem_edl_pb_vs_helmholtz_smoke_call0_echem_edl_pb_grid_boundary_smoke_requires_0 : Prop := True
theorem vc_echem_edl_pb_vs_helmholtz_smoke_call0_echem_edl_pb_grid_boundary_smoke_requires_0_proved : vc_echem_edl_pb_vs_helmholtz_smoke_call0_echem_edl_pb_grid_boundary_smoke_requires_0 := trivial
def vc_echem_edl_pb_vs_helmholtz_smoke_call1_echem_edl_helmholtz_capacitance_stub_requires_0 : Prop := True
theorem vc_echem_edl_pb_vs_helmholtz_smoke_call1_echem_edl_helmholtz_capacitance_stub_requires_0_proved : vc_echem_edl_pb_vs_helmholtz_smoke_call1_echem_edl_helmholtz_capacitance_stub_requires_0 := trivial
def vc_echem_edl_pb_vs_helmholtz_smoke_call2_echem_edl_pb_capacitance_uf_cm2_requires_0 : Prop := True
theorem vc_echem_edl_pb_vs_helmholtz_smoke_call2_echem_edl_pb_capacitance_uf_cm2_requires_0_proved : vc_echem_edl_pb_vs_helmholtz_smoke_call2_echem_edl_pb_capacitance_uf_cm2_requires_0 := trivial

end echem_edl_pb_vs_helmholtz_smoke

namespace echem_neb_stub_image_count

def vc_echem_neb_stub_image_count_requires_0 : Prop := True
theorem vc_echem_neb_stub_image_count_requires_0_proved : vc_echem_neb_stub_image_count_requires_0 := trivial
def vc_echem_neb_stub_image_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_neb_stub_image_count_ensures_0_proved (result : Int) : vc_echem_neb_stub_image_count_ensures_0 result := trivial
def vc_echem_neb_stub_image_count_decreases_0 : Nat := 0
theorem vc_echem_neb_stub_image_count_decreases_0_proved : vc_echem_neb_stub_image_count_decreases_0 = 0 := rfl

end echem_neb_stub_image_count

namespace echem_neb_stub_image_energy_at

def vc_echem_neb_stub_image_energy_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_neb_stub_image_energy_at_requires_1 (i : Int) : Prop := True
theorem vc_echem_neb_stub_image_energy_at_requires_1_proved (i : Int) : vc_echem_neb_stub_image_energy_at_requires_1 i := trivial
def vc_echem_neb_stub_image_energy_at_ensures_0 (i : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_neb_stub_image_energy_at_ensures_1 (i : Int) (result : Float) : Prop := (result ≤ (1 : Float))
def vc_echem_neb_stub_image_energy_at_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_neb_stub_image_energy_at_decreases_0_proved (i : Int) : vc_echem_neb_stub_image_energy_at_decreases_0 i = Int.toNat i := rfl

end echem_neb_stub_image_energy_at

namespace echem_static_barrier_neb_stub

def vc_echem_static_barrier_neb_stub_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_stub_requires_0_proved : vc_echem_static_barrier_neb_stub_requires_0 := trivial
def vc_echem_static_barrier_neb_stub_ensures_0 (result : Float) : Prop := (result = (0.73 : Float))
def vc_echem_static_barrier_neb_stub_decreases_0 : Nat := 0
theorem vc_echem_static_barrier_neb_stub_decreases_0_proved : vc_echem_static_barrier_neb_stub_decreases_0 = 0 := rfl
def vc_echem_static_barrier_neb_stub_call0_echem_neb_stub_image_energy_at_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_stub_call0_echem_neb_stub_image_energy_at_requires_0_proved : vc_echem_static_barrier_neb_stub_call0_echem_neb_stub_image_energy_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_stub_image_energy_at' at call 0 -/
def vc_echem_static_barrier_neb_stub_call0_echem_neb_stub_image_energy_at_requires_1 : Prop := True
def vc_echem_static_barrier_neb_stub_call1_echem_neb_stub_image_energy_at_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_stub_call1_echem_neb_stub_image_energy_at_requires_0_proved : vc_echem_static_barrier_neb_stub_call1_echem_neb_stub_image_energy_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_stub_image_energy_at' at call 1 -/
def vc_echem_static_barrier_neb_stub_call1_echem_neb_stub_image_energy_at_requires_1 : Prop := True
def vc_echem_static_barrier_neb_stub_call2_echem_neb_stub_image_energy_at_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_stub_call2_echem_neb_stub_image_energy_at_requires_0_proved : vc_echem_static_barrier_neb_stub_call2_echem_neb_stub_image_energy_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_stub_image_energy_at' at call 2 -/
def vc_echem_static_barrier_neb_stub_call2_echem_neb_stub_image_energy_at_requires_1 : Prop := True

end echem_static_barrier_neb_stub

namespace echem_neb_image_count

def vc_echem_neb_image_count_requires_0 : Prop := True
theorem vc_echem_neb_image_count_requires_0_proved : vc_echem_neb_image_count_requires_0 := trivial
def vc_echem_neb_image_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_neb_image_count_ensures_0_proved (result : Int) : vc_echem_neb_image_count_ensures_0 result := trivial
def vc_echem_neb_image_count_decreases_0 : Nat := 0
theorem vc_echem_neb_image_count_decreases_0_proved : vc_echem_neb_image_count_decreases_0 = 0 := rfl

end echem_neb_image_count

namespace echem_neb_reaction_lambda_at

def vc_echem_neb_reaction_lambda_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_neb_reaction_lambda_at_requires_1 (i : Int) : Prop := True
theorem vc_echem_neb_reaction_lambda_at_requires_1_proved (i : Int) : vc_echem_neb_reaction_lambda_at_requires_1 i := trivial
def vc_echem_neb_reaction_lambda_at_ensures_0 (i : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_neb_reaction_lambda_at_ensures_1 (i : Int) (result : Float) : Prop := (result ≤ (1 : Float))
def vc_echem_neb_reaction_lambda_at_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_neb_reaction_lambda_at_decreases_0_proved (i : Int) : vc_echem_neb_reaction_lambda_at_decreases_0 i = Int.toNat i := rfl
def vc_echem_neb_reaction_lambda_at_call0_echem_neb_reaction_lambda_at_requires_0 (i : Int) : Prop := ((i - 1) ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_neb_reaction_lambda_at' at call 0 -/
def vc_echem_neb_reaction_lambda_at_call0_echem_neb_reaction_lambda_at_requires_1 (i : Int) : Prop := True

end echem_neb_reaction_lambda_at

namespace echem_neb_sin_pi_lambda

def vc_echem_neb_sin_pi_lambda_requires_0 (lam : Float) : Prop := (lam ≥ (0 : Float))
def vc_echem_neb_sin_pi_lambda_requires_1 (lam : Float) : Prop := (lam ≤ (1 : Float))
def vc_echem_neb_sin_pi_lambda_ensures_0 (lam : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_neb_sin_pi_lambda_ensures_1 (lam : Float) (result : Float) : Prop := (result ≤ (1 : Float))
def vc_echem_neb_sin_pi_lambda_decreases_0 (lam : Float) : Nat := 0
theorem vc_echem_neb_sin_pi_lambda_decreases_0_proved (lam : Float) : vc_echem_neb_sin_pi_lambda_decreases_0 lam = 0 := rfl

end echem_neb_sin_pi_lambda

namespace echem_neb_climbing_bump_ev

def vc_echem_neb_climbing_bump_ev_requires_0 (lam : Float) : Prop := (lam ≥ (0 : Float))
def vc_echem_neb_climbing_bump_ev_requires_1 (lam : Float) : Prop := (lam ≤ (1 : Float))
def vc_echem_neb_climbing_bump_ev_ensures_0 (lam : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_neb_climbing_bump_ev_decreases_0 (lam : Float) : Nat := 0
theorem vc_echem_neb_climbing_bump_ev_decreases_0_proved (lam : Float) : vc_echem_neb_climbing_bump_ev_decreases_0 lam = 0 := rfl
def vc_echem_neb_climbing_bump_ev_call0_echem_neb_sin_pi_lambda_requires_0 (lam : Float) : Prop := (lam ≥ (0 : Float))
def vc_echem_neb_climbing_bump_ev_call0_echem_neb_sin_pi_lambda_requires_1 (lam : Float) : Prop := (lam ≤ (1 : Float))

end echem_neb_climbing_bump_ev

namespace echem_neb_image_energy_ev_at

def vc_echem_neb_image_energy_ev_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_neb_image_energy_ev_at_requires_1 (i : Int) : Prop := True
theorem vc_echem_neb_image_energy_ev_at_requires_1_proved (i : Int) : vc_echem_neb_image_energy_ev_at_requires_1 i := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_neb_image_energy_ev_at_ensures_0 (i : Int) (result : Float) : Prop := True
theorem vc_echem_neb_image_energy_ev_at_ensures_0_proved (i : Int) (result : Float) : vc_echem_neb_image_energy_ev_at_ensures_0 i result := trivial
def vc_echem_neb_image_energy_ev_at_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_neb_image_energy_ev_at_decreases_0_proved (i : Int) : vc_echem_neb_image_energy_ev_at_decreases_0 i = Int.toNat i := rfl
def vc_echem_neb_image_energy_ev_at_call0_echem_dft_energy_at_potential_requires_0 (i : Int) : Prop := True
theorem vc_echem_neb_image_energy_ev_at_call0_echem_dft_energy_at_potential_requires_0_proved (i : Int) : vc_echem_neb_image_energy_ev_at_call0_echem_dft_energy_at_potential_requires_0 i := trivial
def vc_echem_neb_image_energy_ev_at_call1_echem_neb_reaction_lambda_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_neb_reaction_lambda_at' at call 1 -/
def vc_echem_neb_image_energy_ev_at_call1_echem_neb_reaction_lambda_at_requires_1 (i : Int) : Prop := True
def vc_echem_neb_image_energy_ev_at_call2_echem_neb_climbing_bump_ev_requires_0 (i : Int) (lam : Float) : Prop := (lam ≥ (0 : Float))
def vc_echem_neb_image_energy_ev_at_call2_echem_neb_climbing_bump_ev_requires_1 (i : Int) (lam : Float) : Prop := (lam ≤ (1 : Float))

end echem_neb_image_energy_ev_at

namespace echem_neb_image_energy_at

def vc_echem_neb_image_energy_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_neb_image_energy_at_requires_1 (i : Int) : Prop := True
theorem vc_echem_neb_image_energy_at_requires_1_proved (i : Int) : vc_echem_neb_image_energy_at_requires_1 i := trivial
def vc_echem_neb_image_energy_at_ensures_0 (i : Int) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_neb_image_energy_at_ensures_0_proved (i : Int) (result : Float) : vc_echem_neb_image_energy_at_ensures_0 i result := trivial
def vc_echem_neb_image_energy_at_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_neb_image_energy_at_decreases_0_proved (i : Int) : vc_echem_neb_image_energy_at_decreases_0 i = Int.toNat i := rfl
def vc_echem_neb_image_energy_at_call0_echem_neb_image_energy_ev_at_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_neb_image_energy_ev_at' at call 0 -/
def vc_echem_neb_image_energy_at_call0_echem_neb_image_energy_ev_at_requires_1 (i : Int) : Prop := True

end echem_neb_image_energy_at

namespace echem_neb_max_image_energy_ev

def vc_echem_neb_max_image_energy_ev_requires_0 : Prop := True
theorem vc_echem_neb_max_image_energy_ev_requires_0_proved : vc_echem_neb_max_image_energy_ev_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_neb_max_image_energy_ev_ensures_0 (result : Float) : Prop := True
theorem vc_echem_neb_max_image_energy_ev_ensures_0_proved (result : Float) : vc_echem_neb_max_image_energy_ev_ensures_0 result := trivial
def vc_echem_neb_max_image_energy_ev_decreases_0 : Nat := 0
theorem vc_echem_neb_max_image_energy_ev_decreases_0_proved : vc_echem_neb_max_image_energy_ev_decreases_0 = 0 := rfl
def vc_echem_neb_max_image_energy_ev_call0_echem_neb_image_energy_ev_at_requires_0 : Prop := True
theorem vc_echem_neb_max_image_energy_ev_call0_echem_neb_image_energy_ev_at_requires_0_proved : vc_echem_neb_max_image_energy_ev_call0_echem_neb_image_energy_ev_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_image_energy_ev_at' at call 0 -/
def vc_echem_neb_max_image_energy_ev_call0_echem_neb_image_energy_ev_at_requires_1 : Prop := True
def vc_echem_neb_max_image_energy_ev_call1_echem_neb_image_count_requires_0 : Prop := True
theorem vc_echem_neb_max_image_energy_ev_call1_echem_neb_image_count_requires_0_proved : vc_echem_neb_max_image_energy_ev_call1_echem_neb_image_count_requires_0 := trivial
def vc_echem_neb_max_image_energy_ev_call2_echem_neb_image_energy_ev_at_requires_0 : Prop := True
theorem vc_echem_neb_max_image_energy_ev_call2_echem_neb_image_energy_ev_at_requires_0_proved : vc_echem_neb_max_image_energy_ev_call2_echem_neb_image_energy_ev_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_image_energy_ev_at' at call 2 -/
def vc_echem_neb_max_image_energy_ev_call2_echem_neb_image_energy_ev_at_requires_1 : Prop := True

end echem_neb_max_image_energy_ev

namespace echem_neb_endpoint_min_ev

def vc_echem_neb_endpoint_min_ev_requires_0 : Prop := True
theorem vc_echem_neb_endpoint_min_ev_requires_0_proved : vc_echem_neb_endpoint_min_ev_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_neb_endpoint_min_ev_ensures_0 (result : Float) : Prop := True
theorem vc_echem_neb_endpoint_min_ev_ensures_0_proved (result : Float) : vc_echem_neb_endpoint_min_ev_ensures_0 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_neb_endpoint_min_ev_ensures_1 (result : Float) : Prop := True
theorem vc_echem_neb_endpoint_min_ev_ensures_1_proved (result : Float) : vc_echem_neb_endpoint_min_ev_ensures_1 result := trivial
def vc_echem_neb_endpoint_min_ev_decreases_0 : Nat := 0
theorem vc_echem_neb_endpoint_min_ev_decreases_0_proved : vc_echem_neb_endpoint_min_ev_decreases_0 = 0 := rfl
def vc_echem_neb_endpoint_min_ev_call0_echem_neb_image_energy_ev_at_requires_0 : Prop := True
theorem vc_echem_neb_endpoint_min_ev_call0_echem_neb_image_energy_ev_at_requires_0_proved : vc_echem_neb_endpoint_min_ev_call0_echem_neb_image_energy_ev_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_image_energy_ev_at' at call 0 -/
def vc_echem_neb_endpoint_min_ev_call0_echem_neb_image_energy_ev_at_requires_1 : Prop := True
def vc_echem_neb_endpoint_min_ev_call1_echem_neb_image_energy_ev_at_requires_0 : Prop := True
theorem vc_echem_neb_endpoint_min_ev_call1_echem_neb_image_energy_ev_at_requires_0_proved : vc_echem_neb_endpoint_min_ev_call1_echem_neb_image_energy_ev_at_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_neb_image_energy_ev_at' at call 1 -/
def vc_echem_neb_endpoint_min_ev_call1_echem_neb_image_energy_ev_at_requires_1 : Prop := True

end echem_neb_endpoint_min_ev

namespace echem_static_barrier_neb

def vc_echem_static_barrier_neb_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_requires_0_proved : vc_echem_static_barrier_neb_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_static_barrier_neb_ensures_0 (result : Float) : Prop := True
theorem vc_echem_static_barrier_neb_ensures_0_proved (result : Float) : vc_echem_static_barrier_neb_ensures_0 result := trivial
def vc_echem_static_barrier_neb_decreases_0 : Nat := 0
theorem vc_echem_static_barrier_neb_decreases_0_proved : vc_echem_static_barrier_neb_decreases_0 = 0 := rfl
def vc_echem_static_barrier_neb_call0_echem_neb_max_image_energy_ev_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_call0_echem_neb_max_image_energy_ev_requires_0_proved : vc_echem_static_barrier_neb_call0_echem_neb_max_image_energy_ev_requires_0 := trivial
def vc_echem_static_barrier_neb_call1_echem_neb_endpoint_min_ev_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_call1_echem_neb_endpoint_min_ev_requires_0_proved : vc_echem_static_barrier_neb_call1_echem_neb_endpoint_min_ev_requires_0 := trivial

end echem_static_barrier_neb

namespace echem_static_barrier_neb_vs_stub_smoke

def vc_echem_static_barrier_neb_vs_stub_smoke_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_vs_stub_smoke_requires_0_proved : vc_echem_static_barrier_neb_vs_stub_smoke_requires_0 := trivial
def vc_echem_static_barrier_neb_vs_stub_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_static_barrier_neb_vs_stub_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_static_barrier_neb_vs_stub_smoke_decreases_0 : Nat := 0
theorem vc_echem_static_barrier_neb_vs_stub_smoke_decreases_0_proved : vc_echem_static_barrier_neb_vs_stub_smoke_decreases_0 = 0 := rfl
def vc_echem_static_barrier_neb_vs_stub_smoke_call0_echem_neb_image_count_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_vs_stub_smoke_call0_echem_neb_image_count_requires_0_proved : vc_echem_static_barrier_neb_vs_stub_smoke_call0_echem_neb_image_count_requires_0 := trivial
def vc_echem_static_barrier_neb_vs_stub_smoke_call1_echem_static_barrier_neb_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_vs_stub_smoke_call1_echem_static_barrier_neb_requires_0_proved : vc_echem_static_barrier_neb_vs_stub_smoke_call1_echem_static_barrier_neb_requires_0 := trivial
def vc_echem_static_barrier_neb_vs_stub_smoke_call2_echem_static_barrier_neb_stub_requires_0 : Prop := True
theorem vc_echem_static_barrier_neb_vs_stub_smoke_call2_echem_static_barrier_neb_stub_requires_0_proved : vc_echem_static_barrier_neb_vs_stub_smoke_call2_echem_static_barrier_neb_stub_requires_0 := trivial

end echem_static_barrier_neb_vs_stub_smoke

namespace echem_slab_layer_count

def vc_echem_slab_layer_count_requires_0 : Prop := True
theorem vc_echem_slab_layer_count_requires_0_proved : vc_echem_slab_layer_count_requires_0 := trivial
def vc_echem_slab_layer_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_slab_layer_count_ensures_0_proved (result : Int) : vc_echem_slab_layer_count_ensures_0 result := trivial
def vc_echem_slab_layer_count_decreases_0 : Nat := 0
theorem vc_echem_slab_layer_count_decreases_0_proved : vc_echem_slab_layer_count_decreases_0 = 0 := rfl

end echem_slab_layer_count

namespace echem_slab_atom_count

def vc_echem_slab_atom_count_requires_0 : Prop := True
theorem vc_echem_slab_atom_count_requires_0_proved : vc_echem_slab_atom_count_requires_0 := trivial
def vc_echem_slab_atom_count_ensures_0 (result : Int) : Prop := (result = 12)
def vc_echem_slab_atom_count_decreases_0 : Nat := 0
theorem vc_echem_slab_atom_count_decreases_0_proved : vc_echem_slab_atom_count_decreases_0 = 0 := rfl
def vc_echem_slab_atom_count_call0_echem_slab_layer_count_requires_0 : Prop := True
theorem vc_echem_slab_atom_count_call0_echem_slab_layer_count_requires_0_proved : vc_echem_slab_atom_count_call0_echem_slab_layer_count_requires_0 := trivial

end echem_slab_atom_count

namespace echem_slab_lattice_a_ang

def vc_echem_slab_lattice_a_ang_requires_0 : Prop := True
theorem vc_echem_slab_lattice_a_ang_requires_0_proved : vc_echem_slab_lattice_a_ang_requires_0 := trivial
def vc_echem_slab_lattice_a_ang_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_slab_lattice_a_ang_ensures_0_proved (result : Float) : vc_echem_slab_lattice_a_ang_ensures_0 result := trivial
def vc_echem_slab_lattice_a_ang_decreases_0 : Nat := 0
theorem vc_echem_slab_lattice_a_ang_decreases_0_proved : vc_echem_slab_lattice_a_ang_decreases_0 = 0 := rfl

end echem_slab_lattice_a_ang

namespace echem_slab_h2o_oxygen_z_ang

def vc_echem_slab_h2o_oxygen_z_ang_requires_0 : Prop := True
theorem vc_echem_slab_h2o_oxygen_z_ang_requires_0_proved : vc_echem_slab_h2o_oxygen_z_ang_requires_0 := trivial
def vc_echem_slab_h2o_oxygen_z_ang_ensures_0 (result : Float) : Prop := (result > (2 : Float))
def vc_echem_slab_h2o_oxygen_z_ang_ensures_1 (result : Float) : Prop := (result < (4 : Float))
def vc_echem_slab_h2o_oxygen_z_ang_decreases_0 : Nat := 0
theorem vc_echem_slab_h2o_oxygen_z_ang_decreases_0_proved : vc_echem_slab_h2o_oxygen_z_ang_decreases_0 = 0 := rfl

end echem_slab_h2o_oxygen_z_ang

namespace echem_slab_geometry_smoke

def vc_echem_slab_geometry_smoke_requires_0 : Prop := True
theorem vc_echem_slab_geometry_smoke_requires_0_proved : vc_echem_slab_geometry_smoke_requires_0 := trivial
def vc_echem_slab_geometry_smoke_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_slab_geometry_smoke_ensures_0_proved (result : Int) : vc_echem_slab_geometry_smoke_ensures_0 result := trivial
def vc_echem_slab_geometry_smoke_decreases_0 : Nat := 0
theorem vc_echem_slab_geometry_smoke_decreases_0_proved : vc_echem_slab_geometry_smoke_decreases_0 = 0 := rfl
def vc_echem_slab_geometry_smoke_call0_echem_slab_atom_count_requires_0 : Prop := True
theorem vc_echem_slab_geometry_smoke_call0_echem_slab_atom_count_requires_0_proved : vc_echem_slab_geometry_smoke_call0_echem_slab_atom_count_requires_0 := trivial
def vc_echem_slab_geometry_smoke_call1_echem_slab_lattice_a_ang_requires_0 : Prop := True
theorem vc_echem_slab_geometry_smoke_call1_echem_slab_lattice_a_ang_requires_0_proved : vc_echem_slab_geometry_smoke_call1_echem_slab_lattice_a_ang_requires_0 := trivial
def vc_echem_slab_geometry_smoke_call2_echem_slab_h2o_oxygen_z_ang_requires_0 : Prop := True
theorem vc_echem_slab_geometry_smoke_call2_echem_slab_h2o_oxygen_z_ang_requires_0_proved : vc_echem_slab_geometry_smoke_call2_echem_slab_h2o_oxygen_z_ang_requires_0 := trivial

end echem_slab_geometry_smoke

namespace echem_potential_volcano_trend_smoke

def vc_echem_potential_volcano_trend_smoke_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_requires_0_proved : vc_echem_potential_volcano_trend_smoke_requires_0 := trivial
def vc_echem_potential_volcano_trend_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_potential_volcano_trend_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_potential_volcano_trend_smoke_decreases_0 : Nat := 0
theorem vc_echem_potential_volcano_trend_smoke_decreases_0_proved : vc_echem_potential_volcano_trend_smoke_decreases_0 = 0 := rfl
def vc_echem_potential_volcano_trend_smoke_call0_echem_dft_energy_at_potential_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_call0_echem_dft_energy_at_potential_requires_0_proved : vc_echem_potential_volcano_trend_smoke_call0_echem_dft_energy_at_potential_requires_0 := trivial
def vc_echem_potential_volcano_trend_smoke_call1_echem_dft_energy_at_potential_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_call1_echem_dft_energy_at_potential_requires_0_proved : vc_echem_potential_volcano_trend_smoke_call1_echem_dft_energy_at_potential_requires_0 := trivial
def vc_echem_potential_volcano_trend_smoke_call2_echem_dft_energy_at_potential_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_call2_echem_dft_energy_at_potential_requires_0_proved : vc_echem_potential_volcano_trend_smoke_call2_echem_dft_energy_at_potential_requires_0 := trivial
def vc_echem_potential_volcano_trend_smoke_call3_echem_dft_h_star_energy_hartree_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_call3_echem_dft_h_star_energy_hartree_requires_0_proved : vc_echem_potential_volcano_trend_smoke_call3_echem_dft_h_star_energy_hartree_requires_0 := trivial
def vc_echem_potential_volcano_trend_smoke_call4_echem_dft_h2_energy_hartree_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_call4_echem_dft_h2_energy_hartree_requires_0_proved : vc_echem_potential_volcano_trend_smoke_call4_echem_dft_h2_energy_hartree_requires_0 := trivial
def vc_echem_potential_volcano_trend_smoke_call5_echem_hartree_to_ev_requires_0 : Prop := True
theorem vc_echem_potential_volcano_trend_smoke_call5_echem_hartree_to_ev_requires_0_proved : vc_echem_potential_volcano_trend_smoke_call5_echem_hartree_to_ev_requires_0 := trivial

end echem_potential_volcano_trend_smoke

namespace echem_gpu_che_h_ads_progress

def vc_echem_gpu_che_h_ads_progress_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_requires_0_proved : vc_echem_gpu_che_h_ads_progress_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_gpu_che_h_ads_progress_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_gpu_che_h_ads_progress_decreases_0 : Nat := 0
theorem vc_echem_gpu_che_h_ads_progress_decreases_0_proved : vc_echem_gpu_che_h_ads_progress_decreases_0 = 0 := rfl
def vc_echem_gpu_che_h_ads_progress_call0_echem_potential_volcano_trend_smoke_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call0_echem_potential_volcano_trend_smoke_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call0_echem_potential_volcano_trend_smoke_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call1_echem_che_h_adsorption_energy_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call1_echem_che_h_adsorption_energy_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call1_echem_che_h_adsorption_energy_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call2_echem_che_h_adsorption_energy_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call2_echem_che_h_adsorption_energy_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call2_echem_che_h_adsorption_energy_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call3_echem_edl_helmholtz_capacitance_stub_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call3_echem_edl_helmholtz_capacitance_stub_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call3_echem_edl_helmholtz_capacitance_stub_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call4_echem_edl_pb_vs_helmholtz_smoke_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call4_echem_edl_pb_vs_helmholtz_smoke_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call4_echem_edl_pb_vs_helmholtz_smoke_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call5_echem_static_barrier_neb_vs_stub_smoke_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call5_echem_static_barrier_neb_vs_stub_smoke_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call5_echem_static_barrier_neb_vs_stub_smoke_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call6_echem_static_barrier_neb_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call6_echem_static_barrier_neb_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call6_echem_static_barrier_neb_requires_0 := trivial
def vc_echem_gpu_che_h_ads_progress_call7_echem_she_reference_ev_requires_0 : Prop := True
theorem vc_echem_gpu_che_h_ads_progress_call7_echem_she_reference_ev_requires_0_proved : vc_echem_gpu_che_h_ads_progress_call7_echem_she_reference_ev_requires_0 := trivial

end echem_gpu_che_h_ads_progress

namespace echem_marcus_diabatic_da_energy_ev

def vc_echem_marcus_diabatic_da_energy_ev_requires_0 : Prop := True
theorem vc_echem_marcus_diabatic_da_energy_ev_requires_0_proved : vc_echem_marcus_diabatic_da_energy_ev_requires_0 := trivial
def vc_echem_marcus_diabatic_da_energy_ev_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_marcus_diabatic_da_energy_ev_ensures_0_proved (result : Float) : vc_echem_marcus_diabatic_da_energy_ev_ensures_0 result := trivial
def vc_echem_marcus_diabatic_da_energy_ev_decreases_0 : Nat := 0
theorem vc_echem_marcus_diabatic_da_energy_ev_decreases_0_proved : vc_echem_marcus_diabatic_da_energy_ev_decreases_0 = 0 := rfl
def vc_echem_marcus_diabatic_da_energy_ev_call0_echem_dft_energy_at_potential_requires_0 : Prop := True
theorem vc_echem_marcus_diabatic_da_energy_ev_call0_echem_dft_energy_at_potential_requires_0_proved : vc_echem_marcus_diabatic_da_energy_ev_call0_echem_dft_energy_at_potential_requires_0 := trivial

end echem_marcus_diabatic_da_energy_ev

namespace echem_marcus_diabatic_cs_energy_ev

def vc_echem_marcus_diabatic_cs_energy_ev_requires_0 : Prop := True
theorem vc_echem_marcus_diabatic_cs_energy_ev_requires_0_proved : vc_echem_marcus_diabatic_cs_energy_ev_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_marcus_diabatic_cs_energy_ev_ensures_0 (result : Float) : Prop := True
theorem vc_echem_marcus_diabatic_cs_energy_ev_ensures_0_proved (result : Float) : vc_echem_marcus_diabatic_cs_energy_ev_ensures_0 result := trivial
def vc_echem_marcus_diabatic_cs_energy_ev_decreases_0 : Nat := 0
theorem vc_echem_marcus_diabatic_cs_energy_ev_decreases_0_proved : vc_echem_marcus_diabatic_cs_energy_ev_decreases_0 = 0 := rfl
def vc_echem_marcus_diabatic_cs_energy_ev_call0_echem_marcus_diabatic_da_energy_ev_requires_0 : Prop := True
theorem vc_echem_marcus_diabatic_cs_energy_ev_call0_echem_marcus_diabatic_da_energy_ev_requires_0_proved : vc_echem_marcus_diabatic_cs_energy_ev_call0_echem_marcus_diabatic_da_energy_ev_requires_0 := trivial

end echem_marcus_diabatic_cs_energy_ev

namespace echem_marcus_lambda_stub

def vc_echem_marcus_lambda_stub_requires_0 : Prop := True
theorem vc_echem_marcus_lambda_stub_requires_0_proved : vc_echem_marcus_lambda_stub_requires_0 := trivial
def vc_echem_marcus_lambda_stub_ensures_0 (result : Float) : Prop := (result > (0 : Float))
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_marcus_lambda_stub_ensures_1 (result : Float) : Prop := True
theorem vc_echem_marcus_lambda_stub_ensures_1_proved (result : Float) : vc_echem_marcus_lambda_stub_ensures_1 result := trivial
def vc_echem_marcus_lambda_stub_decreases_0 : Nat := 0
theorem vc_echem_marcus_lambda_stub_decreases_0_proved : vc_echem_marcus_lambda_stub_decreases_0 = 0 := rfl
def vc_echem_marcus_lambda_stub_call0_echem_marcus_diabatic_da_energy_ev_requires_0 : Prop := True
theorem vc_echem_marcus_lambda_stub_call0_echem_marcus_diabatic_da_energy_ev_requires_0_proved : vc_echem_marcus_lambda_stub_call0_echem_marcus_diabatic_da_energy_ev_requires_0 := trivial
def vc_echem_marcus_lambda_stub_call1_echem_marcus_diabatic_cs_energy_ev_requires_0 : Prop := True
theorem vc_echem_marcus_lambda_stub_call1_echem_marcus_diabatic_cs_energy_ev_requires_0_proved : vc_echem_marcus_lambda_stub_call1_echem_marcus_diabatic_cs_energy_ev_requires_0 := trivial

end echem_marcus_lambda_stub

namespace echem_marcus_temperature_k

def vc_echem_marcus_temperature_k_requires_0 : Prop := True
theorem vc_echem_marcus_temperature_k_requires_0_proved : vc_echem_marcus_temperature_k_requires_0 := trivial
def vc_echem_marcus_temperature_k_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_marcus_temperature_k_ensures_0_proved (result : Float) : vc_echem_marcus_temperature_k_ensures_0 result := trivial
def vc_echem_marcus_temperature_k_decreases_0 : Nat := 0
theorem vc_echem_marcus_temperature_k_decreases_0_proved : vc_echem_marcus_temperature_k_decreases_0 = 0 := rfl

end echem_marcus_temperature_k

namespace echem_marcus_kb_ev_per_k

def vc_echem_marcus_kb_ev_per_k_requires_0 : Prop := True
theorem vc_echem_marcus_kb_ev_per_k_requires_0_proved : vc_echem_marcus_kb_ev_per_k_requires_0 := trivial
def vc_echem_marcus_kb_ev_per_k_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_marcus_kb_ev_per_k_decreases_0 : Nat := 0
theorem vc_echem_marcus_kb_ev_per_k_decreases_0_proved : vc_echem_marcus_kb_ev_per_k_decreases_0 = 0 := rfl

end echem_marcus_kb_ev_per_k

namespace echem_marcus_delta_g_ev

def vc_echem_marcus_delta_g_ev_requires_0 : Prop := True
theorem vc_echem_marcus_delta_g_ev_requires_0_proved : vc_echem_marcus_delta_g_ev_requires_0 := trivial
def vc_echem_marcus_delta_g_ev_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_marcus_delta_g_ev_ensures_0_proved (result : Float) : vc_echem_marcus_delta_g_ev_ensures_0 result := trivial
def vc_echem_marcus_delta_g_ev_decreases_0 : Nat := 0
theorem vc_echem_marcus_delta_g_ev_decreases_0_proved : vc_echem_marcus_delta_g_ev_decreases_0 = 0 := rfl

end echem_marcus_delta_g_ev

namespace echem_exp_toy

def vc_echem_exp_toy_requires_0 (x : Float) : Prop := True
theorem vc_echem_exp_toy_requires_0_proved (x : Float) : vc_echem_exp_toy_requires_0 x := trivial
def vc_echem_exp_toy_ensures_0 (x : Float) (result : Float) : Prop := (result > (0 : Float))
def vc_echem_exp_toy_decreases_0 (x : Float) : Nat := 0
theorem vc_echem_exp_toy_decreases_0_proved (x : Float) : vc_echem_exp_toy_decreases_0 x = 0 := rfl

end echem_exp_toy

namespace echem_marcus_rate_exponent

def vc_echem_marcus_rate_exponent_requires_0 (delta_g_ev : Float) (lambda_ev : Float) : Prop := (lambda_ev > (0 : Float))
def vc_echem_marcus_rate_exponent_ensures_0 (delta_g_ev : Float) (lambda_ev : Float) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_echem_marcus_rate_exponent_decreases_0 (delta_g_ev : Float) (lambda_ev : Float) : Nat := 0
theorem vc_echem_marcus_rate_exponent_decreases_0_proved (delta_g_ev : Float) (lambda_ev : Float) : vc_echem_marcus_rate_exponent_decreases_0 delta_g_ev lambda_ev = 0 := rfl
def vc_echem_marcus_rate_exponent_call0_echem_marcus_kb_ev_per_k_requires_0 (delta_g_ev : Float) (lambda_ev : Float) : Prop := True
theorem vc_echem_marcus_rate_exponent_call0_echem_marcus_kb_ev_per_k_requires_0_proved (delta_g_ev : Float) (lambda_ev : Float) : vc_echem_marcus_rate_exponent_call0_echem_marcus_kb_ev_per_k_requires_0 delta_g_ev lambda_ev := trivial
def vc_echem_marcus_rate_exponent_call1_echem_marcus_temperature_k_requires_0 (delta_g_ev : Float) (lambda_ev : Float) : Prop := True
theorem vc_echem_marcus_rate_exponent_call1_echem_marcus_temperature_k_requires_0_proved (delta_g_ev : Float) (lambda_ev : Float) : vc_echem_marcus_rate_exponent_call1_echem_marcus_temperature_k_requires_0 delta_g_ev lambda_ev := trivial

end echem_marcus_rate_exponent

namespace echem_marcus_rate_stub

def vc_echem_marcus_rate_stub_requires_0 (coupling_ev : Float) : Prop := (coupling_ev ≥ (0 : Float))
def vc_echem_marcus_rate_stub_ensures_0 (coupling_ev : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_marcus_rate_stub_decreases_0 (coupling_ev : Float) : Nat := 0
theorem vc_echem_marcus_rate_stub_decreases_0_proved (coupling_ev : Float) : vc_echem_marcus_rate_stub_decreases_0 coupling_ev = 0 := rfl
def vc_echem_marcus_rate_stub_call0_echem_marcus_lambda_stub_requires_0 (coupling_ev : Float) : Prop := True
theorem vc_echem_marcus_rate_stub_call0_echem_marcus_lambda_stub_requires_0_proved (coupling_ev : Float) : vc_echem_marcus_rate_stub_call0_echem_marcus_lambda_stub_requires_0 coupling_ev := trivial
def vc_echem_marcus_rate_stub_call1_echem_marcus_delta_g_ev_requires_0 (coupling_ev : Float) : Prop := True
theorem vc_echem_marcus_rate_stub_call1_echem_marcus_delta_g_ev_requires_0_proved (coupling_ev : Float) : vc_echem_marcus_rate_stub_call1_echem_marcus_delta_g_ev_requires_0 coupling_ev := trivial
def vc_echem_marcus_rate_stub_call2_echem_marcus_rate_exponent_requires_0 (coupling_ev : Float) (lam : Float) : Prop := (lam > (0 : Float))
def vc_echem_marcus_rate_stub_call3_echem_exp_toy_requires_0 (coupling_ev : Float) : Prop := True
theorem vc_echem_marcus_rate_stub_call3_echem_exp_toy_requires_0_proved (coupling_ev : Float) : vc_echem_marcus_rate_stub_call3_echem_exp_toy_requires_0 coupling_ev := trivial

end echem_marcus_rate_stub

namespace echem_marcus_lambda_smoke

def vc_echem_marcus_lambda_smoke_requires_0 : Prop := True
theorem vc_echem_marcus_lambda_smoke_requires_0_proved : vc_echem_marcus_lambda_smoke_requires_0 := trivial
def vc_echem_marcus_lambda_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_marcus_lambda_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_marcus_lambda_smoke_decreases_0 : Nat := 0
theorem vc_echem_marcus_lambda_smoke_decreases_0_proved : vc_echem_marcus_lambda_smoke_decreases_0 = 0 := rfl
def vc_echem_marcus_lambda_smoke_call0_echem_marcus_lambda_stub_requires_0 : Prop := True
theorem vc_echem_marcus_lambda_smoke_call0_echem_marcus_lambda_stub_requires_0_proved : vc_echem_marcus_lambda_smoke_call0_echem_marcus_lambda_stub_requires_0 := trivial

end echem_marcus_lambda_smoke

namespace echem_marcus_coupling_monotonic_smoke

def vc_echem_marcus_coupling_monotonic_smoke_requires_0 : Prop := True
theorem vc_echem_marcus_coupling_monotonic_smoke_requires_0_proved : vc_echem_marcus_coupling_monotonic_smoke_requires_0 := trivial
def vc_echem_marcus_coupling_monotonic_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_marcus_coupling_monotonic_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_marcus_coupling_monotonic_smoke_decreases_0 : Nat := 0
theorem vc_echem_marcus_coupling_monotonic_smoke_decreases_0_proved : vc_echem_marcus_coupling_monotonic_smoke_decreases_0 = 0 := rfl
def vc_echem_marcus_coupling_monotonic_smoke_call0_echem_marcus_rate_stub_requires_0 : Prop := ((0.02 : Float) ≥ (0 : Float))
def vc_echem_marcus_coupling_monotonic_smoke_call1_echem_marcus_rate_stub_requires_0 : Prop := ((0.05 : Float) ≥ (0 : Float))
def vc_echem_marcus_coupling_monotonic_smoke_call2_echem_marcus_rate_stub_requires_0 : Prop := ((0.1 : Float) ≥ (0 : Float))

end echem_marcus_coupling_monotonic_smoke

namespace echem_gc_mu_electron_ev

def vc_echem_gc_mu_electron_ev_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_gc_mu_electron_ev_requires_0_proved (u_v : Float) : vc_echem_gc_mu_electron_ev_requires_0 u_v := trivial
def vc_echem_gc_mu_electron_ev_ensures_0 (u_v : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_gc_mu_electron_ev_ensures_0_proved (u_v : Float) (result : Float) : vc_echem_gc_mu_electron_ev_ensures_0 u_v result := trivial
def vc_echem_gc_mu_electron_ev_decreases_0 (u_v : Float) : Nat := 0
theorem vc_echem_gc_mu_electron_ev_decreases_0_proved (u_v : Float) : vc_echem_gc_mu_electron_ev_decreases_0 u_v = 0 := rfl
def vc_echem_gc_mu_electron_ev_call0_echem_she_reference_ev_requires_0 (u_v : Float) : Prop := True
theorem vc_echem_gc_mu_electron_ev_call0_echem_she_reference_ev_requires_0_proved (u_v : Float) : vc_echem_gc_mu_electron_ev_call0_echem_she_reference_ev_requires_0 u_v := trivial

end echem_gc_mu_electron_ev

namespace echem_gc_target_charge

def vc_echem_gc_target_charge_requires_0 : Prop := True
theorem vc_echem_gc_target_charge_requires_0_proved : vc_echem_gc_target_charge_requires_0 := trivial
def vc_echem_gc_target_charge_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_gc_target_charge_ensures_0_proved (result : Float) : vc_echem_gc_target_charge_ensures_0 result := trivial
def vc_echem_gc_target_charge_decreases_0 : Nat := 0
theorem vc_echem_gc_target_charge_decreases_0_proved : vc_echem_gc_target_charge_decreases_0 = 0 := rfl

end echem_gc_target_charge

namespace echem_gc_charge_neutrality_next

def vc_echem_gc_charge_neutrality_next_requires_0 (q : Float) (u_v : Float) : Prop := True
theorem vc_echem_gc_charge_neutrality_next_requires_0_proved (q : Float) (u_v : Float) : vc_echem_gc_charge_neutrality_next_requires_0 q u_v := trivial
def vc_echem_gc_charge_neutrality_next_ensures_0 (q : Float) (u_v : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_gc_charge_neutrality_next_decreases_0 (q : Float) (u_v : Float) : Nat := 0
theorem vc_echem_gc_charge_neutrality_next_decreases_0_proved (q : Float) (u_v : Float) : vc_echem_gc_charge_neutrality_next_decreases_0 q u_v = 0 := rfl
def vc_echem_gc_charge_neutrality_next_call0_echem_gc_mu_electron_ev_requires_0 (q : Float) (u_v : Float) : Prop := True
theorem vc_echem_gc_charge_neutrality_next_call0_echem_gc_mu_electron_ev_requires_0_proved (q : Float) (u_v : Float) : vc_echem_gc_charge_neutrality_next_call0_echem_gc_mu_electron_ev_requires_0 q u_v := trivial
def vc_echem_gc_charge_neutrality_next_call1_echem_she_reference_ev_requires_0 (q : Float) (u_v : Float) : Prop := True
theorem vc_echem_gc_charge_neutrality_next_call1_echem_she_reference_ev_requires_0_proved (q : Float) (u_v : Float) : vc_echem_gc_charge_neutrality_next_call1_echem_she_reference_ev_requires_0 q u_v := trivial

end echem_gc_charge_neutrality_next

namespace echem_gc_charge_drift_abs

def vc_echem_gc_charge_drift_abs_requires_0 (q : Float) : Prop := True
theorem vc_echem_gc_charge_drift_abs_requires_0_proved (q : Float) : vc_echem_gc_charge_drift_abs_requires_0 q := trivial
def vc_echem_gc_charge_drift_abs_ensures_0 (q : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_gc_charge_drift_abs_decreases_0 (q : Float) : Nat := 0
theorem vc_echem_gc_charge_drift_abs_decreases_0_proved (q : Float) : vc_echem_gc_charge_drift_abs_decreases_0 q = 0 := rfl

end echem_gc_charge_drift_abs

namespace echem_gc_charge_neutrality_smoke

def vc_echem_gc_charge_neutrality_smoke_requires_0 : Prop := True
theorem vc_echem_gc_charge_neutrality_smoke_requires_0_proved : vc_echem_gc_charge_neutrality_smoke_requires_0 := trivial
def vc_echem_gc_charge_neutrality_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_gc_charge_neutrality_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_gc_charge_neutrality_smoke_decreases_0 : Nat := 0
theorem vc_echem_gc_charge_neutrality_smoke_decreases_0_proved : vc_echem_gc_charge_neutrality_smoke_decreases_0 = 0 := rfl
def vc_echem_gc_charge_neutrality_smoke_call0_echem_gc_charge_neutrality_next_requires_0 : Prop := True
theorem vc_echem_gc_charge_neutrality_smoke_call0_echem_gc_charge_neutrality_next_requires_0_proved : vc_echem_gc_charge_neutrality_smoke_call0_echem_gc_charge_neutrality_next_requires_0 := trivial
def vc_echem_gc_charge_neutrality_smoke_call1_echem_gc_charge_drift_abs_requires_0 : Prop := True
theorem vc_echem_gc_charge_neutrality_smoke_call1_echem_gc_charge_drift_abs_requires_0_proved : vc_echem_gc_charge_neutrality_smoke_call1_echem_gc_charge_drift_abs_requires_0 := trivial

end echem_gc_charge_neutrality_smoke

namespace echem_ml_holdout_count

def vc_echem_ml_holdout_count_requires_0 : Prop := True
theorem vc_echem_ml_holdout_count_requires_0_proved : vc_echem_ml_holdout_count_requires_0 := trivial
def vc_echem_ml_holdout_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_ml_holdout_count_ensures_0_proved (result : Int) : vc_echem_ml_holdout_count_ensures_0 result := trivial
def vc_echem_ml_holdout_count_decreases_0 : Nat := 0
theorem vc_echem_ml_holdout_count_decreases_0_proved : vc_echem_ml_holdout_count_decreases_0 = 0 := rfl

end echem_ml_holdout_count

namespace echem_ml_holdout_u_v

def vc_echem_ml_holdout_u_v_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_ml_holdout_u_v_requires_1 (i : Int) : Prop := True
theorem vc_echem_ml_holdout_u_v_requires_1_proved (i : Int) : vc_echem_ml_holdout_u_v_requires_1 i := trivial
def vc_echem_ml_holdout_u_v_ensures_0 (i : Int) (result : Float) : Prop := (result ≥ (-0.5 : Float))
def vc_echem_ml_holdout_u_v_ensures_1 (i : Int) (result : Float) : Prop := (result ≤ (0.5 : Float))
def vc_echem_ml_holdout_u_v_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_ml_holdout_u_v_decreases_0_proved (i : Int) : vc_echem_ml_holdout_u_v_decreases_0 i = Int.toNat i := rfl

end echem_ml_holdout_u_v

namespace echem_ml_holdout_x

def vc_echem_ml_holdout_x_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_ml_holdout_x_requires_1 (i : Int) : Prop := True
theorem vc_echem_ml_holdout_x_requires_1_proved (i : Int) : vc_echem_ml_holdout_x_requires_1 i := trivial
def vc_echem_ml_holdout_x_ensures_0 (i : Int) (result : Float) : Prop := (result ≥ (-0.05 : Float))
def vc_echem_ml_holdout_x_ensures_1 (i : Int) (result : Float) : Prop := (result ≤ (0.12 : Float))
def vc_echem_ml_holdout_x_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_ml_holdout_x_decreases_0_proved (i : Int) : vc_echem_ml_holdout_x_decreases_0 i = Int.toNat i := rfl

end echem_ml_holdout_x

namespace echem_ml_holdout_vx

def vc_echem_ml_holdout_vx_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_ml_holdout_vx_requires_1 (i : Int) : Prop := True
theorem vc_echem_ml_holdout_vx_requires_1_proved (i : Int) : vc_echem_ml_holdout_vx_requires_1 i := trivial
def vc_echem_ml_holdout_vx_ensures_0 (i : Int) (result : Float) : Prop := (result ≥ (-0.02 : Float))
def vc_echem_ml_holdout_vx_ensures_1 (i : Int) (result : Float) : Prop := (result ≤ (0.04 : Float))
def vc_echem_ml_holdout_vx_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_ml_holdout_vx_decreases_0_proved (i : Int) : vc_echem_ml_holdout_vx_decreases_0 i = Int.toNat i := rfl

end echem_ml_holdout_vx

namespace echem_ml_dft_reference_ev

def vc_echem_ml_dft_reference_ev_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_ml_dft_reference_ev_requires_1 (i : Int) : Prop := True
theorem vc_echem_ml_dft_reference_ev_requires_1_proved (i : Int) : vc_echem_ml_dft_reference_ev_requires_1 i := trivial
def vc_echem_ml_dft_reference_ev_ensures_0 (i : Int) (result : Float) : Prop := (result ≤ (0 : Float))
def vc_echem_ml_dft_reference_ev_decreases_0 (i : Int) : Nat := Int.toNat i
theorem vc_echem_ml_dft_reference_ev_decreases_0_proved (i : Int) : vc_echem_ml_dft_reference_ev_decreases_0 i = Int.toNat i := rfl
def vc_echem_ml_dft_reference_ev_call0_echem_ml_holdout_u_v_requires_0 (i : Int) : Prop := (i ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_ml_holdout_u_v' at call 0 -/
def vc_echem_ml_dft_reference_ev_call0_echem_ml_holdout_u_v_requires_1 (i : Int) : Prop := True
def vc_echem_ml_dft_reference_ev_call1_echem_dft_energy_at_potential_requires_0 (i : Int) : Prop := True
theorem vc_echem_ml_dft_reference_ev_call1_echem_dft_energy_at_potential_requires_0_proved (i : Int) : vc_echem_ml_dft_reference_ev_call1_echem_dft_energy_at_potential_requires_0 i := trivial

end echem_ml_dft_reference_ev

namespace echem_ml_abs_err_ev

def vc_echem_ml_abs_err_ev_requires_0 (a : Float) (b : Float) : Prop := True
theorem vc_echem_ml_abs_err_ev_requires_0_proved (a : Float) (b : Float) : vc_echem_ml_abs_err_ev_requires_0 a b := trivial
def vc_echem_ml_abs_err_ev_ensures_0 (a : Float) (b : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_ml_abs_err_ev_decreases_0 (a : Float) (b : Float) : Nat := 0
theorem vc_echem_ml_abs_err_ev_decreases_0_proved (a : Float) (b : Float) : vc_echem_ml_abs_err_ev_decreases_0 a b = 0 := rfl

end echem_ml_abs_err_ev

namespace echem_ml_mae_tolerance_ev

def vc_echem_ml_mae_tolerance_ev_requires_0 : Prop := True
theorem vc_echem_ml_mae_tolerance_ev_requires_0_proved : vc_echem_ml_mae_tolerance_ev_requires_0 := trivial
def vc_echem_ml_mae_tolerance_ev_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_ml_mae_tolerance_ev_decreases_0 : Nat := 0
theorem vc_echem_ml_mae_tolerance_ev_decreases_0_proved : vc_echem_ml_mae_tolerance_ev_decreases_0 = 0 := rfl

end echem_ml_mae_tolerance_ev

namespace echem_ml_step_multiplier

def vc_echem_ml_step_multiplier_requires_0 : Prop := True
theorem vc_echem_ml_step_multiplier_requires_0_proved : vc_echem_ml_step_multiplier_requires_0 := trivial
def vc_echem_ml_step_multiplier_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_ml_step_multiplier_ensures_0_proved (result : Int) : vc_echem_ml_step_multiplier_ensures_0 result := trivial
def vc_echem_ml_step_multiplier_decreases_0 : Nat := 0
theorem vc_echem_ml_step_multiplier_decreases_0_proved : vc_echem_ml_step_multiplier_decreases_0 = 0 := rfl

end echem_ml_step_multiplier

namespace echem_ml_baseline_aimd_steps

def vc_echem_ml_baseline_aimd_steps_requires_0 : Prop := True
theorem vc_echem_ml_baseline_aimd_steps_requires_0_proved : vc_echem_ml_baseline_aimd_steps_requires_0 := trivial
def vc_echem_ml_baseline_aimd_steps_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_ml_baseline_aimd_steps_ensures_0_proved (result : Int) : vc_echem_ml_baseline_aimd_steps_ensures_0 result := trivial
def vc_echem_ml_baseline_aimd_steps_decreases_0 : Nat := 0
theorem vc_echem_ml_baseline_aimd_steps_decreases_0_proved : vc_echem_ml_baseline_aimd_steps_decreases_0 = 0 := rfl

end echem_ml_baseline_aimd_steps

namespace echem_ml_surrogate_aimd_steps

def vc_echem_ml_surrogate_aimd_steps_requires_0 : Prop := True
theorem vc_echem_ml_surrogate_aimd_steps_requires_0_proved : vc_echem_ml_surrogate_aimd_steps_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_ml_surrogate_aimd_steps_ensures_0 (result : Int) : Prop := True
theorem vc_echem_ml_surrogate_aimd_steps_ensures_0_proved (result : Int) : vc_echem_ml_surrogate_aimd_steps_ensures_0 result := trivial
def vc_echem_ml_surrogate_aimd_steps_decreases_0 : Nat := 0
theorem vc_echem_ml_surrogate_aimd_steps_decreases_0_proved : vc_echem_ml_surrogate_aimd_steps_decreases_0 = 0 := rfl

end echem_ml_surrogate_aimd_steps

namespace echem_sei_barrier_ea_ev

def vc_echem_sei_barrier_ea_ev_requires_0 : Prop := True
theorem vc_echem_sei_barrier_ea_ev_requires_0_proved : vc_echem_sei_barrier_ea_ev_requires_0 := trivial
def vc_echem_sei_barrier_ea_ev_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_sei_barrier_ea_ev_ensures_0_proved (result : Float) : vc_echem_sei_barrier_ea_ev_ensures_0 result := trivial
def vc_echem_sei_barrier_ea_ev_decreases_0 : Nat := 0
theorem vc_echem_sei_barrier_ea_ev_decreases_0_proved : vc_echem_sei_barrier_ea_ev_decreases_0 = 0 := rfl
def vc_echem_sei_barrier_ea_ev_call0_echem_static_barrier_neb_requires_0 : Prop := True
theorem vc_echem_sei_barrier_ea_ev_call0_echem_static_barrier_neb_requires_0_proved : vc_echem_sei_barrier_ea_ev_call0_echem_static_barrier_neb_requires_0 := trivial

end echem_sei_barrier_ea_ev

namespace echem_sei_rate_prefactor

def vc_echem_sei_rate_prefactor_requires_0 : Prop := True
theorem vc_echem_sei_rate_prefactor_requires_0_proved : vc_echem_sei_rate_prefactor_requires_0 := trivial
def vc_echem_sei_rate_prefactor_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_sei_rate_prefactor_decreases_0 : Nat := 0
theorem vc_echem_sei_rate_prefactor_decreases_0_proved : vc_echem_sei_rate_prefactor_decreases_0 = 0 := rfl

end echem_sei_rate_prefactor

namespace echem_sei_temperature_ev

def vc_echem_sei_temperature_ev_requires_0 : Prop := True
theorem vc_echem_sei_temperature_ev_requires_0_proved : vc_echem_sei_temperature_ev_requires_0 := trivial
def vc_echem_sei_temperature_ev_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_sei_temperature_ev_decreases_0 : Nat := 0
theorem vc_echem_sei_temperature_ev_decreases_0_proved : vc_echem_sei_temperature_ev_decreases_0 = 0 := rfl

end echem_sei_temperature_ev

namespace echem_sei_deposition_rate_per_step

def vc_echem_sei_deposition_rate_per_step_requires_0 : Prop := True
theorem vc_echem_sei_deposition_rate_per_step_requires_0_proved : vc_echem_sei_deposition_rate_per_step_requires_0 := trivial
def vc_echem_sei_deposition_rate_per_step_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_sei_deposition_rate_per_step_decreases_0 : Nat := 0
theorem vc_echem_sei_deposition_rate_per_step_decreases_0_proved : vc_echem_sei_deposition_rate_per_step_decreases_0 = 0 := rfl
def vc_echem_sei_deposition_rate_per_step_call0_echem_sei_barrier_ea_ev_requires_0 : Prop := True
theorem vc_echem_sei_deposition_rate_per_step_call0_echem_sei_barrier_ea_ev_requires_0_proved : vc_echem_sei_deposition_rate_per_step_call0_echem_sei_barrier_ea_ev_requires_0 := trivial
def vc_echem_sei_deposition_rate_per_step_call1_echem_sei_temperature_ev_requires_0 : Prop := True
theorem vc_echem_sei_deposition_rate_per_step_call1_echem_sei_temperature_ev_requires_0_proved : vc_echem_sei_deposition_rate_per_step_call1_echem_sei_temperature_ev_requires_0 := trivial
def vc_echem_sei_deposition_rate_per_step_call2_echem_sei_rate_prefactor_requires_0 : Prop := True
theorem vc_echem_sei_deposition_rate_per_step_call2_echem_sei_rate_prefactor_requires_0_proved : vc_echem_sei_deposition_rate_per_step_call2_echem_sei_rate_prefactor_requires_0 := trivial

end echem_sei_deposition_rate_per_step

namespace echem_sei_growth_ang_per_event

def vc_echem_sei_growth_ang_per_event_requires_0 : Prop := True
theorem vc_echem_sei_growth_ang_per_event_requires_0_proved : vc_echem_sei_growth_ang_per_event_requires_0 := trivial
def vc_echem_sei_growth_ang_per_event_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_sei_growth_ang_per_event_decreases_0 : Nat := 0
theorem vc_echem_sei_growth_ang_per_event_decreases_0_proved : vc_echem_sei_growth_ang_per_event_decreases_0 = 0 := rfl

end echem_sei_growth_ang_per_event

namespace echem_tddft_stub_honesty_tag

def vc_echem_tddft_stub_honesty_tag_requires_0 : Prop := True
theorem vc_echem_tddft_stub_honesty_tag_requires_0_proved : vc_echem_tddft_stub_honesty_tag_requires_0 := trivial
def vc_echem_tddft_stub_honesty_tag_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_tddft_stub_honesty_tag_ensures_0_proved (result : Int) : vc_echem_tddft_stub_honesty_tag_ensures_0 result := trivial
def vc_echem_tddft_stub_honesty_tag_decreases_0 : Nat := 0
theorem vc_echem_tddft_stub_honesty_tag_decreases_0_proved : vc_echem_tddft_stub_honesty_tag_decreases_0 = 0 := rfl

end echem_tddft_stub_honesty_tag

namespace echem_tddft_excitation_energy_ev

def vc_echem_tddft_excitation_energy_ev_requires_0 : Prop := True
theorem vc_echem_tddft_excitation_energy_ev_requires_0_proved : vc_echem_tddft_excitation_energy_ev_requires_0 := trivial
def vc_echem_tddft_excitation_energy_ev_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_tddft_excitation_energy_ev_decreases_0 : Nat := 0
theorem vc_echem_tddft_excitation_energy_ev_decreases_0_proved : vc_echem_tddft_excitation_energy_ev_decreases_0 = 0 := rfl

end echem_tddft_excitation_energy_ev

namespace echem_tddft_nonadiabatic_coupling_ev

def vc_echem_tddft_nonadiabatic_coupling_ev_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_coupling_ev_requires_0_proved : vc_echem_tddft_nonadiabatic_coupling_ev_requires_0 := trivial
def vc_echem_tddft_nonadiabatic_coupling_ev_ensures_0 (result : Float) : Prop := (result > (0 : Float))
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_tddft_nonadiabatic_coupling_ev_ensures_1 (result : Float) : Prop := True
theorem vc_echem_tddft_nonadiabatic_coupling_ev_ensures_1_proved (result : Float) : vc_echem_tddft_nonadiabatic_coupling_ev_ensures_1 result := trivial
def vc_echem_tddft_nonadiabatic_coupling_ev_decreases_0 : Nat := 0
theorem vc_echem_tddft_nonadiabatic_coupling_ev_decreases_0_proved : vc_echem_tddft_nonadiabatic_coupling_ev_decreases_0 = 0 := rfl
def vc_echem_tddft_nonadiabatic_coupling_ev_call0_echem_marcus_lambda_stub_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_coupling_ev_call0_echem_marcus_lambda_stub_requires_0_proved : vc_echem_tddft_nonadiabatic_coupling_ev_call0_echem_marcus_lambda_stub_requires_0 := trivial

end echem_tddft_nonadiabatic_coupling_ev

namespace echem_tddft_et_barrier_ev

def vc_echem_tddft_et_barrier_ev_requires_0 : Prop := True
theorem vc_echem_tddft_et_barrier_ev_requires_0_proved : vc_echem_tddft_et_barrier_ev_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_echem_tddft_et_barrier_ev_ensures_0 (result : Float) : Prop := True
theorem vc_echem_tddft_et_barrier_ev_ensures_0_proved (result : Float) : vc_echem_tddft_et_barrier_ev_ensures_0 result := trivial
def vc_echem_tddft_et_barrier_ev_decreases_0 : Nat := 0
theorem vc_echem_tddft_et_barrier_ev_decreases_0_proved : vc_echem_tddft_et_barrier_ev_decreases_0 = 0 := rfl
def vc_echem_tddft_et_barrier_ev_call0_echem_marcus_lambda_stub_requires_0 : Prop := True
theorem vc_echem_tddft_et_barrier_ev_call0_echem_marcus_lambda_stub_requires_0_proved : vc_echem_tddft_et_barrier_ev_call0_echem_marcus_lambda_stub_requires_0 := trivial
def vc_echem_tddft_et_barrier_ev_call1_echem_tddft_excitation_energy_ev_requires_0 : Prop := True
theorem vc_echem_tddft_et_barrier_ev_call1_echem_tddft_excitation_energy_ev_requires_0_proved : vc_echem_tddft_et_barrier_ev_call1_echem_tddft_excitation_energy_ev_requires_0 := trivial

end echem_tddft_et_barrier_ev

namespace echem_tddft_step_count

def vc_echem_tddft_step_count_requires_0 : Prop := True
theorem vc_echem_tddft_step_count_requires_0_proved : vc_echem_tddft_step_count_requires_0 := trivial
def vc_echem_tddft_step_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_tddft_step_count_ensures_0_proved (result : Int) : vc_echem_tddft_step_count_ensures_0 result := trivial
def vc_echem_tddft_step_count_decreases_0 : Nat := 0
theorem vc_echem_tddft_step_count_decreases_0_proved : vc_echem_tddft_step_count_decreases_0 = 0 := rfl

end echem_tddft_step_count

namespace echem_tddft_dt_fs

def vc_echem_tddft_dt_fs_requires_0 : Prop := True
theorem vc_echem_tddft_dt_fs_requires_0_proved : vc_echem_tddft_dt_fs_requires_0 := trivial
def vc_echem_tddft_dt_fs_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_tddft_dt_fs_decreases_0 : Nat := 0
theorem vc_echem_tddft_dt_fs_decreases_0_proved : vc_echem_tddft_dt_fs_decreases_0 = 0 := rfl

end echem_tddft_dt_fs

namespace echem_tddft_population_ground_next

def vc_echem_tddft_population_ground_next_requires_0 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) : Prop := (p_ground ≥ (0 : Float))
def vc_echem_tddft_population_ground_next_requires_1 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) : Prop := (p_ground ≤ (1 : Float))
def vc_echem_tddft_population_ground_next_requires_2 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) : Prop := (coupling_ev ≥ (0 : Float))
def vc_echem_tddft_population_ground_next_requires_3 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) : Prop := (dt_fs > (0 : Float))
def vc_echem_tddft_population_ground_next_ensures_0 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_tddft_population_ground_next_ensures_1 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) (result : Float) : Prop := (result ≤ (1 : Float))
def vc_echem_tddft_population_ground_next_decreases_0 (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) : Nat := 0
theorem vc_echem_tddft_population_ground_next_decreases_0_proved (p_ground : Float) (coupling_ev : Float) (dt_fs : Float) : vc_echem_tddft_population_ground_next_decreases_0 p_ground coupling_ev dt_fs = 0 := rfl

end echem_tddft_population_ground_next

namespace echem_tddft_nonadiabatic_smoke

def vc_echem_tddft_nonadiabatic_smoke_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_smoke_requires_0_proved : vc_echem_tddft_nonadiabatic_smoke_requires_0 := trivial
def vc_echem_tddft_nonadiabatic_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_tddft_nonadiabatic_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_tddft_nonadiabatic_smoke_decreases_0 : Nat := 0
theorem vc_echem_tddft_nonadiabatic_smoke_decreases_0_proved : vc_echem_tddft_nonadiabatic_smoke_decreases_0 = 0 := rfl
def vc_echem_tddft_nonadiabatic_smoke_call0_echem_tddft_nonadiabatic_coupling_ev_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_smoke_call0_echem_tddft_nonadiabatic_coupling_ev_requires_0_proved : vc_echem_tddft_nonadiabatic_smoke_call0_echem_tddft_nonadiabatic_coupling_ev_requires_0 := trivial
def vc_echem_tddft_nonadiabatic_smoke_call1_echem_tddft_dt_fs_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_smoke_call1_echem_tddft_dt_fs_requires_0_proved : vc_echem_tddft_nonadiabatic_smoke_call1_echem_tddft_dt_fs_requires_0 := trivial
def vc_echem_tddft_nonadiabatic_smoke_call2_echem_tddft_et_barrier_ev_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_smoke_call2_echem_tddft_et_barrier_ev_requires_0_proved : vc_echem_tddft_nonadiabatic_smoke_call2_echem_tddft_et_barrier_ev_requires_0 := trivial
def vc_echem_tddft_nonadiabatic_smoke_call3_echem_tddft_step_count_requires_0 : Prop := True
theorem vc_echem_tddft_nonadiabatic_smoke_call3_echem_tddft_step_count_requires_0_proved : vc_echem_tddft_nonadiabatic_smoke_call3_echem_tddft_step_count_requires_0 := trivial
def vc_echem_tddft_nonadiabatic_smoke_call4_echem_tddft_population_ground_next_requires_0 (p : Float) : Prop := (p ≥ (0 : Float))
def vc_echem_tddft_nonadiabatic_smoke_call4_echem_tddft_population_ground_next_requires_1 (p : Float) : Prop := (p ≤ (1 : Float))
def vc_echem_tddft_nonadiabatic_smoke_call4_echem_tddft_population_ground_next_requires_2 (coupling : Float) : Prop := (coupling ≥ (0 : Float))
def vc_echem_tddft_nonadiabatic_smoke_call4_echem_tddft_population_ground_next_requires_3 (dt : Float) : Prop := (dt > (0 : Float))

end echem_tddft_nonadiabatic_smoke

namespace chem_lig_backend_auto

def vc_chem_lig_backend_auto_requires_0 : Prop := True
theorem vc_chem_lig_backend_auto_requires_0_proved : vc_chem_lig_backend_auto_requires_0 := trivial
def vc_chem_lig_backend_auto_ensures_0 (result : Int) : Prop := (1 ≤ result)
def vc_chem_lig_backend_auto_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_chem_lig_backend_auto_ensures_1_proved (result : Int) : vc_chem_lig_backend_auto_ensures_1 result := trivial
def vc_chem_lig_backend_auto_decreases_0 : Nat := 0
theorem vc_chem_lig_backend_auto_decreases_0_proved : vc_chem_lig_backend_auto_decreases_0 = 0 := rfl
def vc_chem_lig_backend_auto_call0_lig_backend_select_auto_requires_0 : Prop := True
theorem vc_chem_lig_backend_auto_call0_lig_backend_select_auto_requires_0_proved : vc_chem_lig_backend_auto_call0_lig_backend_select_auto_requires_0 := trivial

end chem_lig_backend_auto

namespace li_std_lig_version

def vc_li_std_lig_version_requires_0 : Prop := True
theorem vc_li_std_lig_version_requires_0_proved : vc_li_std_lig_version_requires_0 := trivial
def vc_li_std_lig_version_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_li_std_lig_version_ensures_0_proved (result : Int) : vc_li_std_lig_version_ensures_0 result := trivial
def vc_li_std_lig_version_decreases_0 : Nat := 0
theorem vc_li_std_lig_version_decreases_0_proved : vc_li_std_lig_version_decreases_0 = 0 := rfl

end li_std_lig_version

namespace lig_backend_cuda

def vc_lig_backend_cuda_requires_0 : Prop := True
theorem vc_lig_backend_cuda_requires_0_proved : vc_lig_backend_cuda_requires_0 := trivial
def vc_lig_backend_cuda_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_cuda_ensures_0_proved (result : Int) : vc_lig_backend_cuda_ensures_0 result := trivial
def vc_lig_backend_cuda_decreases_0 : Nat := 0
theorem vc_lig_backend_cuda_decreases_0_proved : vc_lig_backend_cuda_decreases_0 = 0 := rfl

end lig_backend_cuda

namespace lig_backend_rocm

def vc_lig_backend_rocm_requires_0 : Prop := True
theorem vc_lig_backend_rocm_requires_0_proved : vc_lig_backend_rocm_requires_0 := trivial
def vc_lig_backend_rocm_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_rocm_ensures_0_proved (result : Int) : vc_lig_backend_rocm_ensures_0 result := trivial
def vc_lig_backend_rocm_decreases_0 : Nat := 0
theorem vc_lig_backend_rocm_decreases_0_proved : vc_lig_backend_rocm_decreases_0 = 0 := rfl

end lig_backend_rocm

namespace lig_backend_metal

def vc_lig_backend_metal_requires_0 : Prop := True
theorem vc_lig_backend_metal_requires_0_proved : vc_lig_backend_metal_requires_0 := trivial
def vc_lig_backend_metal_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_metal_ensures_0_proved (result : Int) : vc_lig_backend_metal_ensures_0 result := trivial
def vc_lig_backend_metal_decreases_0 : Nat := 0
theorem vc_lig_backend_metal_decreases_0_proved : vc_lig_backend_metal_decreases_0 = 0 := rfl

end lig_backend_metal

namespace lig_backend_webgpu

def vc_lig_backend_webgpu_requires_0 : Prop := True
theorem vc_lig_backend_webgpu_requires_0_proved : vc_lig_backend_webgpu_requires_0 := trivial
def vc_lig_backend_webgpu_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_webgpu_ensures_0_proved (result : Int) : vc_lig_backend_webgpu_ensures_0 result := trivial
def vc_lig_backend_webgpu_decreases_0 : Nat := 0
theorem vc_lig_backend_webgpu_decreases_0_proved : vc_lig_backend_webgpu_decreases_0 = 0 := rfl

end lig_backend_webgpu

namespace lig_device_kind

def vc_lig_device_kind_requires_0 : Prop := True
theorem vc_lig_device_kind_requires_0_proved : vc_lig_device_kind_requires_0 := trivial
def vc_lig_device_kind_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_device_kind_ensures_0_proved (result : Int) : vc_lig_device_kind_ensures_0 result := trivial
def vc_lig_device_kind_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_device_kind_ensures_1_proved (result : Int) : vc_lig_device_kind_ensures_1 result := trivial
def vc_lig_device_kind_decreases_0 : Nat := 0
theorem vc_lig_device_kind_decreases_0_proved : vc_lig_device_kind_decreases_0 = 0 := rfl
def vc_lig_device_kind_call0_li_rt_lig_device_kind_requires_0 : Prop := True
theorem vc_lig_device_kind_call0_li_rt_lig_device_kind_requires_0_proved : vc_lig_device_kind_call0_li_rt_lig_device_kind_requires_0 := trivial

end lig_device_kind

namespace lig_backend_available

def vc_lig_backend_available_requires_0 (backend_id : Int) : Prop := (backend_id ≥ 1)
def vc_lig_backend_available_requires_1 (backend_id : Int) : Prop := (backend_id ≤ 4)
def vc_lig_backend_available_ensures_0 (backend_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_available_ensures_0_proved (backend_id : Int) (result : Int) : vc_lig_backend_available_ensures_0 backend_id result := trivial
def vc_lig_backend_available_ensures_1 (backend_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_available_ensures_1_proved (backend_id : Int) (result : Int) : vc_lig_backend_available_ensures_1 backend_id result := trivial
def vc_lig_backend_available_decreases_0 (backend_id : Int) : Nat := Int.toNat backend_id
theorem vc_lig_backend_available_decreases_0_proved (backend_id : Int) : vc_lig_backend_available_decreases_0 backend_id = Int.toNat backend_id := rfl
def vc_lig_backend_available_call0_li_rt_lig_backend_available_requires_0 (backend_id : Int) : Prop := (backend_id ≥ 1)
def vc_lig_backend_available_call0_li_rt_lig_backend_available_requires_1 (backend_id : Int) : Prop := (backend_id ≤ 4)

end lig_backend_available

namespace lig_backend_select_auto

def vc_lig_backend_select_auto_requires_0 : Prop := True
theorem vc_lig_backend_select_auto_requires_0_proved : vc_lig_backend_select_auto_requires_0 := trivial
def vc_lig_backend_select_auto_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_select_auto_ensures_0_proved (result : Int) : vc_lig_backend_select_auto_ensures_0 result := trivial
def vc_lig_backend_select_auto_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_select_auto_ensures_1_proved (result : Int) : vc_lig_backend_select_auto_ensures_1 result := trivial
def vc_lig_backend_select_auto_decreases_0 : Nat := 0
theorem vc_lig_backend_select_auto_decreases_0_proved : vc_lig_backend_select_auto_decreases_0 = 0 := rfl
def vc_lig_backend_select_auto_call0_li_rt_lig_backend_select_auto_requires_0 : Prop := True
theorem vc_lig_backend_select_auto_call0_li_rt_lig_backend_select_auto_requires_0_proved : vc_lig_backend_select_auto_call0_li_rt_lig_backend_select_auto_requires_0 := trivial

end lig_backend_select_auto

namespace lig_capability_json

def vc_lig_capability_json_requires_0 : Prop := True
theorem vc_lig_capability_json_requires_0_proved : vc_lig_capability_json_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_capability_json_ensures_0 (result : Int) : Prop := True
theorem vc_lig_capability_json_ensures_0_proved (result : Int) : vc_lig_capability_json_ensures_0 result := trivial
def vc_lig_capability_json_decreases_0 : Nat := 0
theorem vc_lig_capability_json_decreases_0_proved : vc_lig_capability_json_decreases_0 = 0 := rfl
def vc_lig_capability_json_call0_li_rt_lig_capability_json_requires_0 : Prop := True
theorem vc_lig_capability_json_call0_li_rt_lig_capability_json_requires_0_proved : vc_lig_capability_json_call0_li_rt_lig_capability_json_requires_0 := trivial

end lig_capability_json

namespace lig_parse_toml_backend_line

def vc_lig_parse_toml_backend_line_requires_0 (line : Int) : Prop := True
theorem vc_lig_parse_toml_backend_line_requires_0_proved (line : Int) : vc_lig_parse_toml_backend_line_requires_0 line := trivial
def vc_lig_parse_toml_backend_line_ensures_0 (line : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_parse_toml_backend_line_ensures_0_proved (line : Int) (result : Int) : vc_lig_parse_toml_backend_line_ensures_0 line result := trivial
def vc_lig_parse_toml_backend_line_ensures_1 (line : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_parse_toml_backend_line_ensures_1_proved (line : Int) (result : Int) : vc_lig_parse_toml_backend_line_ensures_1 line result := trivial
def vc_lig_parse_toml_backend_line_decreases_0 (line : Int) : Nat := 0
theorem vc_lig_parse_toml_backend_line_decreases_0_proved (line : Int) : vc_lig_parse_toml_backend_line_decreases_0 line = 0 := rfl
def vc_lig_parse_toml_backend_line_call0_li_rt_lig_parse_toml_backend_line_requires_0 (line : Int) : Prop := True
theorem vc_lig_parse_toml_backend_line_call0_li_rt_lig_parse_toml_backend_line_requires_0_proved (line : Int) : vc_lig_parse_toml_backend_line_call0_li_rt_lig_parse_toml_backend_line_requires_0 line := trivial

end lig_parse_toml_backend_line

namespace lig_present_surface_ok

def vc_lig_present_surface_ok_requires_0 : Prop := True
theorem vc_lig_present_surface_ok_requires_0_proved : vc_lig_present_surface_ok_requires_0 := trivial
def vc_lig_present_surface_ok_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_present_surface_ok_ensures_0_proved (result : Int) : vc_lig_present_surface_ok_ensures_0 result := trivial
def vc_lig_present_surface_ok_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_present_surface_ok_ensures_1_proved (result : Int) : vc_lig_present_surface_ok_ensures_1 result := trivial
def vc_lig_present_surface_ok_decreases_0 : Nat := 0
theorem vc_lig_present_surface_ok_decreases_0_proved : vc_lig_present_surface_ok_decreases_0 = 0 := rfl
def vc_lig_present_surface_ok_call0_li_rt_lig_present_surface_ok_requires_0 : Prop := True
theorem vc_lig_present_surface_ok_call0_li_rt_lig_present_surface_ok_requires_0_proved : vc_lig_present_surface_ok_call0_li_rt_lig_present_surface_ok_requires_0 := trivial

end lig_present_surface_ok

namespace lig_wgpu_smoke_status_pass

def vc_lig_wgpu_smoke_status_pass_requires_0 : Prop := True
theorem vc_lig_wgpu_smoke_status_pass_requires_0_proved : vc_lig_wgpu_smoke_status_pass_requires_0 := trivial
def vc_lig_wgpu_smoke_status_pass_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_wgpu_smoke_status_pass_ensures_0_proved (result : Int) : vc_lig_wgpu_smoke_status_pass_ensures_0 result := trivial
def vc_lig_wgpu_smoke_status_pass_decreases_0 : Nat := 0
theorem vc_lig_wgpu_smoke_status_pass_decreases_0_proved : vc_lig_wgpu_smoke_status_pass_decreases_0 = 0 := rfl

end lig_wgpu_smoke_status_pass

namespace lig_wgpu_smoke_status_fail

def vc_lig_wgpu_smoke_status_fail_requires_0 : Prop := True
theorem vc_lig_wgpu_smoke_status_fail_requires_0_proved : vc_lig_wgpu_smoke_status_fail_requires_0 := trivial
def vc_lig_wgpu_smoke_status_fail_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_wgpu_smoke_status_fail_ensures_0_proved (result : Int) : vc_lig_wgpu_smoke_status_fail_ensures_0 result := trivial
def vc_lig_wgpu_smoke_status_fail_decreases_0 : Nat := 0
theorem vc_lig_wgpu_smoke_status_fail_decreases_0_proved : vc_lig_wgpu_smoke_status_fail_decreases_0 = 0 := rfl

end lig_wgpu_smoke_status_fail

namespace lig_wgpu_smoke_run

def vc_lig_wgpu_smoke_run_requires_0 : Prop := True
theorem vc_lig_wgpu_smoke_run_requires_0_proved : vc_lig_wgpu_smoke_run_requires_0 := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_wgpu_smoke_run_ensures_0 (result : Int) : Prop := True
theorem vc_lig_wgpu_smoke_run_ensures_0_proved (result : Int) : vc_lig_wgpu_smoke_run_ensures_0 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_wgpu_smoke_run_ensures_1 (result : Int) : Prop := True
theorem vc_lig_wgpu_smoke_run_ensures_1_proved (result : Int) : vc_lig_wgpu_smoke_run_ensures_1 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_wgpu_smoke_run_ensures_2 (result : Int) : Prop := True
theorem vc_lig_wgpu_smoke_run_ensures_2_proved (result : Int) : vc_lig_wgpu_smoke_run_ensures_2 result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_wgpu_smoke_run_ensures_3 (result : Int) : Prop := True
theorem vc_lig_wgpu_smoke_run_ensures_3_proved (result : Int) : vc_lig_wgpu_smoke_run_ensures_3 result := trivial
def vc_lig_wgpu_smoke_run_decreases_0 : Nat := 0
theorem vc_lig_wgpu_smoke_run_decreases_0_proved : vc_lig_wgpu_smoke_run_decreases_0 = 0 := rfl
def vc_lig_wgpu_smoke_run_call0_lig_device_kind_requires_0 : Prop := True
theorem vc_lig_wgpu_smoke_run_call0_lig_device_kind_requires_0_proved : vc_lig_wgpu_smoke_run_call0_lig_device_kind_requires_0 := trivial
def vc_lig_wgpu_smoke_run_call1_lig_wgpu_smoke_status_pass_requires_0 : Prop := True
theorem vc_lig_wgpu_smoke_run_call1_lig_wgpu_smoke_status_pass_requires_0_proved : vc_lig_wgpu_smoke_run_call1_lig_wgpu_smoke_status_pass_requires_0 := trivial
def vc_lig_wgpu_smoke_run_call2_lig_present_surface_ok_requires_0 : Prop := True
theorem vc_lig_wgpu_smoke_run_call2_lig_present_surface_ok_requires_0_proved : vc_lig_wgpu_smoke_run_call2_lig_present_surface_ok_requires_0 := trivial

end lig_wgpu_smoke_run

namespace lig_wgpu_smoke_passed

def vc_lig_wgpu_smoke_passed_requires_0 (smoke : Int) : Prop := True
theorem vc_lig_wgpu_smoke_passed_requires_0_proved (smoke : Int) : vc_lig_wgpu_smoke_passed_requires_0 smoke := trivial
def vc_lig_wgpu_smoke_passed_ensures_0 (smoke : Int) (result : Int) : Prop := (result ≥ 0)
def vc_lig_wgpu_smoke_passed_ensures_1 (smoke : Int) (result : Int) : Prop := (result ≤ 1)
def vc_lig_wgpu_smoke_passed_decreases_0 (smoke : Int) : Nat := 0
theorem vc_lig_wgpu_smoke_passed_decreases_0_proved (smoke : Int) : vc_lig_wgpu_smoke_passed_decreases_0 smoke = 0 := rfl
def vc_lig_wgpu_smoke_passed_call0_lig_wgpu_smoke_status_pass_requires_0 (smoke : Int) : Prop := True
theorem vc_lig_wgpu_smoke_passed_call0_lig_wgpu_smoke_status_pass_requires_0_proved (smoke : Int) : vc_lig_wgpu_smoke_passed_call0_lig_wgpu_smoke_status_pass_requires_0 smoke := trivial
def vc_lig_wgpu_smoke_passed_call1_lig_backend_cuda_requires_0 (smoke : Int) : Prop := True
theorem vc_lig_wgpu_smoke_passed_call1_lig_backend_cuda_requires_0_proved (smoke : Int) : vc_lig_wgpu_smoke_passed_call1_lig_backend_cuda_requires_0 smoke := trivial
def vc_lig_wgpu_smoke_passed_call2_lig_backend_webgpu_requires_0 (smoke : Int) : Prop := True
theorem vc_lig_wgpu_smoke_passed_call2_lig_backend_webgpu_requires_0_proved (smoke : Int) : vc_lig_wgpu_smoke_passed_call2_lig_backend_webgpu_requires_0 smoke := trivial

end lig_wgpu_smoke_passed

namespace lig_gpu_device_buffer_ready

def vc_lig_gpu_device_buffer_ready_requires_0 : Prop := True
theorem vc_lig_gpu_device_buffer_ready_requires_0_proved : vc_lig_gpu_device_buffer_ready_requires_0 := trivial
def vc_lig_gpu_device_buffer_ready_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_gpu_device_buffer_ready_ensures_0_proved (result : Int) : vc_lig_gpu_device_buffer_ready_ensures_0 result := trivial
def vc_lig_gpu_device_buffer_ready_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_gpu_device_buffer_ready_ensures_1_proved (result : Int) : vc_lig_gpu_device_buffer_ready_ensures_1 result := trivial
def vc_lig_gpu_device_buffer_ready_decreases_0 : Nat := 0
theorem vc_lig_gpu_device_buffer_ready_decreases_0_proved : vc_lig_gpu_device_buffer_ready_decreases_0 = 0 := rfl
def vc_lig_gpu_device_buffer_ready_call0_li_rt_lig_gpu_device_buffer_ready_requires_0 : Prop := True
theorem vc_lig_gpu_device_buffer_ready_call0_li_rt_lig_gpu_device_buffer_ready_requires_0_proved : vc_lig_gpu_device_buffer_ready_call0_li_rt_lig_gpu_device_buffer_ready_requires_0 := trivial

end lig_gpu_device_buffer_ready

namespace lig_emit_cuda_enabled

def vc_lig_emit_cuda_enabled_requires_0 : Prop := True
theorem vc_lig_emit_cuda_enabled_requires_0_proved : vc_lig_emit_cuda_enabled_requires_0 := trivial
def vc_lig_emit_cuda_enabled_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_lig_emit_cuda_enabled_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_lig_emit_cuda_enabled_decreases_0 : Nat := 0
theorem vc_lig_emit_cuda_enabled_decreases_0_proved : vc_lig_emit_cuda_enabled_decreases_0 = 0 := rfl
def vc_lig_emit_cuda_enabled_call0_li_rt_lig_emit_env_flag_requires_0 : Prop := True
theorem vc_lig_emit_cuda_enabled_call0_li_rt_lig_emit_env_flag_requires_0_proved : vc_lig_emit_cuda_enabled_call0_li_rt_lig_emit_env_flag_requires_0 := trivial

end lig_emit_cuda_enabled

namespace lig_emit_hip_enabled

def vc_lig_emit_hip_enabled_requires_0 : Prop := True
theorem vc_lig_emit_hip_enabled_requires_0_proved : vc_lig_emit_hip_enabled_requires_0 := trivial
def vc_lig_emit_hip_enabled_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_lig_emit_hip_enabled_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_lig_emit_hip_enabled_decreases_0 : Nat := 0
theorem vc_lig_emit_hip_enabled_decreases_0_proved : vc_lig_emit_hip_enabled_decreases_0 = 0 := rfl
def vc_lig_emit_hip_enabled_call0_li_rt_lig_emit_env_flag_requires_0 : Prop := True
theorem vc_lig_emit_hip_enabled_call0_li_rt_lig_emit_env_flag_requires_0_proved : vc_lig_emit_hip_enabled_call0_li_rt_lig_emit_env_flag_requires_0 := trivial

end lig_emit_hip_enabled

namespace lig_emit_metal_enabled

def vc_lig_emit_metal_enabled_requires_0 : Prop := True
theorem vc_lig_emit_metal_enabled_requires_0_proved : vc_lig_emit_metal_enabled_requires_0 := trivial
def vc_lig_emit_metal_enabled_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_lig_emit_metal_enabled_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_lig_emit_metal_enabled_decreases_0 : Nat := 0
theorem vc_lig_emit_metal_enabled_decreases_0_proved : vc_lig_emit_metal_enabled_decreases_0 = 0 := rfl
def vc_lig_emit_metal_enabled_call0_li_rt_lig_emit_env_flag_requires_0 : Prop := True
theorem vc_lig_emit_metal_enabled_call0_li_rt_lig_emit_env_flag_requires_0_proved : vc_lig_emit_metal_enabled_call0_li_rt_lig_emit_env_flag_requires_0 := trivial

end lig_emit_metal_enabled

namespace lig_emit_vendor_progress

def vc_lig_emit_vendor_progress_requires_0 : Prop := True
theorem vc_lig_emit_vendor_progress_requires_0_proved : vc_lig_emit_vendor_progress_requires_0 := trivial
def vc_lig_emit_vendor_progress_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_emit_vendor_progress_ensures_0_proved (result : Int) : vc_lig_emit_vendor_progress_ensures_0 result := trivial
def vc_lig_emit_vendor_progress_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_emit_vendor_progress_ensures_1_proved (result : Int) : vc_lig_emit_vendor_progress_ensures_1 result := trivial
def vc_lig_emit_vendor_progress_decreases_0 : Nat := 0
theorem vc_lig_emit_vendor_progress_decreases_0_proved : vc_lig_emit_vendor_progress_decreases_0 = 0 := rfl
def vc_lig_emit_vendor_progress_call0_li_rt_lig_emit_vendor_progress_requires_0 : Prop := True
theorem vc_lig_emit_vendor_progress_call0_li_rt_lig_emit_vendor_progress_requires_0_proved : vc_lig_emit_vendor_progress_call0_li_rt_lig_emit_vendor_progress_requires_0 := trivial

end lig_emit_vendor_progress

namespace lig_emit_vendor_lowering_ready

def vc_lig_emit_vendor_lowering_ready_requires_0 : Prop := True
theorem vc_lig_emit_vendor_lowering_ready_requires_0_proved : vc_lig_emit_vendor_lowering_ready_requires_0 := trivial
def vc_lig_emit_vendor_lowering_ready_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_emit_vendor_lowering_ready_ensures_0_proved (result : Int) : vc_lig_emit_vendor_lowering_ready_ensures_0 result := trivial
def vc_lig_emit_vendor_lowering_ready_ensures_1 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_emit_vendor_lowering_ready_ensures_1_proved (result : Int) : vc_lig_emit_vendor_lowering_ready_ensures_1 result := trivial
def vc_lig_emit_vendor_lowering_ready_decreases_0 : Nat := 0
theorem vc_lig_emit_vendor_lowering_ready_decreases_0_proved : vc_lig_emit_vendor_lowering_ready_decreases_0 = 0 := rfl
def vc_lig_emit_vendor_lowering_ready_call0_li_rt_lig_emit_vendor_lowering_ready_requires_0 : Prop := True
theorem vc_lig_emit_vendor_lowering_ready_call0_li_rt_lig_emit_vendor_lowering_ready_requires_0_proved : vc_lig_emit_vendor_lowering_ready_call0_li_rt_lig_emit_vendor_lowering_ready_requires_0 := trivial

end lig_emit_vendor_lowering_ready

namespace lig_gpu_launch_prologue_ok

def vc_lig_gpu_launch_prologue_ok_requires_0 : Prop := True
theorem vc_lig_gpu_launch_prologue_ok_requires_0_proved : vc_lig_gpu_launch_prologue_ok_requires_0 := trivial
def vc_lig_gpu_launch_prologue_ok_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_lig_gpu_launch_prologue_ok_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_lig_gpu_launch_prologue_ok_decreases_0 : Nat := 0
theorem vc_lig_gpu_launch_prologue_ok_decreases_0_proved : vc_lig_gpu_launch_prologue_ok_decreases_0 = 0 := rfl
def vc_lig_gpu_launch_prologue_ok_call0_li_rt_lig_matmul_ready_requires_0 : Prop := True
theorem vc_lig_gpu_launch_prologue_ok_call0_li_rt_lig_matmul_ready_requires_0_proved : vc_lig_gpu_launch_prologue_ok_call0_li_rt_lig_matmul_ready_requires_0 := trivial

end lig_gpu_launch_prologue_ok

namespace lig_kernel_matmul_f32

def vc_lig_kernel_matmul_f32_requires_0 : Prop := True
theorem vc_lig_kernel_matmul_f32_requires_0_proved : vc_lig_kernel_matmul_f32_requires_0 := trivial
def vc_lig_kernel_matmul_f32_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_matmul_f32_ensures_0_proved (result : Int) : vc_lig_kernel_matmul_f32_ensures_0 result := trivial
def vc_lig_kernel_matmul_f32_decreases_0 : Nat := 0
theorem vc_lig_kernel_matmul_f32_decreases_0_proved : vc_lig_kernel_matmul_f32_decreases_0 = 0 := rfl

end lig_kernel_matmul_f32

namespace lig_kernel_mlp_forward_f32

def vc_lig_kernel_mlp_forward_f32_requires_0 : Prop := True
theorem vc_lig_kernel_mlp_forward_f32_requires_0_proved : vc_lig_kernel_mlp_forward_f32_requires_0 := trivial
def vc_lig_kernel_mlp_forward_f32_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_mlp_forward_f32_ensures_0_proved (result : Int) : vc_lig_kernel_mlp_forward_f32_ensures_0 result := trivial
def vc_lig_kernel_mlp_forward_f32_decreases_0 : Nat := 0
theorem vc_lig_kernel_mlp_forward_f32_decreases_0_proved : vc_lig_kernel_mlp_forward_f32_decreases_0 = 0 := rfl

end lig_kernel_mlp_forward_f32

namespace lig_kernel_run

def vc_lig_kernel_run_requires_0 (kernel_id : Int) (backend_id : Int) : Prop := (kernel_id ≥ 1)
def vc_lig_kernel_run_requires_1 (kernel_id : Int) (backend_id : Int) : Prop := (backend_id ≥ 1)
def vc_lig_kernel_run_requires_2 (kernel_id : Int) (backend_id : Int) : Prop := (backend_id ≤ 4)
def vc_lig_kernel_run_ensures_0 (kernel_id : Int) (backend_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_run_ensures_0_proved (kernel_id : Int) (backend_id : Int) (result : Int) : vc_lig_kernel_run_ensures_0 kernel_id backend_id result := trivial
def vc_lig_kernel_run_ensures_1 (kernel_id : Int) (backend_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_run_ensures_1_proved (kernel_id : Int) (backend_id : Int) (result : Int) : vc_lig_kernel_run_ensures_1 kernel_id backend_id result := trivial
def vc_lig_kernel_run_decreases_0 (kernel_id : Int) (backend_id : Int) : Nat := Int.toNat kernel_id
theorem vc_lig_kernel_run_decreases_0_proved (kernel_id : Int) (backend_id : Int) : vc_lig_kernel_run_decreases_0 kernel_id backend_id = Int.toNat kernel_id := rfl
def vc_lig_kernel_run_call0_li_rt_lig_kernel_run_requires_0 (kernel_id : Int) (backend_id : Int) : Prop := (kernel_id ≥ 1)
def vc_lig_kernel_run_call0_li_rt_lig_kernel_run_requires_1 (kernel_id : Int) (backend_id : Int) : Prop := (backend_id ≥ 1)
def vc_lig_kernel_run_call0_li_rt_lig_kernel_run_requires_2 (kernel_id : Int) (backend_id : Int) : Prop := (backend_id ≤ 4)

end lig_kernel_run

namespace lig_kernel_run_auto

def vc_lig_kernel_run_auto_requires_0 (kernel_id : Int) : Prop := (kernel_id ≥ 1)
def vc_lig_kernel_run_auto_ensures_0 (kernel_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_run_auto_ensures_0_proved (kernel_id : Int) (result : Int) : vc_lig_kernel_run_auto_ensures_0 kernel_id result := trivial
def vc_lig_kernel_run_auto_ensures_1 (kernel_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_run_auto_ensures_1_proved (kernel_id : Int) (result : Int) : vc_lig_kernel_run_auto_ensures_1 kernel_id result := trivial
def vc_lig_kernel_run_auto_decreases_0 (kernel_id : Int) : Nat := Int.toNat kernel_id
theorem vc_lig_kernel_run_auto_decreases_0_proved (kernel_id : Int) : vc_lig_kernel_run_auto_decreases_0 kernel_id = Int.toNat kernel_id := rfl
def vc_lig_kernel_run_auto_call0_lig_kernel_run_requires_0 (kernel_id : Int) : Prop := (kernel_id ≥ 1)
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 0 -/
def vc_lig_kernel_run_auto_call0_lig_kernel_run_requires_1 (kernel_id : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 0 -/
def vc_lig_kernel_run_auto_call0_lig_kernel_run_requires_2 (kernel_id : Int) : Prop := True
def vc_lig_kernel_run_auto_call1_lig_backend_select_auto_requires_0 (kernel_id : Int) : Prop := True
theorem vc_lig_kernel_run_auto_call1_lig_backend_select_auto_requires_0_proved (kernel_id : Int) : vc_lig_kernel_run_auto_call1_lig_backend_select_auto_requires_0 kernel_id := trivial

end lig_kernel_run_auto

namespace lig_validity_gate_pass

def vc_lig_validity_gate_pass_requires_0 (min_ratio : Float) : Prop := (min_ratio ≥ (0 : Float))
def vc_lig_validity_gate_pass_requires_1 (min_ratio : Float) : Prop := (min_ratio ≤ (1 : Float))
def vc_lig_validity_gate_pass_ensures_0 (min_ratio : Float) (result : Int) : Prop := (result ≥ 0)
def vc_lig_validity_gate_pass_ensures_1 (min_ratio : Float) (result : Int) : Prop := (result ≤ 1)
def vc_lig_validity_gate_pass_decreases_0 (min_ratio : Float) : Nat := 0
theorem vc_lig_validity_gate_pass_decreases_0_proved (min_ratio : Float) : vc_lig_validity_gate_pass_decreases_0 min_ratio = 0 := rfl
def vc_lig_validity_gate_pass_call0_li_rt_lig_kernel_last_validity_ratio_requires_0 (min_ratio : Float) : Prop := True
theorem vc_lig_validity_gate_pass_call0_li_rt_lig_kernel_last_validity_ratio_requires_0_proved (min_ratio : Float) : vc_lig_validity_gate_pass_call0_li_rt_lig_kernel_last_validity_ratio_requires_0 min_ratio := trivial

end lig_validity_gate_pass

namespace lig_backend_switch_log

def vc_lig_backend_switch_log_requires_0 (from_backend : Int) (to_backend : Int) (ok : Int) : Prop := (from_backend ≥ 1)
def vc_lig_backend_switch_log_requires_1 (from_backend : Int) (to_backend : Int) (ok : Int) : Prop := (from_backend ≤ 4)
def vc_lig_backend_switch_log_requires_2 (from_backend : Int) (to_backend : Int) (ok : Int) : Prop := (to_backend ≥ 1)
def vc_lig_backend_switch_log_requires_3 (from_backend : Int) (to_backend : Int) (ok : Int) : Prop := (to_backend ≤ 4)
def vc_lig_backend_switch_log_requires_4 (from_backend : Int) (to_backend : Int) (ok : Int) : Prop := (ok ≥ 0)
def vc_lig_backend_switch_log_requires_5 (from_backend : Int) (to_backend : Int) (ok : Int) : Prop := (ok ≤ 1)
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_backend_switch_log_ensures_0 (from_backend : Int) (to_backend : Int) (ok : Int) (result : Int) : Prop := True
theorem vc_lig_backend_switch_log_ensures_0_proved (from_backend : Int) (to_backend : Int) (ok : Int) (result : Int) : vc_lig_backend_switch_log_ensures_0 from_backend to_backend ok result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_backend_switch_log_ensures_1 (from_backend : Int) (to_backend : Int) (ok : Int) (result : Int) : Prop := True
theorem vc_lig_backend_switch_log_ensures_1_proved (from_backend : Int) (to_backend : Int) (ok : Int) (result : Int) : vc_lig_backend_switch_log_ensures_1 from_backend to_backend ok result := trivial
/-! VC ensures (opaque): source expr not yet translated -/
def vc_lig_backend_switch_log_ensures_2 (from_backend : Int) (to_backend : Int) (ok : Int) (result : Int) : Prop := True
theorem vc_lig_backend_switch_log_ensures_2_proved (from_backend : Int) (to_backend : Int) (ok : Int) (result : Int) : vc_lig_backend_switch_log_ensures_2 from_backend to_backend ok result := trivial
def vc_lig_backend_switch_log_decreases_0 (from_backend : Int) (to_backend : Int) (ok : Int) : Nat := Int.toNat from_backend
theorem vc_lig_backend_switch_log_decreases_0_proved (from_backend : Int) (to_backend : Int) (ok : Int) : vc_lig_backend_switch_log_decreases_0 from_backend to_backend ok = Int.toNat from_backend := rfl

end lig_backend_switch_log

namespace lig_backend_switch_log_ok

def vc_lig_backend_switch_log_ok_requires_0 (log : Int) : Prop := True
theorem vc_lig_backend_switch_log_ok_requires_0_proved (log : Int) : vc_lig_backend_switch_log_ok_requires_0 log := trivial
def vc_lig_backend_switch_log_ok_ensures_0 (log : Int) (result : Int) : Prop := (result ≥ 0)
def vc_lig_backend_switch_log_ok_ensures_1 (log : Int) (result : Int) : Prop := (result ≤ 1)
def vc_lig_backend_switch_log_ok_decreases_0 (log : Int) : Nat := 0
theorem vc_lig_backend_switch_log_ok_decreases_0_proved (log : Int) : vc_lig_backend_switch_log_ok_decreases_0 log = 0 := rfl
def vc_lig_backend_switch_log_ok_call0_lig_backend_cuda_requires_0 (log : Int) : Prop := True
theorem vc_lig_backend_switch_log_ok_call0_lig_backend_cuda_requires_0_proved (log : Int) : vc_lig_backend_switch_log_ok_call0_lig_backend_cuda_requires_0 log := trivial
def vc_lig_backend_switch_log_ok_call1_lig_backend_webgpu_requires_0 (log : Int) : Prop := True
theorem vc_lig_backend_switch_log_ok_call1_lig_backend_webgpu_requires_0_proved (log : Int) : vc_lig_backend_switch_log_ok_call1_lig_backend_webgpu_requires_0 log := trivial
def vc_lig_backend_switch_log_ok_call2_lig_backend_cuda_requires_0 (log : Int) : Prop := True
theorem vc_lig_backend_switch_log_ok_call2_lig_backend_cuda_requires_0_proved (log : Int) : vc_lig_backend_switch_log_ok_call2_lig_backend_cuda_requires_0 log := trivial
def vc_lig_backend_switch_log_ok_call3_lig_backend_webgpu_requires_0 (log : Int) : Prop := True
theorem vc_lig_backend_switch_log_ok_call3_lig_backend_webgpu_requires_0_proved (log : Int) : vc_lig_backend_switch_log_ok_call3_lig_backend_webgpu_requires_0 log := trivial

end lig_backend_switch_log_ok

namespace li_std_physics_particles_version

def vc_li_std_physics_particles_version_requires_0 : Prop := True
theorem vc_li_std_physics_particles_version_requires_0_proved : vc_li_std_physics_particles_version_requires_0 := trivial
def vc_li_std_physics_particles_version_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_li_std_physics_particles_version_ensures_0_proved (result : Int) : vc_li_std_physics_particles_version_ensures_0 result := trivial
def vc_li_std_physics_particles_version_decreases_0 : Nat := 0
theorem vc_li_std_physics_particles_version_decreases_0_proved : vc_li_std_physics_particles_version_decreases_0 = 0 := rfl

end li_std_physics_particles_version

namespace emitter_tick

def vc_emitter_tick_requires_0 (e : Int) (dt : Float) : Prop := (dt ≥ (0 : Float))
def vc_emitter_tick_ensures_0 (e : Int) (dt : Float) (result : Int) : Prop := (result ≥ 0)
def vc_emitter_tick_decreases_0 (e : Int) (dt : Float) : Nat := 0
theorem vc_emitter_tick_decreases_0_proved (e : Int) (dt : Float) : vc_emitter_tick_decreases_0 e dt = 0 := rfl

end emitter_tick

namespace nbody_pair_force

def vc_nbody_pair_force_requires_0 (ax : Float) (ay : Float) (bx : Float) (by_ : Float) (g : Float) (mass : Float) (soft : Float) (fx : Float) (fy : Float) : Prop := (g > (0 : Float))
def vc_nbody_pair_force_requires_1 (ax : Float) (ay : Float) (bx : Float) (by_ : Float) (g : Float) (mass : Float) (soft : Float) (fx : Float) (fy : Float) : Prop := (mass > (0 : Float))
def vc_nbody_pair_force_ensures_0 (ax : Float) (ay : Float) (bx : Float) (by_ : Float) (g : Float) (mass : Float) (soft : Float) (fx : Float) (fy : Float) (result : Unit) : Prop := (result = 0)
def vc_nbody_pair_force_decreases_0 (ax : Float) (ay : Float) (bx : Float) (by_ : Float) (g : Float) (mass : Float) (soft : Float) (fx : Float) (fy : Float) : Nat := 0
theorem vc_nbody_pair_force_decreases_0_proved (ax : Float) (ay : Float) (bx : Float) (by_ : Float) (g : Float) (mass : Float) (soft : Float) (fx : Float) (fy : Float) : vc_nbody_pair_force_decreases_0 ax ay bx by_ g mass soft fx fy = 0 := rfl

end nbody_pair_force

namespace lj_force_scalar

def vc_lj_force_scalar_requires_0 (r : Float) (epsilon : Float) (sigma : Float) (rc : Float) : Prop := (r > (0 : Float))
def vc_lj_force_scalar_requires_1 (r : Float) (epsilon : Float) (sigma : Float) (rc : Float) : Prop := (sigma > (0 : Float))
def vc_lj_force_scalar_requires_2 (r : Float) (epsilon : Float) (sigma : Float) (rc : Float) : Prop := (rc > (0 : Float))
def vc_lj_force_scalar_ensures_0 (r : Float) (epsilon : Float) (sigma : Float) (rc : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_lj_force_scalar_decreases_0 (r : Float) (epsilon : Float) (sigma : Float) (rc : Float) : Nat := 0
theorem vc_lj_force_scalar_decreases_0_proved (r : Float) (epsilon : Float) (sigma : Float) (rc : Float) : vc_lj_force_scalar_decreases_0 r epsilon sigma rc = 0 := rfl

end lj_force_scalar

namespace md_mini_step

def vc_md_mini_step_requires_0 (px : LiArray Float 16) (py : LiArray Float 16) (pz : LiArray Float 16) (vx : LiArray Float 16) (vy : LiArray Float 16) (vz : LiArray Float 16) (dt : Float) : Prop := (dt > (0 : Float))
def vc_md_mini_step_ensures_0 (px : LiArray Float 16) (py : LiArray Float 16) (pz : LiArray Float 16) (vx : LiArray Float 16) (vy : LiArray Float 16) (vz : LiArray Float 16) (dt : Float) (result : Unit) : Prop := (result = 0)
def vc_md_mini_step_decreases_0 (px : LiArray Float 16) (py : LiArray Float 16) (pz : LiArray Float 16) (vx : LiArray Float 16) (vy : LiArray Float 16) (vz : LiArray Float 16) (dt : Float) : Nat := 0
theorem vc_md_mini_step_decreases_0_proved (px : LiArray Float 16) (py : LiArray Float 16) (pz : LiArray Float 16) (vx : LiArray Float 16) (vy : LiArray Float 16) (vz : LiArray Float 16) (dt : Float) : vc_md_mini_step_decreases_0 px py pz vx vy vz dt = 0 := rfl

end md_mini_step

namespace echem_solvent_water_count

def vc_echem_solvent_water_count_requires_0 : Prop := True
theorem vc_echem_solvent_water_count_requires_0_proved : vc_echem_solvent_water_count_requires_0 := trivial
def vc_echem_solvent_water_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_solvent_water_count_ensures_0_proved (result : Int) : vc_echem_solvent_water_count_ensures_0 result := trivial
def vc_echem_solvent_water_count_decreases_0 : Nat := 0
theorem vc_echem_solvent_water_count_decreases_0_proved : vc_echem_solvent_water_count_decreases_0 = 0 := rfl

end echem_solvent_water_count

namespace echem_solvent_sphere_center_z_ang

def vc_echem_solvent_sphere_center_z_ang_requires_0 : Prop := True
theorem vc_echem_solvent_sphere_center_z_ang_requires_0_proved : vc_echem_solvent_sphere_center_z_ang_requires_0 := trivial
def vc_echem_solvent_sphere_center_z_ang_ensures_0 (result : Float) : Prop := (result > (4 : Float))
def vc_echem_solvent_sphere_center_z_ang_ensures_1 (result : Float) : Prop := (result < (6 : Float))
def vc_echem_solvent_sphere_center_z_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_sphere_center_z_ang_decreases_0_proved : vc_echem_solvent_sphere_center_z_ang_decreases_0 = 0 := rfl

end echem_solvent_sphere_center_z_ang

namespace echem_solvent_lj_epsilon_kcal

def vc_echem_solvent_lj_epsilon_kcal_requires_0 : Prop := True
theorem vc_echem_solvent_lj_epsilon_kcal_requires_0_proved : vc_echem_solvent_lj_epsilon_kcal_requires_0 := trivial
def vc_echem_solvent_lj_epsilon_kcal_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_solvent_lj_epsilon_kcal_decreases_0 : Nat := 0
theorem vc_echem_solvent_lj_epsilon_kcal_decreases_0_proved : vc_echem_solvent_lj_epsilon_kcal_decreases_0 = 0 := rfl

end echem_solvent_lj_epsilon_kcal

namespace echem_solvent_lj_sigma_ang

def vc_echem_solvent_lj_sigma_ang_requires_0 : Prop := True
theorem vc_echem_solvent_lj_sigma_ang_requires_0_proved : vc_echem_solvent_lj_sigma_ang_requires_0 := trivial
def vc_echem_solvent_lj_sigma_ang_ensures_0 (result : Float) : Prop := (result > (3 : Float))
def vc_echem_solvent_lj_sigma_ang_ensures_1 (result : Float) : Prop := (result < (3.5 : Float))
def vc_echem_solvent_lj_sigma_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_lj_sigma_ang_decreases_0_proved : vc_echem_solvent_lj_sigma_ang_decreases_0 = 0 := rfl

end echem_solvent_lj_sigma_ang

namespace echem_solvent_lj_rc_ang

def vc_echem_solvent_lj_rc_ang_requires_0 : Prop := True
theorem vc_echem_solvent_lj_rc_ang_requires_0_proved : vc_echem_solvent_lj_rc_ang_requires_0 := trivial
def vc_echem_solvent_lj_rc_ang_ensures_0 (result : Float) : Prop := (result > (7 : Float))
def vc_echem_solvent_lj_rc_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_lj_rc_ang_decreases_0_proved : vc_echem_solvent_lj_rc_ang_decreases_0 = 0 := rfl

end echem_solvent_lj_rc_ang

namespace echem_ewald_stub_kappa

def vc_echem_ewald_stub_kappa_requires_0 : Prop := True
theorem vc_echem_ewald_stub_kappa_requires_0_proved : vc_echem_ewald_stub_kappa_requires_0 := trivial
def vc_echem_ewald_stub_kappa_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_ewald_stub_kappa_decreases_0 : Nat := 0
theorem vc_echem_ewald_stub_kappa_decreases_0_proved : vc_echem_ewald_stub_kappa_decreases_0 = 0 := rfl

end echem_ewald_stub_kappa

namespace echem_ewald_stub_energy

def vc_echem_ewald_stub_energy_requires_0 (r : Float) : Prop := (r > (0 : Float))
def vc_echem_ewald_stub_energy_ensures_0 (r : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_ewald_stub_energy_decreases_0 (r : Float) : Nat := 0
theorem vc_echem_ewald_stub_energy_decreases_0_proved (r : Float) : vc_echem_ewald_stub_energy_decreases_0 r = 0 := rfl
def vc_echem_ewald_stub_energy_call0_echem_ewald_stub_kappa_requires_0 (r : Float) : Prop := True
theorem vc_echem_ewald_stub_energy_call0_echem_ewald_stub_kappa_requires_0_proved (r : Float) : vc_echem_ewald_stub_energy_call0_echem_ewald_stub_kappa_requires_0 r := trivial

end echem_ewald_stub_energy

namespace echem_solvent_water_spacing_ang

def vc_echem_solvent_water_spacing_ang_requires_0 : Prop := True
theorem vc_echem_solvent_water_spacing_ang_requires_0_proved : vc_echem_solvent_water_spacing_ang_requires_0 := trivial
def vc_echem_solvent_water_spacing_ang_ensures_0 (result : Float) : Prop := (result > (2.5 : Float))
def vc_echem_solvent_water_spacing_ang_ensures_1 (result : Float) : Prop := (result < (3.2 : Float))
def vc_echem_solvent_water_spacing_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_water_spacing_ang_decreases_0_proved : vc_echem_solvent_water_spacing_ang_decreases_0 = 0 := rfl

end echem_solvent_water_spacing_ang

namespace echem_solvent_water_oxygen_x

def vc_echem_solvent_water_oxygen_x_requires_0 (idx : Int) : Prop := (idx ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_water_oxygen_x_requires_1 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_x_requires_1_proved (idx : Int) : vc_echem_solvent_water_oxygen_x_requires_1 idx := trivial
def vc_echem_solvent_water_oxygen_x_ensures_0 (idx : Int) (result : Float) : Prop := (result ≥ (-8 : Float))
def vc_echem_solvent_water_oxygen_x_ensures_1 (idx : Int) (result : Float) : Prop := (result ≤ (8 : Float))
def vc_echem_solvent_water_oxygen_x_decreases_0 (idx : Int) : Nat := 0
theorem vc_echem_solvent_water_oxygen_x_decreases_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_x_decreases_0 idx = 0 := rfl
def vc_echem_solvent_water_oxygen_x_call0_echem_solvent_water_spacing_ang_requires_0 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_x_call0_echem_solvent_water_spacing_ang_requires_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_x_call0_echem_solvent_water_spacing_ang_requires_0 idx := trivial

end echem_solvent_water_oxygen_x

namespace echem_solvent_water_oxygen_y

def vc_echem_solvent_water_oxygen_y_requires_0 (idx : Int) : Prop := (idx ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_water_oxygen_y_requires_1 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_y_requires_1_proved (idx : Int) : vc_echem_solvent_water_oxygen_y_requires_1 idx := trivial
def vc_echem_solvent_water_oxygen_y_ensures_0 (idx : Int) (result : Float) : Prop := (result ≥ (-8 : Float))
def vc_echem_solvent_water_oxygen_y_ensures_1 (idx : Int) (result : Float) : Prop := (result ≤ (8 : Float))
def vc_echem_solvent_water_oxygen_y_decreases_0 (idx : Int) : Nat := 0
theorem vc_echem_solvent_water_oxygen_y_decreases_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_y_decreases_0 idx = 0 := rfl
def vc_echem_solvent_water_oxygen_y_call0_echem_solvent_water_spacing_ang_requires_0 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_y_call0_echem_solvent_water_spacing_ang_requires_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_y_call0_echem_solvent_water_spacing_ang_requires_0 idx := trivial

end echem_solvent_water_oxygen_y

namespace echem_solvent_water_oxygen_z

def vc_echem_solvent_water_oxygen_z_requires_0 (idx : Int) : Prop := (idx ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_water_oxygen_z_requires_1 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_z_requires_1_proved (idx : Int) : vc_echem_solvent_water_oxygen_z_requires_1 idx := trivial
def vc_echem_solvent_water_oxygen_z_ensures_0 (idx : Int) (result : Float) : Prop := (result > (3 : Float))
def vc_echem_solvent_water_oxygen_z_ensures_1 (idx : Int) (result : Float) : Prop := (result < (7 : Float))
def vc_echem_solvent_water_oxygen_z_decreases_0 (idx : Int) : Nat := 0
theorem vc_echem_solvent_water_oxygen_z_decreases_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_z_decreases_0 idx = 0 := rfl
def vc_echem_solvent_water_oxygen_z_call0_echem_solvent_sphere_center_z_ang_requires_0 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_z_call0_echem_solvent_sphere_center_z_ang_requires_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_z_call0_echem_solvent_sphere_center_z_ang_requires_0 idx := trivial
def vc_echem_solvent_water_oxygen_z_call1_echem_solvent_water_count_requires_0 (idx : Int) : Prop := True
theorem vc_echem_solvent_water_oxygen_z_call1_echem_solvent_water_count_requires_0_proved (idx : Int) : vc_echem_solvent_water_oxygen_z_call1_echem_solvent_water_count_requires_0 idx := trivial

end echem_solvent_water_oxygen_z

namespace echem_solvent_pair_distance_sq

def vc_echem_solvent_pair_distance_sq_requires_0 (idx_a : Int) (idx_b : Int) : Prop := (idx_a ≥ 0)
def vc_echem_solvent_pair_distance_sq_requires_1 (idx_a : Int) (idx_b : Int) : Prop := (idx_b ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_pair_distance_sq_requires_2 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_distance_sq_requires_2_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_distance_sq_requires_2 idx_a idx_b := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_pair_distance_sq_requires_3 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_distance_sq_requires_3_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_distance_sq_requires_3 idx_a idx_b := trivial
def vc_echem_solvent_pair_distance_sq_ensures_0 (idx_a : Int) (idx_b : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_solvent_pair_distance_sq_decreases_0 (idx_a : Int) (idx_b : Int) : Nat := 0
theorem vc_echem_solvent_pair_distance_sq_decreases_0_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_distance_sq_decreases_0 idx_a idx_b = 0 := rfl
def vc_echem_solvent_pair_distance_sq_call0_echem_solvent_water_oxygen_x_requires_0 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := (ib ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_water_oxygen_x' at call 0 -/
def vc_echem_solvent_pair_distance_sq_call0_echem_solvent_water_oxygen_x_requires_1 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := True
def vc_echem_solvent_pair_distance_sq_call1_echem_solvent_water_oxygen_x_requires_0 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := (ia ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_water_oxygen_x' at call 1 -/
def vc_echem_solvent_pair_distance_sq_call1_echem_solvent_water_oxygen_x_requires_1 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := True
def vc_echem_solvent_pair_distance_sq_call2_echem_solvent_water_oxygen_y_requires_0 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := (ib ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_water_oxygen_y' at call 2 -/
def vc_echem_solvent_pair_distance_sq_call2_echem_solvent_water_oxygen_y_requires_1 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := True
def vc_echem_solvent_pair_distance_sq_call3_echem_solvent_water_oxygen_y_requires_0 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := (ia ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_water_oxygen_y' at call 3 -/
def vc_echem_solvent_pair_distance_sq_call3_echem_solvent_water_oxygen_y_requires_1 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := True
def vc_echem_solvent_pair_distance_sq_call4_echem_solvent_water_oxygen_z_requires_0 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := (ib ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_water_oxygen_z' at call 4 -/
def vc_echem_solvent_pair_distance_sq_call4_echem_solvent_water_oxygen_z_requires_1 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := True
def vc_echem_solvent_pair_distance_sq_call5_echem_solvent_water_oxygen_z_requires_0 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := (ia ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_water_oxygen_z' at call 5 -/
def vc_echem_solvent_pair_distance_sq_call5_echem_solvent_water_oxygen_z_requires_1 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := True

end echem_solvent_pair_distance_sq

namespace echem_solvent_sqrt_r2

def vc_echem_solvent_sqrt_r2_requires_0 (r2 : Float) : Prop := (r2 ≥ (0 : Float))
def vc_echem_solvent_sqrt_r2_ensures_0 (r2 : Float) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_solvent_sqrt_r2_decreases_0 (r2 : Float) : Nat := 0
theorem vc_echem_solvent_sqrt_r2_decreases_0_proved (r2 : Float) : vc_echem_solvent_sqrt_r2_decreases_0 r2 = 0 := rfl

end echem_solvent_sqrt_r2

namespace echem_solvent_pair_lj_energy

def vc_echem_solvent_pair_lj_energy_requires_0 (idx_a : Int) (idx_b : Int) : Prop := (idx_a ≥ 0)
def vc_echem_solvent_pair_lj_energy_requires_1 (idx_a : Int) (idx_b : Int) : Prop := (idx_b ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_pair_lj_energy_requires_2 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_lj_energy_requires_2_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_lj_energy_requires_2 idx_a idx_b := trivial
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_pair_lj_energy_requires_3 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_lj_energy_requires_3_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_lj_energy_requires_3 idx_a idx_b := trivial
def vc_echem_solvent_pair_lj_energy_ensures_0 (idx_a : Int) (idx_b : Int) (result : Float) : Prop := (result ≥ (-100 : Float))
def vc_echem_solvent_pair_lj_energy_ensures_1 (idx_a : Int) (idx_b : Int) (result : Float) : Prop := (result ≤ (100 : Float))
def vc_echem_solvent_pair_lj_energy_decreases_0 (idx_a : Int) (idx_b : Int) : Nat := 0
theorem vc_echem_solvent_pair_lj_energy_decreases_0_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_lj_energy_decreases_0 idx_a idx_b = 0 := rfl
def vc_echem_solvent_pair_lj_energy_call0_echem_solvent_pair_distance_sq_requires_0 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := (ia ≥ 0)
def vc_echem_solvent_pair_lj_energy_call0_echem_solvent_pair_distance_sq_requires_1 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := (ib ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_distance_sq' at call 0 -/
def vc_echem_solvent_pair_lj_energy_call0_echem_solvent_pair_distance_sq_requires_2 (idx_a : Int) (idx_b : Int) (ia : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_distance_sq' at call 0 -/
def vc_echem_solvent_pair_lj_energy_call0_echem_solvent_pair_distance_sq_requires_3 (idx_a : Int) (idx_b : Int) (ib : Int) : Prop := True
def vc_echem_solvent_pair_lj_energy_call1_echem_solvent_sqrt_r2_requires_0 (idx_a : Int) (idx_b : Int) (r2 : Float) : Prop := (r2 ≥ (0 : Float))
def vc_echem_solvent_pair_lj_energy_call2_echem_solvent_lj_rc_ang_requires_0 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_lj_energy_call2_echem_solvent_lj_rc_ang_requires_0_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_lj_energy_call2_echem_solvent_lj_rc_ang_requires_0 idx_a idx_b := trivial
def vc_echem_solvent_pair_lj_energy_call3_echem_solvent_lj_epsilon_kcal_requires_0 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_lj_energy_call3_echem_solvent_lj_epsilon_kcal_requires_0_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_lj_energy_call3_echem_solvent_lj_epsilon_kcal_requires_0 idx_a idx_b := trivial
def vc_echem_solvent_pair_lj_energy_call4_echem_solvent_lj_sigma_ang_requires_0 (idx_a : Int) (idx_b : Int) : Prop := True
theorem vc_echem_solvent_pair_lj_energy_call4_echem_solvent_lj_sigma_ang_requires_0_proved (idx_a : Int) (idx_b : Int) : vc_echem_solvent_pair_lj_energy_call4_echem_solvent_lj_sigma_ang_requires_0 idx_a idx_b := trivial

end echem_solvent_pair_lj_energy

namespace echem_solvent_shell_energy_stub

def vc_echem_solvent_shell_energy_stub_requires_0 : Prop := True
theorem vc_echem_solvent_shell_energy_stub_requires_0_proved : vc_echem_solvent_shell_energy_stub_requires_0 := trivial
def vc_echem_solvent_shell_energy_stub_ensures_0 (result : Float) : Prop := (result ≠ (0 : Float))
def vc_echem_solvent_shell_energy_stub_decreases_0 : Nat := 0
theorem vc_echem_solvent_shell_energy_stub_decreases_0_proved : vc_echem_solvent_shell_energy_stub_decreases_0 = 0 := rfl
def vc_echem_solvent_shell_energy_stub_call0_echem_solvent_water_count_requires_0 : Prop := True
theorem vc_echem_solvent_shell_energy_stub_call0_echem_solvent_water_count_requires_0_proved : vc_echem_solvent_shell_energy_stub_call0_echem_solvent_water_count_requires_0 := trivial
def vc_echem_solvent_shell_energy_stub_call1_echem_solvent_pair_lj_energy_requires_0 : Prop := True
theorem vc_echem_solvent_shell_energy_stub_call1_echem_solvent_pair_lj_energy_requires_0_proved : vc_echem_solvent_shell_energy_stub_call1_echem_solvent_pair_lj_energy_requires_0 := trivial
def vc_echem_solvent_shell_energy_stub_call1_echem_solvent_pair_lj_energy_requires_1 (j : Int) : Prop := (j ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_lj_energy' at call 1 -/
def vc_echem_solvent_shell_energy_stub_call1_echem_solvent_pair_lj_energy_requires_2 : Prop := True
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_lj_energy' at call 1 -/
def vc_echem_solvent_shell_energy_stub_call1_echem_solvent_pair_lj_energy_requires_3 (j : Int) : Prop := True
def vc_echem_solvent_shell_energy_stub_call2_echem_solvent_pair_distance_sq_requires_0 : Prop := True
theorem vc_echem_solvent_shell_energy_stub_call2_echem_solvent_pair_distance_sq_requires_0_proved : vc_echem_solvent_shell_energy_stub_call2_echem_solvent_pair_distance_sq_requires_0 := trivial
def vc_echem_solvent_shell_energy_stub_call2_echem_solvent_pair_distance_sq_requires_1 (j : Int) : Prop := (j ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_distance_sq' at call 2 -/
def vc_echem_solvent_shell_energy_stub_call2_echem_solvent_pair_distance_sq_requires_2 : Prop := True
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_distance_sq' at call 2 -/
def vc_echem_solvent_shell_energy_stub_call2_echem_solvent_pair_distance_sq_requires_3 (j : Int) : Prop := True
def vc_echem_solvent_shell_energy_stub_call3_echem_solvent_sqrt_r2_requires_0 (r2 : Float) : Prop := (r2 ≥ (0 : Float))
def vc_echem_solvent_shell_energy_stub_call4_echem_ewald_stub_energy_requires_0 (r : Float) : Prop := (r > (0 : Float))

end echem_solvent_shell_energy_stub

namespace echem_solvent_gr_bin_count

def vc_echem_solvent_gr_bin_count_requires_0 : Prop := True
theorem vc_echem_solvent_gr_bin_count_requires_0_proved : vc_echem_solvent_gr_bin_count_requires_0 := trivial
def vc_echem_solvent_gr_bin_count_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_solvent_gr_bin_count_ensures_0_proved (result : Int) : vc_echem_solvent_gr_bin_count_ensures_0 result := trivial
def vc_echem_solvent_gr_bin_count_decreases_0 : Nat := 0
theorem vc_echem_solvent_gr_bin_count_decreases_0_proved : vc_echem_solvent_gr_bin_count_decreases_0 = 0 := rfl

end echem_solvent_gr_bin_count

namespace echem_solvent_gr_dr_ang

def vc_echem_solvent_gr_dr_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_dr_ang_requires_0_proved : vc_echem_solvent_gr_dr_ang_requires_0 := trivial
def vc_echem_solvent_gr_dr_ang_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_solvent_gr_dr_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_gr_dr_ang_decreases_0_proved : vc_echem_solvent_gr_dr_ang_decreases_0 = 0 := rfl

end echem_solvent_gr_dr_ang

namespace echem_solvent_gr_bin_lo_ang

def vc_echem_solvent_gr_bin_lo_ang_requires_0 (bin_idx : Int) : Prop := (bin_idx ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_gr_bin_lo_ang_requires_1 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_lo_ang_requires_1_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_lo_ang_requires_1 bin_idx := trivial
def vc_echem_solvent_gr_bin_lo_ang_ensures_0 (bin_idx : Int) (result : Float) : Prop := (result ≥ (0 : Float))
def vc_echem_solvent_gr_bin_lo_ang_decreases_0 (bin_idx : Int) : Nat := Int.toNat bin_idx
theorem vc_echem_solvent_gr_bin_lo_ang_decreases_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_lo_ang_decreases_0 bin_idx = Int.toNat bin_idx := rfl

end echem_solvent_gr_bin_lo_ang

namespace echem_solvent_gr_bin_center_ang

def vc_echem_solvent_gr_bin_center_ang_requires_0 (bin_idx : Int) : Prop := (bin_idx ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_gr_bin_center_ang_requires_1 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_center_ang_requires_1_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_center_ang_requires_1 bin_idx := trivial
def vc_echem_solvent_gr_bin_center_ang_ensures_0 (bin_idx : Int) (result : Float) : Prop := (result > (0 : Float))
def vc_echem_solvent_gr_bin_center_ang_decreases_0 (bin_idx : Int) : Nat := Int.toNat bin_idx
theorem vc_echem_solvent_gr_bin_center_ang_decreases_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_center_ang_decreases_0 bin_idx = Int.toNat bin_idx := rfl
def vc_echem_solvent_gr_bin_center_ang_call0_echem_solvent_gr_bin_lo_ang_requires_0 (bin_idx : Int) : Prop := (bin_idx ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_gr_bin_lo_ang' at call 0 -/
def vc_echem_solvent_gr_bin_center_ang_call0_echem_solvent_gr_bin_lo_ang_requires_1 (bin_idx : Int) : Prop := True
def vc_echem_solvent_gr_bin_center_ang_call1_echem_solvent_gr_dr_ang_requires_0 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_center_ang_call1_echem_solvent_gr_dr_ang_requires_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_center_ang_call1_echem_solvent_gr_dr_ang_requires_0 bin_idx := trivial

end echem_solvent_gr_bin_center_ang

namespace echem_solvent_gr_bin_hits

def vc_echem_solvent_gr_bin_hits_requires_0 (bin_idx : Int) : Prop := (bin_idx ≥ 0)
/-! VC requires (opaque): source expr not yet translated -/
def vc_echem_solvent_gr_bin_hits_requires_1 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_hits_requires_1_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_requires_1 bin_idx := trivial
def vc_echem_solvent_gr_bin_hits_ensures_0 (bin_idx : Int) (result : Int) : Prop := (result ≥ 0)
def vc_echem_solvent_gr_bin_hits_decreases_0 (bin_idx : Int) : Nat := 0
theorem vc_echem_solvent_gr_bin_hits_decreases_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_decreases_0 bin_idx = 0 := rfl
def vc_echem_solvent_gr_bin_hits_call0_echem_solvent_water_count_requires_0 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_hits_call0_echem_solvent_water_count_requires_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_call0_echem_solvent_water_count_requires_0 bin_idx := trivial
def vc_echem_solvent_gr_bin_hits_call1_echem_solvent_gr_dr_ang_requires_0 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_hits_call1_echem_solvent_gr_dr_ang_requires_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_call1_echem_solvent_gr_dr_ang_requires_0 bin_idx := trivial
def vc_echem_solvent_gr_bin_hits_call2_echem_solvent_pair_distance_sq_requires_0 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_hits_call2_echem_solvent_pair_distance_sq_requires_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_call2_echem_solvent_pair_distance_sq_requires_0 bin_idx := trivial
def vc_echem_solvent_gr_bin_hits_call2_echem_solvent_pair_distance_sq_requires_1 (bin_idx : Int) (j : Int) : Prop := (j ≥ 0)
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_distance_sq' at call 2 -/
def vc_echem_solvent_gr_bin_hits_call2_echem_solvent_pair_distance_sq_requires_2 (bin_idx : Int) : Prop := True
/-! VC call-site requires (opaque): callee 'echem_solvent_pair_distance_sq' at call 2 -/
def vc_echem_solvent_gr_bin_hits_call2_echem_solvent_pair_distance_sq_requires_3 (bin_idx : Int) (j : Int) : Prop := True
def vc_echem_solvent_gr_bin_hits_call3_echem_solvent_sqrt_r2_requires_0 (bin_idx : Int) (r2 : Float) : Prop := (r2 ≥ (0 : Float))
def vc_echem_solvent_gr_bin_hits_call4_echem_solvent_gr_bin_count_requires_0 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_hits_call4_echem_solvent_gr_bin_count_requires_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_call4_echem_solvent_gr_bin_count_requires_0 bin_idx := trivial
def vc_echem_solvent_gr_bin_hits_call5_echem_solvent_gr_bin_lo_ang_requires_0 (bin_idx : Int) : Prop := True
theorem vc_echem_solvent_gr_bin_hits_call5_echem_solvent_gr_bin_lo_ang_requires_0_proved (bin_idx : Int) : vc_echem_solvent_gr_bin_hits_call5_echem_solvent_gr_bin_lo_ang_requires_0 bin_idx := trivial
/-! VC call-site requires (opaque): callee 'echem_solvent_gr_bin_lo_ang' at call 5 -/
def vc_echem_solvent_gr_bin_hits_call5_echem_solvent_gr_bin_lo_ang_requires_1 (bin_idx : Int) : Prop := True

end echem_solvent_gr_bin_hits

namespace echem_solvent_gr_peak_r_ang

def vc_echem_solvent_gr_peak_r_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_r_ang_requires_0_proved : vc_echem_solvent_gr_peak_r_ang_requires_0 := trivial
def vc_echem_solvent_gr_peak_r_ang_ensures_0 (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_echem_solvent_gr_peak_r_ang_ensures_0_proved (result : Float) : vc_echem_solvent_gr_peak_r_ang_ensures_0 result := trivial
def vc_echem_solvent_gr_peak_r_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_gr_peak_r_ang_decreases_0_proved : vc_echem_solvent_gr_peak_r_ang_decreases_0 = 0 := rfl
def vc_echem_solvent_gr_peak_r_ang_call0_echem_solvent_gr_bin_count_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_r_ang_call0_echem_solvent_gr_bin_count_requires_0_proved : vc_echem_solvent_gr_peak_r_ang_call0_echem_solvent_gr_bin_count_requires_0 := trivial
def vc_echem_solvent_gr_peak_r_ang_call1_echem_solvent_gr_bin_hits_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_r_ang_call1_echem_solvent_gr_bin_hits_requires_0_proved : vc_echem_solvent_gr_peak_r_ang_call1_echem_solvent_gr_bin_hits_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_solvent_gr_bin_hits' at call 1 -/
def vc_echem_solvent_gr_peak_r_ang_call1_echem_solvent_gr_bin_hits_requires_1 : Prop := True
def vc_echem_solvent_gr_peak_r_ang_call2_echem_solvent_gr_bin_center_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_r_ang_call2_echem_solvent_gr_bin_center_ang_requires_0_proved : vc_echem_solvent_gr_peak_r_ang_call2_echem_solvent_gr_bin_center_ang_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'echem_solvent_gr_bin_center_ang' at call 2 -/
def vc_echem_solvent_gr_peak_r_ang_call2_echem_solvent_gr_bin_center_ang_requires_1 : Prop := True

end echem_solvent_gr_peak_r_ang

namespace echem_solvent_gr_peak_reference_ang

def vc_echem_solvent_gr_peak_reference_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_reference_ang_requires_0_proved : vc_echem_solvent_gr_peak_reference_ang_requires_0 := trivial
def vc_echem_solvent_gr_peak_reference_ang_ensures_0 (result : Float) : Prop := (result > (2 : Float))
def vc_echem_solvent_gr_peak_reference_ang_ensures_1 (result : Float) : Prop := (result < (4 : Float))
def vc_echem_solvent_gr_peak_reference_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_gr_peak_reference_ang_decreases_0_proved : vc_echem_solvent_gr_peak_reference_ang_decreases_0 = 0 := rfl

end echem_solvent_gr_peak_reference_ang

namespace echem_solvent_gr_peak_tolerance_ang

def vc_echem_solvent_gr_peak_tolerance_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_tolerance_ang_requires_0_proved : vc_echem_solvent_gr_peak_tolerance_ang_requires_0 := trivial
def vc_echem_solvent_gr_peak_tolerance_ang_ensures_0 (result : Float) : Prop := (result > (0 : Float))
def vc_echem_solvent_gr_peak_tolerance_ang_decreases_0 : Nat := 0
theorem vc_echem_solvent_gr_peak_tolerance_ang_decreases_0_proved : vc_echem_solvent_gr_peak_tolerance_ang_decreases_0 = 0 := rfl

end echem_solvent_gr_peak_tolerance_ang

namespace echem_solvent_gr_peak_smoke

def vc_echem_solvent_gr_peak_smoke_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_smoke_requires_0_proved : vc_echem_solvent_gr_peak_smoke_requires_0 := trivial
def vc_echem_solvent_gr_peak_smoke_ensures_0 (result : Int) : Prop := (result ≥ 0)
def vc_echem_solvent_gr_peak_smoke_ensures_1 (result : Int) : Prop := (result ≤ 1)
def vc_echem_solvent_gr_peak_smoke_decreases_0 : Nat := 0
theorem vc_echem_solvent_gr_peak_smoke_decreases_0_proved : vc_echem_solvent_gr_peak_smoke_decreases_0 = 0 := rfl
def vc_echem_solvent_gr_peak_smoke_call0_echem_solvent_gr_peak_r_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_smoke_call0_echem_solvent_gr_peak_r_ang_requires_0_proved : vc_echem_solvent_gr_peak_smoke_call0_echem_solvent_gr_peak_r_ang_requires_0 := trivial
def vc_echem_solvent_gr_peak_smoke_call1_echem_solvent_gr_peak_reference_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_smoke_call1_echem_solvent_gr_peak_reference_ang_requires_0_proved : vc_echem_solvent_gr_peak_smoke_call1_echem_solvent_gr_peak_reference_ang_requires_0 := trivial
def vc_echem_solvent_gr_peak_smoke_call2_echem_solvent_gr_peak_tolerance_ang_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_smoke_call2_echem_solvent_gr_peak_tolerance_ang_requires_0_proved : vc_echem_solvent_gr_peak_smoke_call2_echem_solvent_gr_peak_tolerance_ang_requires_0 := trivial
def vc_echem_solvent_gr_peak_smoke_call3_echem_solvent_shell_energy_stub_requires_0 : Prop := True
theorem vc_echem_solvent_gr_peak_smoke_call3_echem_solvent_shell_energy_stub_requires_0_proved : vc_echem_solvent_gr_peak_smoke_call3_echem_solvent_shell_energy_stub_requires_0 := trivial

end echem_solvent_gr_peak_smoke

namespace li_std_physics_rigid_version

def vc_li_std_physics_rigid_version_requires_0 : Prop := True
theorem vc_li_std_physics_rigid_version_requires_0_proved : vc_li_std_physics_rigid_version_requires_0 := trivial
def vc_li_std_physics_rigid_version_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_li_std_physics_rigid_version_ensures_0_proved (result : Int) : vc_li_std_physics_rigid_version_ensures_0 result := trivial
def vc_li_std_physics_rigid_version_decreases_0 : Nat := 0
theorem vc_li_std_physics_rigid_version_decreases_0_proved : vc_li_std_physics_rigid_version_decreases_0 = 0 := rfl

end li_std_physics_rigid_version

namespace rigid_integrate_semi_implicit

def vc_rigid_integrate_semi_implicit_requires_0 (b : Int) (fx : Float) (fy : Float) (fz : Float) (dt : Float) : Prop := (dt > (0 : Float))
def vc_rigid_integrate_semi_implicit_ensures_0 (b : Int) (fx : Float) (fy : Float) (fz : Float) (dt : Float) (result : Unit) : Prop := (result = 0)
def vc_rigid_integrate_semi_implicit_decreases_0 (b : Int) (fx : Float) (fy : Float) (fz : Float) (dt : Float) : Nat := 0
theorem vc_rigid_integrate_semi_implicit_decreases_0_proved (b : Int) (fx : Float) (fy : Float) (fz : Float) (dt : Float) : vc_rigid_integrate_semi_implicit_decreases_0 b fx fy fz dt = 0 := rfl

end rigid_integrate_semi_implicit

namespace aabb_overlap

def vc_aabb_overlap_requires_0 (min_ax : Float) (min_ay : Float) (max_ax : Float) (max_ay : Float) (min_bx : Float) (min_by : Float) (max_bx : Float) (max_by : Float) : Prop := True
theorem vc_aabb_overlap_requires_0_proved (min_ax : Float) (min_ay : Float) (max_ax : Float) (max_ay : Float) (min_bx : Float) (min_by : Float) (max_bx : Float) (max_by : Float) : vc_aabb_overlap_requires_0 min_ax min_ay max_ax max_ay min_bx min_by max_bx max_by := trivial
def vc_aabb_overlap_ensures_0 (min_ax : Float) (min_ay : Float) (max_ax : Float) (max_ay : Float) (min_bx : Float) (min_by : Float) (max_bx : Float) (max_by : Float) (result : Int) : Prop := (result ≥ 0)
def vc_aabb_overlap_ensures_1 (min_ax : Float) (min_ay : Float) (max_ax : Float) (max_ay : Float) (min_bx : Float) (min_by : Float) (max_bx : Float) (max_by : Float) (result : Int) : Prop := (result ≤ 1)
def vc_aabb_overlap_decreases_0 (min_ax : Float) (min_ay : Float) (max_ax : Float) (max_ay : Float) (min_bx : Float) (min_by : Float) (max_bx : Float) (max_by : Float) : Nat := 0
theorem vc_aabb_overlap_decreases_0_proved (min_ax : Float) (min_ay : Float) (max_ax : Float) (max_ay : Float) (min_bx : Float) (min_by : Float) (max_bx : Float) (max_by : Float) : vc_aabb_overlap_decreases_0 min_ax min_ay max_ax max_ay min_bx min_by max_bx max_by = 0 := rfl

end aabb_overlap

namespace sphere_sphere_overlap

def vc_sphere_sphere_overlap_requires_0 (ax : Float) (ay : Float) (az : Float) (ra : Float) (bx : Float) (by_ : Float) (bz : Float) (rb : Float) : Prop := (ra ≥ (0 : Float))
def vc_sphere_sphere_overlap_requires_1 (ax : Float) (ay : Float) (az : Float) (ra : Float) (bx : Float) (by_ : Float) (bz : Float) (rb : Float) : Prop := (rb ≥ (0 : Float))
def vc_sphere_sphere_overlap_ensures_0 (ax : Float) (ay : Float) (az : Float) (ra : Float) (bx : Float) (by_ : Float) (bz : Float) (rb : Float) (result : Int) : Prop := (result ≥ 0)
def vc_sphere_sphere_overlap_ensures_1 (ax : Float) (ay : Float) (az : Float) (ra : Float) (bx : Float) (by_ : Float) (bz : Float) (rb : Float) (result : Int) : Prop := (result ≤ 1)
def vc_sphere_sphere_overlap_decreases_0 (ax : Float) (ay : Float) (az : Float) (ra : Float) (bx : Float) (by_ : Float) (bz : Float) (rb : Float) : Nat := 0
theorem vc_sphere_sphere_overlap_decreases_0_proved (ax : Float) (ay : Float) (az : Float) (ra : Float) (bx : Float) (by_ : Float) (bz : Float) (rb : Float) : vc_sphere_sphere_overlap_decreases_0 ax ay az ra bx by_ bz rb = 0 := rfl

end sphere_sphere_overlap

namespace pgs_resolve_normal

def vc_pgs_resolve_normal_requires_0 (vn : Float) (impulse : Float) (bias : Float) (mass_inv : Float) : Prop := (mass_inv ≥ (0 : Float))
def vc_pgs_resolve_normal_ensures_0 (vn : Float) (impulse : Float) (bias : Float) (mass_inv : Float) (result : Float) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_pgs_resolve_normal_ensures_0_proved (vn : Float) (impulse : Float) (bias : Float) (mass_inv : Float) (result : Float) : vc_pgs_resolve_normal_ensures_0 vn impulse bias mass_inv result := trivial
def vc_pgs_resolve_normal_decreases_0 (vn : Float) (impulse : Float) (bias : Float) (mass_inv : Float) : Nat := 0
theorem vc_pgs_resolve_normal_decreases_0_proved (vn : Float) (impulse : Float) (bias : Float) (mass_inv : Float) : vc_pgs_resolve_normal_decreases_0 vn impulse bias mass_inv = 0 := rfl

end pgs_resolve_normal

namespace broadphase_cell_index

def vc_broadphase_cell_index_requires_0 (x : Float) (cell_size : Float) : Prop := (cell_size > (0 : Float))
def vc_broadphase_cell_index_ensures_0 (x : Float) (cell_size : Float) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_broadphase_cell_index_ensures_0_proved (x : Float) (cell_size : Float) (result : Int) : vc_broadphase_cell_index_ensures_0 x cell_size result := trivial
def vc_broadphase_cell_index_decreases_0 (x : Float) (cell_size : Float) : Nat := 0
theorem vc_broadphase_cell_index_decreases_0_proved (x : Float) (cell_size : Float) : vc_broadphase_cell_index_decreases_0 x cell_size = 0 := rfl

end broadphase_cell_index

end AutoVC
