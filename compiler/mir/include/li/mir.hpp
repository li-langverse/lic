#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <string>
#include <vector>

namespace li {

enum class MirOp {
  ReturnVoid,
  ReturnInt,
  ReturnFloat,
  ReturnIdent,
  /** Pack locals named `ident + "_" + layout[i].name` into LLVM struct return (scalars or
   *  fixed arrays as `[N x T]` aggregates). */
  ReturnObject,
  EchoInt,
  EchoString,
  CallExtern,
  CallProc,
  ArrayAlloc,
  ArrayStoreInt,
  ArrayLoadInt,
  ArrayStoreFloat,
  ArrayLoadFloat,
  ArrayDotF64,
  /** Element of `array[M, array[N, float]]`; row=int_value/index_ident, col=rhs_int/lhs_ident */
  ArrayLoad2DF64,
  ArrayStore2DF64,
  /** C[M,N] = A[M,K] @ B[K,N] — nested `array[M, array[K, float]]`; M=int_value, K=rhs_int, N=lhs_int */
  ArrayMatMul2DF64,
  ArraySumF64,
  ArraySumI64,
  /** Element-wise binop into `ident` from `lhs_ident` and `rhs_ident` (length `int_value`). */
  ArrayBinOpF64,
  ArrayBinOpI64,
  /** `dest[i] = scale * lhs[i]` — scale in `rhs_ident` (float local) or `float_value` if literal. */
  ArrayScaleF64,
  /** `rhs[i] = scale * lhs[i] + rhs[i]` — scale in `ident`, lhs=x, rhs=y. */
  ArrayAxpyF64,
  LocalAllocInt,
  LocalAllocI64,
  StoreInt,
  StoreI64,
  StoreFloat,
  LoadIntToIdent,
  BinOpInt,
  UnaryBitNotInt,
  BinOpFloat,
  /** `ident = lhs_ident * rhs_ident + float_value` (LLVM fmuladd) — horner / FMA chains */
  FmaFloatF64,
  /** Chained fmuladd: ident = fma(lhs_ident, ident, float_value) repeated int_value times (SSA). */
  HornerFmaUnroll,
  /** acc = acc * x^4 + (1+x+x²+x³); lhs_is_literal, float_value = const x; int_value = supersteps. */
  HornerStepPow4,
  /** Tight loop: acc = acc * float_value + 1.0 repeated int_value times (const x in float_value). */
  HornerConstLoopF64,
  /** Blocked IKJ: C[n,n] += A[n,n] @ B[n,n]; int_value = n, rhs_int = block size. */
  ArrayMatMulBlocked2DF64,
  LocalAllocFloat,
  LocalAllocSimdF64,
  SimdSplatF64,
  SimdMulF64,
  SimdAddF64,
  SimdHorizSumF64,
  SimdCopyF64,
  OmpParallelFor,
  /** `distributed for` — block partition via runtime/li_dpar.c (**G-par-dist**, WP-PAR-23). */
  DParFor,
  /** `par_sum(a)` on float tiles → runtime/li_par_reduce.c tree reduce (WP-PAR-15). */
  ParReduceSumF64,
  Label,
  Jump,
  BranchIfZero,
  AsyncAwait,
  AsyncFrameEnter,
  AsyncFrameLeave,
  /** Push/pop scoped array SIMD: int_value 1=enable, 0=pop (pairs with `@vectorized` on `for`). */
  ArraySimdScope,
  /** WP-PAR-08 — push scoped team(cores=N). int_value = cores. */
  TeamPush,
  /** WP-PAR-08 — pop scoped team. */
  TeamPop,
  /** WP-PAR-71 — overlap comm site (compile-time intent). */
  OverlapComm,
  /** WP-PAR-88 — elide copy site. */
  XferElide,
  /** WP-PAR-89 — fuse xfer site. */
  XferFusion,
  /** WP-PAR-90 — d2d path site. */
  XferD2d,
  /** WP-PAR-91 — rdma gpu site. */
  XferRdmaGpu,
  /** WP-PAR-09 — apply embedded __li_exec_plan at program entry. */
  ExecPlanApply,
  /** WP-PAR-70 — apply embedded __li_comm_plan at program entry. */
  CommPlanApply,
  /** WP-PAR-87 — apply embedded __li_xfer_plan at program entry. */
  XferPlanApply,
};

struct MirArg {
  bool is_literal = false;
  std::int64_t int_value = 0;
  bool is_float_literal = false;
  double float_value = 0.0;
  std::string ident;
  bool is_string = false;
  std::string str_value;
  /** Pass `ident` array alloca by address (CallProc array param). */
  bool is_array_ident = false;
};

struct MirParam {
  std::string name;
  bool is_float = false;
  bool is_string = false;
  bool is_i64 = false;
  bool is_simd_f64 = false;
  std::int64_t simd_lanes = 0;
  /** When >0, slot is `ident + "_" + name` as ArrayAlloc; LLVM uses `[N x scalar]` in structs. */
  std::int64_t fixed_array_elems = 0;
  /** `array[M, array[K, float]]` param: rows in fixed_array_elems, cols here. */
  bool is_matrix = false;
  std::int64_t matrix_cols = 0;
  /** `var array[...]` — pass by pointer; mutations visible to caller (WP-PAR-18). */
  bool is_var = false;
};

/** Array (or matrix) captured by an outlined `__li_par_*` body from the enclosing def. */
struct MirParCapture {
  std::string ident;
  std::int64_t fixed_array_elems = 0;
  bool is_float = false;
  bool is_matrix = false;
  std::int64_t matrix_cols = 0;
};

struct MirInsn {
  MirOp op = MirOp::ReturnVoid;
  std::int64_t int_value = 0;
  double float_value = 0.0;
  std::string ident;
  std::string str_value;
  std::string callee;
  std::string lhs_ident;
  std::string rhs_ident;
  std::string label;
  BinOp bin_op = BinOp::Add;
  bool ret_is_float = false;
  bool ret_is_i64 = false;
  bool index_is_literal = true;
  std::string index_ident;
  bool use_loaded_int = false;
  bool rhs_is_literal = true;
  std::int64_t rhs_int = 0;
  bool lhs_is_literal = false;
  std::int64_t lhs_int = 0;
  bool is_i64 = false;
  bool array_is_float = false;
  /** `array[M, array[K, float]]` row-major tile; cols in rhs_int when true. */
  bool array_is_matrix = false;
  /** Element-wise op: other operand is `array[1, *]` — use its index 0 at every lane. */
  bool array_broadcast_lhs_len1 = false;
  bool array_broadcast_rhs_len1 = false;
  std::int64_t simd_lanes = 0;
  /** Policy-accepted disjoint witness on this `OmpParallelFor` (**G-par**). */
  bool parallel_disjoint_proven = false;
  /** `reduce(+|min|max: ident)` — float accumulator (WP-PAR-15). */
  ParReduceKind par_reduce_kind = ParReduceKind::None;
  std::string par_reduce_var;
  /** Outlined-loop captures published before `li_parallel_for_i64` (WP-PAR-18). */
  std::vector<MirParCapture> par_captures;
  std::vector<MirArg> args;
  /** Layout entries under object root (`name` paths). Used for ReturnObject pack and CallProc
   *  unpack into `ident + "_" + name` (scalar locals or ArrayAlloc slots). */
  std::vector<MirParam> object_layout;
};

struct MirDecorator {
  std::string name;
  /** `@vectorized(lanes=N)` when name is vectorized; 0 if omitted. */
  std::int64_t lanes = 0;
  /** `@vectorized` on the owning `def` (7d-b MIR proc tag); SIMD LLVM only, never `OmpParallelFor`. */
  bool vectorized = false;
  /** `@cpu` host-placement tag (7d-b MIR proc tag); never lowers to device launch. */
  bool cpu = false;
  /** `@gpu` device-placement tag. Lowering/codegen remains G-gpu; this makes placement visible to gates. */
  bool gpu = false;
  /** Requested device count for `@gpu(devices=N)`; 1 means ordinary single-device placement. */
  std::int64_t gpu_devices = 0;
  /** `@offload` hetero placement tag (**WP-PAR-07**). */
  bool offload = false;
  bool parallel = false;
  bool disjoint_proven = false;
};

struct MirFn {
  std::string name;
  bool returns_float = false;
  /** When true, LLVM return type is i8* (ptr / int64 ABI). */
  bool returns_i64 = false;
  bool returns_void = false;
  /** When true, LLVM return type is a struct; `return_object_layout` lists leaf fields. */
  bool returns_object = false;
  /** When true, LLVM return type is `array[M, array[K, float]]` by value. */
  bool returns_matrix = false;
  std::int64_t return_matrix_rows = 0;
  std::int64_t return_matrix_cols = 0;
  bool is_extern = false;
  bool is_async = false;
  /** When true, `ArrayDotF64` / `ArrayBinOpF64` use scalar loops only. */
  bool no_vectorize = false;
  std::vector<MirDecorator> decorators;
  std::vector<MirParam> params;
  /** Populated when `returns_object`; parallel to ReturnObject / unpack layout. */
  std::vector<MirParam> return_object_layout;
  /** Captured array slots for outlined `__li_par_*` bodies (WP-PAR-18). */
  std::vector<MirParCapture> par_captures;
  std::vector<MirInsn> body;
};

/** WP-PAR-70 — fields embedded as `__li_comm_plan` global at link time. */
struct MirCommPlan {
  std::uint32_t overlap_comm_count = 0;
  std::uint32_t ghost_exchange_count = 0;
  std::uint32_t compressed_halo_enabled = 0;
  std::uint32_t rdma_hooks = 0;
};

/** WP-PAR-87 — fields embedded as `__li_xfer_plan` global at link time. */
struct MirXferPlan {
  std::uint32_t elide_copy_count = 0;
  std::uint32_t fusion_count = 0;
  std::uint32_t d2d_path_count = 0;
  std::uint32_t rdma_gpu_count = 0;
};

/** WP-PAR-07 — fields embedded as `__li_exec_plan` global at link time. */
struct MirExecPlan {
  std::int64_t team_cores = 0;
  std::int64_t cluster_world = 0;
  std::string cluster_hosts;
  std::uint32_t offload_count = 0;
  std::uint32_t overlap_comm_count = 0;
};

struct MirModule {
  std::vector<MirFn> functions;
  bool uses_openmp = false;
  bool uses_async = false;
  /** Link runtime/li_rt_httpd.c when MIR calls httpd routing/config symbols. */
  bool needs_rt_httpd = false;
  /** Link runtime/li_rt_net.c when MIR calls socket/epoll/proxy symbols. */
  bool needs_rt_net = false;
  /** Link runtime/li_rt_log.c when MIR calls li_log_* symbols. */
  bool needs_rt_log = false;
  /** li_rt_llm.c — safetensors/GGUF weight file probes. */
  bool needs_rt_llm = false;
  /** runtime/li_par_pool.c — parallel for + thread pool. */
  bool needs_rt_par_pool = false;
  /** runtime/li_par_reduce.c — tree reductions. */
  bool needs_rt_par_reduce = false;
  /** runtime/li_dpar*.c — distributed TCP mesh. */
  bool needs_rt_dpar = false;
  /** runtime/li_exec_plan.c — embedded execution plan (**WP-PAR-07–09**). */
  bool needs_rt_exec_plan = false;
  /** runtime/li_comm_plan.c — embedded comm plan (**WP-PAR-70–71**). */
  bool needs_rt_comm_plan = false;
  /** runtime/li_xfer_plan.c — embedded transfer plan (**WP-PAR-87–92**). */
  bool needs_rt_xfer_plan = false;
  /** runtime/li_fl.c — federated-learning rank masks and fedavg (**WP-PAR-60–65**). */
  bool needs_rt_fl = false;
  /** runtime/li_rt_hetero.c — CPU/GPU/TPU/ASIC orchestration probes (**WP-PAR-80**). */
  bool needs_rt_hetero = false;
  MirExecPlan exec_plan;
  MirCommPlan comm_plan;
  MirXferPlan xfer_plan;
  /** When true: MIR stability pass + strict FP codegen (no fast-math reassociation). */
  bool fp_numerically_stable = false;
};

/** Count `def` decorators with {@link MirDecorator::vectorized}. */
std::size_t count_mir_vectorized_proc(const MirModule& mir);
/** Count `def` decorators with {@link MirDecorator::cpu}. */
std::size_t count_mir_cpu_def(const MirModule& mir);
std::size_t count_mir_gpu_def(const MirModule& mir);
std::size_t count_mir_gpu_multi_device_def(const MirModule& mir);
std::size_t count_mir_parallel_disjoint_proven(const MirModule& mir);

MirModule lower_to_mir(const Module& module);

}  // namespace li
