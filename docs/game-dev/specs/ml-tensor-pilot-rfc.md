# RFC: li-ml tensor pilot (Stage 2b)

Pilot `MlTensorDesc` + `ml_tensor_matmul_64` / `ml_tensor_matmul_nested` bridging to `ml_matmul_tiled_dynamic` (single-tile, nested 8×8 micro-kernel). Full dynamic K/M/N tile loops deferred until lic allows non-constant flat indices.
