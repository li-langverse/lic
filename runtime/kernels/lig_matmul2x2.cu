extern "C" __global__ void lig_matmul2x2_f32(const float* A, const float* B, float* C) {
  if (threadIdx.x != 0u || blockIdx.x != 0u) {
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
