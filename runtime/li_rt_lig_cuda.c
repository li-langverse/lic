#include "li_rt_lig_cuda.h"

#include "lig_cuda_ptx_catalog.h"

#include <dlfcn.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

static int64_t g_cuda_timing_ns = -1;

typedef int CUresult;
typedef int CUdevice;
typedef void* CUcontext;
typedef void* CUmodule;
typedef void* CUfunction;
typedef unsigned long long CUdeviceptr;

typedef CUresult (*cuInit_t)(unsigned int);
typedef CUresult (*cuDeviceGet_t)(CUdevice*, int);
typedef CUresult (*cuCtxCreate_v2_t)(CUcontext*, unsigned int, CUdevice);
typedef CUresult (*cuModuleLoadData_t)(CUmodule*, const char*);
typedef CUresult (*cuModuleGetFunction_t)(CUfunction*, CUmodule, const char*);
typedef CUresult (*cuMemAlloc_v2_t)(CUdeviceptr*, size_t);
typedef CUresult (*cuMemFree_v2_t)(CUdeviceptr);
typedef CUresult (*cuMemcpyHtoD_v2_t)(CUdeviceptr, const void*, size_t);
typedef CUresult (*cuMemcpyDtoH_v2_t)(void*, CUdeviceptr, size_t);
typedef CUresult (*cuLaunchKernel_t)(CUfunction, unsigned int, unsigned int, unsigned int, unsigned int,
                                     unsigned int, unsigned int, unsigned int, void*, void**, void**);
typedef CUresult (*cuCtxSynchronize_t)(void);
typedef CUresult (*cuModuleUnload_t)(CUmodule);
typedef CUresult (*cuCtxDestroy_v2_t)(CUcontext);

#define CU_SUCCESS 0

static void* g_cuda_drv;

static int cuda_drv_load(void) {
  if (g_cuda_drv != NULL) {
    return 1;
  }
  const char* names[] = {"libcuda.so.1", "libcuda.so", NULL};
  for (size_t i = 0; names[i] != NULL; ++i) {
    g_cuda_drv = dlopen(names[i], RTLD_LAZY | RTLD_LOCAL);
    if (g_cuda_drv != NULL) {
      return 1;
    }
  }
  return 0;
}

static void* cuda_sym(const char* name) {
  if (g_cuda_drv == NULL) {
    return NULL;
  }
  return dlsym(g_cuda_drv, name);
}

