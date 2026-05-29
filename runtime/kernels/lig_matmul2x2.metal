#include <metal_stdlib>
using namespace metal;

kernel void lig_matmul2x2_f32(device const float* A [[buffer(0)]],
                              device const float* B [[buffer(1)]],
                              device float* C [[buffer(2)]],
                              uint gid [[thread_position_in_grid]]) {
  if (gid != 0u) {
    return;
  }
  for (int row = 0; row < 2; ++row) {
    for (int col = 0; col < 2; ++col) {
      float sum = 0.0f;
      for (int k = 0; k < 2; ++k) {
        sum += A[row * 2 + k] * B[k * 2 + col];
      }
      C[row * 2 + col] = sum;
    }
  }
}
