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
def vc_main_call0_chem_dft_energy_kernel_hartree_requires_0 : Prop := True
theorem vc_main_call0_chem_dft_energy_kernel_hartree_requires_0_proved : vc_main_call0_chem_dft_energy_kernel_hartree_requires_0 := trivial

end main

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

end AutoVC