int32_t li_rt_lig_cuda_matmul2x2_device(void) {
  g_cuda_timing_ns = -1;
  if (!cuda_drv_load()) {
    return 0;
  }

  cuInit_t cuInit = (cuInit_t)cuda_sym("cuInit");
  cuDeviceGet_t cuDeviceGet = (cuDeviceGet_t)cuda_sym("cuDeviceGet");
  cuCtxCreate_v2_t cuCtxCreate = (cuCtxCreate_v2_t)cuda_sym("cuCtxCreate_v2");
  cuModuleLoadData_t cuModuleLoadData = (cuModuleLoadData_t)cuda_sym("cuModuleLoadData");
  cuModuleGetFunction_t cuModuleGetFunction = (cuModuleGetFunction_t)cuda_sym("cuModuleGetFunction");
  cuMemAlloc_v2_t cuMemAlloc = (cuMemAlloc_v2_t)cuda_sym("cuMemAlloc_v2");
  cuMemFree_v2_t cuMemFree = (cuMemFree_v2_t)cuda_sym("cuMemFree_v2");
  cuMemcpyHtoD_v2_t cuMemcpyHtoD = (cuMemcpyHtoD_v2_t)cuda_sym("cuMemcpyHtoD_v2");
  cuMemcpyDtoH_v2_t cuMemcpyDtoH = (cuMemcpyDtoH_v2_t)cuda_sym("cuMemcpyDtoH_v2");
  cuLaunchKernel_t cuLaunchKernel = (cuLaunchKernel_t)cuda_sym("cuLaunchKernel");
  cuCtxSynchronize_t cuCtxSynchronize = (cuCtxSynchronize_t)cuda_sym("cuCtxSynchronize");
  cuModuleUnload_t cuModuleUnload = (cuModuleUnload_t)cuda_sym("cuModuleUnload");
  cuCtxDestroy_v2_t cuCtxDestroy = (cuCtxDestroy_v2_t)cuda_sym("cuCtxDestroy_v2");

  if (cuInit == NULL || cuDeviceGet == NULL || cuCtxCreate == NULL || cuModuleLoadData == NULL ||
      cuModuleGetFunction == NULL || cuMemAlloc == NULL || cuMemFree == NULL || cuMemcpyHtoD == NULL ||
      cuMemcpyDtoH == NULL || cuLaunchKernel == NULL || cuCtxSynchronize == NULL || cuCtxDestroy == NULL) {
    return 0;
  }

  if (cuInit(0) != CU_SUCCESS) {
    return 0;
  }

  CUdevice dev = 0;
  if (cuDeviceGet(&dev, 0) != CU_SUCCESS) {
    return 0;
  }

  CUcontext ctx = NULL;
  if (cuCtxCreate(&ctx, 0, dev) != CU_SUCCESS) {
    return 0;
  }

  CUmodule module = NULL;
  const LiLigCudaPtxEntry* entry = li_rt_lig_cuda_ptx_lookup("lig_matmul2x2_f32");
  if (entry == NULL || entry->ptx == NULL || entry->ptx_len == 0) {
    cuCtxDestroy(ctx);
    return 0;
  }

  if (cuModuleLoadData(&module, entry->ptx) != CU_SUCCESS) {
    cuCtxDestroy(ctx);
    return 0;
  }

  CUfunction fn = NULL;
  if (cuModuleGetFunction(&fn, module, entry->symbol) != CU_SUCCESS) {
    if (cuModuleUnload != NULL) {
      cuModuleUnload(module);
    }
    cuCtxDestroy(ctx);
    return 0;
  }

  const float a[4] = {1.0f, 2.0f, 3.0f, 4.0f};
  const float b[4] = {5.0f, 6.0f, 7.0f, 8.0f};
  const float expect[4] = {19.0f, 22.0f, 43.0f, 50.0f};
  float c[4] = {0.0f, 0.0f, 0.0f, 0.0f};

  CUdeviceptr d_a = 0;
  CUdeviceptr d_b = 0;
  CUdeviceptr d_c = 0;
  if (cuMemAlloc(&d_a, sizeof(a)) != CU_SUCCESS || cuMemAlloc(&d_b, sizeof(b)) != CU_SUCCESS ||
      cuMemAlloc(&d_c, sizeof(c)) != CU_SUCCESS) {
    if (d_a) {
      cuMemFree(d_a);
    }
    if (d_b) {
      cuMemFree(d_b);
    }
    if (d_c) {
      cuMemFree(d_c);
    }
    if (cuModuleUnload != NULL) {
      cuModuleUnload(module);
    }
    cuCtxDestroy(ctx);
    return 0;
  }

  if (cuMemcpyHtoD(d_a, a, sizeof(a)) != CU_SUCCESS || cuMemcpyHtoD(d_b, b, sizeof(b)) != CU_SUCCESS) {
    cuMemFree(d_a);
    cuMemFree(d_b);
    cuMemFree(d_c);
    if (cuModuleUnload != NULL) {
      cuModuleUnload(module);
    }
    cuCtxDestroy(ctx);
    return 0;
  }

  void* args[] = {&d_a, &d_b, &d_c};
  struct timespec t0;
  struct timespec t1;
  const CUresult launch_rc = cuLaunchKernel(fn, 1, 1, 1, 1, 1, 1, 0, NULL, args, NULL);
  if (launch_rc != CU_SUCCESS) {
    cuMemFree(d_a);
    cuMemFree(d_b);
    cuMemFree(d_c);
    if (cuModuleUnload != NULL) {
      cuModuleUnload(module);
    }
    cuCtxDestroy(ctx);
    return 0;
  }

#if defined(__linux__)
  clock_gettime(CLOCK_MONOTONIC, &t0);
#endif
  if (cuCtxSynchronize() != CU_SUCCESS) {
    cuMemFree(d_a);
    cuMemFree(d_b);
    cuMemFree(d_c);
    if (cuModuleUnload != NULL) {
      cuModuleUnload(module);
    }
    cuCtxDestroy(ctx);
    return 0;
  }
#if defined(__linux__)
  clock_gettime(CLOCK_MONOTONIC, &t1);
  g_cuda_timing_ns =
      (int64_t)(t1.tv_sec - t0.tv_sec) * 1000000000LL + (int64_t)(t1.tv_nsec - t0.tv_nsec);
#endif

  if (cuMemcpyDtoH(c, d_c, sizeof(c)) != CU_SUCCESS) {
    cuMemFree(d_a);
    cuMemFree(d_b);
    cuMemFree(d_c);
    if (cuModuleUnload != NULL) {
      cuModuleUnload(module);
    }
    cuCtxDestroy(ctx);
    return 0;
  }

  cuMemFree(d_a);
  cuMemFree(d_b);
  cuMemFree(d_c);
  if (cuModuleUnload != NULL) {
    cuModuleUnload(module);
  }
  cuCtxDestroy(ctx);

  float err = 0.0f;
  for (int i = 0; i < 4; ++i) {
    const float d = c[i] - expect[i];
    err += (d < 0.0f) ? -d : d;
  }
  if (err >= 1e-4f) {
    g_cuda_timing_ns = -1;
    return 0;
  }
#if defined(__linux__)
  if (g_cuda_timing_ns <= 0) {
    return 0;
  }
#endif
  return 1;
}

int64_t li_rt_lig_cuda_last_timing_ns(void) { return g_cuda_timing_ns; }
