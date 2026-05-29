-- Auto-generated VC obligations (Phase 2e). Props typecheck in Lean; discharge in 2f.
import Init.Data.Float
import Core
import Discharge

open Li

namespace AutoVC

namespace lig_kernel_matmul_f32

def vc_lig_kernel_matmul_f32_requires_0 : Prop := True
theorem vc_lig_kernel_matmul_f32_requires_0_proved : vc_lig_kernel_matmul_f32_requires_0 := trivial
def vc_lig_kernel_matmul_f32_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_matmul_f32_ensures_0_proved (result : Int) : vc_lig_kernel_matmul_f32_ensures_0 result := trivial
def vc_lig_kernel_matmul_f32_decreases_0 : Nat := 0
theorem vc_lig_kernel_matmul_f32_decreases_0_proved : vc_lig_kernel_matmul_f32_decreases_0 = 0 := rfl

end lig_kernel_matmul_f32

namespace lig_backend_webgpu

def vc_lig_backend_webgpu_requires_0 : Prop := True
theorem vc_lig_backend_webgpu_requires_0_proved : vc_lig_backend_webgpu_requires_0 := trivial
def vc_lig_backend_webgpu_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_webgpu_ensures_0_proved (result : Int) : vc_lig_backend_webgpu_ensures_0 result := trivial
def vc_lig_backend_webgpu_decreases_0 : Nat := 0
theorem vc_lig_backend_webgpu_decreases_0_proved : vc_lig_backend_webgpu_decreases_0 = 0 := rfl

end lig_backend_webgpu

namespace lig_backend_vulkan_spirv

def vc_lig_backend_vulkan_spirv_requires_0 : Prop := True
theorem vc_lig_backend_vulkan_spirv_requires_0_proved : vc_lig_backend_vulkan_spirv_requires_0 := trivial
def vc_lig_backend_vulkan_spirv_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_backend_vulkan_spirv_ensures_0_proved (result : Int) : vc_lig_backend_vulkan_spirv_ensures_0 result := trivial
def vc_lig_backend_vulkan_spirv_decreases_0 : Nat := 0
theorem vc_lig_backend_vulkan_spirv_decreases_0_proved : vc_lig_backend_vulkan_spirv_decreases_0 = 0 := rfl

end lig_backend_vulkan_spirv

namespace lig_kernel_run

