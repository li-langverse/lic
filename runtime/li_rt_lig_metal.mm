#include "li_rt_lig_metal.h"

#if defined(__APPLE__)

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <mach/mach_time.h>
#include <stdint.h>
#include <string.h>

static int64_t g_metal_timing_ns = -1;

static const char* k_lig_matmul2_msl =
    "#include <metal_stdlib>\n"
    "using namespace metal;\n"
    "kernel void lig_matmul2x2_f32(\n"
    "    device const float* A [[buffer(0)]],\n"
    "    device const float* B [[buffer(1)]],\n"
    "    device float* C [[buffer(2)]],\n"
    "    uint gid [[thread_position_in_grid]]) {\n"
    "  if (gid != 0u) return;\n"
    "  for (int row = 0; row < 2; ++row) {\n"
    "    for (int col = 0; col < 2; ++col) {\n"
    "      float sum = 0.0f;\n"
    "      for (int k = 0; k < 2; ++k) {\n"
    "        sum += A[row * 2 + k] * B[k * 2 + col];\n"
    "      }\n"
    "      C[row * 2 + col] = sum;\n"
    "    }\n"
    "  }\n"
    "}\n";

int32_t li_rt_lig_metal_matmul2x2_device(void) {
  g_metal_timing_ns = -1;
  @autoreleasepool {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (device == nil) {
      return 0;
    }

    NSError* err = nil;
    id<MTLLibrary> library = [device newLibraryWithSource:[NSString stringWithUTF8String:k_lig_matmul2_msl]
                                                  options:nil
                                                    error:&err];
    if (library == nil) {
      return 0;
    }

    id<MTLFunction> function = [library newFunctionWithName:@"lig_matmul2x2_f32"];
    if (function == nil) {
      return 0;
    }

    id<MTLComputePipelineState> pipeline =
        [device newComputePipelineStateWithFunction:function error:&err];
    if (pipeline == nil) {
      return 0;
    }

    const float a[4] = {1.0f, 2.0f, 3.0f, 4.0f};
    const float b[4] = {5.0f, 6.0f, 7.0f, 8.0f};
    const float expect[4] = {19.0f, 22.0f, 43.0f, 50.0f};
    float c[4] = {0.0f, 0.0f, 0.0f, 0.0f};

    id<MTLBuffer> buf_a =
        [device newBufferWithBytes:a length:sizeof(a) options:MTLResourceStorageModeShared];
    id<MTLBuffer> buf_b =
        [device newBufferWithBytes:b length:sizeof(b) options:MTLResourceStorageModeShared];
    id<MTLBuffer> buf_c =
        [device newBufferWithLength:sizeof(c) options:MTLResourceStorageModeShared];
    if (buf_a == nil || buf_b == nil || buf_c == nil) {
      return 0;
    }

    id<MTLCommandQueue> queue = [device newCommandQueue];
    id<MTLCommandBuffer> cmd = [queue commandBuffer];
    id<MTLComputeCommandEncoder> enc = [cmd computeCommandEncoder];
    if (queue == nil || cmd == nil || enc == nil) {
      return 0;
    }

    [enc setComputePipelineState:pipeline];
    [enc setBuffer:buf_a offset:0 atIndex:0];
    [enc setBuffer:buf_b offset:0 atIndex:1];
    [enc setBuffer:buf_c offset:0 atIndex:2];

    const uint64_t t0 = mach_absolute_time();
    [enc dispatchThreadgroups:MTLSizeMake(1, 1, 1) threadsPerThreadgroup:MTLSizeMake(1, 1, 1)];
    [enc endEncoding];
    [cmd commit];
    [cmd waitUntilCompleted];
    const uint64_t t1 = mach_absolute_time();

    static mach_timebase_info_data_t timebase;
    if (timebase.denom == 0) {
      mach_timebase_info(&timebase);
    }
    g_metal_timing_ns =
        (int64_t)((t1 - t0) * (uint64_t)timebase.numer / (uint64_t)timebase.denom);

    memcpy(c, [buf_c contents], sizeof(c));

    float err = 0.0f;
    for (int i = 0; i < 4; ++i) {
      const float d = c[i] - expect[i];
      err += (d < 0.0f) ? -d : d;
    }
    return (err < 1e-4f) ? 1 : 0;
  }
}

int64_t li_rt_lig_metal_last_timing_ns(void) { return g_metal_timing_ns; }

#endif