def vc_lig_kernel_run_requires_0 (kernel_id : Int) (backend_id : Int) : Prop := (kernel_id ≥ 1)
def vc_lig_kernel_run_requires_1 (kernel_id : Int) (backend_id : Int) : Prop := (1 ≤ backend_id)
def vc_lig_kernel_run_requires_2 (kernel_id : Int) (backend_id : Int) : Prop := (backend_id ≤ 5)
def vc_lig_kernel_run_ensures_0 (kernel_id : Int) (backend_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_run_ensures_0_proved (kernel_id : Int) (backend_id : Int) (result : Int) : vc_lig_kernel_run_ensures_0 kernel_id backend_id result := trivial
def vc_lig_kernel_run_ensures_1 (kernel_id : Int) (backend_id : Int) (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_lig_kernel_run_ensures_1_proved (kernel_id : Int) (backend_id : Int) (result : Int) : vc_lig_kernel_run_ensures_1 kernel_id backend_id result := trivial
def vc_lig_kernel_run_decreases_0 (kernel_id : Int) (backend_id : Int) : Nat := Int.toNat kernel_id
theorem vc_lig_kernel_run_decreases_0_proved (kernel_id : Int) (backend_id : Int) : vc_lig_kernel_run_decreases_0 kernel_id backend_id = Int.toNat kernel_id := rfl
def vc_lig_kernel_run_call0_li_rt_lig_kernel_run_requires_0 (kernel_id : Int) (backend_id : Int) : Prop := (kernel_id ≥ 1)
def vc_lig_kernel_run_call0_li_rt_lig_kernel_run_requires_1 (kernel_id : Int) (backend_id : Int) : Prop := (1 ≤ backend_id)
def vc_lig_kernel_run_call0_li_rt_lig_kernel_run_requires_2 (kernel_id : Int) (backend_id : Int) : Prop := (backend_id ≤ 5)

end lig_kernel_run

namespace lig_validity_gate_pass

def vc_lig_validity_gate_pass_requires_0 (min_ratio : Float) : Prop := ((0 : Float) ≤ min_ratio)
def vc_lig_validity_gate_pass_requires_1 (min_ratio : Float) : Prop := (min_ratio ≤ (1 : Float))
def vc_lig_validity_gate_pass_ensures_0 (min_ratio : Float) (result : Int) : Prop := (result ≥ 0)
def vc_lig_validity_gate_pass_ensures_1 (min_ratio : Float) (result : Int) : Prop := (result ≤ 1)
def vc_lig_validity_gate_pass_decreases_0 (min_ratio : Float) : Nat := 0
theorem vc_lig_validity_gate_pass_decreases_0_proved (min_ratio : Float) : vc_lig_validity_gate_pass_decreases_0 min_ratio = 0 := rfl
def vc_lig_validity_gate_pass_call0_li_rt_lig_kernel_last_validity_ratio_requires_0 (min_ratio : Float) : Prop := True
theorem vc_lig_validity_gate_pass_call0_li_rt_lig_kernel_last_validity_ratio_requires_0_proved (min_ratio : Float) : vc_lig_validity_gate_pass_call0_li_rt_lig_kernel_last_validity_ratio_requires_0 min_ratio := trivial

end lig_validity_gate_pass

namespace main

def vc_main_requires_0 : Prop := True
theorem vc_main_requires_0_proved : vc_main_requires_0 := trivial
def vc_main_ensures_0 (result : Int) : Prop := True
/-! Phase 2f: return expression matches ensures (static witness) -/
theorem vc_main_ensures_0_proved (result : Int) : vc_main_ensures_0 result := trivial
def vc_main_decreases_0 : Nat := 0
theorem vc_main_decreases_0_proved : vc_main_decreases_0 = 0 := rfl
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 0 -/
def vc_main_call0_lig_kernel_run_requires_0 : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 0 -/
def vc_main_call0_lig_kernel_run_requires_1 : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 0 -/
def vc_main_call0_lig_kernel_run_requires_2 : Prop := True
def vc_main_call1_lig_kernel_matmul_f32_requires_0 : Prop := True
theorem vc_main_call1_lig_kernel_matmul_f32_requires_0_proved : vc_main_call1_lig_kernel_matmul_f32_requires_0 := trivial
def vc_main_call2_lig_backend_vulkan_spirv_requires_0 : Prop := True
theorem vc_main_call2_lig_backend_vulkan_spirv_requires_0_proved : vc_main_call2_lig_backend_vulkan_spirv_requires_0 := trivial
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 3 -/
def vc_main_call3_lig_kernel_run_requires_0 : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 3 -/
def vc_main_call3_lig_kernel_run_requires_1 : Prop := True
/-! VC call-site requires (opaque): callee 'lig_kernel_run' at call 3 -/
def vc_main_call3_lig_kernel_run_requires_2 : Prop := True
def vc_main_call4_lig_kernel_matmul_f32_requires_0 : Prop := True
theorem vc_main_call4_lig_kernel_matmul_f32_requires_0_proved : vc_main_call4_lig_kernel_matmul_f32_requires_0 := trivial
def vc_main_call5_lig_backend_webgpu_requires_0 : Prop := True
theorem vc_main_call5_lig_backend_webgpu_requires_0_proved : vc_main_call5_lig_backend_webgpu_requires_0 := trivial
def vc_main_call6_lig_validity_gate_pass_requires_0 : Prop := ((0 : Float) ≤ (0.999 : Float))
def vc_main_call6_lig_validity_gate_pass_requires_1 : Prop := ((0.999 : Float) ≤ (1 : Float))

end main

end AutoVC
